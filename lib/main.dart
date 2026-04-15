import 'dart:typed_data';

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
      FormFlutterFieldFactory.buildFieldsFromPresets(const [
        FormFlutterFieldPreset(
          key: 'meetingMode',
          label: 'Meeting mode',
          kind: FormFlutterFieldKind.autocomplete,
          category: FormFlutterFieldCategory.appointment,
          isRequired: true,
          options: FormFlutterOptionSets.meetingModes,
        ),
      ]);

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
    137,
    80,
    78,
    71,
    13,
    10,
    26,
    10,
    0,
    0,
    0,
    13,
    73,
    72,
    68,
    82,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    1,
    8,
    6,
    0,
    0,
    0,
    31,
    21,
    196,
    137,
    0,
    0,
    0,
    13,
    73,
    68,
    65,
    84,
    120,
    156,
    99,
    248,
    207,
    192,
    240,
    31,
    0,
    5,
    0,
    1,
    255,
    137,
    153,
    61,
    29,
    0,
    0,
    0,
    0,
    73,
    69,
    78,
    68,
    174,
    66,
    96,
    130,
  ]);

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
                        _buildFormCard(context),
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
        fields: [..._fields, ..._factoryFields],
        submitLabel: 'Create Form',
        showValidationSummary: true,
        scrollToFirstError: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onSubmit: (values) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Submitted: ${values.asMap()}')),
          );
        },
      ),
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
            'Full Example Form',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
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
