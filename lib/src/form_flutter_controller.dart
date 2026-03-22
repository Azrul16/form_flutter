import 'package:flutter/foundation.dart';

class FormFlutterValues {
  const FormFlutterValues(this._values);

  final Map<String, Object?> _values;

  T value<T>(String name) {
    return _values[name] as T;
  }

  Map<String, Object?> asMap() {
    return Map<String, Object?>.unmodifiable(_values);
  }
}

class FormFlutterController {
  FormFlutterController({Map<String, Object?> initialValues = const {}})
      : _values = ValueNotifier<Map<String, Object?>>(
          Map<String, Object?>.from(initialValues),
        ),
        _errors = ValueNotifier<Map<String, String?>>(
          <String, String?>{},
        ),
        _asyncStates = ValueNotifier<Map<String, bool>>(
          <String, bool>{},
        );

  final ValueNotifier<Map<String, Object?>> _values;
  final ValueNotifier<Map<String, String?>> _errors;
  final ValueNotifier<Map<String, bool>> _asyncStates;

  ValueListenable<Map<String, Object?>> get valuesListenable => _values;
  ValueListenable<Map<String, String?>> get errorsListenable => _errors;
  ValueListenable<Map<String, bool>> get asyncStatesListenable => _asyncStates;

  FormFlutterValues get snapshot => FormFlutterValues(_values.value);

  T value<T>(String name) {
    return _values.value[name] as T;
  }

  String? error(String name) {
    return _errors.value[name];
  }

  bool isAsyncValidating(String name) {
    return _asyncStates.value[name] ?? false;
  }

  void setValue(String name, Object? value) {
    _values.value = Map<String, Object?>.from(_values.value)..[name] = value;
  }

  void setError(String name, String? error) {
    _errors.value = Map<String, String?>.from(_errors.value)..[name] = error;
  }

  void clearErrors() {
    _errors.value = <String, String?>{};
  }

  void setAsyncValidating(String name, bool isValidating) {
    _asyncStates.value = Map<String, bool>.from(_asyncStates.value)
      ..[name] = isValidating;
  }

  void dispose() {
    _values.dispose();
    _errors.dispose();
    _asyncStates.dispose();
  }
}
