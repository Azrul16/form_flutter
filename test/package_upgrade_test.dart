import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_flutter/form_flutter.dart';

void main() {
  group('FormFlutterCatalog', () {
    test('finds presets by key, category, and search text', () {
      expect(FormFlutterCatalog.byKey('email').label, 'Email address');
      expect(FormFlutterCatalog.maybeByKey('missing'), isNull);
      expect(
        FormFlutterCatalog.byCategory(
          FormFlutterFieldCategory.professional,
        ).map((preset) => preset.key),
        containsAll(['company_name', 'industry', 'resume']),
      );
      expect(
        FormFlutterCatalog.search('payment').map((preset) => preset.key),
        contains('payment_method'),
      );
    });
  });

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

    test('applies preset validation hints and honest picker defaults', () {
      final confirmPreset = FormFlutterCatalog.accountFields.firstWhere(
        (preset) => preset.key == 'confirm_password',
      );
      final confirmField =
          FormFlutterFieldFactory.buildField(confirmPreset)
              as FormFlutterTextField;

      expect(
        confirmField.validator?.call(
          'different',
          const FormFlutterValues({
            'password': 'secret123',
            'confirm_password': 'different',
          }),
        ),
        'Passwords do not match.',
      );

      final dobPreset = FormFlutterCatalog.personalInformation.firstWhere(
        (preset) => preset.key == 'date_of_birth',
      );
      final dobField =
          FormFlutterFieldFactory.buildField(dobPreset) as FormFlutterDateField;
      expect(
        dobField.validator?.call(
          DateTime.now().subtract(const Duration(days: 365 * 10)),
          const FormFlutterValues({}),
        ),
        isNotNull,
      );

      final resumePreset = FormFlutterCatalog.professionalFields.firstWhere(
        (preset) => preset.key == 'resume',
      );
      final resumeField =
          FormFlutterFieldFactory.buildField(resumePreset)
              as FormFlutterFileField;
      expect(resumeField.pickerConfigured, isFalse);
      expect(
        resumeField.validator?.call(
          const FormFlutterFileValue(
            name: 'resume.txt',
            sizeInBytes: 8 * 1024 * 1024,
            extension: 'txt',
          ),
          const FormFlutterValues({}),
        ),
        isNotNull,
      );
    });
  });

  group('FormFlutterSchema', () {
    test('provides production-ready schema templates', () {
      final registration = FormFlutterSchemaTemplates.accountRegistration();
      final jobApplication = FormFlutterSchemaTemplates.jobApplication();
      final appointment = FormFlutterSchemaTemplates.appointmentBooking();

      expect(
        FormFlutterFieldFactory.buildFieldsFromSchema(
          registration,
        ).map((field) => field.name),
        containsAll(['username', 'email', 'password', 'confirm_password']),
      );
      expect(
        FormFlutterFieldFactory.buildFieldsFromSchema(
          jobApplication,
        ).map((field) => field.name),
        containsAll(['full_name', 'industry', 'resume']),
      );
      expect(
        FormFlutterFieldFactory.buildFieldsFromSchema(
          appointment,
        ).map((field) => field.name),
        containsAll(['appointment_date', 'appointment_time', 'priority']),
      );
    });

    test('builds schema sections and initial values from preset overrides', () {
      final schema = FormFlutterSchema(
        initialValues: const {'role': 'member'},
        sections: [
          FormFlutterSchemaSection(
            title: 'Account',
            description: 'Account settings',
            fields: [
              FormFlutterSchemaField.fromPreset(
                FormFlutterCatalog.accountFields.firstWhere(
                  (preset) => preset.key == 'username',
                ),
                label: 'Public handle',
                helperText: 'Visible to other members.',
                hintText: '@ada',
                initialValue: 'ada',
                decorationOverride: const InputDecoration(prefixText: '@'),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ],
      );

      final sections = FormFlutterFieldFactory.buildSectionsFromSchema(schema);
      final initialValues =
          FormFlutterFieldFactory.buildInitialValuesFromSchema(schema);
      final controller = FormFlutterFieldFactory.buildControllerFromSchema(
        schema,
      );
      addTearDown(controller.dispose);

      expect(sections, hasLength(1));
      expect(sections.first.title, 'Account');
      expect(sections.first.description, 'Account settings');

      final field = sections.first.fields.single as FormFlutterTextField;
      expect(field.label, 'Public handle');
      expect(field.helperText, 'Visible to other members.');
      expect(field.hintText, '@ada');
      expect(field.decorationOverride?.prefixText, '@');
      expect(field.textStyle?.fontSize, 18);

      expect(initialValues['role'], 'member');
      expect(initialValues['username'], 'ada');
      expect(controller.value<String>('username'), 'ada');
    });

    test(
      'applies typed schema overrides without requiring custom builders',
      () {
        final schema = FormFlutterSchema(
          sections: [
            FormFlutterSchemaSection(
              title: 'Contact',
              fields: [
                const FormFlutterSchemaField(
                  name: 'phone',
                  kind: FormFlutterFieldKind.phone,
                  label: 'Phone',
                  countryFieldName: 'contactCountry',
                  initialCountryCode: 'BD',
                  allowedCountryCodes: ['BD', 'US'],
                  showCountryName: true,
                  nationalNumberHintText: '1XXXXXXXXX',
                ),
                const FormFlutterSchemaField(
                  name: 'experience',
                  kind: FormFlutterFieldKind.slider,
                  label: 'Experience',
                  sliderMin: 1,
                  sliderMax: 5,
                  sliderDivisions: 4,
                  sliderUnitLabel: 'years',
                ),
              ],
            ),
          ],
        );

        final fields = FormFlutterFieldFactory.buildFieldsFromSchema(schema);

        final phoneField = fields[0] as FormFlutterPhoneField;
        expect(phoneField.resolvedCountryFieldName, 'contactCountry');
        expect(phoneField.initialCountryCode, 'BD');
        expect(phoneField.allowedCountryCodes, ['BD', 'US']);
        expect(phoneField.showCountryName, isTrue);
        expect(phoneField.nationalNumberHintText, '1XXXXXXXXX');

        final sliderField = fields[1] as FormFlutterSliderField;
        expect(sliderField.min, 1);
        expect(sliderField.max, 5);
        expect(sliderField.divisions, 4);
        expect(sliderField.unitLabel, 'years');
      },
    );

    test(
      'passes supported schema overrides through generated otp and autocomplete fields',
      () {
        final schema = FormFlutterSchema(
          sections: [
            FormFlutterSchemaSection(
              title: 'Generated',
              fields: [
                const FormFlutterSchemaField(
                  name: 'otp',
                  kind: FormFlutterFieldKind.otp,
                  label: 'Verification code',
                  hintText: '123456',
                  textStyle: TextStyle(fontSize: 20),
                ),
                const FormFlutterSchemaField(
                  name: 'city',
                  kind: FormFlutterFieldKind.autocomplete,
                  label: 'City',
                  hintText: 'Search city',
                  textStyle: TextStyle(fontWeight: FontWeight.w600),
                  options: [
                    FormFlutterOption(value: 'dhaka', label: 'Dhaka'),
                    FormFlutterOption(value: 'tokyo', label: 'Tokyo'),
                  ],
                ),
              ],
            ),
          ],
        );

        final fields = FormFlutterFieldFactory.buildFieldsFromSchema(schema);
        final otpField = fields[0] as FormFlutterOtpField;
        final autocompleteField =
            fields[1] as FormFlutterAutocompleteField<String>;

        expect(otpField.hintText, '123456');
        expect(otpField.textStyle?.fontSize, 20);
        expect(autocompleteField.hintText, 'Search city');
        expect(autocompleteField.textStyle?.fontWeight, FontWeight.w600);
      },
    );
  });

  group('Validation messages', () {
    test('supports localized validation defaults', () {
      final previous = FormFlutterValidationMessages.current;
      FormFlutterValidationMessages.current =
          const FormFlutterValidationMessages(
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
    testWidgets('schema form wires controller, change, reset, and submit', (
      tester,
    ) async {
      final schema = FormFlutterSchema(
        initialValues: const {'name': 'Ada'},
        sections: const [
          FormFlutterSchemaSection(
            title: 'Profile',
            fields: [
              FormFlutterSchemaField(
                name: 'name',
                kind: FormFlutterFieldKind.text,
                label: 'Name',
              ),
            ],
          ),
        ],
      );
      var changed = 0;
      var reset = 0;
      Map<String, Object?>? submitted;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormFlutterSchemaForm(
              schema: schema,
              showResetButton: true,
              onChanged: (_) => changed++,
              onReset: () => reset++,
              onSubmit: (values) => submitted = values.asMap(),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Grace');
      await tester.pump();
      expect(changed, 1);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Reset'));
      await tester.pump();
      expect(reset, 1);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField))
            .controller
            ?.text,
        'Ada',
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Submit'));
      await tester.pumpAndSettle();
      expect(submitted?['name'], 'Ada');
    });

    testWidgets('stepper flow and validation summary work together', (
      tester,
    ) async {
      final controller = FormFlutterController(
        initialValues: const {'fullName': '', 'email': ''},
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
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNull,
      );

      await tester.enterText(find.byType(TextFormField), 'Ada');
      await tester.pump();

      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Continue'))
            .onPressed,
        isNotNull,
      );

      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Submit'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'Submit'))
            .onPressed,
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
        initialValues: const {'resume': null, 'signature': <List<Offset>>[]},
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

      final signature =
          controller.snapshot.asMap()['signature'] as List<Object?>;
      expect(signature, isNotEmpty);
      expect((signature.first as List<Object?>).length, greaterThan(0));
    });
  });
}
