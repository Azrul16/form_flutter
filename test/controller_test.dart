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
        },
      );

      final json = controller.toJson();
      final restored = FormFlutterController();

      restored.fromJson(json, markAsInitial: true);

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
      expect(restored.value<List<Object?>>('interests'), ['forms', 'dx']);
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
  });
}
