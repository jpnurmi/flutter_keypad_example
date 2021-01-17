import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'delegate.dart';
import 'connection.dart';
import 'layout.dart';

class VirtualKeypad extends StatefulWidget {
  @override
  _VirtualKeypadState createState() => _VirtualKeypadState();
}

class _VirtualKeypadState extends State<VirtualKeypad>
    implements TextInputSource {
  TextInputDelegate? _delegate;
  TextInputLayout _layout = TextInputLayout();

  @override
  void initState() {
    super.initState();
    TextInput.setSource(this);
  }

  @override
  void dispose() {
    TextInput.setSource(TextInput.defaultSource);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      canRequestFocus: false,
      child: Container(
        color: Theme.of(context).backgroundColor,
        height: MediaQuery.of(context).size.height / 3,
        child: Column(
          children: [
            for (final keys in _layout.keys)
              Expanded(
                child: VirtualKeypadRow(
                  keys: keys,
                  enabled: _delegate != null,
                  onPressed: (String key) => _delegate!.addText(key),
                  onLongPress: (String key) => _delegate!.addNumber(key),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void init() {}

  @override
  void cleanup() {}

  @override
  TextInputConnection attach(TextInputClient client) {
    setState(() => _delegate = TextInputDelegate(client));

    return CallbackConnection(
      client,
      onInputTypeChanged: (TextInputType inputType) {
        _delegate!.setInputType(inputType);
      },
      onEditingValueSet: (TextEditingValue value) {
        _delegate!.reset(value);
      },
    );
  }

  @override
  void detach(TextInputClient client) {
    setState(() => _delegate = null);
  }

  @override
  void finishAutofillContext({bool shouldSave = true}) {}
}

class VirtualKeypadRow extends StatelessWidget {
  final bool _enabled;
  final List<String> _keys;
  final ValueSetter<String> _onPressed;
  final ValueSetter<String> _onLongPress;

  VirtualKeypadRow({
    required bool enabled,
    required List<String> keys,
    required ValueSetter<String> onPressed,
    required ValueSetter<String> onLongPress,
  })   : _enabled = enabled,
        _keys = keys,
        _onPressed = onPressed,
        _onLongPress = onLongPress;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final key in _keys)
          Expanded(
            child: RawMaterialButton(
              onPressed: _enabled ? () => _onPressed(key) : null,
              onLongPress: _enabled ? () => _onLongPress(key) : null,
              child: Center(child: Text(key, textAlign: TextAlign.center)),
            ),
          ),
      ],
    );
  }
}
