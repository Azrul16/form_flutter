import 'package:flutter/material.dart';

import 'form_flutter_controller.dart';
import 'form_flutter_field.dart';

/// Signature for deciding whether a form section should be visible.
typedef FormFlutterSectionVisibility = bool Function(FormFlutterValues values);

/// Groups related form fields together for sectioned layouts and step flows.
class FormFlutterSection {
  /// Creates a form section with a title, fields, and optional visibility rule.
  const FormFlutterSection({
    required this.title,
    required this.fields,
    this.description,
    this.isVisible,
  });

  /// The section title shown above its fields.
  final String title;
  /// Optional supporting text shown below the section title.
  final String? description;
  /// The flat list of fields rendered when no sections are supplied.
  final List<FormFlutterField<dynamic>> fields;
  /// Optional visibility rule based on the current form values.
  final FormFlutterSectionVisibility? isVisible;
}

/// Customizable UI copy used by `DynamicFormFlutter`.
class FormFlutterUiText {
  /// Creates a bundle of overridable labels used by the form widget.
  const FormFlutterUiText({
    this.defaultTitle = 'Form Playground',
    this.defaultDescription =
        'Build forms from definitions so validation and UX stay consistent across screens.',
    this.validationSummaryTitle = 'Please fix the following fields:',
    this.asyncValidationLabel = 'Validating...',
    this.continueLabel = 'Continue',
    this.backLabel = 'Back',
    this.stepLabelPrefix = 'Step',
  });

  /// Default title shown when no custom header is provided.
  final String defaultTitle;
  /// Default description shown when no custom header is provided.
  final String defaultDescription;
  /// Heading used for the validation summary panel.
  final String validationSummaryTitle;
  /// Label shown while a field is validating asynchronously.
  final String asyncValidationLabel;
  /// Button label for advancing to the next step.
  final String continueLabel;
  /// Button label for returning to the previous step.
  final String backLabel;
  /// Prefix used when formatting step progress text.
  final String stepLabelPrefix;

  /// Builds the visible step progress label.
  String stepLabel(int current, int total) {
    return '$stepLabelPrefix $current of $total';
  }
}

/// Renders a dynamic form from field definitions and a shared controller.
class DynamicFormFlutter extends StatefulWidget {
  /// Creates a dynamic form widget driven by field definitions.
  const DynamicFormFlutter({
    super.key,
    required this.controller,
    required this.fields,
    required this.onSubmit,
    this.sections,
    this.submitLabel = 'Submit',
    this.header,
    this.renderFieldsAfterHeader = false,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.scrollToFirstError = false,
    this.showValidationSummary = false,
    this.disableSubmitUntilValid = false,
    this.disableSubmitUntilDirty = false,
    this.showAsyncValidationHints = true,
    this.useStepper = false,
    this.fieldSpacing = 16,
    this.sectionSpacing = 24,
    this.uiText = const FormFlutterUiText(),
  });

  /// The controller that stores values, errors, and interaction state.
  final FormFlutterController controller;
  /// The flat list of fields rendered when no sections are supplied.
  final List<FormFlutterField<dynamic>> fields;
  /// Optional grouped sections used for grouped or stepped layouts.
  final List<FormFlutterSection>? sections;
  /// Called with the latest values when the form is submitted successfully.
  final ValueChanged<FormFlutterValues> onSubmit;
  /// Label used by the primary submit button.
  final String submitLabel;
  /// Optional custom header widget shown above the form body.
  final Widget? header;
  /// Whether a custom header should be followed by the generated fields.
  final bool renderFieldsAfterHeader;
  /// Controls when validation errors are recomputed automatically.
  final AutovalidateMode autovalidateMode;
  /// Whether the form should scroll to the first invalid field.
  final bool scrollToFirstError;
  /// Whether to render a summary panel for visible validation errors.
  final bool showValidationSummary;
  /// Whether the submit action should remain disabled until fields are valid.
  final bool disableSubmitUntilValid;
  /// Whether the submit action should remain disabled until changes are made.
  final bool disableSubmitUntilDirty;
  /// Whether async validation progress indicators should be shown.
  final bool showAsyncValidationHints;
  /// Whether the form should render one section at a time as a stepper.
  final bool useStepper;
  /// Vertical spacing between rendered fields.
  final double fieldSpacing;
  /// Vertical spacing between rendered sections.
  final double sectionSpacing;
  /// Text overrides used by the form widget.
  final FormFlutterUiText uiText;

  @override
  State<DynamicFormFlutter> createState() => _DynamicFormFlutterState();
}

class _DynamicFormFlutterState extends State<DynamicFormFlutter> {
  final Map<String, GlobalKey> _fieldKeys = <String, GlobalKey>{};
  bool _submitting = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.valuesListenable.addListener(_handleValueChange);
  }

  @override
  void didUpdateWidget(covariant DynamicFormFlutter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.valuesListenable.removeListener(_handleValueChange);
      widget.controller.valuesListenable.addListener(_handleValueChange);
    }
  }

  @override
    void dispose() {
    widget.controller.valuesListenable.removeListener(_handleValueChange);
    super.dispose();
  }

  void _handleValueChange() {
    if (!mounted) {
      return;
    }
    if (widget.autovalidateMode == AutovalidateMode.disabled) {
      setState(() {});
      return;
    }

    for (final field in _visibleFields) {
      widget.controller.setError(field.name, field.validate(widget.controller));
    }
    setState(() {});
  }

  List<FormFlutterSection> get _visibleSections {
    final sections = widget.sections ??
        [
          FormFlutterSection(
            title: '',
            fields: widget.fields,
          ),
        ];
    final values = widget.controller.snapshot;
    return sections.where((section) => section.isVisible?.call(values) ?? true).toList();
  }

  List<FormFlutterField<dynamic>> get _visibleFields {
    return [
      for (final section in _visibleSections) ...section.fields,
    ];
  }

  List<FormFlutterField<dynamic>> get _currentStepFields {
    if (!widget.useStepper || _visibleSections.isEmpty) {
      return _visibleFields;
    }
    final clampedIndex = _currentStep.clamp(0, _visibleSections.length - 1);
    return _visibleSections[clampedIndex].fields;
  }

  Future<void> _handleSubmit({
    List<FormFlutterField<dynamic>>? scopedFields,
    bool advanceStep = false,
  }) async {
    final fields = scopedFields ?? _visibleFields;
    final isValid = await _validateFields(
      fields,
      scrollOnError: widget.scrollToFirstError,
    );
    if (!isValid) {
      setState(() {});
      return;
    }

    if (advanceStep && widget.useStepper && _currentStep < _visibleSections.length - 1) {
      setState(() {
        _currentStep++;
      });
      return;
    }

    widget.onSubmit(widget.controller.snapshot);
    setState(() {});
  }

  Future<bool> _validateFields(
    List<FormFlutterField<dynamic>> fields, {
    required bool scrollOnError,
  }) async {
    var isValid = true;
    FormFlutterField<dynamic>? firstInvalidField;

    for (final field in fields) {
      final error = field.validate(widget.controller);
      widget.controller.setError(field.name, error);
      if (error != null) {
        isValid = false;
        firstInvalidField ??= field;
      }
    }

    if (!isValid) {
      if (scrollOnError && firstInvalidField != null) {
        await _scrollToField(firstInvalidField.name);
      }
      return false;
    }

    setState(() {
      _submitting = true;
    });

    for (final field in fields) {
      if (!field.hasAsyncValidator) {
        continue;
      }
      widget.controller.setAsyncValidating(field.name, true);
      final error = await field.validateAsync(widget.controller);
      widget.controller.setAsyncValidating(field.name, false);
      widget.controller.setError(field.name, error);
      if (error != null) {
        isValid = false;
        firstInvalidField ??= field;
      }
    }

    setState(() {
      _submitting = false;
    });

    if (!isValid && scrollOnError && firstInvalidField != null) {
      await _scrollToField(firstInvalidField.name);
    }
    return isValid;
  }

  Future<void> _scrollToField(String name) async {
    final key = _fieldKeys[name];
    final context = key?.currentContext;
    if (context == null) {
      return;
    }
    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 250),
      alignment: 0.15,
      curve: Curves.easeOut,
    );
  }

  bool get _submitDisabled {
    final targetFields = widget.useStepper ? _currentStepFields : _visibleFields;
    if (_submitting) {
      return true;
    }
    if (widget.disableSubmitUntilDirty && !widget.controller.hasDirtyFields) {
      return true;
    }
    if (!widget.disableSubmitUntilValid) {
      return false;
    }
    return targetFields.any((field) => field.validate(widget.controller) != null);
  }

  List<String> get _visibleErrors {
    final errors = <String>[];
    for (final field in _visibleFields) {
      final error = widget.controller.error(field.name);
      if (error != null && error.isNotEmpty) {
        errors.add('${field.label}: $error');
      }
    }
    return errors;
  }

  Widget _buildField(FormFlutterField<dynamic> field) {
    final fieldKey = _fieldKeys.putIfAbsent(field.name, GlobalKey.new);
    return KeyedSubtree(
      key: fieldKey,
      child: ValueListenableBuilder<Map<String, bool>>(
        valueListenable: widget.controller.asyncStatesListenable,
        builder: (context, asyncStates, _) {
          final isValidating = asyncStates[field.name] ?? false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              field.buildField(widget.controller),
              if (widget.showAsyncValidationHints && isValidating) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.uiText.asyncValidationLabel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF667085),
                          ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(FormFlutterSection section) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.title.isNotEmpty)
          Text(
            section.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        if (section.title.isNotEmpty && section.description != null) ...[
          const SizedBox(height: 6),
          Text(
            section.description!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF667085),
                ),
          ),
        ],
        SizedBox(height: section.title.isNotEmpty ? 16 : 0),
        for (var i = 0; i < section.fields.length; i++) ...[
          _buildField(section.fields[i]),
          if (i != section.fields.length - 1)
            SizedBox(height: widget.fieldSpacing),
        ],
      ],
    );
  }

  Widget _buildBody() {
    if (widget.header != null && !widget.renderFieldsAfterHeader) {
      return widget.header!;
    }

    final children = <Widget>[];
    if (widget.header != null) {
      children.add(widget.header!);
      children.add(SizedBox(height: widget.sectionSpacing));
    }

    if (widget.useStepper && _visibleSections.isNotEmpty) {
      final stepIndex = _currentStep.clamp(0, _visibleSections.length - 1);
      children.add(
        Text(
          widget.uiText.stepLabel(stepIndex + 1, _visibleSections.length),
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF667085),
                fontWeight: FontWeight.w700,
              ),
        ),
      );
      children.add(const SizedBox(height: 12));
      children.add(_buildSection(_visibleSections[stepIndex]));
    } else {
      if (widget.sections == null) {
        for (var i = 0; i < widget.fields.length; i++) {
          children.add(_buildField(widget.fields[i]));
          if (i != widget.fields.length - 1) {
            children.add(SizedBox(height: widget.fieldSpacing));
          }
        }
      } else {
        for (var i = 0; i < _visibleSections.length; i++) {
          children.add(_buildSection(_visibleSections[i]));
          if (i != _visibleSections.length - 1) {
            children.add(SizedBox(height: widget.sectionSpacing));
          }
        }
      }
    }

    if (widget.header == null) {
      children.insert(
        0,
        Text(
          widget.uiText.defaultTitle,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      );
      children.insert(1, const SizedBox(height: 8));
      children.insert(
        2,
        Text(
          widget.uiText.defaultDescription,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475467),
              ),
        ),
      );
      children.insert(3, const SizedBox(height: 24));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildFooter() {
    if (widget.useStepper && _visibleSections.isNotEmpty) {
      final isLastStep = _currentStep >= _visibleSections.length - 1;
      return Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting
                    ? null
                    : () {
                        setState(() {
                          _currentStep--;
                        });
                      },
                child: Text(widget.uiText.backLabel),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _submitDisabled
                  ? null
                  : () {
                      _handleSubmit(
                        scopedFields: _currentStepFields,
                        advanceStep: !isLastStep,
                      );
                    },
              child: Text(
                isLastStep ? widget.submitLabel : widget.uiText.continueLabel,
              ),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: _submitDisabled
            ? null
            : () {
                _handleSubmit();
              },
        child: Text(widget.submitLabel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, String?>>(
      valueListenable: widget.controller.errorsListenable,
      builder: (context, _, _) {
        final visibleErrors = _visibleErrors;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBody(),
            if (widget.showValidationSummary && visibleErrors.isNotEmpty) ...[
              SizedBox(height: widget.sectionSpacing),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.uiText.validationSummaryTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF991B1B),
                          ),
                    ),
                    const SizedBox(height: 8),
                    for (final error in visibleErrors)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          error,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFB42318),
                              ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            SizedBox(height: widget.sectionSpacing),
            _buildFooter(),
          ],
        );
      },
    );
  }
}
