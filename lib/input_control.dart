import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'delegate.dart';
import 'layout.dart';

class VirtualKeyboardControl extends TextInputControl {
  TextInputDelegate? _delegate;
  final _attached = ValueNotifier<bool>(false);
  final _layout = ValueNotifier<TextInputLayout>(TextInputLayout());

  ValueNotifier<bool> get attached => _attached;
  ValueNotifier<TextInputLayout> get layout => _layout;

  void register() {
    TextInput.setInputControl(this);
  }

  void unregister() {
    TextInput.restorePlatformInputControl();
  }

  void addText(String text) {
    _delegate!.addText(text);
  }

  void addNumber(String number) {
    _delegate!.addNumber(number);
  }

  @override
  void attach(TextInputClient client, TextInputConfiguration configuration) {
    _delegate = TextInputDelegate(this);
    _attached.value = true;
    updateConfig(configuration);
  }

  @override
  void detach(TextInputClient client) {
    _delegate = null;
    _attached.value = false;
  }

  @override
  void setEditingState(TextEditingValue value) {
    _delegate!.reset(value);
  }

  @override
  void updateConfig(TextInputConfiguration configuration) {
    _delegate!.setInputType(configuration.inputType);
  }
}
