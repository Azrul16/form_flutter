import 'package:flutter/material.dart';

import 'form_flutter_controller.dart';
import 'form_flutter_field.dart';

/// Customizable default validation messages used by `FormFlutterValidators`.
class FormFlutterValidationMessages {
  const FormFlutterValidationMessages({
    this.requiredText = 'This field is required.',
    this.email = 'Enter a valid email address.',
    this.phone = 'Enter a valid phone number.',
    this.url = 'Enter a valid URL.',
    this.numericText = 'Use numbers only.',
    this.sameAsField = 'This value does not match.',
    this.requiredNumber = 'Enter a number.',
    this.requiredSelection = 'Make a selection.',
    this.mustBeTrue = 'This field must be accepted.',
    this.requiredDate = 'Select a date.',
    this.requiredTime = 'Select a time.',
    this.requiredFile = 'Select a file.',
    this.imageOnly = 'Only image files are allowed.',
    this.uniqueValue = 'This value is already in use.',
    this.uniqueUsername = 'This username is already taken.',
    this.uniqueEmail = 'This email is already registered.',
  });

  static FormFlutterValidationMessages current =
      const FormFlutterValidationMessages();

  final String requiredText;
  final String email;
  final String phone;
  final String url;
  final String numericText;
  final String sameAsField;
  final String requiredNumber;
  final String requiredSelection;
  final String mustBeTrue;
  final String requiredDate;
  final String requiredTime;
  final String requiredFile;
  final String imageOnly;
  final String uniqueValue;
  final String uniqueUsername;
  final String uniqueEmail;
}

/// Built-in validator helpers for common field validation rules.
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
    String? message,
  }) {
    return (value, _) =>
        value.trim().isEmpty ? (message ?? FormFlutterValidationMessages.current.requiredText) : null;
  }

  static FormFlutterValidator<String> email({
    String? message,
  }) {
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return (value, _) {
      if (value.trim().isEmpty) {
        return null;
      }
      return pattern.hasMatch(value.trim())
          ? null
          : (message ?? FormFlutterValidationMessages.current.email);
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
    String? message,
  }) {
    return pattern(
      RegExp(r'^\+?[0-9 ()-]{7,20}$'),
      message: message ?? FormFlutterValidationMessages.current.phone,
    );
  }

  static FormFlutterValidator<String> url({
    String? message,
  }) {
    return pattern(
      RegExp(r'^(https?:\/\/)?([\w-]+\.)+[\w-]{2,}(\/\S*)?$'),
      message: message ?? FormFlutterValidationMessages.current.url,
    );
  }

  static FormFlutterValidator<String> numericText({
    String? message,
  }) {
    return pattern(
      RegExp(r'^\d+$'),
      message: message ?? FormFlutterValidationMessages.current.numericText,
    );
  }

  static FormFlutterValidator<String> sameAsField(
    String otherFieldName, {
    String? message,
  }) {
    return (value, values) {
      final otherValue = values.asMap()[otherFieldName]?.toString() ?? '';
      return value == otherValue
          ? null
          : (message ?? FormFlutterValidationMessages.current.sameAsField);
    };
  }

  static FormFlutterValidator<T> requiredValue<T>({
    String? message,
  }) {
    return (value, _) {
      final resolvedMessage =
          message ?? FormFlutterValidationMessages.current.requiredText;
      if (value == null) {
        return resolvedMessage;
      }
      if (value is String && value.trim().isEmpty) {
        return resolvedMessage;
      }
      if (value is Iterable && value.isEmpty) {
        return resolvedMessage;
      }
      return null;
    };
  }

  static FormFlutterValidator<double?> requiredNumber({
    String? message,
  }) {
    return (value, _) => value == null
        ? (message ?? FormFlutterValidationMessages.current.requiredNumber)
        : null;
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
    String? message,
  }) {
    return (value, _) => value == null
        ? (message ?? FormFlutterValidationMessages.current.requiredSelection)
        : null;
  }

  static FormFlutterValidator<bool> mustBeTrue({
    String? message,
  }) {
    return (value, _) => value
        ? null
        : (message ?? FormFlutterValidationMessages.current.mustBeTrue);
  }

  static FormFlutterValidator<DateTime?> requiredDate({
    String? message,
  }) {
    return (value, _) => value == null
        ? (message ?? FormFlutterValidationMessages.current.requiredDate)
        : null;
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
    String? message,
  }) {
    return (value, _) => value == null
        ? (message ?? FormFlutterValidationMessages.current.requiredTime)
        : null;
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
    String? message,
  }) {
    return (value, _) => value == null
        ? (message ?? FormFlutterValidationMessages.current.requiredFile)
        : null;
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
    String? message,
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
      return fileExtension(
        imageExtensions,
        message: message ?? FormFlutterValidationMessages.current.imageOnly,
      )(value, const FormFlutterValues({}));
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
    String? message,
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
      return available
          ? null
          : (message ?? FormFlutterValidationMessages.current.uniqueValue);
    };
  }

  static FormFlutterAsyncValidator<String> uniqueUsername(
    Future<bool> Function(String username, FormFlutterValues values) isAvailable, {
    String? message,
    Duration? debounce,
  }) {
    return uniqueValue(
      isAvailable,
      message: message ?? FormFlutterValidationMessages.current.uniqueUsername,
      debounce: debounce,
    );
  }

  static FormFlutterAsyncValidator<String> uniqueEmail(
    Future<bool> Function(String email, FormFlutterValues values) isAvailable, {
    String? message,
    Duration? debounce,
  }) {
    return uniqueValue(
      isAvailable,
      message: message ?? FormFlutterValidationMessages.current.uniqueEmail,
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
