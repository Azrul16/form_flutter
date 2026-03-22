import 'package:flutter/material.dart';

import 'form_flutter.dart';

void main() {
  runApp(const FormFlutterApp());
}

class FormFlutterApp extends StatelessWidget {
  const FormFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155EEF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        useMaterial3: true,
      ),
      home: const FormPlaygroundPage(),
    );
  }
}

class FormPlaygroundPage extends StatefulWidget {
  const FormPlaygroundPage({super.key});

  @override
  State<FormPlaygroundPage> createState() => _FormPlaygroundPageState();
}

class _FormPlaygroundPageState extends State<FormPlaygroundPage> {
  final FormFlutterController _controller = FormFlutterController(
    initialValues: const {
      'fullName': '',
      'username': '',
      'email': '',
      'bio': '',
      'experience': '3',
      'role': 'designer',
      'plan': 'pro',
      'country': 'bd',
      'launchDate': null,
      'supportTime': null,
      'demoDateTime': null,
      'interests': <String>['forms'],
      'satisfactionScore': 72.0,
      'password': '',
      'confirmPassword': '',
      'newsletter': true,
      'acceptTerms': false,
    },
  );

  late final List<FormFlutterField<dynamic>> _fields = [
    FormFlutterTextField(
      name: 'fullName',
      label: 'Full name',
      hintText: 'Ada Lovelace',
      textInputAction: TextInputAction.next,
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.minLength(4),
      ]),
    ),
    FormFlutterTextField(
      name: 'username',
      label: 'Username',
      hintText: 'ada_lovelace',
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.minLength(4),
      ]),
      asyncValidator: FormFlutterPresetValidators.uniqueUsername(
        (username, _) async {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          return username.toLowerCase() != 'admin';
        },
      ),
    ),
    FormFlutterTextField(
      name: 'email',
      label: 'Work email',
      hintText: 'ada@analytical.engine',
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.email(),
      ]),
      asyncValidator: FormFlutterPresetValidators.uniqueEmail(
        (email, _) async {
          await Future<void>.delayed(const Duration(milliseconds: 400));
          return email.toLowerCase() != 'taken@analytical.engine';
        },
      ),
    ),
    FormFlutterTextField(
      name: 'bio',
      label: 'Bio',
      hintText: 'Tell us what this form package should help teams build.',
      maxLines: 4,
      helperText: 'Multiline field support matters for real onboarding and CRM flows.',
      validator: FormFlutterValidators.maxLength(180),
    ),
    FormFlutterTextField(
      name: 'password',
      label: 'Password',
      hintText: 'Strong password',
      obscureText: true,
      validator: FormFlutterPresetValidators.strongPassword(),
    ),
    FormFlutterTextField(
      name: 'confirmPassword',
      label: 'Confirm password',
      hintText: 'Repeat password',
      obscureText: true,
      validator: FormFlutterPresetValidators.confirmPassword('password'),
    ),
    FormFlutterNumberField(
      name: 'experience',
      label: 'Years of experience',
      hintText: '3',
      helperText: 'Number fields should validate ranges without custom plumbing.',
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredNumber(),
        FormFlutterValidators.minNumber(0),
        FormFlutterValidators.maxNumber(50),
      ]),
    ),
    FormFlutterDropdownField<String>(
      name: 'country',
      label: 'Country',
      hintText: 'Choose a country',
      options: const [
        FormFlutterOption(value: 'bd', label: 'Bangladesh'),
        FormFlutterOption(value: 'us', label: 'United States'),
        FormFlutterOption(value: 'jp', label: 'Japan'),
      ],
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterRadioGroupField<String>(
      name: 'role',
      label: 'Primary role',
      options: const [
        FormFlutterOption(value: 'designer', label: 'Designer'),
        FormFlutterOption(value: 'developer', label: 'Developer'),
        FormFlutterOption(value: 'product', label: 'Product manager'),
      ],
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterDropdownField<String>(
      name: 'plan',
      label: 'Plan',
      options: const [
        FormFlutterOption(value: 'starter', label: 'Starter'),
        FormFlutterOption(value: 'pro', label: 'Pro'),
        FormFlutterOption(value: 'enterprise', label: 'Enterprise'),
      ],
      helperText: 'Dropdowns and radios often share the same validation story.',
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterDateField(
      name: 'launchDate',
      label: 'Launch date',
      hintText: 'Pick your target launch date',
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      validator: FormFlutterValidators.requiredDate(),
    ),
    FormFlutterTimeField(
      name: 'supportTime',
      label: 'Preferred support time',
      hintText: 'Pick a time window start',
      validator: FormFlutterValidators.requiredTime(),
    ),
    FormFlutterDateTimeField(
      name: 'demoDateTime',
      label: 'Demo call',
      hintText: 'Pick a date and time',
    ),
    FormFlutterMultiSelectField<String>(
      name: 'interests',
      label: 'Package interests',
      helperText: 'A real form package needs repeatable, many-choice input too.',
      options: const [
        FormFlutterOption(value: 'forms', label: 'Forms'),
        FormFlutterOption(value: 'validation', label: 'Validation'),
        FormFlutterOption(value: 'accessibility', label: 'Accessibility'),
        FormFlutterOption(value: 'automation', label: 'Automation'),
        FormFlutterOption(value: 'analytics', label: 'Analytics'),
      ],
      validator: FormFlutterValidators.minItems<String>(1),
    ),
    const FormFlutterSliderField(
      name: 'satisfactionScore',
      label: 'Package vision score',
      helperText: 'Slider and range-like inputs are common in onboarding and feedback.',
      min: 0,
      max: 100,
      divisions: 20,
      unitLabel: 'points',
    ),
    FormFlutterSwitchField(
      name: 'newsletter',
      label: 'Send product updates',
      helperText: 'Switch fields are useful for optional preferences.',
    ),
    FormFlutterCheckboxField(
      name: 'acceptTerms',
      label: 'I agree that form validation, state, and UX belong in one package.',
      validator: FormFlutterValidators.mustBeTrue(),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'form_flutter',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'A package direction for building serious Flutter forms.',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This playground now covers text, password, multiline, number, dropdown, radio, switch, checkbox, date, time, date-time, slider, multi-select, and reusable validators.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: const Color(0xFF475467),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 900;
                        final formCard = Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Color(0xFFE4E7EC)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: DynamicFormFlutter(
                              controller: _controller,
                              fields: _fields,
                              submitLabel: 'Validate package flow',
                              onSubmit: (values) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Validated values: ${values.asMap()}',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );

                        final insightCard =
                            ValueListenableBuilder<Map<String, Object?>>(
                          valueListenable: _controller.valuesListenable,
                          builder: (context, values, _) {
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: const BorderSide(color: Color(0xFFE4E7EC)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Included in this pass',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const _FeaturePoint(
                                      title: 'Field coverage',
                                      description:
                                          'Text, password, multiline, number, dropdown, radio, checkbox, switch, date, time, date-time, slider, and multi-select now share one API.',
                                    ),
                                    const _FeaturePoint(
                                      title: 'Reusable validation',
                                      description:
                                          'Common validators and preset validators can be combined instead of being rewritten screen by screen.',
                                    ),
                                    const _FeaturePoint(
                                      title: 'Catalog layer',
                                      description:
                                          'The package now includes grouped field presets and common option sets for personal, contact, address, academic, professional, commerce, appointment, and consent flows.',
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Preset fields available: ${FormFlutterCatalog.all().length}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Live values',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF101828),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        values.toString(),
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: Colors.white,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );

                        if (isCompact) {
                          return ListView(
                            children: [
                              formCard,
                              const SizedBox(height: 24),
                              insightCard,
                            ],
                          );
                        }

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 6, child: formCard),
                            const SizedBox(width: 24),
                            Expanded(flex: 4, child: insightCard),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeaturePoint extends StatelessWidget {
  const _FeaturePoint({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 10,
            height: 10,
            margin: const EdgeInsets.only(top: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF475467),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
