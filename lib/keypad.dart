import 'package:flutter/material.dart';

import 'input_control.dart';
import 'layout.dart';

class VirtualKeypad extends StatefulWidget {
  @override
  _VirtualKeypadState createState() => _VirtualKeypadState();
}

class _VirtualKeypadState extends State<VirtualKeypad> {
  final _inputControl = VirtualKeyboardControl();

  @override
  void initState() {
    super.initState();
    _inputControl.register();
  }

  @override
  void dispose() {
    _inputControl.unregister();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      canRequestFocus: false,
      child: TextFieldTapRegion(
        child: Container(
          color: Theme.of(context).colorScheme.background,
          height: MediaQuery.of(context).size.height / 3,
          child: ValueListenableBuilder<TextInputLayout>(
              valueListenable: _inputControl.layout,
              builder: (_, layout, __) {
                return Column(
                  children: [
                    for (final keys in layout.keys)
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                            valueListenable: _inputControl.attached,
                            builder: (_, attached, __) {
                              return VirtualKeypadRow(
                                keys: keys,
                                enabled: attached,
                                onPressed: (String key) =>
                                    _inputControl.addText(key),
                                onLongPress: (String key) =>
                                    _inputControl.addNumber(key),
                              );
                            }),
                      ),
                  ],
                );
              }),
        ),
      ),
    );
  }
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
  })  : _enabled = enabled,
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
