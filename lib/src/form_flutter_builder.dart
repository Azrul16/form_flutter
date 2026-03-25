import 'package:flutter/material.dart';

import 'form_flutter_catalog.dart';
import 'form_flutter_controller.dart';
import 'form_flutter_field.dart';
import 'form_flutter_validators.dart';
import 'form_flutter_widgets.dart';

const Object _formFlutterSchemaUnset = Object();

/// Builds a custom field from a `FormFlutterFieldPreset`.
typedef FormFlutterPresetBuilder =
    FormFlutterField<dynamic> Function(FormFlutterFieldPreset preset);

/// Builds a custom field from a schema field and its resolved preset metadata.
typedef FormFlutterSchemaFieldBuilder =
    FormFlutterField<dynamic> Function(
      FormFlutterSchemaField field,
      FormFlutterFieldPreset preset,
    );

/// Describes a full form schema with optional sections and initial values.
class FormFlutterSchema {
  /// Creates a schema for building fields, sections, and controller state.
  const FormFlutterSchema({
    required this.sections,
    this.initialValues = const {},
  });

  /// Sections that make up the schema.
  final List<FormFlutterSchemaSection> sections;

  /// Root-level initial values merged with field-level defaults.
  final Map<String, Object?> initialValues;
}

/// Describes a schema section that can be converted into `FormFlutterSection`.
class FormFlutterSchemaSection {
  /// Creates a schema section.
  const FormFlutterSchemaSection({
    required this.title,
    required this.fields,
    this.description,
    this.isVisible,
  });

  /// Visible title of the section.
  final String title;

  /// Optional supporting text below the title.
  final String? description;

  /// Fields that belong to this section.
  final List<FormFlutterSchemaField> fields;

  /// Optional visibility rule for the whole section.
  final FormFlutterSectionVisibility? isVisible;
}

/// Describes a field in a schema, optionally based on a preset plus overrides.
class FormFlutterSchemaField {
  /// Creates a schema field from explicit values or a preset with overrides.
  const FormFlutterSchemaField({
    this.preset,
    this.name,
    this.kind,
    this.label,
    this.helperText,
    this.hintText,
    this.description,
    this.options,
    this.isRequired,
    this.validationNotes,
    this.initialValue = _formFlutterSchemaUnset,
    this.validator,
    this.asyncValidator,
    this.decorationOverride,
    this.textStyle,
    this.maxLines,
    this.countryFieldName,
    this.initialCountryCode,
    this.allowedCountryCodes,
    this.showCountryName,
    this.showCountryFlagInSelector,
    this.showCountryIsoCodeInSelector,
    this.showCountryDialCodeInSelector,
    this.countryMenuMaxHeight,
    this.nationalNumberHintText,
    this.sliderMin,
    this.sliderMax,
    this.sliderDivisions,
    this.sliderUnitLabel,
    this.fieldBuilder,
  }) : assert(
         preset != null || (name != null && kind != null && label != null),
         'Provide either a preset or explicit name, kind, and label.',
       );

  /// Creates a schema field from a preset with local overrides.
  factory FormFlutterSchemaField.fromPreset(
    FormFlutterFieldPreset preset, {
    String? name,
    FormFlutterFieldKind? kind,
    String? label,
    String? helperText,
    String? hintText,
    String? description,
    List<FormFlutterOption<String>>? options,
    bool? isRequired,
    List<String>? validationNotes,
    Object? initialValue = _formFlutterSchemaUnset,
    FormFlutterValidator<dynamic>? validator,
    FormFlutterAsyncValidator<dynamic>? asyncValidator,
    InputDecoration? decorationOverride,
    TextStyle? textStyle,
    int? maxLines,
    String? countryFieldName,
    String? initialCountryCode,
    List<String>? allowedCountryCodes,
    bool? showCountryName,
    bool? showCountryFlagInSelector,
    bool? showCountryIsoCodeInSelector,
    bool? showCountryDialCodeInSelector,
    double? countryMenuMaxHeight,
    String? nationalNumberHintText,
    double? sliderMin,
    double? sliderMax,
    int? sliderDivisions,
    String? sliderUnitLabel,
    FormFlutterSchemaFieldBuilder? fieldBuilder,
  }) {
    return FormFlutterSchemaField(
      preset: preset,
      name: name,
      kind: kind,
      label: label,
      helperText: helperText,
      hintText: hintText,
      description: description,
      options: options,
      isRequired: isRequired,
      validationNotes: validationNotes,
      initialValue: initialValue,
      validator: validator,
      asyncValidator: asyncValidator,
      decorationOverride: decorationOverride,
      textStyle: textStyle,
      maxLines: maxLines,
      countryFieldName: countryFieldName,
      initialCountryCode: initialCountryCode,
      allowedCountryCodes: allowedCountryCodes,
      showCountryName: showCountryName,
      showCountryFlagInSelector: showCountryFlagInSelector,
      showCountryIsoCodeInSelector: showCountryIsoCodeInSelector,
      showCountryDialCodeInSelector: showCountryDialCodeInSelector,
      countryMenuMaxHeight: countryMenuMaxHeight,
      nationalNumberHintText: nationalNumberHintText,
      sliderMin: sliderMin,
      sliderMax: sliderMax,
      sliderDivisions: sliderDivisions,
      sliderUnitLabel: sliderUnitLabel,
      fieldBuilder: fieldBuilder,
    );
  }

  /// Optional preset used as the base field definition.
  final FormFlutterFieldPreset? preset;

  /// Optional override for the field name.
  final String? name;

  /// Optional override for the field kind.
  final FormFlutterFieldKind? kind;

  /// Optional override for the field label.
  final String? label;

  /// Optional helper text used by the generated field widget.
  final String? helperText;

  /// Optional hint text used by generated input widgets.
  final String? hintText;

  /// Optional preset description override used when helper text is not provided.
  final String? description;

  /// Optional override for selectable options.
  final List<FormFlutterOption<String>>? options;

  /// Optional override for required behavior.
  final bool? isRequired;

  /// Optional override for preset validation notes.
  final List<String>? validationNotes;

  /// Optional initial value for this field.
  final Object? initialValue;

  /// Optional direct validator override.
  final FormFlutterValidator<dynamic>? validator;

  /// Optional direct async validator override.
  final FormFlutterAsyncValidator<dynamic>? asyncValidator;

  /// Optional decoration override passed to generated field widgets.
  final InputDecoration? decorationOverride;

  /// Optional text style override passed to generated field widgets.
  final TextStyle? textStyle;

  /// Optional max lines override for text and multiline fields.
  final int? maxLines;

  /// Optional country field name override for generated phone fields.
  final String? countryFieldName;

  /// Optional default country code for generated phone fields.
  final String? initialCountryCode;

  /// Optional country allow-list for generated phone fields.
  final List<String>? allowedCountryCodes;

  /// Optional flag for showing full country names in phone selectors.
  final bool? showCountryName;

  /// Optional flag for showing flags in phone selectors.
  final bool? showCountryFlagInSelector;

  /// Optional flag for showing ISO country codes in phone selectors.
  final bool? showCountryIsoCodeInSelector;

  /// Optional flag for showing dial codes in phone selectors.
  final bool? showCountryDialCodeInSelector;

  /// Optional max menu height for the phone country selector.
  final double? countryMenuMaxHeight;

  /// Optional hint text for the national number part of phone fields.
  final String? nationalNumberHintText;

  /// Optional minimum value override for generated slider fields.
  final double? sliderMin;

  /// Optional maximum value override for generated slider fields.
  final double? sliderMax;

  /// Optional divisions override for generated slider fields.
  final int? sliderDivisions;

  /// Optional unit label override for generated slider fields.
  final String? sliderUnitLabel;

  /// Optional builder override for this single schema field.
  final FormFlutterSchemaFieldBuilder? fieldBuilder;

  /// Whether this schema field defines an initial value.
  bool get hasInitialValue => !identical(initialValue, _formFlutterSchemaUnset);

  /// Returns the effective field name.
  String get resolvedName => name ?? preset!.key;

  /// Returns the effective field kind.
  FormFlutterFieldKind get resolvedKind => kind ?? preset!.kind;

  /// Returns the effective field label.
  String get resolvedLabel => label ?? preset!.label;

  /// Returns the effective helper text for generated widgets.
  String? get resolvedHelperText =>
      helperText ?? description ?? preset?.description;

  /// Returns the effective hint text for generated widgets.
  String? get resolvedHintText => hintText;

  /// Returns the effective option list.
  List<FormFlutterOption<String>> get resolvedOptions =>
      options ?? preset?.options ?? const [];

  /// Returns the effective required flag.
  bool get resolvedIsRequired => isRequired ?? preset?.isRequired ?? false;

  /// Returns the effective validation notes.
  List<String> get resolvedValidationNotes =>
      validationNotes ?? preset?.validationNotes ?? const [];

  /// Returns merged preset metadata for this schema field.
  FormFlutterFieldPreset toPreset() {
    return FormFlutterFieldPreset(
      key: resolvedName,
      label: resolvedLabel,
      kind: resolvedKind,
      category: preset?.category ?? FormFlutterFieldCategory.advanced,
      description: description ?? helperText ?? preset?.description,
      options: resolvedOptions,
      isRequired: resolvedIsRequired,
      validationNotes: resolvedValidationNotes,
    );
  }
}

class _ResolvedFieldConfig {
  const _ResolvedFieldConfig({
    required this.name,
    required this.label,
    required this.kind,
    required this.helperText,
    required this.hintText,
    required this.options,
    required this.isRequired,
    required this.validationNotes,
    required this.validator,
    required this.asyncValidator,
    required this.decorationOverride,
    required this.textStyle,
    required this.maxLines,
    required this.countryFieldName,
    required this.initialCountryCode,
    required this.allowedCountryCodes,
    required this.showCountryName,
    required this.showCountryFlagInSelector,
    required this.showCountryIsoCodeInSelector,
    required this.showCountryDialCodeInSelector,
    required this.countryMenuMaxHeight,
    required this.nationalNumberHintText,
    required this.sliderMin,
    required this.sliderMax,
    required this.sliderDivisions,
    required this.sliderUnitLabel,
  });

  factory _ResolvedFieldConfig.fromPreset(FormFlutterFieldPreset preset) {
    return _ResolvedFieldConfig(
      name: preset.key,
      label: preset.label,
      kind: preset.kind,
      helperText: preset.description,
      hintText: null,
      options: preset.options,
      isRequired: preset.isRequired,
      validationNotes: preset.validationNotes,
      validator: null,
      asyncValidator: null,
      decorationOverride: null,
      textStyle: null,
      maxLines: null,
      countryFieldName: null,
      initialCountryCode: null,
      allowedCountryCodes: null,
      showCountryName: null,
      showCountryFlagInSelector: null,
      showCountryIsoCodeInSelector: null,
      showCountryDialCodeInSelector: null,
      countryMenuMaxHeight: null,
      nationalNumberHintText: null,
      sliderMin: null,
      sliderMax: null,
      sliderDivisions: null,
      sliderUnitLabel: null,
    );
  }

  factory _ResolvedFieldConfig.fromSchema(FormFlutterSchemaField field) {
    return _ResolvedFieldConfig(
      name: field.resolvedName,
      label: field.resolvedLabel,
      kind: field.resolvedKind,
      helperText: field.resolvedHelperText,
      hintText: field.resolvedHintText,
      options: field.resolvedOptions,
      isRequired: field.resolvedIsRequired,
      validationNotes: field.resolvedValidationNotes,
      validator: field.validator,
      asyncValidator: field.asyncValidator,
      decorationOverride: field.decorationOverride,
      textStyle: field.textStyle,
      maxLines: field.maxLines,
      countryFieldName: field.countryFieldName,
      initialCountryCode: field.initialCountryCode,
      allowedCountryCodes: field.allowedCountryCodes,
      showCountryName: field.showCountryName,
      showCountryFlagInSelector: field.showCountryFlagInSelector,
      showCountryIsoCodeInSelector: field.showCountryIsoCodeInSelector,
      showCountryDialCodeInSelector: field.showCountryDialCodeInSelector,
      countryMenuMaxHeight: field.countryMenuMaxHeight,
      nationalNumberHintText: field.nationalNumberHintText,
      sliderMin: field.sliderMin,
      sliderMax: field.sliderMax,
      sliderDivisions: field.sliderDivisions,
      sliderUnitLabel: field.sliderUnitLabel,
    );
  }

  final String name;
  final String label;
  final FormFlutterFieldKind kind;
  final String? helperText;
  final String? hintText;
  final List<FormFlutterOption<String>> options;
  final bool isRequired;
  final List<String> validationNotes;
  final FormFlutterValidator<dynamic>? validator;
  final FormFlutterAsyncValidator<dynamic>? asyncValidator;
  final InputDecoration? decorationOverride;
  final TextStyle? textStyle;
  final int? maxLines;
  final String? countryFieldName;
  final String? initialCountryCode;
  final List<String>? allowedCountryCodes;
  final bool? showCountryName;
  final bool? showCountryFlagInSelector;
  final bool? showCountryIsoCodeInSelector;
  final bool? showCountryDialCodeInSelector;
  final double? countryMenuMaxHeight;
  final String? nationalNumberHintText;
  final double? sliderMin;
  final double? sliderMax;
  final int? sliderDivisions;
  final String? sliderUnitLabel;
}

/// Converts preset metadata and schema definitions into concrete field widgets.
class FormFlutterFieldFactory {
  /// Private constructor to prevent instantiation.
  const FormFlutterFieldFactory._();

  /// Builds a list of fields from preset metadata.
  static List<FormFlutterField<dynamic>> buildFieldsFromPresets(
    Iterable<FormFlutterFieldPreset> presets, {
    Map<String, FormFlutterPresetBuilder> buildersByKey = const {},
    Map<FormFlutterFieldKind, FormFlutterPresetBuilder> buildersByKind =
        const {},
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    filePicker,
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    imagePicker,
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

  /// Builds a single field from a preset definition.
  static FormFlutterField<dynamic> buildField(
    FormFlutterFieldPreset preset, {
    Map<String, FormFlutterPresetBuilder> buildersByKey = const {},
    Map<FormFlutterFieldKind, FormFlutterPresetBuilder> buildersByKind =
        const {},
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    filePicker,
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    imagePicker,
  }) {
    final keyBuilder = buildersByKey[preset.key];
    if (keyBuilder != null) {
      return keyBuilder(preset);
    }

    final kindBuilder = buildersByKind[preset.kind];
    if (kindBuilder != null) {
      return kindBuilder(preset);
    }

    return _buildFromConfig(
      _ResolvedFieldConfig.fromPreset(preset),
      filePicker: filePicker,
      imagePicker: imagePicker,
    );
  }

  /// Builds concrete sections from a schema definition.
  static List<FormFlutterSection> buildSectionsFromSchema(
    FormFlutterSchema schema, {
    Map<String, FormFlutterSchemaFieldBuilder> buildersByName = const {},
    Map<FormFlutterFieldKind, FormFlutterSchemaFieldBuilder> buildersByKind =
        const {},
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    filePicker,
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    imagePicker,
  }) {
    return [
      for (final section in schema.sections)
        FormFlutterSection(
          title: section.title,
          description: section.description,
          isVisible: section.isVisible,
          fields: [
            for (final field in section.fields)
              buildFieldFromSchema(
                field,
                buildersByName: buildersByName,
                buildersByKind: buildersByKind,
                filePicker: filePicker,
                imagePicker: imagePicker,
              ),
          ],
        ),
    ];
  }

  /// Builds a flat list of fields from a schema definition.
  static List<FormFlutterField<dynamic>> buildFieldsFromSchema(
    FormFlutterSchema schema, {
    Map<String, FormFlutterSchemaFieldBuilder> buildersByName = const {},
    Map<FormFlutterFieldKind, FormFlutterSchemaFieldBuilder> buildersByKind =
        const {},
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    filePicker,
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    imagePicker,
  }) {
    return [
      for (final section in schema.sections)
        for (final field in section.fields)
          buildFieldFromSchema(
            field,
            buildersByName: buildersByName,
            buildersByKind: buildersByKind,
            filePicker: filePicker,
            imagePicker: imagePicker,
          ),
    ];
  }

  /// Builds a single field from a schema definition.
  static FormFlutterField<dynamic> buildFieldFromSchema(
    FormFlutterSchemaField field, {
    Map<String, FormFlutterSchemaFieldBuilder> buildersByName = const {},
    Map<FormFlutterFieldKind, FormFlutterSchemaFieldBuilder> buildersByKind =
        const {},
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    filePicker,
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    imagePicker,
  }) {
    final preset = field.toPreset();

    if (field.fieldBuilder != null) {
      return field.fieldBuilder!(field, preset);
    }

    final nameBuilder = buildersByName[field.resolvedName];
    if (nameBuilder != null) {
      return nameBuilder(field, preset);
    }

    final kindBuilder = buildersByKind[field.resolvedKind];
    if (kindBuilder != null) {
      return kindBuilder(field, preset);
    }

    return _buildFromConfig(
      _ResolvedFieldConfig.fromSchema(field),
      filePicker: filePicker,
      imagePicker: imagePicker,
    );
  }

  /// Builds merged initial values from a schema.
  static Map<String, Object?> buildInitialValuesFromSchema(
    FormFlutterSchema schema,
  ) {
    final initialValues = Map<String, Object?>.from(schema.initialValues);
    for (final section in schema.sections) {
      for (final field in section.fields) {
        if (field.hasInitialValue) {
          initialValues[field.resolvedName] = field.initialValue;
        }
      }
    }
    return initialValues;
  }

  /// Builds a controller seeded from schema-level and field-level initial values.
  static FormFlutterController buildControllerFromSchema(
    FormFlutterSchema schema,
  ) {
    return FormFlutterController(
      initialValues: buildInitialValuesFromSchema(schema),
    );
  }

  static FormFlutterField<dynamic> _buildFromConfig(
    _ResolvedFieldConfig config, {
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    filePicker,
    Future<FormFlutterFileValue?> Function(
      BuildContext context,
      FormFlutterController controller,
    )?
    imagePicker,
  }) {
    switch (config.kind) {
      case FormFlutterFieldKind.email:
        return FormFlutterTextField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          keyboardType: TextInputType.emailAddress,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<String>(config.validator) ??
              _buildStringValidator(
                config,
                fallback: FormFlutterValidators.email(),
              ),
          asyncValidator: _castAsyncValidator<String>(config.asyncValidator),
        );
      case FormFlutterFieldKind.password:
        return FormFlutterTextField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          obscureText: true,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          enableObscureTextToggle: true,
          validator:
              _castValidator<String>(config.validator) ??
              _buildPasswordValidator(config),
          asyncValidator: _castAsyncValidator<String>(config.asyncValidator),
        );
      case FormFlutterFieldKind.phone:
        return FormFlutterPhoneField(
          name: config.name,
          label: config.label,
          countryFieldName: config.countryFieldName,
          initialCountryCode: config.initialCountryCode ?? 'US',
          allowedCountryCodes: config.allowedCountryCodes,
          showCountryName: config.showCountryName ?? false,
          showCountryFlagInSelector: config.showCountryFlagInSelector ?? false,
          showCountryIsoCodeInSelector:
              config.showCountryIsoCodeInSelector ?? true,
          showCountryDialCodeInSelector:
              config.showCountryDialCodeInSelector ?? true,
          countryMenuMaxHeight: config.countryMenuMaxHeight ?? 420,
          nationalNumberHintText: config.nationalNumberHintText,
          helperText: config.helperText,
          validator:
              _castValidator<String>(config.validator) ??
              _buildStringValidator(
                config,
                fallback: FormFlutterValidators.phone(),
              ),
          asyncValidator: _castAsyncValidator<String>(config.asyncValidator),
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
        );
      case FormFlutterFieldKind.url:
        return FormFlutterTextField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          keyboardType: TextInputType.url,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<String>(config.validator) ??
              _buildStringValidator(
                config,
                fallback: FormFlutterValidators.url(),
              ),
          asyncValidator: _castAsyncValidator<String>(config.asyncValidator),
        );
      case FormFlutterFieldKind.multiline:
        return FormFlutterTextField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          maxLines: config.maxLines ?? 4,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<String>(config.validator) ??
              _buildStringValidator(config),
          asyncValidator: _castAsyncValidator<String>(config.asyncValidator),
        );
      case FormFlutterFieldKind.number:
        return FormFlutterNumberField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<double?>(config.validator) ??
              _buildNumberValidator(config),
          asyncValidator: _castAsyncValidator<double?>(config.asyncValidator),
        );
      case FormFlutterFieldKind.dropdown:
        return FormFlutterDropdownField<String>(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          options: config.options,
          decorationOverride: config.decorationOverride,
          validator:
              _castValidator<String?>(config.validator) ??
              (config.isRequired
                  ? FormFlutterValidators.requiredSelection<String>()
                  : null),
          asyncValidator: _castAsyncValidator<String?>(config.asyncValidator),
        );
      case FormFlutterFieldKind.radio:
        return FormFlutterRadioGroupField<String>(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          options: config.options,
          decoration: config.decorationOverride,
          validator:
              _castValidator<String?>(config.validator) ??
              (config.isRequired
                  ? FormFlutterValidators.requiredSelection<String>()
                  : null),
          asyncValidator: _castAsyncValidator<String?>(config.asyncValidator),
        );
      case FormFlutterFieldKind.checkbox:
        return FormFlutterCheckboxField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          decoration: config.decorationOverride,
          titleStyle: config.textStyle,
          validator:
              _castValidator<bool>(config.validator) ??
              (config.isRequired ? FormFlutterValidators.mustBeTrue() : null),
          asyncValidator: _castAsyncValidator<bool>(config.asyncValidator),
        );
      case FormFlutterFieldKind.switchField:
        return FormFlutterSwitchField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          decoration: config.decorationOverride,
          titleStyle: config.textStyle,
          validator: _castValidator<bool>(config.validator),
          asyncValidator: _castAsyncValidator<bool>(config.asyncValidator),
        );
      case FormFlutterFieldKind.date:
        return FormFlutterDateField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<DateTime?>(config.validator) ??
              _buildDateValidator(config),
          asyncValidator: _castAsyncValidator<DateTime?>(config.asyncValidator),
        );
      case FormFlutterFieldKind.time:
        return FormFlutterTimeField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<TimeOfDay?>(config.validator) ??
              (config.isRequired ? FormFlutterValidators.requiredTime() : null),
          asyncValidator: _castAsyncValidator<TimeOfDay?>(
            config.asyncValidator,
          ),
        );
      case FormFlutterFieldKind.dateTime:
        return FormFlutterDateTimeField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<DateTime?>(config.validator) ??
              (config.isRequired ? FormFlutterValidators.requiredDate() : null),
          asyncValidator: _castAsyncValidator<DateTime?>(config.asyncValidator),
        );
      case FormFlutterFieldKind.slider:
        return FormFlutterSliderField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          min: config.sliderMin ?? 0,
          max: config.sliderMax ?? 100,
          divisions: config.sliderDivisions,
          unitLabel: config.sliderUnitLabel,
          decoration: config.decorationOverride,
          valueStyle: config.textStyle,
          validator: _castValidator<double>(config.validator),
          asyncValidator: _castAsyncValidator<double>(config.asyncValidator),
        );
      case FormFlutterFieldKind.multiSelect:
        return FormFlutterMultiSelectField<String>(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          options: config.options,
          decoration: config.decorationOverride,
          validator:
              _castValidator<List<String>>(config.validator) ??
              (config.isRequired
                  ? FormFlutterValidators.minItems<String>(1)
                  : null),
          asyncValidator: _castAsyncValidator<List<String>>(
            config.asyncValidator,
          ),
        );
      case FormFlutterFieldKind.otp:
        return FormFlutterOtpField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<String>(config.validator) ??
              (config.isRequired
                  ? FormFlutterPresetValidators.otp()
                  : FormFlutterValidators.conditional<String>(
                      (values) =>
                          (values.asMap()[config.name]?.toString() ?? '')
                              .isNotEmpty,
                      FormFlutterPresetValidators.otp(),
                    )),
          asyncValidator: _castAsyncValidator<String>(config.asyncValidator),
        );
      case FormFlutterFieldKind.search:
        return FormFlutterSearchField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<String>(config.validator) ??
              _buildStringValidator(config),
          asyncValidator: _castAsyncValidator<String>(config.asyncValidator),
        );
      case FormFlutterFieldKind.autocomplete:
        return FormFlutterAutocompleteField<String>(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          options: config.options.map((option) => option.value).toList(),
          decoration: config.decorationOverride,
          textStyle: config.textStyle,
          displayStringForOption: (option) {
            for (final item in config.options) {
              if (item.value == option) {
                return item.label;
              }
            }
            return option;
          },
          validator:
              _castValidator<String?>(config.validator) ??
              (config.isRequired
                  ? FormFlutterValidators.requiredSelection<String>()
                  : null),
          asyncValidator: _castAsyncValidator<String?>(config.asyncValidator),
        );
      case FormFlutterFieldKind.file:
        return FormFlutterFileField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          decoration: config.decorationOverride,
          onPick: filePicker ?? _noopPicker,
          pickerConfigured: filePicker != null,
          validator:
              _castValidator<FormFlutterFileValue?>(config.validator) ??
              _buildFileValidator(config),
          asyncValidator: _castAsyncValidator<FormFlutterFileValue?>(
            config.asyncValidator,
          ),
        );
      case FormFlutterFieldKind.image:
        return FormFlutterImageField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          decoration: config.decorationOverride,
          onPick: imagePicker ?? filePicker ?? _noopPicker,
          pickerConfigured: imagePicker != null || filePicker != null,
          validator:
              _castValidator<FormFlutterFileValue?>(config.validator) ??
              _buildFileValidator(config, imageOnlyByKind: true),
          asyncValidator: _castAsyncValidator<FormFlutterFileValue?>(
            config.asyncValidator,
          ),
        );
      case FormFlutterFieldKind.signature:
        return FormFlutterSignatureField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          decoration: config.decorationOverride,
          validator:
              _castValidator<List<List<Offset>>>(config.validator) ??
              (config.isRequired
                  ? FormFlutterValidators.requiredValue<List<List<Offset>>>()
                  : null),
          asyncValidator: _castAsyncValidator<List<List<Offset>>>(
            config.asyncValidator,
          ),
        );
      case FormFlutterFieldKind.text:
        return FormFlutterTextField(
          name: config.name,
          label: config.label,
          helperText: config.helperText,
          hintText: config.hintText,
          decorationOverride: config.decorationOverride,
          textStyle: config.textStyle,
          validator:
              _castValidator<String>(config.validator) ??
              _buildStringValidator(config),
          asyncValidator: _castAsyncValidator<String>(config.asyncValidator),
        );
    }
  }

  static bool _hasValidationNote(_ResolvedFieldConfig config, String fragment) {
    final needle = fragment.toLowerCase();
    return config.validationNotes.any(
      (note) => note.toLowerCase().contains(needle),
    );
  }

  static bool _isRequired(_ResolvedFieldConfig config) {
    return config.isRequired || _hasValidationNote(config, 'required');
  }

  static FormFlutterValidator<String>? _buildPasswordValidator(
    _ResolvedFieldConfig config,
  ) {
    if (_hasValidationNote(config, 'match another field')) {
      final validators = <FormFlutterValidator<String>>[];
      if (_isRequired(config)) {
        validators.add(FormFlutterValidators.requiredText());
      }
      validators.add(
        FormFlutterValidators.sameAsField(
          _inferMatchingFieldName(config.name),
          message: 'Passwords do not match.',
        ),
      );
      return FormFlutterValidators.combine(validators);
    }

    if (_hasValidationNote(config, 'password strength')) {
      return FormFlutterPresetValidators.password();
    }

    return _buildStringValidator(config);
  }

  static FormFlutterValidator<double?>? _buildNumberValidator(
    _ResolvedFieldConfig config,
  ) {
    final validators = <FormFlutterValidator<double?>>[];
    if (_isRequired(config)) {
      validators.add(FormFlutterValidators.requiredNumber());
    }
    if (_hasValidationNote(config, 'min value')) {
      validators.add(FormFlutterValidators.minNumber(0));
    }
    if (_hasValidationNote(config, 'max value')) {
      validators.add(FormFlutterValidators.maxNumber(100));
    }
    if (validators.isEmpty) {
      return null;
    }
    return FormFlutterValidators.combine(validators);
  }

  static FormFlutterValidator<DateTime?>? _buildDateValidator(
    _ResolvedFieldConfig config,
  ) {
    final validators = <FormFlutterValidator<DateTime?>>[];
    if (_isRequired(config)) {
      validators.add(FormFlutterValidators.requiredDate());
    }
    if (_hasValidationNote(config, 'minimum age')) {
      validators.add(FormFlutterValidators.minimumAge(18));
    }
    if (validators.isEmpty) {
      return null;
    }
    return FormFlutterValidators.combine(validators);
  }

  static FormFlutterValidator<FormFlutterFileValue?>? _buildFileValidator(
    _ResolvedFieldConfig config, {
    bool imageOnlyByKind = false,
  }) {
    final validators = <FormFlutterValidator<FormFlutterFileValue?>>[];
    if (_isRequired(config)) {
      validators.add(FormFlutterValidators.requiredFile());
    }
    if (_hasValidationNote(config, 'file size limit')) {
      validators.add(FormFlutterValidators.fileSize(5 * 1024 * 1024));
    }
    if (imageOnlyByKind) {
      validators.add(FormFlutterValidators.imageOnly());
    } else if (_hasValidationNote(config, 'file type restriction')) {
      validators.add(
        FormFlutterValidators.fileExtension(['pdf', 'doc', 'docx']),
      );
    }
    if (validators.isEmpty) {
      return null;
    }
    return FormFlutterValidators.combine(validators);
  }

  static String _inferMatchingFieldName(String fieldName) {
    if (fieldName.startsWith('confirm_')) {
      return fieldName.substring('confirm_'.length);
    }
    if (fieldName.startsWith('confirm')) {
      final suffix = fieldName.substring('confirm'.length);
      if (suffix.isEmpty) {
        return 'password';
      }
      final lowerFirst = suffix[0].toLowerCase() + suffix.substring(1);
      return lowerFirst.startsWith('_') ? lowerFirst.substring(1) : lowerFirst;
    }
    return 'password';
  }

  static FormFlutterValidator<T>? _castValidator<T>(
    FormFlutterValidator<dynamic>? validator,
  ) {
    if (validator == null) {
      return null;
    }
    return (value, values) => validator(value, values);
  }

  static FormFlutterAsyncValidator<T>? _castAsyncValidator<T>(
    FormFlutterAsyncValidator<dynamic>? validator,
  ) {
    if (validator == null) {
      return null;
    }
    return (value, values) => validator(value, values);
  }

  static FormFlutterValidator<String>? _buildStringValidator(
    _ResolvedFieldConfig config, {
    FormFlutterValidator<String>? fallback,
  }) {
    final validators = <FormFlutterValidator<String>>[];
    if (_isRequired(config)) {
      validators.add(FormFlutterValidators.requiredText());
    }

    if (_hasValidationNote(config, 'email')) {
      validators.add(FormFlutterValidators.email());
    }
    if (_hasValidationNote(config, 'url')) {
      validators.add(FormFlutterValidators.url());
    }
    if (_hasValidationNote(config, 'minimum length')) {
      validators.add(FormFlutterValidators.minLength(3));
    }
    if (_hasValidationNote(config, 'exact length')) {
      validators.add(FormFlutterValidators.exactLength(6));
    }
    if (_hasValidationNote(config, 'number only')) {
      validators.add(FormFlutterValidators.numericText());
    }
    if (_hasValidationNote(config, 'regex pattern')) {
      final postalLike =
          config.name.contains('postal') || config.name.contains('zip');
      if (postalLike) {
        validators.add(
          FormFlutterValidators.pattern(
            RegExp(r'^[A-Za-z0-9 -]{3,12}$'),
            message: 'Enter a valid postal code.',
          ),
        );
      }
    }
    if (_hasValidationNote(config, 'match another field')) {
      validators.add(
        FormFlutterValidators.sameAsField(_inferMatchingFieldName(config.name)),
      );
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
