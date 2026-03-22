# form_flutter

A Flutter package for building reusable, schema-friendly forms with shared validation, common field widgets, and preset field catalogs.

## Features

- Reusable form controller for values, errors, and async validation state
- Common field widgets for text, password, multiline, number, dropdown, radio, checkbox, switch, date, time, date-time, slider, and multi-select
- Sync and async validators for text, numbers, dates, files, conditional rules, and uniqueness checks
- Preset field catalog for personal, contact, address, account, academic, professional, survey, commerce, appointment, and consent flows
- Common option sets for fields like gender, marital status, degree, employment type, payment method, and more

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  form_flutter: ^1.0.0
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

For a complete runnable sample, see [`example/lib/main.dart`](example/lib/main.dart).

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

This package includes a dedicated `example/` app for pub.dev example points, and the root app in `lib/main.dart` acts as a local full-form playground with styling, colored options, and broader customization examples.
