# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and follows the versioning used by the package.

## 0.2.0

- Improved release readiness with broader dartdoc coverage across the public API
- Hardened controller serialization with explicit tagged `DateTime` encoding and optional legacy date-string decoding
- Improved dynamic form async-validation handling for field lists built as `FormFlutterField<dynamic>`
- Modernized core field behavior and reduced technical debt in form widgets
- Expanded test coverage for controller serialization, reset flows, async validation, section visibility, and stepper flows
- Verified the package with clean `flutter analyze`, passing tests, and `pub publish --dry-run`

## 0.1.0

- Added controller serialization helpers with `toJson()` and `fromJson()` support for form values, `DateTime`, `TimeOfDay`, and `FormFlutterFileValue`
- Added controller state-management helpers for `reset()`, `resetField()`, touched tracking, dirty tracking, and listenables for touched/dirty field state
- Added focused controller tests covering serialization, reset behavior, and touched/dirty tracking
- Updated the package playground and example app to demonstrate export, import, reset, and live touched/dirty state previews

## 0.0.2

- Added country-aware phone input with dial-code selection, digit limiting, and allowed-country filtering
- Added full country dataset with flags, ISO codes, and dial codes
- Added searchable country picker with live keyboard filtering and result sorting
- Added reusable `FormFlutterCountryField` for standalone country selection
- Improved dropdown and radio selected-state rendering for better readability and fewer layout issues
- Updated local and example apps to demonstrate country selection and phone-field improvements

## 0.0.1

- Initial package foundation for `form_flutter`
- Added `FormFlutterController` for centralized form values and error handling
- Added reusable field widgets for text, password, multiline, number, dropdown, radio, checkbox, switch, date, time, date-time, slider, and multi-select
- Added synchronous validators for text, numeric, date, conditional, file, and password-strength rules
- Added asynchronous validation support for unique username/email and other submit-time checks
- Added `FormFlutterCatalog` and `FormFlutterOptionSets` for reusable field presets and shared dropdown/radio options
- Added demo usage in `lib/main.dart`
