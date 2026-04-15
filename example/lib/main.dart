import 'dart:convert';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_flutter/form_flutter.dart';

void main() {
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ExampleApp(),
    ),
  );
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'form_flutter example',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155EEF),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FB),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF155EEF), width: 1.5),
          ),
        ),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  Map<String, Object?>? _savedSnapshot;

  late final FormFlutterSchema _schema = FormFlutterSchema(
    initialValues: const {
      'schemaPhoneCountry': 'US',
      'experience': 4.0,
      'newsletter': true,
      'timezone': 'utc_minus_5',
    },
    sections: [
      FormFlutterSchemaSection(
        title: 'Account basics',
        description:
            'Generated from presets with local screen-specific overrides.',
        fields: [
          FormFlutterSchemaField.fromPreset(
            FormFlutterCatalog.accountFields.firstWhere(
              (preset) => preset.key == 'username',
            ),
            label: 'Public username',
            helperText: 'Visible to your team in shared workspaces.',
            hintText: '@ada',
            initialValue: 'ada_team',
            decorationOverride: const InputDecoration(
              prefixIcon: Icon(Icons.alternate_email),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
          FormFlutterSchemaField.fromPreset(
            FormFlutterCatalog.contactInformation.firstWhere(
              (preset) => preset.key == 'phone',
            ),
            name: 'supportPhone',
            label: 'Support phone',
            countryFieldName: 'schemaPhoneCountry',
            allowedCountryCodes: const ['US', 'CA'],
            showCountryFlagInSelector: false,
            nationalNumberHintText: '5551234567',
            helperText: 'Used only for customer-facing contact points.',
          ),
        ],
      ),
      const FormFlutterSchemaSection(
        title: 'Preferences',
        description:
            'Mixed generated fields without any custom field factories.',
        fields: [
          FormFlutterSchemaField(
            name: 'experience',
            kind: FormFlutterFieldKind.slider,
            label: 'Experience',
            helperText: 'How experienced is this owner with production forms?',
            sliderMin: 1,
            sliderMax: 10,
            sliderDivisions: 9,
            sliderUnitLabel: 'years',
          ),
          FormFlutterSchemaField(
            name: 'timezone',
            kind: FormFlutterFieldKind.dropdown,
            label: 'Primary timezone',
            options: [
              FormFlutterOption(value: 'utc_minus_5', label: 'UTC-5'),
              FormFlutterOption(value: 'utc_plus_0', label: 'UTC+0'),
              FormFlutterOption(value: 'utc_plus_6', label: 'UTC+6'),
            ],
            isRequired: true,
            helperText:
                'Useful for routing notifications and support coverage.',
          ),
          FormFlutterSchemaField(
            name: 'newsletter',
            kind: FormFlutterFieldKind.switchField,
            label: 'Receive release updates',
            helperText:
                'See how boolean fields can also be generated from schema.',
          ),
        ],
      ),
    ],
  );

  late final FormFlutterController _schemaController =
      FormFlutterFieldFactory.buildControllerFromSchema(_schema);
  late final List<FormFlutterSection> _schemaSections =
      FormFlutterFieldFactory.buildSectionsFromSchema(_schema);

  final FormFlutterController _controller = FormFlutterController(
    initialValues: const {
      'fullName': '',
      'email': '',
      'phone': '',
      'phoneCountry': 'US',
      'password': '',
      'team': 'product',
      'interests': <String>['analytics'],
      'priority': 65.0,
      'available': true,
      'startDate': null,
    },
  );

  late final List<FormFlutterField<dynamic>> _fields = [
    FormFlutterTextField(
      name: 'fullName',
      label: 'Full name',
      decorationOverride: const InputDecoration(
        prefixIcon: Icon(Icons.person_outline),
        fillColor: Color(0xFFF8FBFF),
      ),
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.minLength(3),
      ]),
    ),
    FormFlutterTextField(
      name: 'email',
      label: 'Email',
      keyboardType: TextInputType.emailAddress,
      decorationOverride: const InputDecoration(
        prefixIcon: Icon(Icons.mail_outline),
      ),
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.email(),
      ]),
      asyncValidator: FormFlutterValidators.uniqueEmail(
        (email, _) async => email != 'taken@example.com',
      ),
    ),
    FormFlutterPhoneField(
      name: 'phone',
      label: 'Phone',
      countryFieldName: 'phoneCountry',
      initialCountryCode: 'US',
      showCountryFlagInSelector: false,
      showCountryIsoCodeInSelector: true,
      showCountryDialCodeInSelector: true,
      nationalNumberHintText: 'Enter phone number',
      validator: FormFlutterValidators.combine([
        FormFlutterValidators.requiredText(),
        FormFlutterValidators.numericText(),
      ]),
    ),
    FormFlutterTextField(
      name: 'password',
      label: 'Password',
      hintText: 'Create password',
      obscureText: true,
      enableObscureTextToggle: true,
      decorationOverride: const InputDecoration(
        prefixIcon: Icon(Icons.lock_outline),
      ),
      validator: FormFlutterPresetValidators.strongPassword(),
    ),
    FormFlutterDropdownField<String>(
      name: 'team',
      label: 'Team',
      decorationOverride: const InputDecoration(
        prefixIcon: Icon(Icons.groups_2_outlined),
      ),
      options: const [
        FormFlutterOption(
          value: 'design',
          label: 'Design',
          color: Color(0xFF7C3AED),
          icon: Icons.brush_outlined,
          indicatorSize: 16,
        ),
        FormFlutterOption(
          value: 'product',
          label: 'Product',
          color: Color(0xFFEA580C),
          icon: Icons.insights_outlined,
          indicatorSize: 16,
        ),
        FormFlutterOption(
          value: 'engineering',
          label: 'Engineering',
          color: Color(0xFF2563EB),
          icon: Icons.code,
          indicatorSize: 16,
        ),
      ],
      validator: FormFlutterValidators.requiredSelection<String>(),
    ),
    FormFlutterMultiSelectField<String>(
      name: 'interests',
      label: 'Interests',
      options: [
        const FormFlutterOption(
          value: 'automation',
          label: 'Automation',
          color: Color(0xFFEA580C),
          backgroundColor: Color(0xFFFFF7ED),
          selectedColor: Color(0xFFEA580C),
          selectedTextColor: Colors.white,
          icon: Icons.bolt_outlined,
        ),
        FormFlutterOption(
          value: 'analytics',
          label: 'Analytics',
          color: const Color(0xFFDC2626),
          backgroundColor: const Color(0xFFFEF2F2),
          selectedColor: const Color(0xFFDC2626),
          selectedTextColor: Colors.white,
          icon: Icons.monitor_outlined,
        ),
        const FormFlutterOption(
          value: 'accessibility',
          label: 'Accessibility',
          color: Color(0xFF7C3AED),
          backgroundColor: Color(0xFFF5F3FF),
          selectedColor: Color(0xFF7C3AED),
          selectedTextColor: Colors.white,
          icon: Icons.accessibility_new,
        ),
      ],
      optionBuilder: (context, option, isSelected) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (option.selectedColor ?? option.color ?? Colors.blue)
                : (option.backgroundColor ?? Colors.white),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  option.borderColor ?? option.color ?? const Color(0xFFD0D5DD),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size: 16,
                  color: isSelected
                      ? (option.selectedTextColor ?? Colors.white)
                      : (option.color ?? const Color(0xFF344054)),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                option.label,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? (option.selectedTextColor ?? Colors.white)
                      : (option.textColor ?? const Color(0xFF344054)),
                ),
              ),
            ],
          ),
        );
      },
      validator: FormFlutterValidators.minItems<String>(1),
    ),
    FormFlutterSliderField(
      name: 'priority',
      label: 'Priority',
      min: 0,
      max: 100,
      divisions: 20,
      unitLabel: 'pts',
      activeColor: const Color(0xFF155EEF),
      inactiveColor: const Color(0xFFD0D5DD),
      thumbColor: const Color(0xFF155EEF),
      valueStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        color: Color(0xFF155EEF),
      ),
    ),
    FormFlutterDateField(
      name: 'startDate',
      label: 'Start date',
      decorationOverride: const InputDecoration(
        prefixIcon: Icon(Icons.calendar_month_outlined),
      ),
      validator: FormFlutterValidators.requiredDate(),
    ),
    FormFlutterSwitchField(
      name: 'available',
      label: 'Available for contact',
      activeColor: const Color(0xFF155EEF),
      titleStyle: const TextStyle(fontWeight: FontWeight.w700),
      decoration: const InputDecoration(fillColor: Color(0xFFF8FBFF)),
    ),
  ];

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

  void _resetSchemaForm() {
    _schemaController.reset();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schema-generated form reset to initial values.'),
      ),
    );
  }

  @override
  void dispose() {
    _schemaController.dispose();
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
            colors: [Color(0xFFEFF6FF), Color(0xFFF4F7FB), Color(0xFFFFF7ED)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 980),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ExampleHeader(),
                    const SizedBox(height: 20),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 820;
                          final formCards = <Widget>[
                            _ExampleCard(
                              child: DynamicFormFlutter(
                                controller: _controller,
                                fields: _fields,
                                submitLabel: 'Submit example form',
                                header: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Styled example',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'This v1.0.2 sample uses decoration overrides, option colors, icons, a country-aware phone field, explicit picker UX, and controller serialization helpers.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF475467),
                                          ),
                                    ),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        FilledButton.icon(
                                          onPressed: _exportSnapshot,
                                          icon: const Icon(
                                            Icons.upload_file_outlined,
                                          ),
                                          label: const Text('Export JSON'),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed: _importSnapshot,
                                          icon: const Icon(
                                            Icons.download_outlined,
                                          ),
                                          label: const Text('Import JSON'),
                                        ),
                                        TextButton.icon(
                                          onPressed: _resetForm,
                                          icon: const Icon(
                                            Icons.restart_alt_outlined,
                                          ),
                                          label: const Text('Reset'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    _ExampleGrid(
                                      children: [
                                        _ExampleFieldCard(
                                          child: _fields[0].buildField(
                                            _controller,
                                          ),
                                        ),
                                        _ExampleFieldCard(
                                          child: _fields[1].buildField(
                                            _controller,
                                          ),
                                        ),
                                        _ExampleFieldCard(
                                          child: _fields[2].buildField(
                                            _controller,
                                          ),
                                        ),
                                        _ExampleFieldCard(
                                          child: _fields[3].buildField(
                                            _controller,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    _ExampleFieldCard(
                                      child: _fields[4].buildField(_controller),
                                    ),
                                    const SizedBox(height: 14),
                                    _ExampleFieldCard(
                                      child: _fields[5].buildField(_controller),
                                    ),
                                    const SizedBox(height: 14),
                                    _ExampleGrid(
                                      children: [
                                        _ExampleFieldCard(
                                          child: _fields[6].buildField(
                                            _controller,
                                          ),
                                        ),
                                        _ExampleFieldCard(
                                          child: _fields[7].buildField(
                                            _controller,
                                          ),
                                        ),
                                        _ExampleFieldCard(
                                          child: _fields[8].buildField(
                                            _controller,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                                onSubmit: (values) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Submitted: ${values.asMap()}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            _ExampleCard(
                              child: DynamicFormFlutter(
                                controller: _schemaController,
                                fields: const [],
                                sections: _schemaSections,
                                useStepper: true,
                                disableSubmitUntilDirty: true,
                                showValidationSummary: true,
                                submitLabel: 'Submit schema form',
                                header: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Schema-generated example',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'This v1.0.2 sample uses FormFlutterSchema plus preset overrides to build a stepper form with stronger generated validation and without custom field factories.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: const Color(0xFF475467),
                                          ),
                                    ),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: [
                                        FilledButton.tonalIcon(
                                          onPressed: _resetSchemaForm,
                                          icon: const Icon(
                                            Icons.schema_outlined,
                                          ),
                                          label: const Text(
                                            'Reset schema form',
                                          ),
                                        ),
                                        _InlineInfoChip(
                                          label:
                                              '${_schemaSections.length} sections',
                                        ),
                                        const _InlineInfoChip(
                                          label: 'Preset overrides',
                                        ),
                                        const _InlineInfoChip(
                                          label: 'Generated fields',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                ),
                                onSubmit: (values) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Schema submit: ${values.asMap()}',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ];

                          final preview = _ExampleCard(
                            dark: true,
                            child: _ExampleStatePreview(
                              controller: _controller,
                              savedSnapshot: _savedSnapshot,
                            ),
                          );

                          if (compact) {
                            return ListView(
                              children: [
                                ...formCards,
                                const SizedBox(height: 20),
                                preview,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 7,
                                child: ListView(children: formCards),
                              ),
                              const SizedBox(width: 20),
                              Expanded(flex: 4, child: preview),
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
      ),
    );
  }
}

class _ExampleStatePreview extends StatelessWidget {
  const _ExampleStatePreview({
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
                      'Live preview',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Watch values, serialized JSON, and touched/dirty state update together.',
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
                    _PreviewBlock(title: 'Values', content: values.toString()),
                    const SizedBox(height: 14),
                    _PreviewBlock(title: 'Current JSON', content: currentJson),
                    const SizedBox(height: 14),
                    _PreviewBlock(
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

class _ExampleHeader extends StatelessWidget {
  const _ExampleHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [Color(0xFF155EEF), Color(0xFF1D4ED8), Color(0xFF7C3AED)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'form_flutter example',
            style: theme.textTheme.labelLarge?.copyWith(
              color: const Color(0xFFDBEAFE),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Detailed Styling and Schema Example',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'v1.0.2 explores direct field definitions, controller helpers, explicit picker UX, and schema-generated forms in one example app.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: const Color(0xFFE0EAFF),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  const _ExampleCard({required this.child, this.dark = false});

  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: dark
            ? const Color(0xFF0F172A)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: dark ? const Color(0xFF1F2937) : const Color(0xFFD7E2F2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ExampleGrid extends StatelessWidget {
  const _ExampleGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1) const SizedBox(height: 14),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final child in children)
              SizedBox(width: (constraints.maxWidth - 14) / 2, child: child),
          ],
        );
      },
    );
  }
}

class _InlineInfoChip extends StatelessWidget {
  const _InlineInfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF4FF),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFD0DDFB)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF155EEF),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PreviewBlock extends StatelessWidget {
  const _PreviewBlock({required this.title, required this.content});

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
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF1F2937)),
          ),
          child: Text(
            content,
            style: const TextStyle(
              color: Color(0xFFE5E7EB),
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

class _ExampleFieldCard extends StatelessWidget {
  const _ExampleFieldCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: child,
    );
  }
}
