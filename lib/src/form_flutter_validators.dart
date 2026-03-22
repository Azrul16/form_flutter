import 'package:flutter/material.dart';

import 'form_flutter_controller.dart';
import 'form_flutter_field.dart';

abstract final class FormFlutterValidators {
  static FormFlutterValidator<T> combine<T>(
    List<FormFlutterValidator<T>> validators,
  ) {
    return (value, values) {
      for (final validator in validators) {
        final result = validator(value, values);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  static FormFlutterAsyncValidator<T> combineAsync<T>(
    List<FormFlutterAsyncValidator<T>> validators,
  ) {
    return (value, values) async {
      for (final validator in validators) {
        final result = await validator(value, values);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }

  static FormFlutterValidator<String> requiredText({
    String message = 'This field is required.',
  }) {
    return (value, _) => value.trim().isEmpty ? message : null;
  }

  static FormFlutterValidator<String> email({
    String message = 'Enter a valid email address.',
  }) {
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return (value, _) {
      if (value.trim().isEmpty) {
        return null;
      }
      return pattern.hasMatch(value.trim()) ? null : message;
    };
  }

  static FormFlutterValidator<String> minLength(
    int length, {
    String? message,
  }) {
    return (value, _) {
      return value.trim().length < length
          ? (message ?? 'Use at least $length characters.')
          : null;
    };
  }

  static FormFlutterValidator<String> maxLength(
    int length, {
    String? message,
  }) {
    return (value, _) {
      return value.trim().length > length
          ? (message ?? 'Use no more than $length characters.')
          : null;
    };
  }

  static FormFlutterValidator<String> exactLength(
    int length, {
    String? message,
  }) {
    return (value, _) {
      if (value.trim().isEmpty) {
        return null;
      }
      return value.trim().length != length
          ? (message ?? 'Use exactly $length characters.')
          : null;
    };
  }

  static FormFlutterValidator<String> pattern(
    RegExp regex, {
    required String message,
  }) {
    return (value, _) {
      if (value.trim().isEmpty) {
        return null;
      }
      return regex.hasMatch(value.trim()) ? null : message;
    };
  }

  static FormFlutterValidator<String> phone({
    String message = 'Enter a valid phone number.',
  }) {
    return pattern(
      RegExp(r'^\+?[0-9 ()-]{7,20}$'),
      message: message,
    );
  }

  static FormFlutterValidator<String> url({
    String message = 'Enter a valid URL.',
  }) {
    return pattern(
      RegExp(r'^(https?:\/\/)?([\w-]+\.)+[\w-]{2,}(\/\S*)?$'),
      message: message,
    );
  }

  static FormFlutterValidator<String> numericText({
    String message = 'Use numbers only.',
  }) {
    return pattern(
      RegExp(r'^\d+$'),
      message: message,
    );
  }

  static FormFlutterValidator<String> sameAsField(
    String otherFieldName, {
    String message = 'This value does not match.',
  }) {
    return (value, values) {
      final otherValue = values.asMap()[otherFieldName]?.toString() ?? '';
      return value == otherValue ? null : message;
    };
  }

  static FormFlutterValidator<T> requiredValue<T>({
    String message = 'This field is required.',
  }) {
    return (value, _) {
      if (value == null) {
        return message;
      }
      if (value is String && value.trim().isEmpty) {
        return message;
      }
      if (value is Iterable && value.isEmpty) {
        return message;
      }
      return null;
    };
  }

  static FormFlutterValidator<double?> requiredNumber({
    String message = 'Enter a number.',
  }) {
    return (value, _) => value == null ? message : null;
  }

  static FormFlutterValidator<double?> minNumber(
    double min, {
    String? message,
  }) {
    return (value, _) {
      if (value == null) {
        return null;
      }
      return value < min ? (message ?? 'Value must be at least $min.') : null;
    };
  }

  static FormFlutterValidator<double?> maxNumber(
    double max, {
    String? message,
  }) {
    return (value, _) {
      if (value == null) {
        return null;
      }
      return value > max ? (message ?? 'Value must be at most $max.') : null;
    };
  }

  static FormFlutterValidator<T?> requiredSelection<T>({
    String message = 'Make a selection.',
  }) {
    return (value, _) => value == null ? message : null;
  }

  static FormFlutterValidator<bool> mustBeTrue({
    String message = 'This field must be accepted.',
  }) {
    return (value, _) => value ? null : message;
  }

  static FormFlutterValidator<DateTime?> requiredDate({
    String message = 'Select a date.',
  }) {
    return (value, _) => value == null ? message : null;
  }

  static FormFlutterValidator<DateTime?> minDate(
    DateTime min, {
    String? message,
  }) {
    return (value, _) {
      if (value == null) {
        return null;
      }
      return value.isBefore(min)
          ? (message ?? 'Date must be on or after ${_formatDate(min)}.')
          : null;
    };
  }

  static FormFlutterValidator<DateTime?> maxDate(
    DateTime max, {
    String? message,
  }) {
    return (value, _) {
      if (value == null) {
        return null;
      }
      return value.isAfter(max)
          ? (message ?? 'Date must be on or before ${_formatDate(max)}.')
          : null;
    };
  }

  static FormFlutterValidator<DateTime?> minimumAge(
    int age, {
    String? message,
  }) {
    return (value, _) {
      if (value == null) {
        return null;
      }
      final today = DateTime.now();
      var actualAge = today.year - value.year;
      final hadBirthday = today.month > value.month ||
          (today.month == value.month && today.day >= value.day);
      if (!hadBirthday) {
        actualAge--;
      }
      return actualAge < age
          ? (message ?? 'You must be at least $age years old.')
          : null;
    };
  }

  static FormFlutterValidator<TimeOfDay?> requiredTime({
    String message = 'Select a time.',
  }) {
    return (value, _) => value == null ? message : null;
  }

  static FormFlutterValidator<List<T>> minItems<T>(
    int count, {
    String? message,
  }) {
    return (value, _) {
      return value.length < count
          ? (message ?? 'Select at least $count item${count == 1 ? '' : 's'}.')
          : null;
    };
  }

  static FormFlutterValidator<List<T>> maxItems<T>(
    int count, {
    String? message,
  }) {
    return (value, _) {
      return value.length > count
          ? (message ?? 'Select no more than $count items.')
          : null;
    };
  }

  static FormFlutterValidator<T> custom<T>(
    String? Function(T value, FormFlutterValues values) validator,
  ) {
    return validator;
  }

  static FormFlutterValidator<T> requiredIf<T>(
    bool Function(FormFlutterValues values) condition, {
    String message = 'This field is required.',
  }) {
    return (value, values) {
      if (!condition(values)) {
        return null;
      }
      return requiredValue<T>(message: message)(value, values);
    };
  }

  static FormFlutterValidator<T> conditional<T>(
    bool Function(FormFlutterValues values) condition,
    FormFlutterValidator<T> validator,
  ) {
    return (value, values) {
      if (!condition(values)) {
        return null;
      }
      return validator(value, values);
    };
  }

  static FormFlutterValidator<FormFlutterFileValue?> requiredFile({
    String message = 'Select a file.',
  }) {
    return (value, _) => value == null ? message : null;
  }

  static FormFlutterValidator<FormFlutterFileValue?> fileSize(
    int maxBytes, {
    String? message,
  }) {
    return (value, _) {
      if (value == null) {
        return null;
      }
      return value.sizeInBytes > maxBytes
          ? (message ?? 'File size must be at most ${_formatBytes(maxBytes)}.')
          : null;
    };
  }

  static FormFlutterValidator<FormFlutterFileValue?> fileExtension(
    List<String> allowedExtensions, {
    String? message,
  }) {
    final normalizedAllowed = allowedExtensions
        .map((extension) => extension.toLowerCase().replaceFirst('.', ''))
        .toSet();
    return (value, _) {
      if (value == null) {
        return null;
      }
      final parts = value.name.split('.');
      final fallbackExtension = parts.length > 1 ? parts.last : null;
      final rawExtension =
          (value.extension ?? fallbackExtension)?.toLowerCase();
      final normalizedExtension = rawExtension?.replaceFirst('.', '');
      if (normalizedExtension == null ||
          !normalizedAllowed.contains(normalizedExtension)) {
        return message ??
            'Allowed file types: ${normalizedAllowed.join(', ')}.';
      }
      return null;
    };
  }

  static FormFlutterValidator<FormFlutterFileValue?> imageOnly({
    String message = 'Only image files are allowed.',
  }) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp', 'svg'];
    return (value, _) {
      if (value == null) {
        return null;
      }
      final mimeType = value.mimeType?.toLowerCase();
      if (mimeType != null && mimeType.startsWith('image/')) {
        return null;
      }
      return fileExtension(imageExtensions, message: message)(value, const FormFlutterValues({}));
    };
  }

  static FormFlutterValidator<String> strongPassword({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialCharacter = true,
    String? message,
  }) {
    return (value, _) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      final failures = <String>[];
      if (trimmed.length < minLength) {
        failures.add('$minLength+ characters');
      }
      if (requireUppercase && !RegExp(r'[A-Z]').hasMatch(trimmed)) {
        failures.add('uppercase');
      }
      if (requireLowercase && !RegExp(r'[a-z]').hasMatch(trimmed)) {
        failures.add('lowercase');
      }
      if (requireNumber && !RegExp(r'\d').hasMatch(trimmed)) {
        failures.add('number');
      }
      if (requireSpecialCharacter &&
          !RegExp(r'[!@#$%^&*(),.?":{}|<>_\-\\/\[\]+=`~;]').hasMatch(trimmed)) {
        failures.add('special character');
      }
      if (failures.isEmpty) {
        return null;
      }
      return message ?? 'Password must include ${failures.join(', ')}.';
    };
  }

  static FormFlutterValidator<String> mediumPassword({
    int minLength = 8,
  }) {
    return strongPassword(
      minLength: minLength,
      requireSpecialCharacter: false,
    );
  }

  static FormFlutterValidator<String> highStrengthPassword({
    int minLength = 12,
  }) {
    return strongPassword(
      minLength: minLength,
      requireSpecialCharacter: true,
    );
  }

  static FormFlutterAsyncValidator<String> uniqueValue(
    Future<bool> Function(String value, FormFlutterValues values) isAvailable, {
    String message = 'This value is already in use.',
    Duration? debounce,
  }) {
    return (value, values) async {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      if (debounce != null) {
        await Future<void>.delayed(debounce);
      }
      final available = await isAvailable(trimmed, values);
      return available ? null : message;
    };
  }

  static FormFlutterAsyncValidator<String> uniqueUsername(
    Future<bool> Function(String username, FormFlutterValues values) isAvailable, {
    String message = 'This username is already taken.',
    Duration? debounce,
  }) {
    return uniqueValue(
      isAvailable,
      message: message,
      debounce: debounce,
    );
  }

  static FormFlutterAsyncValidator<String> uniqueEmail(
    Future<bool> Function(String email, FormFlutterValues values) isAvailable, {
    String message = 'This email is already registered.',
    Duration? debounce,
  }) {
    return uniqueValue(
      isAvailable,
      message: message,
      debounce: debounce,
    );
  }

  static String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String _formatBytes(int bytes) {
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
}
