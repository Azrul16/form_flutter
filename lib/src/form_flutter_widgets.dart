import 'package:flutter/material.dart';

import 'form_flutter_controller.dart';
import 'form_flutter_field.dart';

class DynamicFormFlutter extends StatefulWidget {
  const DynamicFormFlutter({
    super.key,
    required this.controller,
    required this.fields,
    required this.onSubmit,
    this.submitLabel = 'Submit',
  });

  final FormFlutterController controller;
  final List<FormFlutterField<dynamic>> fields;
  final ValueChanged<FormFlutterValues> onSubmit;
  final String submitLabel;

  @override
  State<DynamicFormFlutter> createState() => _DynamicFormFlutterState();
}

class _DynamicFormFlutterState extends State<DynamicFormFlutter> {
  bool _submitting = false;

  Future<void> _handleSubmit() async {
    var isValid = true;
    for (final field in widget.fields) {
      final error = field.validate(widget.controller);
      widget.controller.setError(field.name, error);
      if (error != null) {
        isValid = false;
      }
    }

    if (!isValid) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    for (final field in widget.fields) {
      if (field.asyncValidator == null) {
        continue;
      }
      widget.controller.setAsyncValidating(field.name, true);
      final error = await field.validateAsync(widget.controller);
      widget.controller.setAsyncValidating(field.name, false);
      widget.controller.setError(field.name, error);
      if (error != null) {
        isValid = false;
      }
    }

    if (isValid) {
      widget.onSubmit(widget.controller.snapshot);
    }
    setState(() {
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Form Playground',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Build forms from definitions so validation and UX stay consistent across screens.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475467),
              ),
        ),
        const SizedBox(height: 24),
        for (final field in widget.fields) ...[
          field.buildField(widget.controller),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _submitting ? null : _handleSubmit,
            child: Text(widget.submitLabel),
          ),
        ),
      ],
    );
  }
}
