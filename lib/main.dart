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
      validator: FormFlutterValidators.requiredDate(),
    ),
    FormFlutterTimeField(
      name: 'supportTime',
      label: 'Support time',
      hintText: 'Select time',
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
  ];

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
        color: Colors.white.withOpacity(0.9),
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
        submitLabel: 'Create Form',
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionHeader(
              eyebrow: 'Registration Form',
              title: 'Project onboarding',
            ),
            const _SectionSummary(
              text:
                  'A polished package demo with validations, styled options, password controls, and scheduling inputs.',
            ),
            _ResponsiveFieldGrid(
              children: [
                _FieldCard(child: _fields[0].buildField(_controller)),
                _FieldCard(child: _fields[1].buildField(_controller)),
                _FieldCard(child: _fields[2].buildField(_controller)),
                _FieldCard(child: _fields[3].buildField(_controller)),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionHeader(eyebrow: 'Profile', title: 'Project details'),
            _FieldCard(child: _fields[4].buildField(_controller)),
            const SizedBox(height: 12),
            _ResponsiveFieldGrid(
              children: [
                _FieldCard(child: _fields[5].buildField(_controller)),
                _FieldCard(child: _fields[6].buildField(_controller)),
                _FieldCard(child: _fields[7].buildField(_controller)),
                _FieldCard(child: _fields[8].buildField(_controller)),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionHeader(
              eyebrow: 'Preferences',
              title: 'Colored options',
            ),
            const _SectionSummary(
              text:
                  'Selected dropdown values now invert against their background so the active choice stays readable.',
            ),
            _ResponsiveFieldGrid(
              children: [
                _FieldCard(child: _fields[9].buildField(_controller)),
                _FieldCard(child: _fields[10].buildField(_controller)),
              ],
            ),
            const SizedBox(height: 12),
            _FieldCard(child: _fields[11].buildField(_controller)),
            const SizedBox(height: 12),
            _FieldCard(child: _fields[12].buildField(_controller)),
            const SizedBox(height: 12),
            _FieldCard(child: _fields[13].buildField(_controller)),
            const SizedBox(height: 20),
            const _SectionHeader(eyebrow: 'Schedule', title: 'Planning'),
            const _SectionSummary(
              text:
                  'Use date, time, and date-time pickers together for a complete workflow.',
            ),
            _ResponsiveFieldGrid(
              children: [
                _FieldCard(child: _fields[14].buildField(_controller)),
                _FieldCard(child: _fields[15].buildField(_controller)),
                _FieldCard(child: _fields[16].buildField(_controller)),
              ],
            ),
            const SizedBox(height: 20),
            const _SectionHeader(eyebrow: 'Final', title: 'Consent'),
            _FieldCard(child: _fields[17].buildField(_controller)),
            const SizedBox(height: 12),
            _FieldCard(child: _fields[18].buildField(_controller)),
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
    final theme = Theme.of(context);
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
      child: ValueListenableBuilder<Map<String, Object?>>(
        valueListenable: _controller.valuesListenable,
        builder: (context, values, _) {
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
                'Preview how your controller state changes while the form is edited.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF94A3B8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: const [
                  _PreviewChip(label: 'Text', tone: Color(0xFF0F766E)),
                  _PreviewChip(label: 'Select', tone: Color(0xFF1D4ED8)),
                  _PreviewChip(label: 'Date', tone: Color(0xFFB45309)),
                  _PreviewChip(label: 'Toggle', tone: Color(0xFF7C3AED)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111827),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF1F2937)),
                ),
                child: Text(
                  values.toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE5E7EB),
                    fontFamily: 'monospace',
                    height: 1.5,
                  ),
                ),
              ),
            ],
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

class _ResponsiveFieldGrid extends StatelessWidget {
  const _ResponsiveFieldGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final twoColumns = constraints.maxWidth > 700;
        if (!twoColumns) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 12),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += 2) {
          rows.add(
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: children[i]),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1) const SizedBox(height: 12),
            ],
          ],
        );
      },
    );
  }
}

class _FieldCard extends StatelessWidget {
  const _FieldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
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
        color: tone.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tone.withOpacity(0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: tone,
          fontWeight: FontWeight.w600,
        ),
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
