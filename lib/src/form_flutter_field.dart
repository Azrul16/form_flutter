import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'form_flutter_controller.dart';
import 'form_flutter_phone_countries.dart';

part 'form_flutter_field_inputs.dart';

/// Synchronous validator signature used by form fields.
typedef FormFlutterValidator<T> =
    String? Function(T value, FormFlutterValues values);

/// Asynchronous validator signature used by form fields.
typedef FormFlutterAsyncValidator<T> =
    Future<String?> Function(T value, FormFlutterValues values);

/// Builds a custom widget for an option in dropdown, radio, or multiselect fields.
typedef FormFlutterOptionBuilder<T> =
    Widget Function(
      BuildContext context,
      FormFlutterOption<T> option,
      bool isSelected,
    );

/// Describes a selectable option for choice-based fields.
class FormFlutterOption<T> {
  const FormFlutterOption({
    required this.value,
    required this.label,
    this.color,
    this.backgroundColor,
    this.selectedColor,
    this.textColor,
    this.selectedTextColor,
    this.borderColor,
    this.indicatorSize,
    this.icon,
  });

  final T value;
  final String label;
  final Color? color;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? textColor;
  final Color? selectedTextColor;
  final Color? borderColor;
  final double? indicatorSize;
  final IconData? icon;
}

/// Lightweight file metadata container used by file and image fields.
class FormFlutterFileValue {
  const FormFlutterFileValue({
    required this.name,
    required this.sizeInBytes,
    this.extension,
    this.mimeType,
    this.bytes,
  });

  final String name;
  final int sizeInBytes;
  final String? extension;
  final String? mimeType;
  final Uint8List? bytes;
}

/// Base abstraction for all field definitions rendered by the package.
abstract class FormFlutterField<T> {
  const FormFlutterField({
    required this.name,
    required this.label,
    this.helperText,
    this.validator,
    this.asyncValidator,
  });

  final String name;
  final String label;
  final String? helperText;
  final FormFlutterValidator<T>? validator;
  final FormFlutterAsyncValidator<T>? asyncValidator;

  /// Whether this field has an asynchronous validator.
  bool get hasAsyncValidator => asyncValidator != null;

  T normalizeValue(Object? rawValue);

  Widget buildField(FormFlutterController controller);

  String? validate(FormFlutterController controller) {
    final values = controller.snapshot;
    return validator?.call(normalizeValue(values.asMap()[name]), values);
  }

  Future<String?> validateAsync(FormFlutterController controller) async {
    final values = controller.snapshot;
    final validator = asyncValidator;
    if (validator == null) {
      return null;
    }
    return validator(normalizeValue(values.asMap()[name]), values);
  }
}

abstract class _FormFlutterInputField<T> extends FormFlutterField<T> {
  const _FormFlutterInputField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.hintText,
    this.decorationOverride,
    this.textStyle,
  });

  final String? hintText;
  final InputDecoration? decorationOverride;
  final TextStyle? textStyle;

  InputDecoration decoration(FormFlutterController controller) {
    final baseDecoration = InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      errorText: controller.error(name),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
    return baseDecoration
        .copyWith(
          labelText: decorationOverride?.labelText ?? label,
          hintText: decorationOverride?.hintText ?? hintText,
          helperText: decorationOverride?.helperText ?? helperText,
          errorText: decorationOverride?.errorText ?? controller.error(name),
        )
        .copyWith(
          icon: decorationOverride?.icon,
          iconColor: decorationOverride?.iconColor,
          prefixIcon: decorationOverride?.prefixIcon,
          prefixIconColor: decorationOverride?.prefixIconColor,
          suffixIcon: decorationOverride?.suffixIcon,
          suffixIconColor: decorationOverride?.suffixIconColor,
          filled: decorationOverride?.filled,
          fillColor: decorationOverride?.fillColor,
          contentPadding: decorationOverride?.contentPadding,
          border: decorationOverride?.border ?? baseDecoration.border,
          enabledBorder: decorationOverride?.enabledBorder,
          focusedBorder: decorationOverride?.focusedBorder,
          errorBorder: decorationOverride?.errorBorder,
          focusedErrorBorder: decorationOverride?.focusedErrorBorder,
          disabledBorder: decorationOverride?.disabledBorder,
          labelStyle: decorationOverride?.labelStyle,
          floatingLabelStyle: decorationOverride?.floatingLabelStyle,
          helperStyle: decorationOverride?.helperStyle,
          hintStyle: decorationOverride?.hintStyle,
          errorStyle: decorationOverride?.errorStyle,
        );
  }
}

/// Single-line or multiline text input field.
class FormFlutterTextField extends _FormFlutterInputField<String> {
  const FormFlutterTextField({
    required super.name,
    required super.label,
    super.hintText,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.obscureText = false,
    this.enableObscureTextToggle = false,
    this.allowPaste = true,
    super.helperText,
    super.validator,
    super.asyncValidator,
    super.decorationOverride,
    super.textStyle,
  });

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool obscureText;
  final bool enableObscureTextToggle;
  final bool allowPaste;

  @override
  String normalizeValue(Object? rawValue) {
    return (rawValue ?? '').toString();
  }

  @override
  Widget buildField(FormFlutterController controller) {
    if (enableObscureTextToggle && obscureText) {
      final passwordField = _FormFlutterPasswordInput(
        field: this,
        controller: controller,
      );
      return allowPaste
          ? passwordField
          : _FormFlutterPasteGuard(child: passwordField);
    }

    final textField = _FormFlutterTextInput(
      field: this,
      controller: controller,
    );
    return allowPaste ? textField : _FormFlutterPasteGuard(child: textField);
  }
}

/// OTP or verification-code input rendered as fixed slots.
class FormFlutterOtpField extends _FormFlutterInputField<String> {
  const FormFlutterOtpField({
    required super.name,
    required super.label,
    this.length = 6,
    this.allowPaste = true,
    this.obscureText = false,
    this.boxWidth = 44,
    this.boxSpacing = 10,
    super.hintText,
    super.helperText,
    super.validator,
    super.asyncValidator,
    super.decorationOverride,
    super.textStyle,
  });

  final int length;
  final bool allowPaste;
  final bool obscureText;
  final double boxWidth;
  final double boxSpacing;

  @override
  String normalizeValue(Object? rawValue) {
    return (rawValue ?? '').toString();
  }

  @override
  Widget buildField(FormFlutterController controller) {
    final field = _FormFlutterOtpInput(field: this, controller: controller);
    return allowPaste ? field : _FormFlutterPasteGuard(child: field);
  }
}

/// Search text field with a search action and clear affordance.
class FormFlutterSearchField extends _FormFlutterInputField<String> {
  const FormFlutterSearchField({
    required super.name,
    required super.label,
    this.onSubmitted,
    super.hintText,
    super.helperText,
    super.validator,
    super.asyncValidator,
    super.decorationOverride,
    super.textStyle,
  });

  final ValueChanged<String>? onSubmitted;

  @override
  String normalizeValue(Object? rawValue) {
    return (rawValue ?? '').toString();
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return _FormFlutterSearchInput(field: this, controller: controller);
  }
}

class _FormFlutterPasteGuard extends StatelessWidget {
  const _FormFlutterPasteGuard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const <ShortcutActivator, Intent>{
        SingleActivator(LogicalKeyboardKey.keyV, control: true):
            DoNothingIntent(),
        SingleActivator(LogicalKeyboardKey.keyV, meta: true): DoNothingIntent(),
        SingleActivator(LogicalKeyboardKey.insert, shift: true):
            DoNothingIntent(),
      },
      child: child,
    );
  }
}

class _FormFlutterOtpInput extends StatefulWidget {
  const _FormFlutterOtpInput({required this.field, required this.controller});

  final FormFlutterOtpField field;
  final FormFlutterController controller;

  @override
  State<_FormFlutterOtpInput> createState() => _FormFlutterOtpInputState();
}

class _FormFlutterOtpInputState extends State<_FormFlutterOtpInput> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.field.normalizeValue(
        widget.controller.snapshot.asMap()[widget.field.name],
      ),
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
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
        if (_textController.text != currentValue) {
          _textController.value = TextEditingValue(
            text: currentValue,
            selection: TextSelection.collapsed(offset: currentValue.length),
          );
        }

        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: widget.controller.errorsListenable,
          builder: (context, _, _) {
            final slots = List<String>.generate(widget.field.length, (index) {
              if (index >= currentValue.length) {
                return '';
              }
              return widget.field.obscureText ? '*' : currentValue[index];
            });
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _focusNode.requestFocus,
              child: InputDecorator(
                decoration: widget.field.decoration(widget.controller),
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        maxLength: widget.field.length,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(widget.field.length),
                        ],
                        onChanged: (value) {
                          widget.controller.setValue(widget.field.name, value);
                          widget.controller.setError(widget.field.name, null);
                        },
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    IgnorePointer(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final totalSpacing =
                              widget.field.boxSpacing * (slots.length - 1);
                          final maxBoxWidth =
                              (constraints.maxWidth - totalSpacing) /
                              slots.length;
                          final boxWidth = maxBoxWidth.isFinite
                              ? maxBoxWidth.clamp(28.0, widget.field.boxWidth)
                              : widget.field.boxWidth;

                          return Row(
                            children: [
                              for (var i = 0; i < slots.length; i++) ...[
                                Container(
                                  width: boxWidth,
                                  height: 54,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.35),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          i == currentValue.length &&
                                              _focusNode.hasFocus
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : const Color(0xFFD0D5DD),
                                    ),
                                  ),
                                  child: Text(
                                    slots[i],
                                    style:
                                        widget.field.textStyle ??
                                        Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                if (i != slots.length - 1)
                                  SizedBox(width: widget.field.boxSpacing),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FormFlutterSearchInput extends StatefulWidget {
  const _FormFlutterSearchInput({
    required this.field,
    required this.controller,
  });

  final FormFlutterSearchField field;
  final FormFlutterController controller;

  @override
  State<_FormFlutterSearchInput> createState() =>
      _FormFlutterSearchInputState();
}

class _FormFlutterSearchInputState extends State<_FormFlutterSearchInput> {
  late final TextEditingController _textController;

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
        if (_textController.text != currentValue) {
          _textController.value = TextEditingValue(
            text: currentValue,
            selection: TextSelection.collapsed(offset: currentValue.length),
          );
        }

        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: widget.controller.errorsListenable,
          builder: (context, _, _) {
            return TextFormField(
              controller: _textController,
              textInputAction: TextInputAction.search,
              style: widget.field.textStyle,
              onChanged: (value) {
                widget.controller.setValue(widget.field.name, value);
                widget.controller.setError(widget.field.name, null);
              },
              onFieldSubmitted: widget.field.onSubmitted,
              decoration: widget.field
                  .decoration(widget.controller)
                  .copyWith(
                    prefixIcon:
                        widget.field.decorationOverride?.prefixIcon ??
                        const Icon(Icons.search_rounded),
                    suffixIcon: currentValue.isEmpty
                        ? widget.field.decorationOverride?.suffixIcon
                        : IconButton(
                            onPressed: () {
                              _textController.clear();
                              widget.controller.setValue(widget.field.name, '');
                              widget.controller.setError(
                                widget.field.name,
                                null,
                              );
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
            );
          },
        );
      },
    );
  }
}

/// Numeric text input field with optional decimal support.
class FormFlutterNumberField extends _FormFlutterInputField<double?> {
  const FormFlutterNumberField({
    required super.name,
    required super.label,
    super.hintText,
    super.helperText,
    super.validator,
    super.asyncValidator,
    super.decorationOverride,
    super.textStyle,
    this.allowDecimals = true,
  });

  final bool allowDecimals;

  @override
  double? normalizeValue(Object? rawValue) {
    if (rawValue is num) {
      return rawValue.toDouble();
    }
    if (rawValue == null) {
      return null;
    }
    return double.tryParse(rawValue.toString());
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return _FormFlutterNumberInput(field: this, controller: controller);
  }
}

/// Country-aware phone number field with national-number length rules.
class FormFlutterPhoneField extends _FormFlutterInputField<String> {
  const FormFlutterPhoneField({
    required super.name,
    required super.label,
    this.countryFieldName,
    this.initialCountryCode = 'US',
    this.allowedCountryCodes,
    this.showCountryName = false,
    this.showCountryFlagInSelector = false,
    this.showCountryIsoCodeInSelector = true,
    this.showCountryDialCodeInSelector = true,
    this.countryMenuMaxHeight = 420,
    this.nationalNumberHintText,
    super.helperText,
    super.validator,
    super.asyncValidator,
    super.decorationOverride,
    super.textStyle,
  }) : super(hintText: null);

  final String? countryFieldName;
  final String initialCountryCode;
  final List<String>? allowedCountryCodes;
  final bool showCountryName;
  final bool showCountryFlagInSelector;
  final bool showCountryIsoCodeInSelector;
  final bool showCountryDialCodeInSelector;
  final double countryMenuMaxHeight;
  final String? nationalNumberHintText;

  String get resolvedCountryFieldName => countryFieldName ?? '${name}Country';

  @override
  String normalizeValue(Object? rawValue) {
    return (rawValue ?? '').toString();
  }

  @override
  String? validate(FormFlutterController controller) {
    final values = controller.snapshot;
    final phoneNumber = normalizeValue(values.asMap()[name]);
    final selectedCountry = FormFlutterPhoneCountries.byIsoCode(
      values.asMap()[resolvedCountryFieldName]?.toString() ??
          initialCountryCode,
    );

    if (phoneNumber.isNotEmpty) {
      if (phoneNumber.length < selectedCountry.minNationalNumberLength ||
          phoneNumber.length > selectedCountry.maxNationalNumberLength) {
        return 'Use ${selectedCountry.minNationalNumberLength}-${selectedCountry.maxNationalNumberLength} digits for ${selectedCountry.name}.';
      }
    }

    return super.validate(controller);
  }

  @override
  Widget buildField(FormFlutterController controller) {
    final allowedCountries = FormFlutterPhoneCountries.resolveAllowed(
      allowedCountryCodes,
    );
    return _FormFlutterPhoneInput(
      field: this,
      controller: controller,
      countries: allowedCountries,
    );
  }
}

/// Dropdown field populated from the built-in phone-country dataset.
class FormFlutterCountryField extends FormFlutterDropdownField<String> {
  FormFlutterCountryField({
    required super.name,
    required super.label,
    List<String>? allowedCountryCodes,
    bool includeFlag = true,
    bool includeDialCode = false,
    super.helperText,
    super.validator,
    super.asyncValidator,
    super.hintText,
    super.optionBuilder,
    super.decorationOverride,
  }) : super(
         options: [
           for (final country in FormFlutterPhoneCountries.resolveAllowed(
             allowedCountryCodes,
           ))
             FormFlutterOption<String>(
               value: country.isoCode,
               label: _countryFieldLabel(
                 country,
                 includeFlag: includeFlag,
                 includeDialCode: includeDialCode,
               ),
             ),
         ],
       );
}

class _FormFlutterPhoneInput extends StatefulWidget {
  const _FormFlutterPhoneInput({
    required this.field,
    required this.controller,
    required this.countries,
  });

  final FormFlutterPhoneField field;
  final FormFlutterController controller;
  final List<FormFlutterPhoneCountry> countries;

  @override
  State<_FormFlutterPhoneInput> createState() => _FormFlutterPhoneInputState();
}

class _FormFlutterPhoneInputState extends State<_FormFlutterPhoneInput> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final currentCountry = widget.controller.snapshot
        .asMap()[widget.field.resolvedCountryFieldName];
    if (currentCountry == null ||
        !widget.countries.any(
          (country) =>
              country.isoCode == currentCountry.toString().trim().toUpperCase(),
        )) {
      final seededCountry =
          widget.countries.any(
            (country) =>
                country.isoCode ==
                widget.field.initialCountryCode.toUpperCase(),
          )
          ? widget.field.initialCountryCode.toUpperCase()
          : widget.countries.first.isoCode;
      widget.controller.setValue(
        widget.field.resolvedCountryFieldName,
        seededCountry,
      );
    }
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
        final selectedCountry = _resolveSelectedCountry(values);
        final currentValue = widget.field.normalizeValue(
          values[widget.field.name],
        );
        if (_textController.text != currentValue) {
          _textController.value = TextEditingValue(
            text: currentValue,
            selection: TextSelection.collapsed(offset: currentValue.length),
          );
        }

        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: widget.controller.errorsListenable,
          builder: (context, _, _) {
            return TextFormField(
              controller: _textController,
              keyboardType: TextInputType.phone,
              style: widget.field.textStyle,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(
                  selectedCountry.maxNationalNumberLength,
                ),
              ],
              onChanged: (value) {
                widget.controller.setValue(widget.field.name, value);
                widget.controller.setError(widget.field.name, null);
              },
              decoration: widget.field
                  .decoration(widget.controller)
                  .copyWith(
                    hintText:
                        widget.field.nationalNumberHintText ??
                        '${selectedCountry.minNationalNumberLength}-${selectedCountry.maxNationalNumberLength} digits',
                    helperText:
                        widget.field.helperText ??
                        'Dial code ${selectedCountry.dialCode} - ${selectedCountry.minNationalNumberLength}-${selectedCountry.maxNationalNumberLength} digits',
                    prefix: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: _PhoneCountrySelector(
                        countries: widget.countries,
                        selectedCountry: selectedCountry,
                        showCountryName: widget.field.showCountryName,
                        showCountryFlag: widget.field.showCountryFlagInSelector,
                        showCountryIsoCode:
                            widget.field.showCountryIsoCodeInSelector,
                        showCountryDialCode:
                            widget.field.showCountryDialCodeInSelector,
                        menuMaxHeight: widget.field.countryMenuMaxHeight,
                        onChanged: (country) {
                          widget.controller.setValue(
                            widget.field.resolvedCountryFieldName,
                            country.isoCode,
                          );
                          final current = widget.field.normalizeValue(
                            widget.controller.snapshot
                                .asMap()[widget.field.name],
                          );
                          final trimmed =
                              current.length > country.maxNationalNumberLength
                              ? current.substring(
                                  0,
                                  country.maxNationalNumberLength,
                                )
                              : current;
                          if (trimmed != current) {
                            widget.controller.setValue(
                              widget.field.name,
                              trimmed,
                            );
                          }
                          widget.controller.setError(widget.field.name, null);
                          setState(() {
                            _textController.value = TextEditingValue(
                              text: trimmed,
                              selection: TextSelection.collapsed(
                                offset: trimmed.length,
                              ),
                            );
                          });
                        },
                      ),
                    ),
                  ),
            );
          },
        );
      },
    );
  }

  FormFlutterPhoneCountry _resolveSelectedCountry(Map<String, Object?> values) {
    final storedIsoCode =
        values[widget.field.resolvedCountryFieldName]?.toString() ??
        widget.field.initialCountryCode;
    final selectedCountry = widget.countries.where(
      (country) => country.isoCode == storedIsoCode.toUpperCase(),
    );
    if (selectedCountry.isNotEmpty) {
      return selectedCountry.first;
    }
    return widget.countries.first;
  }
}

class _PhoneCountrySelector extends StatelessWidget {
  const _PhoneCountrySelector({
    required this.countries,
    required this.selectedCountry,
    required this.showCountryName,
    required this.showCountryFlag,
    required this.showCountryIsoCode,
    required this.showCountryDialCode,
    required this.menuMaxHeight,
    required this.onChanged,
  });

  final List<FormFlutterPhoneCountry> countries;
  final FormFlutterPhoneCountry selectedCountry;
  final bool showCountryName;
  final bool showCountryFlag;
  final bool showCountryIsoCode;
  final bool showCountryDialCode;
  final double menuMaxHeight;
  final ValueChanged<FormFlutterPhoneCountry> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).colorScheme.outlineVariant;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final result = await showModalBottomSheet<FormFlutterPhoneCountry>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return _PhoneCountryPickerSheet(
                countries: countries,
                selectedCountry: selectedCountry,
                showCountryName: showCountryName,
                maxHeight: menuMaxHeight,
              );
            },
          );
          if (result != null) {
            onChanged(result);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCountryFlag) ...[
                Text(
                  selectedCountry.flagEmoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  _phoneSelectorLabel(
                    selectedCountry,
                    showCountryName: showCountryName,
                    showCountryIsoCode: showCountryIsoCode,
                    showCountryDialCode: showCountryDialCode,
                  ),
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF101828),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: Color(0xFF667085),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _countryFieldLabel(
  FormFlutterPhoneCountry country, {
  required bool includeFlag,
  required bool includeDialCode,
}) {
  final parts = <String>[];
  if (includeFlag) {
    parts.add(country.flagEmoji);
  }
  parts.add(country.name);
  var label = parts.join(' ');
  if (includeDialCode) {
    label = '$label (${country.dialCode})';
  }
  return label;
}

String _phoneSelectorLabel(
  FormFlutterPhoneCountry country, {
  required bool showCountryName,
  required bool showCountryIsoCode,
  required bool showCountryDialCode,
}) {
  final parts = <String>[];
  if (showCountryName) {
    parts.add(country.name);
  } else {
    if (showCountryIsoCode) {
      parts.add(country.isoCode);
    }
    if (showCountryDialCode) {
      parts.add(country.dialCode);
    }
  }

  if (parts.isEmpty) {
    parts.add(country.dialCode);
  }

  return parts.join(' ');
}

class _PhoneCountryPickerSheet extends StatefulWidget {
  const _PhoneCountryPickerSheet({
    required this.countries,
    required this.selectedCountry,
    required this.showCountryName,
    required this.maxHeight,
  });

  final List<FormFlutterPhoneCountry> countries;
  final FormFlutterPhoneCountry selectedCountry;
  final bool showCountryName;
  final double maxHeight;

  @override
  State<_PhoneCountryPickerSheet> createState() =>
      _PhoneCountryPickerSheetState();
}

class _PhoneCountryPickerSheetState extends State<_PhoneCountryPickerSheet> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late List<FormFlutterPhoneCountry> _filteredCountries = widget.countries;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _searchFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxHeight = widget.maxHeight.clamp(320.0, 640.0).toDouble();
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        constraints: BoxConstraints(maxWidth: 640, maxHeight: maxHeight),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 52,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFD0D5DD),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select country',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101828),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search country or code',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _filteredCountries = widget.countries;
                                });
                                _searchFocusNode.requestFocus();
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                      ),
                    ),
                    onChanged: (value) {
                      final query = value.trim().toLowerCase();
                      setState(() {
                        _filteredCountries = _searchCountries(query);
                      });
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _filteredCountries.isEmpty
                  ? Center(
                      child: Text(
                        'No countries found.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF667085),
                        ),
                      ),
                    )
                  : Scrollbar(
                      thumbVisibility: true,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
                        itemCount: _filteredCountries.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final country = _filteredCountries[index];
                          final isSelected =
                              country.isoCode == widget.selectedCountry.isoCode;
                          return Material(
                            color: isSelected
                                ? const Color(0xFFECFDF3)
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(18),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: isSelected
                                      ? const Color(0xFF12B76A)
                                      : const Color(0xFFE4E7EC),
                                ),
                              ),
                              title: Text(
                                '${country.flagEmoji} ${country.name}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF101828),
                                ),
                              ),
                              subtitle: widget.showCountryName
                                  ? Text(
                                      '${country.isoCode}  ${country.dialCode}',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: const Color(0xFF667085),
                                          ),
                                    )
                                  : null,
                              trailing: isSelected
                                  ? const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF12B76A),
                                    )
                                  : Text(
                                      country.dialCode,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF344054),
                                          ),
                                    ),
                              onTap: () => Navigator.of(context).pop(country),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<FormFlutterPhoneCountry> _searchCountries(String query) {
    if (query.isEmpty) {
      return widget.countries;
    }

    final matches = widget.countries.where((country) {
      final name = country.name.toLowerCase();
      final isoCode = country.isoCode.toLowerCase();
      final dialCode = country.dialCode.toLowerCase();
      return name.contains(query) ||
          isoCode.contains(query) ||
          dialCode.contains(query);
    }).toList();

    matches.sort((a, b) {
      final rankA = _countrySearchRank(a, query);
      final rankB = _countrySearchRank(b, query);
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      return a.name.compareTo(b.name);
    });

    return matches;
  }

  int _countrySearchRank(FormFlutterPhoneCountry country, String query) {
    final name = country.name.toLowerCase();
    final isoCode = country.isoCode.toLowerCase();
    final dialCode = country.dialCode.toLowerCase();

    if (isoCode == query || dialCode == query || name == query) {
      return 0;
    }
    if (name.startsWith(query)) {
      return 1;
    }
    if (isoCode.startsWith(query)) {
      return 2;
    }
    if (dialCode.startsWith(query)) {
      return 3;
    }
    if (name.contains(query)) {
      return 4;
    }
    if (isoCode.contains(query)) {
      return 5;
    }
    if (dialCode.contains(query)) {
      return 6;
    }
    return 7;
  }
}

/// Generic dropdown field backed by typed options.
class FormFlutterDropdownField<T> extends _FormFlutterInputField<T?> {
  const FormFlutterDropdownField({
    required super.name,
    required super.label,
    required this.options,
    super.helperText,
    super.validator,
    super.asyncValidator,
    super.hintText,
    this.optionBuilder,
    super.decorationOverride,
  });

  final List<FormFlutterOption<T>> options;
  final FormFlutterOptionBuilder<T>? optionBuilder;

  @override
  T? normalizeValue(Object? rawValue) {
    return rawValue as T?;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, _, _) {
            return DropdownButtonFormField<T>(
              initialValue: normalizeValue(values[name]),
              isExpanded: true,
              decoration: decoration(controller),
              items: [
                for (final option in options)
                  DropdownMenuItem<T>(
                    value: option.value,
                    child: _buildOption(context, option, false),
                  ),
              ],
              selectedItemBuilder: (context) {
                return [
                  for (final option in options)
                    SizedBox(
                      width: double.infinity,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _buildSelectedOption(context, option),
                      ),
                    ),
                ];
              },
              onChanged: (value) {
                controller.setValue(name, value);
                controller.setError(name, null);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    FormFlutterOption<T> option,
    bool isSelected,
  ) {
    return optionBuilder?.call(context, option, isSelected) ??
        _FormFlutterOptionLabel(option: option, isSelected: isSelected);
  }

  Widget _buildSelectedOption(
    BuildContext context,
    FormFlutterOption<T> option,
  ) {
    if (optionBuilder != null) {
      return optionBuilder!(context, option, true);
    }

    final accentColor =
        option.color ?? option.selectedColor ?? option.borderColor;
    final foregroundColor =
        option.textColor ?? accentColor ?? const Color(0xFF101828);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (option.color != null || option.icon != null) ...[
            Container(
              width: option.indicatorSize ?? 12,
              height: option.indicatorSize ?? 12,
              decoration: BoxDecoration(
                color: option.color ?? accentColor ?? const Color(0xFFD0D5DD),
                shape: BoxShape.circle,
              ),
              child: option.icon == null
                  ? null
                  : Icon(
                      option.icon,
                      size: (option.indicatorSize ?? 12) * 0.7,
                      color:
                          _foregroundColorFor(option.color ?? accentColor) ??
                          Colors.white,
                    ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FormFlutterAutocompleteField<T extends Object>
    extends FormFlutterField<T?> {
  const FormFlutterAutocompleteField({
    required super.name,
    required super.label,
    required this.options,
    required this.displayStringForOption,
    this.decoration,
    this.hintText,
    this.textStyle,
    this.emptyStateText = 'No matches found.',
    this.onQueryChanged,
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  final List<T> options;
  final String Function(T option) displayStringForOption;
  final InputDecoration? decoration;
  final String? hintText;
  final TextStyle? textStyle;
  final String emptyStateText;
  final ValueChanged<String>? onQueryChanged;

  @override
  T? normalizeValue(Object? rawValue) {
    return rawValue as T?;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return _FormFlutterAutocompleteInput<T>(
      field: this,
      controller: controller,
    );
  }
}

/// Radio-group field for mutually exclusive option selection.
class FormFlutterRadioGroupField<T> extends FormFlutterField<T?> {
  const FormFlutterRadioGroupField({
    required super.name,
    required super.label,
    required this.options,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.decoration,
    this.optionBuilder,
  });

  final List<FormFlutterOption<T>> options;
  final InputDecoration? decoration;
  final FormFlutterOptionBuilder<T>? optionBuilder;

  @override
  T? normalizeValue(Object? rawValue) {
    return rawValue as T?;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, _) {
            final selected = normalizeValue(values[name]);
            return InputDecorator(
              decoration: _mergeDecoratorDecoration(errors[name]),
              child: RadioGroup<T>(
                groupValue: selected,
                onChanged: (value) {
                  controller.setValue(name, value);
                  controller.setError(name, null);
                },
                child: Column(
                  children: [
                    for (final option in options)
                      RadioListTile<T>(
                        value: option.value,
                        activeColor: option.color,
                        fillColor: option.color == null
                            ? null
                            : WidgetStatePropertyAll<Color>(option.color!),
                        title:
                            optionBuilder?.call(
                              context,
                              option,
                              selected == option.value,
                            ) ??
                            _FormFlutterOptionLabel(
                              option: selected == option.value
                                  ? FormFlutterOption<T>(
                                      value: option.value,
                                      label: option.label,
                                      color: option.color,
                                      backgroundColor: option.backgroundColor,
                                      selectedColor: option.selectedColor,
                                      textColor: option.textColor,
                                      selectedTextColor:
                                          option.textColor ??
                                          option.color ??
                                          const Color(0xFF101828),
                                      borderColor: option.borderColor,
                                      indicatorSize: option.indicatorSize,
                                      icon: option.icon,
                                    )
                                  : option,
                              isSelected: selected == option.value,
                            ),
                        contentPadding: EdgeInsets.zero,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _mergeDecoratorDecoration(String? errorText) {
    final base = InputDecoration(
      labelText: label,
      helperText: helperText,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
    return base.copyWith(
      labelStyle: decoration?.labelStyle,
      helperStyle: decoration?.helperStyle,
      hintStyle: decoration?.hintStyle,
      errorStyle: decoration?.errorStyle,
      filled: decoration?.filled,
      fillColor: decoration?.fillColor,
      contentPadding: decoration?.contentPadding,
      border: decoration?.border ?? base.border,
      enabledBorder: decoration?.enabledBorder,
      focusedBorder: decoration?.focusedBorder,
      errorBorder: decoration?.errorBorder,
      focusedErrorBorder: decoration?.focusedErrorBorder,
    );
  }
}

/// Checkbox field for boolean consent-style values.
class FormFlutterCheckboxField extends FormFlutterField<bool> {
  const FormFlutterCheckboxField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.decoration,
    this.activeColor,
    this.checkColor,
    this.titleStyle,
  });

  final InputDecoration? decoration;
  final Color? activeColor;
  final Color? checkColor;
  final TextStyle? titleStyle;

  @override
  bool normalizeValue(Object? rawValue) {
    return rawValue == true;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final checked = normalizeValue(values[name]);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, _) {
            return InputDecorator(
              decoration: _mergeDecoratorDecoration(errors[name]),
              child: CheckboxListTile(
                value: checked,
                activeColor: activeColor,
                checkColor: checkColor,
                onChanged: (value) {
                  controller.setValue(name, value ?? false);
                  controller.setError(name, null);
                },
                title: Text(label, style: titleStyle),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _mergeDecoratorDecoration(String? errorText) {
    final base = InputDecoration(
      helperText: helperText,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
    return base.copyWith(
      filled: decoration?.filled,
      fillColor: decoration?.fillColor,
      contentPadding: decoration?.contentPadding,
      border: decoration?.border ?? base.border,
      enabledBorder: decoration?.enabledBorder,
      focusedBorder: decoration?.focusedBorder,
      errorBorder: decoration?.errorBorder,
      focusedErrorBorder: decoration?.focusedErrorBorder,
      helperStyle: decoration?.helperStyle,
      errorStyle: decoration?.errorStyle,
    );
  }
}

/// Switch field for boolean on/off values.
class FormFlutterSwitchField extends FormFlutterField<bool> {
  const FormFlutterSwitchField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.decoration,
    this.activeColor,
    this.thumbColor,
    this.trackColor,
    this.titleStyle,
  });

  final InputDecoration? decoration;
  final Color? activeColor;
  final WidgetStateProperty<Color?>? thumbColor;
  final WidgetStateProperty<Color?>? trackColor;
  final TextStyle? titleStyle;

  @override
  bool normalizeValue(Object? rawValue) {
    return rawValue == true;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final currentValue = normalizeValue(values[name]);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, _) {
            return InputDecorator(
              decoration: _mergeDecoratorDecoration(errors[name]),
              child: SwitchListTile(
                value: currentValue,
                activeThumbColor: activeColor,
                activeTrackColor: activeColor?.withValues(alpha: 0.35),
                thumbColor: thumbColor,
                trackColor: trackColor,
                onChanged: (value) {
                  controller.setValue(name, value);
                  controller.setError(name, null);
                },
                title: Text(label, style: titleStyle),
                contentPadding: EdgeInsets.zero,
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _mergeDecoratorDecoration(String? errorText) {
    final base = InputDecoration(
      helperText: helperText,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
    return base.copyWith(
      filled: decoration?.filled,
      fillColor: decoration?.fillColor,
      contentPadding: decoration?.contentPadding,
      border: decoration?.border ?? base.border,
      enabledBorder: decoration?.enabledBorder,
      focusedBorder: decoration?.focusedBorder,
      errorBorder: decoration?.errorBorder,
      focusedErrorBorder: decoration?.focusedErrorBorder,
      helperStyle: decoration?.helperStyle,
      errorStyle: decoration?.errorStyle,
    );
  }
}

/// File picker field driven by a custom async picker callback.
class FormFlutterFileField extends FormFlutterField<FormFlutterFileValue?> {
  const FormFlutterFileField({
    required super.name,
    required super.label,
    required this.onPick,
    this.decoration,
    this.pickButtonLabel = 'Choose file',
    this.clearButtonLabel = 'Clear',
    this.placeholder,
    this.canClear = true,
    this.leading,
    this.pickerConfigured = true,
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  final Future<FormFlutterFileValue?> Function(
    BuildContext context,
    FormFlutterController controller,
  )
  onPick;
  final InputDecoration? decoration;
  final String pickButtonLabel;
  final String clearButtonLabel;
  final String? placeholder;
  final bool canClear;
  final Widget? leading;
  final bool pickerConfigured;

  @override
  FormFlutterFileValue? normalizeValue(Object? rawValue) {
    return rawValue as FormFlutterFileValue?;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return _FormFlutterFilePicker(field: this, controller: controller);
  }
}

/// Image field with file-picker behavior plus preview support.
class FormFlutterImageField extends FormFlutterFileField {
  const FormFlutterImageField({
    required super.name,
    required super.label,
    required super.onPick,
    super.decoration,
    super.pickButtonLabel,
    super.clearButtonLabel,
    super.placeholder,
    super.canClear,
    super.pickerConfigured,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.previewHeight = 160,
    this.previewFit = BoxFit.cover,
    this.previewPlaceholder,
  }) : super(leading: const Icon(Icons.image_outlined));

  final double previewHeight;
  final BoxFit previewFit;
  final Widget? previewPlaceholder;

  @override
  Widget buildField(FormFlutterController controller) {
    return _FormFlutterImagePicker(field: this, controller: controller);
  }
}

/// Signature pad field that stores one or more drawn strokes.
class FormFlutterSignatureField extends FormFlutterField<List<List<Offset>>> {
  const FormFlutterSignatureField({
    required super.name,
    required super.label,
    this.decoration,
    this.canvasHeight = 220,
    this.strokeWidth = 2.6,
    this.strokeColor,
    this.backgroundColor,
    this.clearButtonLabel = 'Clear signature',
    this.placeholder = 'Sign inside the box.',
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  final InputDecoration? decoration;
  final double canvasHeight;
  final double strokeWidth;
  final Color? strokeColor;
  final Color? backgroundColor;
  final String clearButtonLabel;
  final String placeholder;

  @override
  List<List<Offset>> normalizeValue(Object? rawValue) {
    if (rawValue is List<List<Offset>>) {
      return rawValue;
    }
    if (rawValue is List) {
      return rawValue
          .map<List<Offset>>((stroke) {
            if (stroke is List<Offset>) {
              return stroke;
            }
            if (stroke is List) {
              return stroke.cast<Offset>();
            }
            return const <Offset>[];
          })
          .where((stroke) => stroke.isNotEmpty)
          .toList(growable: false);
    }
    return const <List<Offset>>[];
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return _FormFlutterSignaturePad(field: this, controller: controller);
  }
}

/// Date picker field backed by `showDatePicker`.
class FormFlutterDateField extends _FormFlutterInputField<DateTime?> {
  const FormFlutterDateField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.firstDate,
    this.lastDate,
    super.hintText,
    this.dateFormatter,
    super.decorationOverride,
    super.textStyle,
  });

  final DateTime? firstDate;
  final DateTime? lastDate;
  final String Function(DateTime value)? dateFormatter;

  @override
  DateTime? normalizeValue(Object? rawValue) {
    if (rawValue is DateTime) {
      return rawValue;
    }
    return null;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final selectedDate = normalizeValue(values[name]);
        final text = selectedDate == null
            ? (hintText ?? 'Select a date')
            : (dateFormatter?.call(selectedDate) ?? _formatDate(selectedDate));
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, _, _) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? now,
                  firstDate: firstDate ?? DateTime(now.year - 100),
                  lastDate: lastDate ?? DateTime(now.year + 100),
                );
                if (picked != null) {
                  controller.setValue(name, picked);
                  controller.setError(name, null);
                }
              },
              child: InputDecorator(
                decoration: decoration(controller).copyWith(
                  suffixIcon:
                      decorationOverride?.suffixIcon ??
                      const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(text, style: textStyle),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

/// Time picker field backed by `showTimePicker`.
class FormFlutterTimeField extends _FormFlutterInputField<TimeOfDay?> {
  const FormFlutterTimeField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    super.hintText,
    this.timeFormatter,
    super.decorationOverride,
    super.textStyle,
  });

  final String Function(BuildContext context, TimeOfDay value)? timeFormatter;

  @override
  TimeOfDay? normalizeValue(Object? rawValue) {
    if (rawValue is TimeOfDay) {
      return rawValue;
    }
    return null;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final selected = normalizeValue(values[name]);
        final text = selected == null
            ? (hintText ?? 'Select a time')
            : (timeFormatter?.call(context, selected) ??
                  selected.format(context));
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, _, _) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selected ?? TimeOfDay.now(),
                );
                if (picked != null) {
                  controller.setValue(name, picked);
                  controller.setError(name, null);
                }
              },
              child: InputDecorator(
                decoration: decoration(controller).copyWith(
                  suffixIcon:
                      decorationOverride?.suffixIcon ??
                      const Icon(Icons.schedule_outlined),
                ),
                child: Text(text, style: textStyle),
              ),
            );
          },
        );
      },
    );
  }
}

/// Combined date and time picker field.
class FormFlutterDateTimeField extends _FormFlutterInputField<DateTime?> {
  const FormFlutterDateTimeField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.firstDate,
    this.lastDate,
    super.hintText,
    this.dateTimeFormatter,
    super.decorationOverride,
    super.textStyle,
  });

  final DateTime? firstDate;
  final DateTime? lastDate;
  final String Function(BuildContext context, DateTime value)?
  dateTimeFormatter;

  @override
  DateTime? normalizeValue(Object? rawValue) {
    if (rawValue is DateTime) {
      return rawValue;
    }
    return null;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final selected = normalizeValue(values[name]);
        final text = selected == null
            ? (hintText ?? 'Select date and time')
            : (dateTimeFormatter?.call(context, selected) ??
                  _formatDateTime(context, selected));
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, _, _) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: selected ?? now,
                  firstDate: firstDate ?? DateTime(now.year - 100),
                  lastDate: lastDate ?? DateTime(now.year + 100),
                );
                if (date == null || !context.mounted) {
                  return;
                }
                final time = await showTimePicker(
                  context: context,
                  initialTime: selected == null
                      ? TimeOfDay.fromDateTime(now)
                      : TimeOfDay.fromDateTime(selected),
                );
                if (time != null) {
                  controller.setValue(
                    name,
                    DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                  controller.setError(name, null);
                }
              },
              child: InputDecorator(
                decoration: decoration(controller).copyWith(
                  suffixIcon:
                      decorationOverride?.suffixIcon ??
                      const Icon(Icons.event_outlined),
                ),
                child: Text(text, style: textStyle),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final time = TimeOfDay.fromDateTime(value).format(context);
    return '${value.year}-$month-$day $time';
  }
}

/// Slider field for selecting a numeric value within a range.
class FormFlutterSliderField extends FormFlutterField<double> {
  const FormFlutterSliderField({
    required super.name,
    required super.label,
    required this.min,
    required this.max,
    this.divisions,
    this.unitLabel,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.decoration,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.valueStyle,
  });

  final double min;
  final double max;
  final int? divisions;
  final String? unitLabel;
  final InputDecoration? decoration;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final TextStyle? valueStyle;

  @override
  double normalizeValue(Object? rawValue) {
    if (rawValue is num) {
      return rawValue.toDouble();
    }
    return min;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, _) {
            final currentValue = normalizeValue(values[name]);
            final displayValue = currentValue % 1 == 0
                ? currentValue.toStringAsFixed(0)
                : currentValue.toStringAsFixed(1);
            return InputDecorator(
              decoration: _mergeDecoratorDecoration(errors[name]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unitLabel == null
                        ? displayValue
                        : '$displayValue $unitLabel',
                    style: valueStyle,
                  ),
                  Slider(
                    value: currentValue.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: displayValue,
                    activeColor: activeColor,
                    inactiveColor: inactiveColor,
                    thumbColor: thumbColor,
                    onChanged: (value) {
                      controller.setValue(name, value);
                      controller.setError(name, null);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _mergeDecoratorDecoration(String? errorText) {
    final base = InputDecoration(
      labelText: label,
      helperText: helperText,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
    return base.copyWith(
      filled: decoration?.filled,
      fillColor: decoration?.fillColor,
      contentPadding: decoration?.contentPadding,
      border: decoration?.border ?? base.border,
      enabledBorder: decoration?.enabledBorder,
      focusedBorder: decoration?.focusedBorder,
      errorBorder: decoration?.errorBorder,
      focusedErrorBorder: decoration?.focusedErrorBorder,
      labelStyle: decoration?.labelStyle,
      helperStyle: decoration?.helperStyle,
      errorStyle: decoration?.errorStyle,
    );
  }
}

/// Multi-select field that stores a list of selected values.
class FormFlutterMultiSelectField<T> extends FormFlutterField<List<T>> {
  const FormFlutterMultiSelectField({
    required super.name,
    required super.label,
    required this.options,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.decoration,
    this.optionBuilder,
  });

  final List<FormFlutterOption<T>> options;
  final InputDecoration? decoration;
  final FormFlutterOptionBuilder<T>? optionBuilder;

  @override
  List<T> normalizeValue(Object? rawValue) {
    if (rawValue is List<T>) {
      return rawValue;
    }
    if (rawValue is List) {
      return rawValue.cast<T>();
    }
    return <T>[];
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final selected = normalizeValue(values[name]);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, _) {
            return InputDecorator(
              decoration: _mergeDecoratorDecoration(errors[name]),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in options)
                    optionBuilder == null
                        ? FilterChip(
                            label: Text(
                              option.label,
                              style: TextStyle(
                                color: _optionTextColor(
                                  option,
                                  isSelected: selected.contains(option.value),
                                ),
                              ),
                            ),
                            selected: selected.contains(option.value),
                            backgroundColor: option.backgroundColor,
                            selectedColor: option.selectedColor ?? option.color,
                            side: BorderSide(
                              color:
                                  option.borderColor ??
                                  option.color ??
                                  const Color(0xFFD0D5DD),
                            ),
                            checkmarkColor:
                                _optionTextColor(option, isSelected: true) ??
                                Colors.white,
                            avatar: option.color == null && option.icon == null
                                ? null
                                : CircleAvatar(
                                    radius: (option.indicatorSize ?? 14) / 2,
                                    backgroundColor:
                                        option.color ?? const Color(0xFFD0D5DD),
                                    child: option.icon == null
                                        ? null
                                        : Icon(
                                            option.icon,
                                            size: option.indicatorSize == null
                                                ? 10
                                                : option.indicatorSize! * 0.72,
                                            color: Colors.white,
                                          ),
                                  ),
                            onSelected: (isSelected) {
                              final next = List<T>.from(selected);
                              if (isSelected) {
                                if (!next.contains(option.value)) {
                                  next.add(option.value);
                                }
                              } else {
                                next.remove(option.value);
                              }
                              controller.setValue(name, next);
                              controller.setError(name, null);
                            },
                          )
                        : InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              final next = List<T>.from(selected);
                              if (selected.contains(option.value)) {
                                next.remove(option.value);
                              } else {
                                next.add(option.value);
                              }
                              controller.setValue(name, next);
                              controller.setError(name, null);
                            },
                            child: optionBuilder!(
                              context,
                              option,
                              selected.contains(option.value),
                            ),
                          ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _mergeDecoratorDecoration(String? errorText) {
    final base = InputDecoration(
      labelText: label,
      helperText: helperText,
      errorText: errorText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
    );
    return base.copyWith(
      filled: decoration?.filled,
      fillColor: decoration?.fillColor,
      contentPadding: decoration?.contentPadding,
      border: decoration?.border ?? base.border,
      enabledBorder: decoration?.enabledBorder,
      focusedBorder: decoration?.focusedBorder,
      errorBorder: decoration?.errorBorder,
      focusedErrorBorder: decoration?.focusedErrorBorder,
      labelStyle: decoration?.labelStyle,
      helperStyle: decoration?.helperStyle,
      errorStyle: decoration?.errorStyle,
    );
  }
}

class _FormFlutterAutocompleteInput<T extends Object> extends StatefulWidget {
  const _FormFlutterAutocompleteInput({
    required this.field,
    required this.controller,
  });

  final FormFlutterAutocompleteField<T> field;
  final FormFlutterController controller;

  @override
  State<_FormFlutterAutocompleteInput<T>> createState() =>
      _FormFlutterAutocompleteInputState<T>();
}

class _FormFlutterAutocompleteInputState<T extends Object>
    extends State<_FormFlutterAutocompleteInput<T>> {
  late final TextEditingController _textController;
  bool _preserveQueryForClearedSelection = false;

  @override
  void initState() {
    super.initState();
    final currentValue = widget.field.normalizeValue(
      widget.controller.snapshot.asMap()[widget.field.name],
    );
    _textController = TextEditingController(
      text: currentValue == null
          ? ''
          : widget.field.displayStringForOption(currentValue),
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
        final currentLabel = currentValue == null
            ? ''
            : widget.field.displayStringForOption(currentValue);
        if (_preserveQueryForClearedSelection && currentValue == null) {
          _preserveQueryForClearedSelection = false;
        } else if (_textController.text != currentLabel &&
            !_textController.value.composing.isValid) {
          _textController.value = TextEditingValue(
            text: currentLabel,
            selection: TextSelection.collapsed(offset: currentLabel.length),
          );
        }

        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: widget.controller.errorsListenable,
          builder: (context, _, _) {
            return Autocomplete<T>(
              initialValue: TextEditingValue(text: currentLabel),
              displayStringForOption: widget.field.displayStringForOption,
              optionsBuilder: (textEditingValue) {
                final query = textEditingValue.text.trim().toLowerCase();
                widget.field.onQueryChanged?.call(textEditingValue.text);
                if (query.isEmpty) {
                  return widget.field.options;
                }
                return widget.field.options.where((option) {
                  return widget.field
                      .displayStringForOption(option)
                      .toLowerCase()
                      .contains(query);
                });
              },
              onSelected: (selection) {
                final label = widget.field.displayStringForOption(selection);
                widget.controller.setValue(widget.field.name, selection);
                widget.controller.setError(widget.field.name, null);
                _textController.value = TextEditingValue(
                  text: label,
                  selection: TextSelection.collapsed(offset: label.length),
                );
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    if (_textController.text != textEditingController.text) {
                      textEditingController.value = _textController.value;
                    }
                    return TextFormField(
                      controller: textEditingController,
                      focusNode: focusNode,
                      style: widget.field.textStyle,
                      onChanged: (value) {
                        _textController.value = TextEditingValue(
                          text: value,
                          selection: TextSelection.collapsed(
                            offset: value.length,
                          ),
                        );
                        final selectedValue = widget.field.normalizeValue(
                          widget.controller.snapshot.asMap()[widget.field.name],
                        );
                        final selectedLabel = selectedValue == null
                            ? ''
                            : widget.field.displayStringForOption(
                                selectedValue,
                              );
                        if (value != selectedLabel) {
                          _preserveQueryForClearedSelection = true;
                          widget.controller.setValue(widget.field.name, null);
                          widget.controller.setError(widget.field.name, null);
                        }
                      },
                      decoration:
                          _mergeDecoratorDecoration(
                            widget.field.label,
                            widget.field.helperText,
                            widget.controller.error(widget.field.name),
                            widget.field.decoration,
                            hintText: widget.field.hintText,
                          ).copyWith(
                            prefixIcon:
                                widget.field.decoration?.prefixIcon ??
                                const Icon(Icons.auto_awesome_outlined),
                          ),
                    );
                  },
              optionsViewBuilder: (context, onSelected, options) {
                final optionsList = options.toList(growable: false);
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 420,
                        maxHeight: 240,
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shrinkWrap: true,
                        itemCount: optionsList.length,
                        itemBuilder: (context, index) {
                          final option = optionsList[index];
                          return ListTile(
                            title: Text(
                              widget.field.displayStringForOption(option),
                              style: widget.field.textStyle,
                            ),
                            onTap: () => onSelected(option),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FormFlutterFilePicker extends StatefulWidget {
  const _FormFlutterFilePicker({required this.field, required this.controller});

  final FormFlutterFileField field;
  final FormFlutterController controller;

  @override
  State<_FormFlutterFilePicker> createState() => _FormFlutterFilePickerState();
}

class _FormFlutterFilePickerState extends State<_FormFlutterFilePicker> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: widget.controller.valuesListenable,
      builder: (context, values, _) {
        final file = widget.field.normalizeValue(values[widget.field.name]);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: widget.controller.errorsListenable,
          builder: (context, errors, _) {
            return InputDecorator(
              decoration: _mergeDecoratorDecoration(
                widget.field.label,
                widget.field.helperText,
                errors[widget.field.name],
                widget.field.decoration,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.field.leading ??
                          const Icon(Icons.attach_file_rounded),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              file?.name ??
                                  widget.field.placeholder ??
                                  'No file selected.',
                            ),
                            if (file != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                _describeFile(file),
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: const Color(0xFF667085)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: (!widget.field.pickerConfigured || _loading)
                            ? null
                            : () async {
                                setState(() {
                                  _loading = true;
                                });
                                final picked = await widget.field.onPick(
                                  context,
                                  widget.controller,
                                );
                                if (!mounted) {
                                  return;
                                }
                                if (picked != null) {
                                  widget.controller.setValue(
                                    widget.field.name,
                                    picked,
                                  );
                                  widget.controller.setError(
                                    widget.field.name,
                                    null,
                                  );
                                }
                                setState(() {
                                  _loading = false;
                                });
                              },
                        icon: Icon(
                          _loading
                              ? Icons.hourglass_top_rounded
                              : Icons.upload_file_outlined,
                        ),
                        label: Text(widget.field.pickButtonLabel),
                      ),
                      if (widget.field.canClear && file != null)
                        TextButton(
                          onPressed: () {
                            widget.controller.setValue(widget.field.name, null);
                            widget.controller.setError(widget.field.name, null);
                          },
                          child: Text(widget.field.clearButtonLabel),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _FormFlutterImagePicker extends StatelessWidget {
  const _FormFlutterImagePicker({
    required this.field,
    required this.controller,
  });

  final FormFlutterImageField field;
  final FormFlutterController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final file = field.normalizeValue(values[field.name]);
        final preview = file?.bytes == null
            ? field.previewPlaceholder ??
                  Container(
                    height: field.previewHeight,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.image_outlined, size: 36),
                  )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  file!.bytes!,
                  height: field.previewHeight,
                  width: double.infinity,
                  fit: field.previewFit,
                ),
              );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            preview,
            const SizedBox(height: 12),
            _FormFlutterFilePicker(field: field, controller: controller),
          ],
        );
      },
    );
  }
}

class _FormFlutterSignaturePad extends StatefulWidget {
  const _FormFlutterSignaturePad({
    required this.field,
    required this.controller,
  });

  final FormFlutterSignatureField field;
  final FormFlutterController controller;

  @override
  State<_FormFlutterSignaturePad> createState() =>
      _FormFlutterSignaturePadState();
}

class _FormFlutterSignaturePadState extends State<_FormFlutterSignaturePad> {
  late List<List<Offset>> _strokes;
  bool _drawing = false;

  @override
  void initState() {
    super.initState();
    _strokes = List<List<Offset>>.from(
      widget.field
          .normalizeValue(widget.controller.snapshot.asMap()[widget.field.name])
          .map((stroke) => List<Offset>.from(stroke)),
    );
  }

  void _syncController() {
    widget.controller.setValue(
      widget.field.name,
      _strokes
          .map((stroke) => List<Offset>.from(stroke))
          .toList(growable: false),
    );
    widget.controller.setError(widget.field.name, null);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, String?>>(
      valueListenable: widget.controller.errorsListenable,
      builder: (context, errors, _) {
        return InputDecorator(
          decoration: _mergeDecoratorDecoration(
            widget.field.label,
            widget.field.helperText,
            errors[widget.field.name],
            widget.field.decoration,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color:
                      widget.field.backgroundColor ?? const Color(0xFFF8FAFC),
                  child: SizedBox(
                    width: double.infinity,
                    height: widget.field.canvasHeight,
                    child: GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          _drawing = true;
                          _strokes.add([details.localPosition]);
                        });
                        _syncController();
                      },
                      onPanUpdate: (details) {
                        if (!_drawing || _strokes.isEmpty) {
                          return;
                        }
                        setState(() {
                          _strokes.last.add(details.localPosition);
                        });
                        _syncController();
                      },
                      onPanEnd: (_) {
                        setState(() {
                          _drawing = false;
                        });
                      },
                      child: CustomPaint(
                        painter: _FormFlutterSignaturePainter(
                          strokes: _strokes,
                          strokeColor:
                              widget.field.strokeColor ??
                              Theme.of(context).colorScheme.primary,
                          strokeWidth: widget.field.strokeWidth,
                        ),
                        child: _strokes.isEmpty
                            ? Center(
                                child: Text(
                                  widget.field.placeholder,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: const Color(0xFF667085),
                                      ),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _strokes.isEmpty
                      ? null
                      : () {
                          setState(() {
                            _strokes = <List<Offset>>[];
                          });
                          _syncController();
                        },
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: Text(widget.field.clearButtonLabel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FormFlutterSignaturePainter extends CustomPainter {
  const _FormFlutterSignaturePainter({
    required this.strokes,
    required this.strokeColor,
    required this.strokeWidth,
  });

  final List<List<Offset>> strokes;
  final Color strokeColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in strokes) {
      if (stroke.length == 1) {
        canvas.drawPoints(PointMode.points, stroke, paint);
        continue;
      }

      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FormFlutterSignaturePainter oldDelegate) {
    return oldDelegate.strokes != strokes ||
        oldDelegate.strokeColor != strokeColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _FormFlutterOptionLabel<T> extends StatelessWidget {
  const _FormFlutterOptionLabel({
    required this.option,
    this.isSelected = false,
  });

  final FormFlutterOption<T> option;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (option.color != null) ...[
          Container(
            width: option.indicatorSize ?? 10,
            height: option.indicatorSize ?? 10,
            decoration: BoxDecoration(
              color: option.color,
              shape: BoxShape.circle,
            ),
            child: option.icon == null
                ? null
                : Icon(
                    option.icon,
                    size: (option.indicatorSize ?? 10) * 0.7,
                    color: Colors.white,
                  ),
          ),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            option.label,
            style: TextStyle(
              color: _optionTextColor(option, isSelected: isSelected),
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

Color? _optionTextColor<T>(
  FormFlutterOption<T> option, {
  required bool isSelected,
}) {
  if (!isSelected) {
    return option.textColor ?? const Color(0xFF101828);
  }

  return option.selectedTextColor ??
      _foregroundColorFor(
        option.selectedColor ?? option.color ?? option.backgroundColor,
      ) ??
      option.textColor ??
      const Color(0xFF101828);
}

Color? _foregroundColorFor(Color? backgroundColor) {
  if (backgroundColor == null) {
    return null;
  }
  return ThemeData.estimateBrightnessForColor(backgroundColor) ==
          Brightness.dark
      ? Colors.white
      : const Color(0xFF101828);
}

InputDecoration _mergeDecoratorDecoration(
  String? label,
  String? helperText,
  String? errorText,
  InputDecoration? decoration, {
  String? hintText,
}) {
  final base = InputDecoration(
    labelText: label,
    hintText: hintText,
    helperText: helperText,
    errorText: errorText,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
  );
  return base.copyWith(
    filled: decoration?.filled,
    fillColor: decoration?.fillColor,
    contentPadding: decoration?.contentPadding,
    border: decoration?.border ?? base.border,
    enabledBorder: decoration?.enabledBorder,
    focusedBorder: decoration?.focusedBorder,
    errorBorder: decoration?.errorBorder,
    focusedErrorBorder: decoration?.focusedErrorBorder,
    labelStyle: decoration?.labelStyle,
    floatingLabelStyle: decoration?.floatingLabelStyle,
    helperStyle: decoration?.helperStyle,
    hintStyle: decoration?.hintStyle,
    errorStyle: decoration?.errorStyle,
    prefixIcon: decoration?.prefixIcon,
    suffixIcon: decoration?.suffixIcon,
    icon: decoration?.icon,
  );
}

String _describeFile(FormFlutterFileValue file) {
  final extension = (file.extension == null || file.extension!.isEmpty)
      ? null
      : file.extension!.toUpperCase();
  final type = extension ?? file.mimeType ?? 'File';
  return '$type - ${_formatFileSize(file.sizeInBytes)}';
}

String _formatFileSize(int bytes) {
  const units = ['B', 'KB', 'MB', 'GB'];
  var value = bytes.toDouble();
  var unitIndex = 0;
  while (value >= 1024 && unitIndex < units.length - 1) {
    value /= 1024;
    unitIndex++;
  }
  final precision = unitIndex == 0 ? 0 : 1;
  return '${value.toStringAsFixed(precision)} ${units[unitIndex]}';
}
