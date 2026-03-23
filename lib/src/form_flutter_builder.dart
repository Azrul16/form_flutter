import 'package:flutter/material.dart';

import 'form_flutter_catalog.dart';
import 'form_flutter_controller.dart';
import 'form_flutter_field.dart';
import 'form_flutter_validators.dart';

/// Builds a custom field from a `FormFlutterFieldPreset`.
typedef FormFlutterPresetBuilder =
    FormFlutterField<dynamic> Function(FormFlutterFieldPreset preset);

/// Converts preset metadata into concrete `FormFlutterField` definitions.
class FormFlutterFieldFactory {
  const FormFlutterFieldFactory._();

  static List<FormFlutterField<dynamic>> buildFieldsFromPresets(
    Iterable<FormFlutterFieldPreset> presets, {
    Map<String, FormFlutterPresetBuilder> buildersByKey = const {},
    Map<FormFlutterFieldKind, FormFlutterPresetBuilder> buildersByKind =
        const {},
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )? filePicker,
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )? imagePicker,
  }) {
    return [
      for (final preset in presets)
        buildField(
          preset,
          buildersByKey: buildersByKey,
          buildersByKind: buildersByKind,
          filePicker: filePicker,
          imagePicker: imagePicker,
        ),
    ];
  }

  static FormFlutterField<dynamic> buildField(
    FormFlutterFieldPreset preset, {
    Map<String, FormFlutterPresetBuilder> buildersByKey = const {},
    Map<FormFlutterFieldKind, FormFlutterPresetBuilder> buildersByKind =
        const {},
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )? filePicker,
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )? imagePicker,
  }) {
    final keyBuilder = buildersByKey[preset.key];
    if (keyBuilder != null) {
      return keyBuilder(preset);
    }

    final kindBuilder = buildersByKind[preset.kind];
    if (kindBuilder != null) {
      return kindBuilder(preset);
    }

    switch (preset.kind) {
      case FormFlutterFieldKind.email:
        return FormFlutterTextField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          keyboardType: TextInputType.emailAddress,
          validator: _buildStringValidator(
            preset,
            fallback: FormFlutterValidators.email(),
          ),
        );
      case FormFlutterFieldKind.password:
        return FormFlutterTextField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          obscureText: true,
          enableObscureTextToggle: true,
          validator: _buildStringValidator(
            preset,
            fallback: FormFlutterPresetValidators.password(),
          ),
        );
      case FormFlutterFieldKind.phone:
        return FormFlutterPhoneField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator: _buildStringValidator(
            preset,
            fallback: FormFlutterValidators.phone(),
          ),
        );
      case FormFlutterFieldKind.url:
        return FormFlutterTextField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          keyboardType: TextInputType.url,
          validator: _buildStringValidator(
            preset,
            fallback: FormFlutterValidators.url(),
          ),
        );
      case FormFlutterFieldKind.multiline:
        return FormFlutterTextField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          maxLines: 4,
          validator: _buildStringValidator(preset),
        );
      case FormFlutterFieldKind.number:
        return FormFlutterNumberField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator: preset.isRequired
              ? FormFlutterValidators.requiredNumber()
              : null,
        );
      case FormFlutterFieldKind.dropdown:
        return FormFlutterDropdownField<String>(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          options: preset.options,
          validator: preset.isRequired
              ? FormFlutterValidators.requiredSelection<String>()
              : null,
        );
      case FormFlutterFieldKind.radio:
        return FormFlutterRadioGroupField<String>(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          options: preset.options,
          validator: preset.isRequired
              ? FormFlutterValidators.requiredSelection<String>()
              : null,
        );
      case FormFlutterFieldKind.checkbox:
        return FormFlutterCheckboxField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator:
              preset.isRequired ? FormFlutterValidators.mustBeTrue() : null,
        );
      case FormFlutterFieldKind.switchField:
        return FormFlutterSwitchField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
        );
      case FormFlutterFieldKind.date:
        return FormFlutterDateField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator:
              preset.isRequired ? FormFlutterValidators.requiredDate() : null,
        );
      case FormFlutterFieldKind.time:
        return FormFlutterTimeField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator:
              preset.isRequired ? FormFlutterValidators.requiredTime() : null,
        );
      case FormFlutterFieldKind.dateTime:
        return FormFlutterDateTimeField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator:
              preset.isRequired ? FormFlutterValidators.requiredDate() : null,
        );
      case FormFlutterFieldKind.slider:
        return FormFlutterSliderField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          min: 0,
          max: 100,
        );
      case FormFlutterFieldKind.multiSelect:
        return FormFlutterMultiSelectField<String>(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          options: preset.options,
          validator: preset.isRequired
              ? FormFlutterValidators.minItems<String>(1)
              : null,
        );
      case FormFlutterFieldKind.otp:
        return FormFlutterOtpField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator: preset.isRequired
              ? FormFlutterPresetValidators.otp()
              : FormFlutterValidators.conditional<String>(
                  (values) =>
                      (values.asMap()[preset.key]?.toString() ?? '').isNotEmpty,
                  FormFlutterPresetValidators.otp(),
                ),
        );
      case FormFlutterFieldKind.search:
        return FormFlutterSearchField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator: _buildStringValidator(preset),
        );
      case FormFlutterFieldKind.autocomplete:
        return FormFlutterAutocompleteField<String>(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          options: preset.options.map((option) => option.value).toList(),
          displayStringForOption: (option) {
            for (final item in preset.options) {
              if (item.value == option) {
                return item.label;
              }
            }
            return option;
          },
          validator: preset.isRequired
              ? FormFlutterValidators.requiredSelection<String>()
              : null,
        );
      case FormFlutterFieldKind.file:
        return FormFlutterFileField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          onPick: filePicker ?? _noopPicker,
          validator:
              preset.isRequired ? FormFlutterValidators.requiredFile() : null,
        );
      case FormFlutterFieldKind.image:
        return FormFlutterImageField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          onPick: imagePicker ?? filePicker ?? _noopPicker,
          validator: preset.isRequired
              ? FormFlutterValidators.combine<FormFlutterFileValue?>([
                  FormFlutterValidators.requiredFile(),
                  FormFlutterValidators.imageOnly(),
                ])
              : FormFlutterValidators.imageOnly(),
        );
      case FormFlutterFieldKind.signature:
        return FormFlutterSignatureField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator: preset.isRequired
              ? FormFlutterValidators.requiredValue<List<List<Offset>>>()
              : null,
        );
      case FormFlutterFieldKind.text:
        return FormFlutterTextField(
          name: preset.key,
          label: preset.label,
          helperText: preset.description,
          validator: _buildStringValidator(preset),
        );
    }
  }

  static FormFlutterValidator<String>? _buildStringValidator(
    FormFlutterFieldPreset preset, {
    FormFlutterValidator<String>? fallback,
  }) {
    final validators = <FormFlutterValidator<String>>[];
    if (preset.isRequired) {
      validators.add(FormFlutterValidators.requiredText());
    }

    if (preset.validationNotes.any((note) => note.contains('email'))) {
      validators.add(FormFlutterValidators.email());
    }
    if (preset.validationNotes.any((note) => note.contains('URL'))) {
      validators.add(FormFlutterValidators.url());
    }
    if (preset.validationNotes.any((note) => note.contains('minimum length'))) {
      validators.add(FormFlutterValidators.minLength(3));
    }
    if (fallback != null) {
      validators.add(fallback);
    }

    if (validators.isEmpty) {
      return null;
    }
    return FormFlutterValidators.combine(validators);
  }

  static Future<FormFlutterFileValue?> _noopPicker(
    BuildContext context,
    FormFlutterController controller,
  ) async {
    return null;
  }
}
