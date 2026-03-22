# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and follows the versioning used by the package.

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
