import 'dart:async';

import 'package:flutter/services.dart';

class TextInputDelegate {
  String _text = '';
  TextSelection _selection = TextSelection.collapsed(offset: 0);
  final TextInputControl _control;
  TextInputType _inputType = TextInputType.text;

  bool _isComposing = false;
  int _composingIndex = 0;
  String _composingText = '';
  Timer? _composingTimer;

  TextInputDelegate(this._control);

  TextEditingValue get value {
    return TextEditingValue(
      text: _text,
      selection: _selection,
      composing: _isComposing
          ? TextRange(start: _selection.start - 1, end: _selection.start)
          : TextRange.empty,
    );
  }

  void reset(TextEditingValue value) {
    _text = value.text;
    _selection = value.selection;
  }

  void setInputType(TextInputType inputType) {
    _inputType = inputType;
  }

  bool _overrideNumeric = false;
  bool get _isNumeric => _overrideNumeric || _inputType == TextInputType.number;

  bool _canCompose(String text) {
    return text.length > 1 &&
        !_isNumeric &&
        _isComposing &&
        _text.isNotEmpty &&
        _selection.start > 0 &&
        _selection.isCollapsed;
  }

  void _startComposing(String text) {
    _isComposing = true;
    _composingText = text;
    _composingIndex = (_composingIndex + 1) % text.length;

    _composingTimer?.cancel();
    _composingTimer = Timer(Duration(seconds: 1), _stopComposing);
  }

  void _stopComposing() {
    _control.updateEditingValue(value.copyWith(composing: TextRange.empty));
    _composingIndex = 0;
    _isComposing = false;
  }

  String _keyText(String text) {
    final rows = text.split('\n');
    return _isNumeric || rows.last.isEmpty ? rows.first : rows.last;
  }

  void addNumber(String text) {
    _overrideNumeric = true;
    addText(text);
    _overrideNumeric = false;
  }

  void addText(String text) {
    final keyText = _keyText(text);
    if (keyText != _composingText) {
      _isComposing = false;
      _composingIndex = 0;
    }

    final char = keyText[_composingIndex];
    if (_canCompose(keyText)) {
      replaceText(_selection.start - 1, _selection.start, char);
    } else {
      removeText(_selection.start, _selection.end);
      insertText(_selection.start, char);
    }

    if (!_isNumeric && keyText.length > 1) {
      _startComposing(keyText);
    }

    _control.updateEditingValue(value);
  }

  void insertText(int start, String text) {
    _text = _text.replaceRange(start, start, text);
    _selection = TextSelection.collapsed(offset: start + text.length);
  }

  void removeText(int start, int end) {
    _text = _text.replaceRange(start, end, '');
    _selection = TextSelection.collapsed(offset: start);
  }

  void replaceText(int start, int end, String text) {
    _text = _text.replaceRange(start, end, text);
    _selection = TextSelection.collapsed(offset: start + text.length);
  }
}
