import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_flutter/form_flutter.dart';

void main() {
  group('FormFlutterFieldFactory', () {
    test('builds catalog-promised field kinds', () {
      final presets = [
        const FormFlutterFieldPreset(
          key: 'otp',
          label: 'OTP',
          kind: FormFlutterFieldKind.otp,
          category: FormFlutterFieldCategory.account,
          isRequired: true,
        ),
        const FormFlutterFieldPreset(
          key: 'search',
          label: 'Search',
          kind: FormFlutterFieldKind.search,
          category: FormFlutterFieldCategory.advanced,
        ),
        const FormFlutterFieldPreset(
          key: 'city',
          label: 'City',
          kind: FormFlutterFieldKind.autocomplete,
          category: FormFlutterFieldCategory.address,
          options: [
            FormFlutterOption(value: 'dhaka', label: 'Dhaka'),
            FormFlutterOption(value: 'tokyo', label: 'Tokyo'),
          ],
        ),
        const FormFlutterFieldPreset(
          key: 'resume',
          label: 'Resume',
          kind: FormFlutterFieldKind.file,
          category: FormFlutterFieldCategory.professional,
        ),
        const FormFlutterFieldPreset(
          key: 'photo',
          label: 'Photo',
          kind: FormFlutterFieldKind.image,
          category: FormFlutterFieldCategory.media,
        ),
        const FormFlutterFieldPreset(
          key: 'signature',
          label: 'Signature',
          kind: FormFlutterFieldKind.signature,
          category: FormFlutterFieldCategory.consent,
        ),
      ];

      final fields = FormFlutterFieldFactory.buildFieldsFromPresets(presets);

      expect(fields[0], isA<FormFlutterOtpField>());
      expect(fields[1], isA<FormFlutterSearchField>());
      expect(fields[2], isA<FormFlutterAutocompleteField<String>>());
      expect(fields[3], isA<FormFlutterFileField>());
      expect(fields[4], isA<FormFlutterImageField>());
      expect(fields[5], isA<FormFlutterSignatureField>());
    });
  });

  group('Validation messages', () {
    test('supports localized validation defaults', () {
      final previous = FormFlutterValidationMessages.current;
      FormFlutterValidationMessages.current = const FormFlutterValidationMessages(
        requiredText: 'Required in test language.',
      );

      final result = FormFlutterValidators.requiredText()(
        '',
        const FormFlutterValues({}),
      );

      expect(result, 'Required in test language.');
      FormFlutterValidationMessages.current = previous;
    });
  });

  group('Upgraded widgets', () {
    testWidgets('stepper flow and validation summary work together', (
      tester,
    ) async {
      final controller = FormFlutterController(
        initialValues: const {
          'fullName': '',
          'email': '',
        },
      );

      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: DynamicFormFlutter(
                controller: controller,
                fields: const [],
                sections: [
                  FormFlutterSection(
                    title: 'Basics',
                    fields: [
                      FormFlutterTextField(
                        name: 'fullName',
                        label: 'Full name',
                        validator: FormFlutterValidators.requiredText(),
                      ),
                    ],
                  ),
                  FormFlutterSection(
                    title: 'Contact',
                    fields: [
                      FormFlutterTextField(
                        name: 'email',
                        label: 'Email',
                        validator: FormFlutterPresetValidators.emailAddress(),
                      ),
                    ],
                  ),
                ],
                useStepper: true,
                disableSubmitUntilDirty: true,
                showValidationSummary: true,
                onSubmit: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue')).onPressed,
        isNull,
      );

      await tester.enterText(find.byType(TextFormField), 'Ada');
      await tester.pump();

      expect(
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue')).onPressed,
        isNotNull,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit')).onPressed,
        isNotNull,
      );

      await tester.enterText(find.byType(TextFormField), 'bad-email');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Please fix the following fields:'), findsOneWidget);
      expect(find.textContaining('Email:'), findsOneWidget);
    });

    testWidgets('file and signature fields update controller state', (
      tester,
    ) async {
      final controller = FormFlutterController(
        initialValues: const {
          'resume': null,
          'signature': <List<Offset>>[],
        },
      );

      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                FormFlutterFileField(
                  name: 'resume',
                  label: 'Resume',
                  onPick: (context, controller) async {
                    return FormFlutterFileValue(
                      name: 'resume.pdf',
                      sizeInBytes: 2048,
                      extension: 'pdf',
                      mimeType: 'application/pdf',
                      bytes: Uint8List.fromList(const [1, 2, 3]),
                    );
                  },
                ).buildField(controller),
                const SizedBox(height: 24),
                FormFlutterSignatureField(
                  name: 'signature',
                  label: 'Signature',
                ).buildField(controller),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Choose file'));
      await tester.pumpAndSettle();

      final picked = controller.value<FormFlutterFileValue?>('resume');
      expect(picked?.name, 'resume.pdf');
      expect(picked?.bytes, isNotNull);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(CustomPaint).last),
      );
      await gesture.moveBy(const Offset(20, 20));
      await gesture.up();
      await tester.pumpAndSettle();

      final signature = controller.snapshot.asMap()['signature'] as List<Object?>;
      expect(signature, isNotEmpty);
      expect((signature.first as List<Object?>).length, greaterThan(0));
    });
  });
}
