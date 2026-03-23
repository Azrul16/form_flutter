import 'dart:convert';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'form_flutter.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const FormFlutterApp(),
    ),
  );
}

class FormFlutterApp extends StatelessWidget {
  const FormFlutterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Flutter',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: const Color(0xFFF3F7F6),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF0F172A),
          displayColor: const Color(0xFF0F172A),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
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
  Map<String, Object?>? _savedSnapshot;

  final FormFlutterController _controller = FormFlutterController(
    initialValues: const {
      'fullName': '',
      'username': '',
      'email': '',
      'phone': '',
      'phoneCountry': 'BD',
      'bio': '',
      'password': '',
      'confirmPassword': '',
      'experience': '3',
      'country': 'BD',
      'department': 'engineering',
      'role': 'designer',
      'plan': 'pro',
      'launchDate': null,
      'supportTime': null,
      'demoDateTime': null,
      'interests': <String>['forms', 'accessibility'],
      'satisfactionScore': 72.0,
      'newsletter': true,
      'acceptTerms': false,
      'otpCode': '',
      'companySearch': '',
      'city': null,
      'resume': null,
      'avatar': null,
      'signature': <List<Offset>>[],
      'meetingMode': 'online',
    },
  );

  late final List<FormFlutterField<dynamic>> _fields = [
    FormFlutterTextField(
      name: 'fullName',
      label: 'Full name',
      hintText: 'Ada Lovelace',
      decorationOverride: InputDecoration(
        prefixIcon: const Icon(Icons.person_outline),
        filled: true,
        fillColor: const Color(0xFFF8FFFD),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
      ),
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.minLength(4),
      ]),
    ),
    FormFlutterTextField(
      name: 'username',
      label: 'Username',
      hintText: 'ada_lovelace',
      decorationOverride: const InputDecoration(
        prefixIcon: Icon(Icons.alternate_email),
        filled: true,
        fillColor: Color(0xFFF8FAFF),
      ),
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.minLength(4),
      ]),
      asyncValidator: FormFlutterPresetValidators.uniqueUsername((
        username,
        _,
      ) async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        return username.toLowerCase() != 'admin';
      }),
    ),
    FormFlutterTextField(
      name: 'email',
      label: 'Work email',
      hintText: 'ada@analytical.engine',
      keyboardType: TextInputType.emailAddress,
      decorationOverride: const InputDecoration(
        prefixIcon: Icon(Icons.mail_outline),
      ),
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.email(),
      ]),
      asyncValidator: FormFlutterPresetValidators.uniqueEmail((email, _) async {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        return email.toLowerCase() != 'taken@analytical.engine';
      }),
    ),
    FormFlutterPhoneField(
      name: 'phone',
      label: 'Phone',
      countryFieldName: 'phoneCountry',
      initialCountryCode: 'BD',
      showCountryFlagInSelector: false,
      showCountryIsoCodeInSelector: true,
      showCountryDialCodeInSelector: true,
      nationalNumberHintText: 'Enter mobile number',
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.numericText(),
      ]),
    ),
    FormFlutterTextField(
      name: 'bio',
      label: 'About project',
      hintText: 'Describe the form flow you want to build',
      maxLines: 4,
      validator: FormFlutterValidators.maxLength(180),
    ),
    FormFlutterTextField(
      name: 'password',
      label: 'Password',
      hintText: 'Create password',
      obscureText: true,
      enableObscureTextToggle: true,
      validator: FormFlutterPresetValidators.strongPassword(),
    ),
    FormFlutterTextField(
      name: 'confirmPassword',
      label: 'Confirm password',
      hintText: 'Repeat password',
      obscureText: true,
      allowPaste: false,
      validator: FormFlutterPresetValidators.confirmPassword('password'),
    ),
    FormFlutterOtpField(
      name: 'otpCode',
      label: 'Verification code',
      helperText: 'A custom OTP input with package-managed state.',
      validator: FormFlutterPresetValidators.otp(),
    ),
    FormFlutterNumberField(
      name: 'experience',
      label: 'Years of experience',
      hintText: '3',
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredNumber(),
        FormFlutterValidators.minNumber(0),
        FormFlutterValidators.maxNumber(50),
      ]),
    ),
    FormFlutterCountryField(
      name: 'country',
      label: 'Country',
      includeFlag: true,
      includeDialCode: false,
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterDropdownField<String>(
      name: 'department',
      label: 'Department',
      options: const [
        FormFlutterOption(
          value: 'engineering',
          label: 'Engineering',
          color: Color(0xFF0F766E),
          icon: Icons.code,
          indicatorSize: 18,
        ),
        FormFlutterOption(
          value: 'design',
          label: 'Design',
          color: Color(0xFF7C3AED),
          icon: Icons.brush_outlined,
          indicatorSize: 18,
        ),
        FormFlutterOption(
          value: 'product',
          label: 'Product',
          color: Color(0xFFEA580C),
          icon: Icons.insights_outlined,
          indicatorSize: 18,
        ),
      ],
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterRadioGroupField<String>(
      name: 'role',
      label: 'Role',
      options: const [
        FormFlutterOption(
          value: 'designer',
          label: 'Designer',
          color: Color(0xFF7C3AED),
          icon: Icons.palette_outlined,
          indicatorSize: 16,
        ),
        FormFlutterOption(
          value: 'developer',
          label: 'Developer',
          color: Color(0xFF2563EB),
          icon: Icons.code,
          indicatorSize: 16,
        ),
        FormFlutterOption(
          value: 'product',
          label: 'Product manager',
          color: Color(0xFFEA580C),
          icon: Icons.track_changes_outlined,
          indicatorSize: 16,
        ),
      ],
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterDropdownField<String>(
      name: 'plan',
      label: 'Plan',
      options: const [
        FormFlutterOption(
          value: 'starter',
          label: 'Starter',
          color: Color(0xFF475467),
          backgroundColor: Color(0xFFF8FAFC),
          selectedColor: Color(0xFF475467),
          textColor: Color(0xFF344054),
          selectedTextColor: Colors.white,
        ),
        FormFlutterOption(
          value: 'pro',
          label: 'Pro',
          color: Color(0xFF0F766E),
          backgroundColor: Color(0xFFECFDF5),
          selectedColor: Color(0xFF0F766E),
          textColor: Color(0xFF065F46),
          selectedTextColor: Colors.white,
        ),
        FormFlutterOption(
          value: 'enterprise',
          label: 'Enterprise',
          color: Color(0xFFB54708),
          backgroundColor: Color(0xFFFFF7ED),
          selectedColor: Color(0xFFB54708),
          textColor: Color(0xFF9A3412),
          selectedTextColor: Colors.white,
        ),
      ],
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterMultiSelectField<String>(
      name: 'interests',
      label: 'Interests',
      options: [
        const FormFlutterOption(
          value: 'forms',
          label: 'Forms',
          color: Color(0xFF0F766E),
          icon: Icons.view_list_outlined,
          backgroundColor: Color(0xFFF0FDFA),
          selectedColor: Color(0xFF0F766E),
          selectedTextColor: Colors.white,
        ),
        const FormFlutterOption(
          value: 'validation',
          label: 'Validation',
          color: Color(0xFF2563EB),
          icon: Icons.rule_folder_outlined,
          backgroundColor: Color(0xFFEFF6FF),
          selectedColor: Color(0xFF2563EB),
          selectedTextColor: Colors.white,
        ),
        const FormFlutterOption(
          value: 'accessibility',
          label: 'Accessibility',
          color: Color(0xFF7C3AED),
          icon: Icons.accessibility_new,
          backgroundColor: Color(0xFFF5F3FF),
          selectedColor: Color(0xFF7C3AED),
          selectedTextColor: Colors.white,
        ),
        const FormFlutterOption(
          value: 'automation',
          label: 'Automation',
          color: Color(0xFFEA580C),
          icon: Icons.bolt_outlined,
          backgroundColor: Color(0xFFFFF7ED),
          selectedColor: Color(0xFFEA580C),
          selectedTextColor: Colors.white,
        ),
        FormFlutterOption(
          value: 'analytics',
          label: 'Analytics',
          color: const Color(0xFFDC2626),
          icon: Icons.monitor_outlined,
          backgroundColor: const Color(0xFFFEF2F2),
          selectedColor: const Color(0xFFDC2626),
          selectedTextColor: Colors.white,
        ),
      ],
      validator: FormFlutterValidators.minItems<String>(1),
    ),
    const FormFlutterSliderField(
      name: 'satisfactionScore',
      label: 'Priority score',
      min: 0,
      max: 100,
      divisions: 20,
      unitLabel: 'pts',
    ),
    FormFlutterDateField(
      name: 'launchDate',
      label: 'Launch date',
      hintText: 'Select date',
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      dateFormatter: (value) =>
          '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}',
      validator: FormFlutterValidators.requiredDate(),
    ),
    FormFlutterTimeField(
      name: 'supportTime',
      label: 'Support time',
      hintText: 'Select time',
      timeFormatter: (context, value) =>
          '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}',
      validator: FormFlutterValidators.requiredTime(),
    ),
    FormFlutterDateTimeField(
      name: 'demoDateTime',
      label: 'Demo meeting',
      hintText: 'Select date and time',
    ),
    FormFlutterSwitchField(name: 'newsletter', label: 'Send updates'),
    FormFlutterCheckboxField(
      name: 'acceptTerms',
      label: 'I accept terms and privacy policy',
      validator: FormFlutterValidators.mustBeTrue(),
    ),
    FormFlutterSearchField(
      name: 'companySearch',
      label: 'Workspace search',
      hintText: 'Search teams, flows, docs',
      helperText: 'Reusable search field with clear affordance.',
    ),
    FormFlutterAutocompleteField<String>(
      name: 'city',
      label: 'Launch city',
      hintText: 'Start typing a city',
      options: const ['Dhaka', 'Tokyo', 'Berlin', 'Nairobi', 'Toronto'],
      displayStringForOption: (option) => option,
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterFileField(
      name: 'resume',
      label: 'Requirements doc',
      helperText: 'Simulated file picker so the package stays plugin-light.',
      onPick: _pickDemoFile,
      validator: FormFlutterValidators.requiredFile(),
    ),
    FormFlutterImageField(
      name: 'avatar',
      label: 'Cover image',
      helperText: 'Image field with built-in preview support.',
      onPick: _pickDemoImage,
      validator: FormFlutterValidators.combine<FormFlutterFileValue?>([
        FormFlutterValidators.requiredFile(),
        FormFlutterValidators.imageOnly(),
      ]),
    ),
    FormFlutterSignatureField(
      name: 'signature',
      label: 'Approval signature',
      helperText: 'Draw directly on canvas and keep the points serializable.',
      validator: FormFlutterValidators.requiredValue<List<List<Offset>>>(),
    ),
  ];

  late final List<FormFlutterField<dynamic>> _factoryFields =
      FormFlutterFieldFactory.buildFieldsFromPresets(
        const [
          FormFlutterFieldPreset(
            key: 'meetingMode',
            label: 'Meeting mode',
            kind: FormFlutterFieldKind.autocomplete,
            category: FormFlutterFieldCategory.appointment,
            isRequired: true,
            options: FormFlutterOptionSets.meetingModes,
          ),
        ],
      );

  late final List<FormFlutterSection> _sections = [
    FormFlutterSection(
      title: 'Registration',
      description:
          'Core identity, password, and OTP fields with sync and async validation.',
      fields: [
        _fields[0],
        _fields[1],
        _fields[2],
        _fields[3],
        _fields[5],
        _fields[6],
        _fields[7],
      ],
    ),
    FormFlutterSection(
      title: 'Project details',
      description: 'Profile, role, plan, and colored option widgets.',
      fields: [
        _fields[4],
        _fields[8],
        _fields[9],
        _fields[10],
        _fields[11],
        _fields[12],
        _fields[13],
      ],
    ),
    FormFlutterSection(
      title: 'Schedule',
      description: 'Date and time fields now support formatter hooks.',
      fields: [
        _fields[14],
        _fields[15],
        _fields[16],
        _factoryFields.first,
      ],
    ),
    FormFlutterSection(
      title: 'New field kinds',
      description:
          'Search, autocomplete, file/image preview, and serializable signature capture.',
      fields: [
        _fields[19],
        _fields[20],
        _fields[21],
        _fields[22],
        _fields[23],
      ],
    ),
    FormFlutterSection(
      title: 'Consent',
      description: 'Stepper footer, validation summary, and submit guards.',
      fields: [
        _fields[17],
        _fields[18],
      ],
    ),
  ];

  static Future<FormFlutterFileValue?> _pickDemoFile(
    BuildContext context,
    FormFlutterController controller,
  ) async {
    return FormFlutterFileValue(
      name: 'project-brief.pdf',
      sizeInBytes: 24816,
      extension: 'pdf',
      mimeType: 'application/pdf',
      bytes: Uint8List.fromList(List<int>.generate(24, (index) => index)),
    );
  }

  static Future<FormFlutterFileValue?> _pickDemoImage(
    BuildContext context,
    FormFlutterController controller,
  ) async {
    return FormFlutterFileValue(
      name: 'cover.png',
      sizeInBytes: _demoImageBytes.length,
      extension: 'png',
      mimeType: 'image/png',
      bytes: _demoImageBytes,
    );
  }

  static final Uint8List _demoImageBytes = Uint8List.fromList(const [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1,
    0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 13, 73, 68, 65, 84,
    120, 156, 99, 248, 207, 192, 240, 31, 0, 5, 0, 1, 255, 137, 153, 61, 29,
    0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
  ]);

  void _exportSnapshot() {
    setState(() {
      _savedSnapshot = _controller.toJson();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Serialized form state saved from controller.'),
      ),
    );
  }

  void _importSnapshot() {
    final savedSnapshot = _savedSnapshot;
    if (savedSnapshot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Export a snapshot first to import it.')),
      );
      return;
    }

    _controller.fromJson(savedSnapshot);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Controller restored from serialized state.'),
      ),
    );
  }

  void _resetForm() {
    _controller.reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Form reset to initial values.')),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDDFBF7), Color(0xFFF7FAFC), Color(0xFFFFF1E8)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 1040;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _BackdropGlow(),
                        const _TopBanner(),
                        const SizedBox(height: 24),
                        if (isCompact) ...[
                          _buildFormCard(context),
                          const SizedBox(height: 20),
                          _buildSummaryCard(context),
                        ] else
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 8, child: _buildFormCard(context)),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 4,
                                child: _buildSummaryCard(context),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFD7E4E2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: DynamicFormFlutter(
        controller: _controller,
        fields: _fields,
        sections: _sections,
        submitLabel: 'Create Form',
        useStepper: true,
        showValidationSummary: true,
        disableSubmitUntilDirty: true,
        scrollToFirstError: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        renderFieldsAfterHeader: true,
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              eyebrow: 'Registration Form',
              title: 'Project onboarding',
            ),
            const _SectionSummary(
              text:
                  'A polished package demo with sections, stepper navigation, validation summaries, formatter hooks, field factory output, file previews, and signature capture.',
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: _exportSnapshot,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: const Text('Export JSON'),
                ),
                OutlinedButton.icon(
                  onPressed: _importSnapshot,
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Import JSON'),
                ),
                TextButton.icon(
                  onPressed: _resetForm,
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
        onSubmit: (values) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submitted: ${values.asMap()}')),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: _PlaygroundStatePreview(
        controller: _controller,
        savedSnapshot: _savedSnapshot,
      ),
    );
  }
}

class _PlaygroundStatePreview extends StatelessWidget {
  const _PlaygroundStatePreview({
    required this.controller,
    required this.savedSnapshot,
  });

  final FormFlutterController controller;
  final Map<String, Object?>? savedSnapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        return ValueListenableBuilder<Map<String, bool>>(
          valueListenable: controller.touchedFieldsListenable,
          builder: (context, touchedFields, _) {
            return ValueListenableBuilder<Map<String, bool>>(
              valueListenable: controller.dirtyFieldsListenable,
              builder: (context, dirtyFields, _) {
                final touchedCount = touchedFields.values
                    .where((value) => value)
                    .length;
                final dirtyCount = dirtyFields.values
                    .where((value) => value)
                    .length;
                final currentJson = const JsonEncoder.withIndent(
                  '  ',
                ).convert(controller.toJson());
                final savedJson = savedSnapshot == null
                    ? 'No exported snapshot yet.'
                    : const JsonEncoder.withIndent('  ').convert(savedSnapshot);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live values',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Preview values, serialized JSON, and touched or dirty tracking while the form is edited.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        const _PreviewChip(
                          label: 'Text',
                          tone: Color(0xFF0F766E),
                        ),
                        _PreviewChip(
                          label: 'Touched $touchedCount',
                          tone: const Color(0xFF38BDF8),
                        ),
                        _PreviewChip(
                          label: 'Dirty $dirtyCount',
                          tone: const Color(0xFFF97316),
                        ),
                        _PreviewChip(
                          label: controller.hasDirtyFields
                              ? 'Unsaved'
                              : 'Clean',
                          tone: controller.hasDirtyFields
                              ? const Color(0xFFEF4444)
                              : const Color(0xFF22C55E),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _SummaryBlock(title: 'Values', content: values.toString()),
                    const SizedBox(height: 14),
                    _SummaryBlock(title: 'Current JSON', content: currentJson),
                    const SizedBox(height: 14),
                    _SummaryBlock(
                      title: 'Last Exported JSON',
                      content: savedJson,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TopBanner extends StatelessWidget {
  const _TopBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F766E), Color(0xFF115E59), Color(0xFF1D4ED8)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x220F766E),
            blurRadius: 28,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'form_flutter',
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFCCFBF1),
              letterSpacing: 1.4,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Full Example Form',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'All implemented field widgets with readable selected states, stronger styling controls, and a cleaner package showcase.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFE0F2FE),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              _BannerStat(label: 'Field types', value: '13+'),
              _BannerStat(label: 'Validation', value: 'Sync + Async'),
              _BannerStat(label: 'Styling', value: 'Per option'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BackdropGlow extends StatelessWidget {
  const _BackdropGlow();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox(
        height: 0,
        child: Stack(
          clipBehavior: Clip.none,
          children: const [
            Positioned(
              left: -20,
              top: -60,
              child: _GlowOrb(
                size: 220,
                colors: [Color(0x5514B8A6), Color(0x0014B8A6)],
              ),
            ),
            Positioned(
              right: 60,
              top: 40,
              child: _GlowOrb(
                size: 180,
                colors: [Color(0x44F97316), Color(0x00F97316)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF0F766E),
              letterSpacing: 1.0,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF101828),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionSummary extends StatelessWidget {
  const _SectionSummary({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: const Color(0xFF475467),
          height: 1.5,
        ),
      ),
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({required this.title, required this.content});

  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111827),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFE5E7EB),
              fontFamily: 'monospace',
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.label, required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(color: tone, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _BannerStat extends StatelessWidget {
  const _BannerStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x22FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: const Color(0xFFCCFBF1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
