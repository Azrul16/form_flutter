import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Offset, TimeOfDay;

import 'form_flutter_field.dart' show FormFlutterFileValue;

/// Immutable access to the controller's current form values.
class FormFlutterValues {
  /// Creates a read-only wrapper around a map of form values.
  const FormFlutterValues(this._values);

  final Map<String, Object?> _values;

  /// Returns the typed value stored for the given field name.
  T value<T>(String name) {
    return _values[name] as T;
  }

  /// Returns an unmodifiable view of all current values.
  Map<String, Object?> asMap() {
    return Map<String, Object?>.unmodifiable(_values);
  }

  /// Returns the current values as a JSON-serializable map.
  Map<String, Object?> toJson() {
    return _serializeMap(_values);
  }
}

/// Central controller for form values, errors, async state, and field interaction state.
class FormFlutterController {
  /// Creates a controller with optional initial field values.
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

  /// A listenable view of the current form values.
  ValueListenable<Map<String, Object?>> get valuesListenable => _values;
  /// A listenable view of current validation errors.
  ValueListenable<Map<String, String?>> get errorsListenable => _errors;
  /// A listenable view of async validation states keyed by field name.
  ValueListenable<Map<String, bool>> get asyncStatesListenable => _asyncStates;
  /// A listenable view of fields that have been interacted with.
  ValueListenable<Map<String, bool>> get touchedFieldsListenable =>
      _touchedFields;
  /// A listenable view of fields whose values differ from their initial values.
  ValueListenable<Map<String, bool>> get dirtyFieldsListenable => _dirtyFields;

  /// Returns a snapshot wrapper around the current form values.
  FormFlutterValues get snapshot => FormFlutterValues(_values.value);

  /// Returns the controller's current initial-value baseline.
  Map<String, Object?> get initialValues {
    return Map<String, Object?>.unmodifiable(_initialValues);
  }

  /// Returns the typed value stored for the given field name.
  T value<T>(String name) {
    return _values.value[name] as T;
  }

  /// Returns the current error message for a field, if any.
  String? error(String name) {
    return _errors.value[name];
  }

  /// Returns whether a field is currently running async validation.
  bool isAsyncValidating(String name) {
    return _asyncStates.value[name] ?? false;
  }

  /// Returns whether a field has been interacted with.
  bool isTouched(String name) {
    return _touchedFields.value[name] ?? false;
  }

  /// Returns whether a field value differs from its initial value.
  bool isDirty(String name) {
    return _dirtyFields.value[name] ?? false;
  }

  /// Returns whether any field has been interacted with.
  bool get hasTouchedFields {
    return _touchedFields.value.containsValue(true);
  }

  /// Returns whether any field value differs from its initial value.
  bool get hasDirtyFields {
    return _dirtyFields.value.containsValue(true);
  }

  /// Updates a field value and refreshes touched and dirty tracking.
  void setValue(String name, Object? value) {
    _values.value = Map<String, Object?>.from(_values.value)..[name] = value;
    _touchedFields.value = Map<String, bool>.from(_touchedFields.value)
      ..[name] = true;
    _dirtyFields.value = Map<String, bool>.from(_dirtyFields.value)
      ..[name] = !_deepEquals(_initialValues[name], value);
  }

  /// Sets or clears the validation error for a field.
  void setError(String name, String? error) {
    _errors.value = Map<String, String?>.from(_errors.value)..[name] = error;
  }

  /// Clears all current field errors.
  void clearErrors() {
    _errors.value = <String, String?>{};
  }

  /// Marks a field as currently validating asynchronously.
  void setAsyncValidating(String name, bool isValidating) {
    _asyncStates.value = Map<String, bool>.from(_asyncStates.value)
      ..[name] = isValidating;
  }

  /// Marks a field as touched or untouched.
  void markTouched(String name, [bool touched = true]) {
    _touchedFields.value = Map<String, bool>.from(_touchedFields.value)
      ..[name] = touched;
  }

  /// Clears touched state for all fields.
  void clearTouched() {
    _touchedFields.value = <String, bool>{};
  }

  /// Clears dirty state for all fields.
  void clearDirty() {
    _dirtyFields.value = <String, bool>{};
  }

  /// Returns the current values as a JSON-serializable map.
  Map<String, Object?> toJson() {
    return snapshot.toJson();
  }

  /// Restores values from a serialized snapshot with optional merge and reset behavior.
  ///
  /// Set [decodeLegacyDateTimeStrings] to `true` only when restoring older
  /// snapshots that encoded `DateTime` values as plain ISO-8601 strings.
  void fromJson(
    Map<String, Object?> json, {
    bool merge = false,
    bool markAsInitial = false,
    bool clearErrors = true,
    bool clearAsyncStates = true,
    bool clearTouched = true,
    bool decodeLegacyDateTimeStrings = false,
  }) {
    final decoded = _deserializeMap(
      json,
      decodeLegacyDateTimeStrings: decodeLegacyDateTimeStrings,
    );
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

  /// Resets the controller back to its initial values or to a provided value map.
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

  /// Resets a single field back to its initial value and clears related state.
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

  /// Disposes all internal listenables used by the controller.
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
  if (value is Offset) {
    return <String, Object?>{
      '__form_flutter_type': 'offset',
      'dx': value.dx,
      'dy': value.dy,
    };
  }
  if (value is DateTime) {
    return <String, Object?>{
      '__form_flutter_type': 'date_time',
      'value': value.toIso8601String(),
    };
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
      'bytes': value.bytes,
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

Map<String, Object?> _deserializeMap(
  Map<String, Object?> value, {
  bool decodeLegacyDateTimeStrings = false,
}) {
  return value.map(
    (key, entry) => MapEntry(
      key,
      _deserializeValue(
        entry,
        decodeLegacyDateTimeStrings: decodeLegacyDateTimeStrings,
      ),
    ),
  );
}

Object? _deserializeValue(
  Object? value, {
  bool decodeLegacyDateTimeStrings = false,
}) {
  if (value is Map<String, Object?>) {
    final taggedType = value['__form_flutter_type'];
    if (taggedType == 'date_time') {
      return DateTime.tryParse(value['value']?.toString() ?? '');
    }
    if (taggedType == 'offset') {
      return Offset(
        (value['dx'] as num?)?.toDouble() ?? 0,
        (value['dy'] as num?)?.toDouble() ?? 0,
      );
    }
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
        bytes: (value['bytes'] as List?)?.cast<int>() == null
            ? null
            : Uint8List.fromList((value['bytes'] as List).cast<int>()),
      );
    }
    return _deserializeMap(
      value,
      decodeLegacyDateTimeStrings: decodeLegacyDateTimeStrings,
    );
  }
  if (value is Map) {
    return _deserializeMap(
      value.map(
        (key, entry) => MapEntry(key.toString(), entry),
      ),
      decodeLegacyDateTimeStrings: decodeLegacyDateTimeStrings,
    );
  }
  if (value is List) {
    return value
        .map(
          (item) => _deserializeValue(
            item,
            decodeLegacyDateTimeStrings: decodeLegacyDateTimeStrings,
          ),
        )
        .toList(growable: false);
  }
  if (decodeLegacyDateTimeStrings && value is String) {
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
        left.mimeType == right.mimeType &&
        listEquals(left.bytes, right.bytes);
  }
  return left == right;
}
