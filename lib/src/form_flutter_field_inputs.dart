part of 'form_flutter_field.dart';

abstract class _ControllerSyncedTextInputState<T extends StatefulWidget>
    extends State<T> {
  TextEditingController get controller;

  void syncText(String nextText) {
    if (controller.text == nextText) {
      return;
    }
    controller.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }
}

class _FormFlutterTextInput extends StatefulWidget {
  const _FormFlutterTextInput({required this.field, required this.controller});

  final FormFlutterTextField field;
  final FormFlutterController controller;

  @override
  State<_FormFlutterTextInput> createState() => _FormFlutterTextInputState();
}

class _FormFlutterTextInputState
    extends _ControllerSyncedTextInputState<_FormFlutterTextInput> {
  late final TextEditingController _textController;

  @override
  TextEditingController get controller => _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.field.normalizeValue(
        widget.controller.snapshot.asMap()[widget.field.name],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: widget.controller.valuesListenable,
      builder: (context, values, _) {
        final currentValue = widget.field.normalizeValue(
          values[widget.field.name],
        );
        syncText(currentValue);

        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: widget.controller.errorsListenable,
          builder: (context, _, _) {
            return TextFormField(
              controller: _textController,
              keyboardType: widget.field.keyboardType,
              textInputAction: widget.field.textInputAction,
              maxLines: widget.field.obscureText ? 1 : widget.field.maxLines,
              obscureText: widget.field.obscureText,
              style: widget.field.textStyle,
              enableInteractiveSelection: widget.field.allowPaste,
              contextMenuBuilder: widget.field.allowPaste
                  ? null
                  : (context, editableTextState) => const SizedBox.shrink(),
              onChanged: (value) {
                widget.controller.setValue(widget.field.name, value);
                widget.controller.setError(widget.field.name, null);
              },
              decoration: widget.field.decoration(widget.controller),
            );
          },
        );
      },
    );
  }
}

class _FormFlutterPasswordInput extends StatefulWidget {
  const _FormFlutterPasswordInput({
    required this.field,
    required this.controller,
  });

  final FormFlutterTextField field;
  final FormFlutterController controller;

  @override
  State<_FormFlutterPasswordInput> createState() =>
      _FormFlutterPasswordInputState();
}

class _FormFlutterPasswordInputState
    extends _ControllerSyncedTextInputState<_FormFlutterPasswordInput> {
  late final TextEditingController _textController;
  late bool _obscure;

  @override
  TextEditingController get controller => _textController;

  @override
  void initState() {
    super.initState();
    _obscure = widget.field.obscureText;
    _textController = TextEditingController(
      text: widget.field.normalizeValue(
        widget.controller.snapshot.asMap()[widget.field.name],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: widget.controller.valuesListenable,
      builder: (context, values, _) {
        final currentValue = widget.field.normalizeValue(
          values[widget.field.name],
        );
        syncText(currentValue);

        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: widget.controller.errorsListenable,
          builder: (context, _, _) {
            final decoration = widget.field.decoration(widget.controller);
            return TextFormField(
              controller: _textController,
              keyboardType: widget.field.keyboardType,
              textInputAction: widget.field.textInputAction,
              maxLines: 1,
              obscureText: _obscure,
              style: widget.field.textStyle,
              enableInteractiveSelection: widget.field.allowPaste,
              contextMenuBuilder: widget.field.allowPaste
                  ? null
                  : (context, editableTextState) => const SizedBox.shrink(),
              onChanged: (value) {
                widget.controller.setValue(widget.field.name, value);
                widget.controller.setError(widget.field.name, null);
              },
              decoration: decoration.copyWith(
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscure = !_obscure;
                    });
                  },
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FormFlutterNumberInput extends StatefulWidget {
  const _FormFlutterNumberInput({
    required this.field,
    required this.controller,
  });

  final FormFlutterNumberField field;
  final FormFlutterController controller;

  @override
  State<_FormFlutterNumberInput> createState() =>
      _FormFlutterNumberInputState();
}

class _FormFlutterNumberInputState
    extends _ControllerSyncedTextInputState<_FormFlutterNumberInput> {
  late final TextEditingController _textController;

  @override
  TextEditingController get controller => _textController;

  @override
  void initState() {
    super.initState();
    final existingValue =
        widget.controller.snapshot.asMap()[widget.field.name]?.toString() ?? '';
    _textController = TextEditingController(text: existingValue);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: widget.controller.valuesListenable,
      builder: (context, values, _) {
        final nextText = values[widget.field.name]?.toString() ?? '';
        syncText(nextText);

        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: widget.controller.errorsListenable,
          builder: (context, _, _) {
            return TextFormField(
              controller: _textController,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.field.allowDecimals,
                signed: false,
              ),
              style: widget.field.textStyle,
              onChanged: (value) {
                widget.controller.setValue(widget.field.name, value);
                widget.controller.setError(widget.field.name, null);
              },
              decoration: widget.field.decoration(widget.controller),
            );
          },
        );
      },
    );
  }
}
