# form_flutter

A Flutter package for building reusable, schema-friendly forms with shared validation, common field widgets, and preset field catalogs.

## Features

- Reusable form controller for values, errors, async validation state, serialization, reset flows, and touched or dirty tracking
- Common field widgets for text, password, multiline, number, phone, country, dropdown, radio, checkbox, switch, date, time, date-time, slider, and multi-select
- Sync and async validators for text, numbers, dates, files, conditional rules, and uniqueness checks
- Preset field catalog for personal, contact, address, account, academic, professional, survey, commerce, appointment, and consent flows
- Schema builder helpers for turning presets and schema definitions into full sections, controllers, and generated fields with per-field overrides
- Common option sets for fields like gender, marital status, degree, employment type, payment method, and more
- Dedicated example app and local playground demonstrating controller export, import, reset, live state previews, and schema-generated forms

## What's New In 1.0.2

- Text and number inputs now stay visually in sync when values are changed through controller helpers like `fromJson(...)` and `reset(...)`
- `DynamicFormFlutter` autovalidation now revalidates touched dependent fields, improving flows like confirm-password checks when source values change
- `device_preview` is now demo-only in `example/`, keeping the package runtime dependency surface cleaner

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  form_flutter: ^1.0.2
```

Then run:

```bash
flutter pub get
```

## Usage

Import the package:

```dart
import 'package:form_flutter/form_flutter.dart';
```

Create a controller and define your fields:

```dart
final controller = FormFlutterController(
  initialValues: const {
    'fullName': '',
    'email': '',
    'phone': '',
    'phoneCountry': 'US',
    'team': 'product',
    'acceptTerms': false,
  },
);

final fields = <FormFlutterField<dynamic>>[
  FormFlutterTextField(
    name: 'fullName',
    label: 'Full name',
    validator: FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.minLength(3),
    ]),
  ),
  FormFlutterTextField(
    name: 'email',
    label: 'Email',
    keyboardType: TextInputType.emailAddress,
    validator: FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.email(),
    ]),
    asyncValidator: FormFlutterValidators.uniqueEmail(
      (email, _) async => email != 'taken@example.com',
    ),
  ),
  FormFlutterPhoneField(
    name: 'phone',
    label: 'Phone',
    countryFieldName: 'phoneCountry',
    validator: FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.numericText(),
    ]),
  ),
  FormFlutterDropdownField<String>(
    name: 'team',
    label: 'Team',
    options: const [
      FormFlutterOption(value: 'design', label: 'Design'),
      FormFlutterOption(value: 'product', label: 'Product'),
      FormFlutterOption(value: 'engineering', label: 'Engineering'),
    ],
    validator: FormFlutterValidators.requiredSelection<String>(),
  ),
  FormFlutterCheckboxField(
    name: 'acceptTerms',
    label: 'I agree to the Terms and Conditions',
    validator: FormFlutterValidators.mustBeTrue(),
  ),
];
```

Render them with `DynamicFormFlutter`:

```dart
DynamicFormFlutter(
  controller: controller,
  fields: fields,
  submitLabel: 'Submit',
  onSubmit: (values) {
    debugPrint('Submitted: ${values.asMap()}');
  },
)
```

### Quick Example

```dart
class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final controller = FormFlutterController(
    initialValues: const {
      'fullName': '',
      'email': '',
      'phone': '',
      'phoneCountry': 'US',
      'newsletter': true,
    },
  );

  late final fields = <FormFlutterField<dynamic>>[
    FormFlutterTextField(
      name: 'fullName',
      label: 'Full name',
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.minLength(3),
      ]),
    ),
    FormFlutterTextField(
      name: 'email',
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: FormFlutterPresetValidators.emailAddress(),
    ),
    FormFlutterPhoneField(
      name: 'phone',
      label: 'Phone',
      countryFieldName: 'phoneCountry',
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.numericText(),
      ]),
    ),
    FormFlutterSwitchField(
      name: 'newsletter',
      label: 'Receive product updates',
    ),
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicFormFlutter(
      controller: controller,
      fields: fields,
      submitLabel: 'Create account',
      onSubmit: (values) {
        final json = controller.toJson();
        debugPrint('Submitted values: ${values.asMap()}');
        debugPrint('Serialized snapshot: $json');
      },
    );
  }
}
```

For complete runnable samples, see [`example/lib/main.dart`](example/lib/main.dart) and [`lib/main.dart`](lib/main.dart).

## Schema builder

You can also generate a full form from schema definitions and preset metadata.

```dart
final schema = FormFlutterSchema(
  initialValues: const {
    'phoneCountry': 'US',
    'newsletter': true,
  },
  sections: [
    FormFlutterSchemaSection(
      title: 'Account',
      description: 'Create the basics once and override only what this screen needs.',
      fields: [
        FormFlutterSchemaField.fromPreset(
          FormFlutterCatalog.accountFields.firstWhere(
            (preset) => preset.key == 'username',
          ),
          label: 'Public username',
          helperText: 'Shown on your profile.',
          hintText: '@ada',
          initialValue: 'ada',
          decorationOverride: const InputDecoration(prefixIcon: Icon(Icons.alternate_email)),
        ),
        FormFlutterSchemaField.fromPreset(
          FormFlutterCatalog.contactInformation.firstWhere(
            (preset) => preset.key == 'phone',
          ),
          countryFieldName: 'phoneCountry',
          allowedCountryCodes: const ['US', 'CA'],
          nationalNumberHintText: '5551234567',
        ),
      ],
    ),
    const FormFlutterSchemaSection(
      title: 'Preferences',
      fields: [
        FormFlutterSchemaField(
          name: 'experience',
          kind: FormFlutterFieldKind.slider,
          label: 'Experience',
          sliderMin: 1,
          sliderMax: 10,
          sliderDivisions: 9,
          sliderUnitLabel: 'years',
        ),
      ],
    ),
  ],
);

final controller = FormFlutterFieldFactory.buildControllerFromSchema(schema);
final sections = FormFlutterFieldFactory.buildSectionsFromSchema(schema);

DynamicFormFlutter(
  controller: controller,
  fields: const [],
  sections: sections,
  onSubmit: (values) {
    debugPrint('Schema submit: ${values.asMap()}');
  },
)
```

Schema helpers include:

- `FormFlutterSchema`, `FormFlutterSchemaSection`, and `FormFlutterSchemaField`
- `FormFlutterSchemaField.fromPreset(...)` for merging preset defaults with screen-specific overrides
- `FormFlutterFieldFactory.buildFieldsFromSchema(...)` for flat forms
- `FormFlutterFieldFactory.buildSectionsFromSchema(...)` for sectioned or stepper forms
- `FormFlutterFieldFactory.buildInitialValuesFromSchema(...)` and `buildControllerFromSchema(...)` for form state setup
- typed overrides like `label`, `helperText`, `hintText`, `options`, `validator`, `asyncValidator`, phone-country config, slider ranges, `decorationOverride`, and `textStyle`

## Controller helpers

`FormFlutterController` now includes state and serialization helpers for real-world form flows.

```dart
final snapshot = controller.toJson();

controller.fromJson(snapshot);
controller.reset();
controller.resetField('email');

final isEmailTouched = controller.isTouched('email');
final isEmailDirty = controller.isDirty('email');
final hasUnsavedChanges = controller.hasDirtyFields;
```

Available controller helpers include:

- `toJson` and `fromJson` for serializing and restoring values
- `reset` and `resetField` for full-form and per-field reset flows
- `isTouched`, `isDirty`, `hasTouchedFields`, and `hasDirtyFields` for change tracking
- `touchedFieldsListenable` and `dirtyFieldsListenable` for reactive UI updates
- `valuesListenable`, `errorsListenable`, and `asyncStatesListenable` for controller-driven widgets

Serialization notes:

- `DateTime` values are exported with a tagged JSON object and restored automatically
- `TimeOfDay` values are exported with a tagged JSON object and restored automatically
- `FormFlutterFileValue` values are exported with name, size, extension, and MIME metadata

## API overview

| Area | Main APIs |
| --- | --- |
| Controller | `FormFlutterController`, `FormFlutterValues` |
| Form widget | `DynamicFormFlutter` |
| Text-like fields | `FormFlutterTextField`, `FormFlutterNumberField`, `FormFlutterPhoneField`, `FormFlutterCountryField` |
| Choice fields | `FormFlutterDropdownField`, `FormFlutterRadioGroupField`, `FormFlutterMultiSelectField` |
| Toggle fields | `FormFlutterCheckboxField`, `FormFlutterSwitchField` |
| Date and time fields | `FormFlutterDateField`, `FormFlutterTimeField`, `FormFlutterDateTimeField` |
| Range fields | `FormFlutterSliderField` |
| Validators | `FormFlutterValidators`, `FormFlutterPresetValidators` |
| Catalog and presets | `FormFlutterCatalog`, `FormFlutterOptionSets`, `FormFlutterFieldPreset` |
| Schema builder | `FormFlutterSchema`, `FormFlutterSchemaSection`, `FormFlutterSchemaField`, `FormFlutterFieldFactory` |
| Supporting models | `FormFlutterOption`, `FormFlutterFileValue` |

Typical flow:

1. Create a `FormFlutterController` with `initialValues`.
2. Define a list of `FormFlutterField<dynamic>` widgets.
3. Attach validators and async validators where needed.
4. Render everything with `DynamicFormFlutter`.
5. Read `values.asMap()` on submit or persist with `controller.toJson()`.

## Styling and customization

You can customize field visuals at both the field level and the option level.

Field customization example:

```dart
FormFlutterTextField(
  name: 'fullName',
  label: 'Full name',
  decorationOverride: InputDecoration(
    prefixIcon: const Icon(Icons.person_outline),
    fillColor: const Color(0xFFF8FBFF),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
    ),
  ),
  textStyle: const TextStyle(
    fontWeight: FontWeight.w600,
  ),
)
```

Option customization example:

```dart
FormFlutterDropdownField<String>(
  name: 'team',
  label: 'Team',
  options: const [
    FormFlutterOption(
      value: 'design',
      label: 'Design',
      color: Color(0xFF7C3AED),
      icon: Icons.brush_outlined,
      indicatorSize: 16,
    ),
    FormFlutterOption(
      value: 'engineering',
      label: 'Engineering',
      color: Color(0xFF2563EB),
      icon: Icons.code,
      indicatorSize: 16,
    ),
  ],
)
```

Multi-select fields also support a full custom option builder:

```dart
FormFlutterMultiSelectField<String>(
  name: 'interests',
  label: 'Interests',
  options: const [
    FormFlutterOption(
      value: 'analytics',
      label: 'Analytics',
      color: Color(0xFFDC2626),
      backgroundColor: Color(0xFFFEF2F2),
      selectedColor: Color(0xFFDC2626),
      selectedTextColor: Colors.white,
      icon: Icons.monitoring_outlined,
    ),
  ],
  optionBuilder: (context, option, isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (option.selectedColor ?? option.color ?? Colors.blue)
            : (option.backgroundColor ?? Colors.white),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: option.borderColor ?? option.color ?? const Color(0xFFD0D5DD),
        ),
      ),
      child: Text(option.label),
    );
  },
)
```

Available visual controls include:

- `decorationOverride` and `textStyle` for text/date/time-like fields
- `decoration`, `titleStyle`, `activeColor`, `checkColor`, `thumbColor`, and `trackColor` for toggle-style fields
- `activeColor`, `inactiveColor`, `thumbColor`, and `valueStyle` for sliders
- `color`, `backgroundColor`, `selectedColor`, `textColor`, `selectedTextColor`, `borderColor`, `indicatorSize`, and `icon` for options
- `optionBuilder` for custom dropdown, radio, and multi-select option rendering

## Validators

Available validator helpers include:

- `requiredText`, `requiredNumber`, `requiredSelection`, `requiredDate`, `requiredTime`, `requiredValue`
- `email`, `phone`, `url`, `numericText`, `pattern`
- `minLength`, `maxLength`, `exactLength`
- `minNumber`, `maxNumber`
- `minDate`, `maxDate`, `minimumAge`
- `sameAsField`, `requiredIf`, `conditional`
- `minItems`, `maxItems`
- `requiredFile`, `fileSize`, `fileExtension`, `imageOnly`
- `strongPassword`, `mediumPassword`, `highStrengthPassword`
- `uniqueValue`, `uniqueUsername`, `uniqueEmail`
- `combine`, `combineAsync`, `custom`

Preset validator helpers also include:

- `FormFlutterPresetValidators.emailAddress()`
- `FormFlutterPresetValidators.phoneNumber()`
- `FormFlutterPresetValidators.password()`
- `FormFlutterPresetValidators.strongPassword()`
- `FormFlutterPresetValidators.highStrengthPassword()`
- `FormFlutterPresetValidators.confirmPassword()`
- `FormFlutterPresetValidators.otp()`
- `FormFlutterPresetValidators.uniqueUsername()`
- `FormFlutterPresetValidators.uniqueEmail()`

## Preset catalog

`form_flutter` includes metadata presets and option sets to help build real-world forms faster.

Examples:

- `FormFlutterCatalog.personalInformation`
- `FormFlutterCatalog.contactInformation`
- `FormFlutterCatalog.addressInformation`
- `FormFlutterCatalog.accountFields`
- `FormFlutterCatalog.professionalFields`
- `FormFlutterCatalog.appointmentFields`
- `FormFlutterCatalog.consentFields`

Examples of shared option sets:

- `FormFlutterOptionSets.gender`
- `FormFlutterOptionSets.maritalStatus`
- `FormFlutterOptionSets.degrees`
- `FormFlutterOptionSets.employmentTypes`
- `FormFlutterOptionSets.paymentMethods`

## Additional information

This package includes:

- a dedicated `example/` app for pub.dev example points
- optional demo tooling (`device_preview`) scoped to `example/` only
- a root app in `lib/main.dart` that acts as a local full-form playground
- live examples of controller export, import, reset, touched or dirty state previews, and schema-generated forms
- controller tests covering serialization, reset behavior, and field-state tracking

If you want to explore the most complete demos, start with [`example/lib/main.dart`](example/lib/main.dart) and [`lib/main.dart`](lib/main.dart).
