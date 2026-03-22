import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show TimeOfDay;

import 'form_flutter_field.dart' show FormFlutterFileValue;

class FormFlutterValues {
  const FormFlutterValues(this._values);

  final Map<String, Object?> _values;

  T value<T>(String name) {
    return _values[name] as T;
  }

  Map<String, Object?> asMap() {
    return Map<String, Object?>.unmodifiable(_values);
  }

  Map<String, Object?> toJson() {
    return _serializeMap(_values);
  }
}

class FormFlutterController {
  FormFlutterController({Map<String, Object?> initialValues = const {}})
      : _initialValues = Map<String, Object?>.from(initialValues),
        _values = ValueNotifier<Map<String, Object?>>(
          Map<String, Object?>.from(initialValues),
        ),
        _errors = ValueNotifier<Map<String, String?>>(
          <String, String?>{},
        ),
        _asyncStates = ValueNotifier<Map<String, bool>>(
          <String, bool>{},
        ),
        _touchedFields = ValueNotifier<Map<String, bool>>(
          <String, bool>{},
        ),
        _dirtyFields = ValueNotifier<Map<String, bool>>(
          <String, bool>{},
        );

  Map<String, Object?> _initialValues;
  final ValueNotifier<Map<String, Object?>> _values;
  final ValueNotifier<Map<String, String?>> _errors;
  final ValueNotifier<Map<String, bool>> _asyncStates;
  final ValueNotifier<Map<String, bool>> _touchedFields;
  final ValueNotifier<Map<String, bool>> _dirtyFields;

  ValueListenable<Map<String, Object?>> get valuesListenable => _values;
  ValueListenable<Map<String, String?>> get errorsListenable => _errors;
  ValueListenable<Map<String, bool>> get asyncStatesListenable => _asyncStates;
  ValueListenable<Map<String, bool>> get touchedFieldsListenable =>
      _touchedFields;
  ValueListenable<Map<String, bool>> get dirtyFieldsListenable => _dirtyFields;

  FormFlutterValues get snapshot => FormFlutterValues(_values.value);

  Map<String, Object?> get initialValues {
    return Map<String, Object?>.unmodifiable(_initialValues);
  }

  T value<T>(String name) {
    return _values.value[name] as T;
  }

  String? error(String name) {
    return _errors.value[name];
  }

  bool isAsyncValidating(String name) {
    return _asyncStates.value[name] ?? false;
  }

  bool isTouched(String name) {
    return _touchedFields.value[name] ?? false;
  }

  bool isDirty(String name) {
    return _dirtyFields.value[name] ?? false;
  }

  bool get hasTouchedFields {
    return _touchedFields.value.containsValue(true);
  }

  bool get hasDirtyFields {
    return _dirtyFields.value.containsValue(true);
  }

  void setValue(String name, Object? value) {
    _values.value = Map<String, Object?>.from(_values.value)..[name] = value;
    _touchedFields.value = Map<String, bool>.from(_touchedFields.value)
      ..[name] = true;
    _dirtyFields.value = Map<String, bool>.from(_dirtyFields.value)
      ..[name] = !_deepEquals(_initialValues[name], value);
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

  void markTouched(String name, [bool touched = true]) {
    _touchedFields.value = Map<String, bool>.from(_touchedFields.value)
      ..[name] = touched;
  }

  void clearTouched() {
    _touchedFields.value = <String, bool>{};
  }

  void clearDirty() {
    _dirtyFields.value = <String, bool>{};
  }

  Map<String, Object?> toJson() {
    return snapshot.toJson();
  }

  void fromJson(
    Map<String, Object?> json, {
    bool merge = false,
    bool markAsInitial = false,
    bool clearErrors = true,
    bool clearAsyncStates = true,
    bool clearTouched = true,
  }) {
    final decoded = _deserializeMap(json);
    final nextValues = merge
        ? (Map<String, Object?>.from(_values.value)..addAll(decoded))
        : decoded;

    _values.value = nextValues;

    if (markAsInitial) {
      _initialValues = Map<String, Object?>.from(nextValues);
      _dirtyFields.value = <String, bool>{};
    } else {
      _dirtyFields.value = _computeDirtyFields(nextValues, _initialValues);
    }

    if (clearTouched) {
      _touchedFields.value = <String, bool>{};
    }
    if (clearErrors) {
      this.clearErrors();
    }
    if (clearAsyncStates) {
      _asyncStates.value = <String, bool>{};
    }
  }

  void reset({
    Map<String, Object?>? values,
    bool clearErrors = true,
    bool clearAsyncStates = true,
  }) {
    final nextValues = values == null
        ? Map<String, Object?>.from(_initialValues)
        : Map<String, Object?>.from(values);

    _values.value = nextValues;
    _touchedFields.value = <String, bool>{};
    _dirtyFields.value = values == null
        ? <String, bool>{}
        : _computeDirtyFields(nextValues, _initialValues);

    if (clearErrors) {
      this.clearErrors();
    }
    if (clearAsyncStates) {
      _asyncStates.value = <String, bool>{};
    }
  }

  void resetField(String name) {
    _values.value = Map<String, Object?>.from(_values.value)
      ..[name] = _initialValues[name];
    _errors.value = Map<String, String?>.from(_errors.value)..remove(name);
    _asyncStates.value = Map<String, bool>.from(_asyncStates.value)
      ..remove(name);
    _touchedFields.value = Map<String, bool>.from(_touchedFields.value)
      ..remove(name);
    _dirtyFields.value = Map<String, bool>.from(_dirtyFields.value)
      ..remove(name);
  }

  void dispose() {
    _values.dispose();
    _errors.dispose();
    _asyncStates.dispose();
    _touchedFields.dispose();
    _dirtyFields.dispose();
  }
}

Map<String, Object?> _serializeMap(Map<String, Object?> value) {
  return value.map(
    (key, entry) => MapEntry(key, _serializeValue(entry)),
  );
}

Object? _serializeValue(Object? value) {
  if (value is DateTime) {
    return value.toIso8601String();
  }
  if (value is TimeOfDay) {
    return <String, Object?>{
      '__form_flutter_type': 'time_of_day',
      'hour': value.hour,
      'minute': value.minute,
    };
  }
  if (value is FormFlutterFileValue) {
    return <String, Object?>{
      '__form_flutter_type': 'file',
      'name': value.name,
      'sizeInBytes': value.sizeInBytes,
      'extension': value.extension,
      'mimeType': value.mimeType,
    };
  }
  if (value is Map<String, Object?>) {
    return _serializeMap(value);
  }
  if (value is Map) {
    return value.map(
      (key, entry) => MapEntry(key.toString(), _serializeValue(entry)),
    );
  }
  if (value is Iterable) {
    return value.map(_serializeValue).toList(growable: false);
  }
  return value;
}

Map<String, Object?> _deserializeMap(Map<String, Object?> value) {
  return value.map(
    (key, entry) => MapEntry(key, _deserializeValue(entry)),
  );
}

Object? _deserializeValue(Object? value) {
  if (value is Map<String, Object?>) {
    final taggedType = value['__form_flutter_type'];
    if (taggedType == 'time_of_day') {
      return TimeOfDay(
        hour: (value['hour'] as num?)?.toInt() ?? 0,
        minute: (value['minute'] as num?)?.toInt() ?? 0,
      );
    }
    if (taggedType == 'file') {
      return FormFlutterFileValue(
        name: value['name']?.toString() ?? '',
        sizeInBytes: (value['sizeInBytes'] as num?)?.toInt() ?? 0,
        extension: value['extension']?.toString(),
        mimeType: value['mimeType']?.toString(),
      );
    }
    return _deserializeMap(value);
  }
  if (value is Map) {
    return _deserializeMap(
      value.map(
        (key, entry) => MapEntry(key.toString(), entry),
      ),
    );
  }
  if (value is List) {
    return value.map(_deserializeValue).toList(growable: false);
  }
  if (value is String) {
    final parsedDateTime = DateTime.tryParse(value);
    if (parsedDateTime != null && _looksLikeIsoDate(value)) {
      return parsedDateTime;
    }
  }
  return value;
}

Map<String, bool> _computeDirtyFields(
  Map<String, Object?> values,
  Map<String, Object?> initialValues,
) {
  final allKeys = <String>{
    ...values.keys,
    ...initialValues.keys,
  };
  final dirty = <String, bool>{};
  for (final key in allKeys) {
    if (!_deepEquals(values[key], initialValues[key])) {
      dirty[key] = true;
    }
  }
  return dirty;
}

bool _looksLikeIsoDate(String value) {
  return value.contains('-') && value.contains(':');
}

bool _deepEquals(Object? left, Object? right) {
  if (identical(left, right)) {
    return true;
  }
  if (left is List && right is List) {
    if (left.length != right.length) {
      return false;
    }
    for (var i = 0; i < left.length; i++) {
      if (!_deepEquals(left[i], right[i])) {
        return false;
      }
    }
    return true;
  }
  if (left is Map && right is Map) {
    if (left.length != right.length) {
      return false;
    }
    for (final entry in left.entries) {
      if (!right.containsKey(entry.key) ||
          !_deepEquals(entry.value, right[entry.key])) {
        return false;
      }
    }
    return true;
  }
  if (left is FormFlutterFileValue && right is FormFlutterFileValue) {
    return left.name == right.name &&
        left.sizeInBytes == right.sizeInBytes &&
        left.extension == right.extension &&
        left.mimeType == right.mimeType;
  }
  return left == right;
}
