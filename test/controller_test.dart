import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_flutter/form_flutter.dart';

void main() {
  group('FormFlutterController', () {
    test('tracks touched and dirty fields', () {
      final controller = FormFlutterController(
        initialValues: const {
          'name': 'Ada',
          'tags': <String>['math'],
        },
      );

      expect(controller.hasTouchedFields, isFalse);
      expect(controller.hasDirtyFields, isFalse);

      controller.setValue('name', 'Grace');

      expect(controller.isTouched('name'), isTrue);
      expect(controller.isDirty('name'), isTrue);
      expect(controller.hasTouchedFields, isTrue);
      expect(controller.hasDirtyFields, isTrue);

      controller.setValue('name', 'Ada');

      expect(controller.isTouched('name'), isTrue);
      expect(controller.isDirty('name'), isFalse);

      controller.dispose();
    });

    test('serializes and restores controller values', () {
      final controller = FormFlutterController(
        initialValues: {
          'name': 'Ada',
          'birthday': DateTime(2024, 1, 2, 3, 4, 5),
          'meetingTime': const TimeOfDay(hour: 9, minute: 30),
          'resume': const FormFlutterFileValue(
            name: 'resume.pdf',
            sizeInBytes: 2048,
            extension: 'pdf',
            mimeType: 'application/pdf',
          ),
          'interests': const ['forms', 'dx'],
          'signature': const [
            [Offset(1, 2), Offset(3, 4)],
          ],
        },
      );

      final json = controller.toJson();
      final restored = FormFlutterController();

      restored.fromJson(json, markAsInitial: true);
      final restoredMap = restored.snapshot.asMap();

      expect(restored.value<String>('name'), 'Ada');
      expect(
        restored.value<DateTime>('birthday'),
        DateTime(2024, 1, 2, 3, 4, 5),
      );
      expect(
        restored.value<TimeOfDay>('meetingTime'),
        const TimeOfDay(hour: 9, minute: 30),
      );

      final file = restored.value<FormFlutterFileValue>('resume');
      expect(file.name, 'resume.pdf');
      expect(file.sizeInBytes, 2048);
      expect(file.extension, 'pdf');
      expect(file.mimeType, 'application/pdf');
      expect(restoredMap['interests'], ['forms', 'dx']);
      final signature = restoredMap['signature'] as List<Object?>;
      final firstStroke = signature.first as List<Object?>;
      expect(firstStroke.first, const Offset(1, 2));
      expect(restored.hasDirtyFields, isFalse);

      controller.dispose();
      restored.dispose();
    });

    test('reset restores initial values and clears state', () {
      final controller = FormFlutterController(
        initialValues: const {
          'email': 'ada@example.com',
        },
      );

      controller.setValue('email', 'grace@example.com');
      controller.setError('email', 'Invalid');
      controller.setAsyncValidating('email', true);

      expect(controller.isTouched('email'), isTrue);
      expect(controller.isDirty('email'), isTrue);

      controller.reset();

      expect(controller.value<String>('email'), 'ada@example.com');
      expect(controller.error('email'), isNull);
      expect(controller.isAsyncValidating('email'), isFalse);
      expect(controller.isTouched('email'), isFalse);
      expect(controller.isDirty('email'), isFalse);

      controller.dispose();
    });

    test('resetField restores one field only', () {
      final controller = FormFlutterController(
        initialValues: const {
          'firstName': 'Ada',
          'lastName': 'Lovelace',
        },
      );

      controller.setValue('firstName', 'Grace');
      controller.setValue('lastName', 'Hopper');

      controller.resetField('firstName');

      expect(controller.value<String>('firstName'), 'Ada');
      expect(controller.value<String>('lastName'), 'Hopper');
      expect(controller.isTouched('firstName'), isFalse);
      expect(controller.isDirty('firstName'), isFalse);
      expect(controller.isDirty('lastName'), isTrue);

      controller.dispose();
    });

    test('serializes file bytes for media-aware fields', () {
      final controller = FormFlutterController(
        initialValues: {
          'avatar': FormFlutterFileValue(
            name: 'avatar.png',
            sizeInBytes: 3,
            extension: 'png',
            mimeType: 'image/png',
            bytes: Uint8List.fromList(const [1, 2, 3]),
          ),
        },
      );

      final restored = FormFlutterController();
      restored.fromJson(controller.toJson(), markAsInitial: true);

      expect(
        restored.value<FormFlutterFileValue>('avatar').bytes,
        Uint8List.fromList(const [1, 2, 3]),
      );

      controller.dispose();
      restored.dispose();
    });


    test('keeps plain ISO-like strings as strings by default', () {
      final controller = FormFlutterController();

      controller.fromJson(const {
        'raw': '2024-01-02T03:04:05.000',
      });

      expect(controller.value<String>('raw'), '2024-01-02T03:04:05.000');

      controller.dispose();
    });

    test('can decode legacy date strings when requested', () {
      final controller = FormFlutterController();

      controller.fromJson(
        const {
          'legacyDate': '2024-01-02T03:04:05.000',
        },
        decodeLegacyDateTimeStrings: true,
      );

      expect(
        controller.value<DateTime>('legacyDate'),
        DateTime(2024, 1, 2, 3, 4, 5),
      );

      controller.dispose();
    });
  });
}
