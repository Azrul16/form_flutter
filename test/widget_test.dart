import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_flutter/form_flutter.dart';
import 'package:form_flutter/main.dart';

void main() {
  testWidgets('renders the form package playground', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FormFlutterApp());
    await tester.pumpAndSettle();

    expect(find.text('Full Example Form'), findsOneWidget);
    expect(find.text('Create Form'), findsOneWidget);
  });

  testWidgets('shows validation errors and blocks submit when invalid', (
    WidgetTester tester,
  ) async {
    final controller = FormFlutterController(initialValues: const {'name': ''});
    Object? submitted;

    await tester.pumpWidget(
      _TestApp(
        child: DynamicFormFlutter(
          controller: controller,
          fields: [
            FormFlutterTextField(
              name: 'name',
              label: 'Name',
              validator: FormFlutterValidators.requiredText(),
            ),
          ],
          onSubmit: (values) => submitted = values.asMap(),
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('This field is required.'), findsOneWidget);
    expect(submitted, isNull);

    controller.dispose();
  });

  testWidgets('submits valid values', (WidgetTester tester) async {
    final controller = FormFlutterController(initialValues: const {'name': ''});
    Map<String, Object?>? submitted;

    await tester.pumpWidget(
      _TestApp(
        child: DynamicFormFlutter(
          controller: controller,
          fields: [
            FormFlutterTextField(
              name: 'name',
              label: 'Name',
              validator: FormFlutterValidators.requiredText(),
            ),
          ],
          onSubmit: (values) => submitted = values.asMap(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'Ada');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(submitted, isNotNull);
    expect(submitted!['name'], 'Ada');

    controller.dispose();
  });

  testWidgets(
    'revalidates touched dependent fields when source field changes',
    (WidgetTester tester) async {
      final controller = FormFlutterController(
        initialValues: const {'password': '', 'confirm': ''},
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _TestApp(
          child: DynamicFormFlutter(
            controller: controller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            fields: [
              FormFlutterTextField(
                name: 'password',
                label: 'Password',
                validator: FormFlutterValidators.requiredText(),
              ),
              FormFlutterTextField(
                name: 'confirm',
                label: 'Confirm',
                validator: FormFlutterValidators.sameAsField('password'),
              ),
            ],
            onSubmit: (_) {},
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField).at(0), 'abc123');
      await tester.enterText(find.byType(TextFormField).at(1), 'abc123');
      await tester.pump();
      expect(find.text('This value does not match.'), findsNothing);

      await tester.enterText(find.byType(TextFormField).at(0), 'abc456');
      await tester.pump();
      expect(find.text('This value does not match.'), findsOneWidget);
    },
  );

  testWidgets('text field stays in sync after fromJson and reset', (
    WidgetTester tester,
  ) async {
    final controller = FormFlutterController(
      initialValues: const {'name': 'Ada'},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _TestApp(
        child: FormFlutterTextField(
          name: 'name',
          label: 'Name',
        ).buildField(controller),
      ),
    );

    TextFormField textField() =>
        tester.widget<TextFormField>(find.byType(TextFormField));

    expect(textField().controller?.text, 'Ada');

    controller.fromJson(const {'name': 'Grace'});
    await tester.pump();
    expect(textField().controller?.text, 'Grace');

    controller.reset();
    await tester.pump();
    expect(textField().controller?.text, 'Ada');
  });

  testWidgets('number field stays in sync after fromJson and reset', (
    WidgetTester tester,
  ) async {
    final controller = FormFlutterController(
      initialValues: const {'experience': '3'},
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _TestApp(
        child: FormFlutterNumberField(
          name: 'experience',
          label: 'Experience',
        ).buildField(controller),
      ),
    );

    TextFormField textField() =>
        tester.widget<TextFormField>(find.byType(TextFormField));

    expect(textField().controller?.text, '3');

    controller.fromJson(const {'experience': 8});
    await tester.pump();
    expect(textField().controller?.text, '8');

    controller.reset();
    await tester.pump();
    expect(textField().controller?.text, '3');
  });

  testWidgets('shows async validation progress while validating', (
    WidgetTester tester,
  ) async {
    final controller = FormFlutterController(
      initialValues: const {'email': 'ada@example.com'},
    );
    final completer = Completer<String?>();

    await tester.pumpWidget(
      _TestApp(
        child: DynamicFormFlutter(
          controller: controller,
          fields: [
            FormFlutterTextField(
              name: 'email',
              label: 'Email',
              validator: FormFlutterValidators.requiredText(),
              asyncValidator: (_, _) => completer.future,
            ),
          ],
          onSubmit: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Validating...'), findsOneWidget);

    completer.complete(null);
    await tester.pumpAndSettle();

    expect(find.text('Validating...'), findsNothing);

    controller.dispose();
  });

  testWidgets('updates visible sections when values change', (
    WidgetTester tester,
  ) async {
    final controller = FormFlutterController(initialValues: const {'mode': ''});

    await tester.pumpWidget(
      _TestApp(
        child: DynamicFormFlutter(
          controller: controller,
          fields: const [],
          sections: [
            const FormFlutterSection(
              title: 'Primary',
              fields: [FormFlutterTextField(name: 'mode', label: 'Mode')],
            ),
            FormFlutterSection(
              title: 'Advanced',
              fields: const [
                FormFlutterTextField(name: 'details', label: 'Details'),
              ],
              isVisible: (values) => values.asMap()['mode'] == 'show',
            ),
          ],
          onSubmit: (_) {},
        ),
      ),
    );

    expect(find.text('Advanced'), findsNothing);

    await tester.enterText(find.byType(TextFormField).first, 'show');
    await tester.pump();

    expect(find.text('Advanced'), findsOneWidget);

    controller.dispose();
  });

  testWidgets('advances through stepper sections', (WidgetTester tester) async {
    final controller = FormFlutterController(
      initialValues: const {'name': '', 'code': ''},
    );

    await tester.pumpWidget(
      _TestApp(
        child: DynamicFormFlutter(
          controller: controller,
          fields: const [],
          sections: [
            FormFlutterSection(
              title: 'Account',
              fields: [
                FormFlutterTextField(
                  name: 'name',
                  label: 'Name',
                  validator: FormFlutterValidators.requiredText(),
                ),
              ],
            ),
            FormFlutterSection(
              title: 'Confirm',
              fields: [FormFlutterTextField(name: 'code', label: 'Code')],
            ),
          ],
          useStepper: true,
          onSubmit: (_) {},
        ),
      ),
    );

    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'Ada');
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Confirm'), findsOneWidget);
    expect(find.text('Back'), findsOneWidget);

    controller.dispose();
  });
}

class _TestApp extends StatelessWidget {
  const _TestApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
