import 'package:flutter/material.dart';

import 'form_flutter_controller.dart';

typedef FormFlutterValidator<T> = String? Function(
  T value,
  FormFlutterValues values,
);

typedef FormFlutterAsyncValidator<T> = Future<String?> Function(
  T value,
  FormFlutterValues values,
);

class FormFlutterOption<T> {
  const FormFlutterOption({
    required this.value,
    required this.label,
  });

  final T value;
  final String label;
}

class FormFlutterFileValue {
  const FormFlutterFileValue({
    required this.name,
    required this.sizeInBytes,
    this.extension,
    this.mimeType,
  });

  final String name;
  final int sizeInBytes;
  final String? extension;
  final String? mimeType;
}

abstract class FormFlutterField<T> {
  const FormFlutterField({
    required this.name,
    required this.label,
    this.helperText,
    this.validator,
    this.asyncValidator,
  });

  final String name;
  final String label;
  final String? helperText;
  final FormFlutterValidator<T>? validator;
  final FormFlutterAsyncValidator<T>? asyncValidator;

  T normalizeValue(Object? rawValue);

  Widget buildField(FormFlutterController controller);

  String? validate(FormFlutterController controller) {
    final values = controller.snapshot;
    return validator?.call(
      normalizeValue(values.asMap()[name]),
      values,
    );
  }

  Future<String?> validateAsync(FormFlutterController controller) async {
    final values = controller.snapshot;
    final validator = asyncValidator;
    if (validator == null) {
      return null;
    }
    return validator(
      normalizeValue(values.asMap()[name]),
      values,
    );
  }
}

abstract class _FormFlutterInputField<T> extends FormFlutterField<T> {
  const _FormFlutterInputField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.hintText,
  });

  final String? hintText;

  InputDecoration decoration(FormFlutterController controller) {
    return InputDecoration(
      labelText: label,
      hintText: hintText,
      helperText: helperText,
      errorText: controller.error(name),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class FormFlutterTextField extends _FormFlutterInputField<String> {
  const FormFlutterTextField({
    required super.name,
    required super.label,
    super.hintText,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.obscureText = false,
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final bool obscureText;

  @override
  String normalizeValue(Object? rawValue) {
    return (rawValue ?? '').toString();
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, String?>>(
      valueListenable: controller.errorsListenable,
      builder: (context, _, __) {
        return TextFormField(
          initialValue: normalizeValue(controller.snapshot.asMap()[name]),
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscureText ? 1 : maxLines,
          obscureText: obscureText,
          onChanged: (value) {
            controller.setValue(name, value);
            controller.setError(name, null);
          },
          decoration: decoration(controller),
        );
      },
    );
  }
}

class FormFlutterNumberField extends _FormFlutterInputField<double?> {
  const FormFlutterNumberField({
    required super.name,
    required super.label,
    super.hintText,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.allowDecimals = true,
  });

  final bool allowDecimals;

  @override
  double? normalizeValue(Object? rawValue) {
    if (rawValue is num) {
      return rawValue.toDouble();
    }
    if (rawValue == null) {
      return null;
    }
    return double.tryParse(rawValue.toString());
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, String?>>(
      valueListenable: controller.errorsListenable,
      builder: (context, _, __) {
        final existingValue = controller.snapshot.asMap()[name];
        final initialValue =
            existingValue == null ? '' : existingValue.toString();
        return TextFormField(
          initialValue: initialValue,
          keyboardType: TextInputType.numberWithOptions(
            decimal: allowDecimals,
            signed: false,
          ),
          onChanged: (value) {
            controller.setValue(name, value);
            controller.setError(name, null);
          },
          decoration: decoration(controller),
        );
      },
    );
  }
}

class FormFlutterDropdownField<T> extends _FormFlutterInputField<T?> {
  const FormFlutterDropdownField({
    required super.name,
    required super.label,
    required this.options,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.hintText,
  }) : super(hintText: null);

  final List<FormFlutterOption<T>> options;
  final String? hintText;

  @override
  T? normalizeValue(Object? rawValue) {
    return rawValue as T?;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, __, ___) {
            return DropdownButtonFormField<T>(
              value: normalizeValue(values[name]),
              decoration: InputDecoration(
                labelText: label,
                helperText: helperText,
                hintText: hintText,
                errorText: controller.error(name),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              items: [
                for (final option in options)
                  DropdownMenuItem<T>(
                    value: option.value,
                    child: Text(option.label),
                  ),
              ],
              onChanged: (value) {
                controller.setValue(name, value);
                controller.setError(name, null);
              },
            );
          },
        );
      },
    );
  }
}

class FormFlutterRadioGroupField<T> extends FormFlutterField<T?> {
  const FormFlutterRadioGroupField({
    required super.name,
    required super.label,
    required this.options,
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  final List<FormFlutterOption<T>> options;

  @override
  T? normalizeValue(Object? rawValue) {
    return rawValue as T?;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, __) {
            final selected = normalizeValue(values[name]);
            return InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                helperText: helperText,
                errorText: errors[name],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                children: [
                  for (final option in options)
                    RadioListTile<T>(
                      value: option.value,
                      groupValue: selected,
                      title: Text(option.label),
                      contentPadding: EdgeInsets.zero,
                      onChanged: (value) {
                        controller.setValue(name, value);
                        controller.setError(name, null);
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class FormFlutterCheckboxField extends FormFlutterField<bool> {
  const FormFlutterCheckboxField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  @override
  bool normalizeValue(Object? rawValue) {
    return rawValue == true;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final checked = normalizeValue(values[name]);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, __) {
            return InputDecorator(
              decoration: InputDecoration(
                helperText: helperText,
                errorText: errors[name],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: CheckboxListTile(
                value: checked,
                onChanged: (value) {
                  controller.setValue(name, value ?? false);
                  controller.setError(name, null);
                },
                title: Text(label),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            );
          },
        );
      },
    );
  }
}

class FormFlutterSwitchField extends FormFlutterField<bool> {
  const FormFlutterSwitchField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  @override
  bool normalizeValue(Object? rawValue) {
    return rawValue == true;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final currentValue = normalizeValue(values[name]);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, __) {
            return InputDecorator(
              decoration: InputDecoration(
                helperText: helperText,
                errorText: errors[name],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: SwitchListTile(
                value: currentValue,
                onChanged: (value) {
                  controller.setValue(name, value);
                  controller.setError(name, null);
                },
                title: Text(label),
                contentPadding: EdgeInsets.zero,
              ),
            );
          },
        );
      },
    );
  }
}

class FormFlutterDateField extends _FormFlutterInputField<DateTime?> {
  const FormFlutterDateField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.firstDate,
    this.lastDate,
    this.hintText,
  }) : super(hintText: null);

  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hintText;

  @override
  DateTime? normalizeValue(Object? rawValue) {
    if (rawValue is DateTime) {
      return rawValue;
    }
    return null;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final selectedDate = normalizeValue(values[name]);
        final text = selectedDate == null
            ? (hintText ?? 'Select a date')
            : _formatDate(selectedDate);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, __, ___) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate ?? now,
                  firstDate: firstDate ?? DateTime(now.year - 100),
                  lastDate: lastDate ?? DateTime(now.year + 100),
                );
                if (picked != null) {
                  controller.setValue(name, picked);
                  controller.setError(name, null);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  helperText: helperText,
                  errorText: controller.error(name),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  suffixIcon: const Icon(Icons.calendar_today_outlined),
                ),
                child: Text(text),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class FormFlutterTimeField extends _FormFlutterInputField<TimeOfDay?> {
  const FormFlutterTimeField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.hintText,
  }) : super(hintText: null);

  final String? hintText;

  @override
  TimeOfDay? normalizeValue(Object? rawValue) {
    if (rawValue is TimeOfDay) {
      return rawValue;
    }
    return null;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final selected = normalizeValue(values[name]);
        final text =
            selected == null ? (hintText ?? 'Select a time') : selected.format(context);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, __, ___) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: selected ?? TimeOfDay.now(),
                );
                if (picked != null) {
                  controller.setValue(name, picked);
                  controller.setError(name, null);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  helperText: helperText,
                  errorText: controller.error(name),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  suffixIcon: const Icon(Icons.schedule_outlined),
                ),
                child: Text(text),
              ),
            );
          },
        );
      },
    );
  }
}

class FormFlutterDateTimeField extends _FormFlutterInputField<DateTime?> {
  const FormFlutterDateTimeField({
    required super.name,
    required super.label,
    super.helperText,
    super.validator,
    super.asyncValidator,
    this.firstDate,
    this.lastDate,
    this.hintText,
  }) : super(hintText: null);

  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? hintText;

  @override
  DateTime? normalizeValue(Object? rawValue) {
    if (rawValue is DateTime) {
      return rawValue;
    }
    return null;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final selected = normalizeValue(values[name]);
        final text = selected == null
            ? (hintText ?? 'Select date and time')
            : _formatDateTime(context, selected);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, __, ___) {
            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                final now = DateTime.now();
                final date = await showDatePicker(
                  context: context,
                  initialDate: selected ?? now,
                  firstDate: firstDate ?? DateTime(now.year - 100),
                  lastDate: lastDate ?? DateTime(now.year + 100),
                );
                if (date == null || !context.mounted) {
                  return;
                }
                final time = await showTimePicker(
                  context: context,
                  initialTime: selected == null
                      ? TimeOfDay.fromDateTime(now)
                      : TimeOfDay.fromDateTime(selected),
                );
                if (time != null) {
                  controller.setValue(
                    name,
                    DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    ),
                  );
                  controller.setError(name, null);
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: label,
                  helperText: helperText,
                  errorText: controller.error(name),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  suffixIcon: const Icon(Icons.event_outlined),
                ),
                child: Text(text),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDateTime(BuildContext context, DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final time = TimeOfDay.fromDateTime(value).format(context);
    return '${value.year}-$month-$day $time';
  }
}

class FormFlutterSliderField extends FormFlutterField<double> {
  const FormFlutterSliderField({
    required super.name,
    required super.label,
    required this.min,
    required this.max,
    this.divisions,
    this.unitLabel,
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  final double min;
  final double max;
  final int? divisions;
  final String? unitLabel;

  @override
  double normalizeValue(Object? rawValue) {
    if (rawValue is num) {
      return rawValue.toDouble();
    }
    return min;
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, __) {
            final currentValue = normalizeValue(values[name]);
            final displayValue = currentValue % 1 == 0
                ? currentValue.toStringAsFixed(0)
                : currentValue.toStringAsFixed(1);
            return InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                helperText: helperText,
                errorText: errors[name],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    unitLabel == null ? displayValue : '$displayValue $unitLabel',
                  ),
                  Slider(
                    value: currentValue.clamp(min, max),
                    min: min,
                    max: max,
                    divisions: divisions,
                    label: displayValue,
                    onChanged: (value) {
                      controller.setValue(name, value);
                      controller.setError(name, null);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class FormFlutterMultiSelectField<T> extends FormFlutterField<List<T>> {
  const FormFlutterMultiSelectField({
    required super.name,
    required super.label,
    required this.options,
    super.helperText,
    super.validator,
    super.asyncValidator,
  });

  final List<FormFlutterOption<T>> options;

  @override
  List<T> normalizeValue(Object? rawValue) {
    if (rawValue is List<T>) {
      return rawValue;
    }
    if (rawValue is List) {
      return rawValue.cast<T>();
    }
    return <T>[];
  }

  @override
  Widget buildField(FormFlutterController controller) {
    return ValueListenableBuilder<Map<String, Object?>>(
      valueListenable: controller.valuesListenable,
      builder: (context, values, _) {
        final selected = normalizeValue(values[name]);
        return ValueListenableBuilder<Map<String, String?>>(
          valueListenable: controller.errorsListenable,
          builder: (context, errors, __) {
            return InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                helperText: helperText,
                errorText: errors[name],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in options)
                    FilterChip(
                      label: Text(option.label),
                      selected: selected.contains(option.value),
                      onSelected: (isSelected) {
                        final next = List<T>.from(selected);
                        if (isSelected) {
                          if (!next.contains(option.value)) {
                            next.add(option.value);
                          }
                        } else {
                          next.remove(option.value);
                        }
                        controller.setValue(name, next);
                        controller.setError(name, null);
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
