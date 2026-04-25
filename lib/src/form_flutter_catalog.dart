import 'form_flutter_controller.dart';
import 'form_flutter_field.dart';
import 'form_flutter_validators.dart';

/// High-level kinds used by presets and the field factory.
enum FormFlutterFieldKind {
  text,
  email,
  password,
  phone,
  url,
  multiline,
  number,
  dropdown,
  radio,
  checkbox,
  switchField,
  date,
  time,
  dateTime,
  slider,
  multiSelect,
  otp,
  search,
  autocomplete,
  file,
  image,
  signature,
}

/// Categories used to group preset fields by domain or workflow.
enum FormFlutterFieldCategory {
  personal,
  contact,
  address,
  identification,
  account,
  academic,
  professional,
  family,
  health,
  preferences,
  demographic,
  consent,
  survey,
  commerce,
  appointment,
  media,
  hidden,
  advanced,
}

/// Metadata describing a field that can be built from the preset catalog.
class FormFlutterFieldPreset {
  const FormFlutterFieldPreset({
    required this.key,
    required this.label,
    required this.kind,
    required this.category,
    this.description,
    this.options = const [],
    this.isRequired = false,
    this.validationNotes = const [],
  });

  final String key;
  final String label;
  final FormFlutterFieldKind kind;
  final FormFlutterFieldCategory category;
  final String? description;
  final List<FormFlutterOption<String>> options;
  final bool isRequired;
  final List<String> validationNotes;
}

/// Shared option collections for common real-world form choices.
abstract final class FormFlutterOptionSets {
  static const gender = [
    FormFlutterOption(value: 'male', label: 'Male'),
    FormFlutterOption(value: 'female', label: 'Female'),
    FormFlutterOption(value: 'other', label: 'Other'),
    FormFlutterOption(value: 'prefer_not_to_say', label: 'Prefer not to say'),
  ];

  static const maritalStatus = [
    FormFlutterOption(value: 'single', label: 'Single'),
    FormFlutterOption(value: 'married', label: 'Married'),
    FormFlutterOption(value: 'divorced', label: 'Divorced'),
    FormFlutterOption(value: 'widowed', label: 'Widowed'),
    FormFlutterOption(value: 'separated', label: 'Separated'),
    FormFlutterOption(value: 'prefer_not_to_say', label: 'Prefer not to say'),
  ];

  static const bloodGroups = [
    FormFlutterOption(value: 'A+', label: 'A+'),
    FormFlutterOption(value: 'A-', label: 'A-'),
    FormFlutterOption(value: 'B+', label: 'B+'),
    FormFlutterOption(value: 'B-', label: 'B-'),
    FormFlutterOption(value: 'AB+', label: 'AB+'),
    FormFlutterOption(value: 'AB-', label: 'AB-'),
    FormFlutterOption(value: 'O+', label: 'O+'),
    FormFlutterOption(value: 'O-', label: 'O-'),
  ];

  static const degrees = [
    FormFlutterOption(value: 'ssc', label: 'SSC'),
    FormFlutterOption(value: 'hsc', label: 'HSC'),
    FormFlutterOption(value: 'diploma', label: 'Diploma'),
    FormFlutterOption(value: 'bachelor', label: 'Bachelor'),
    FormFlutterOption(value: 'master', label: 'Master'),
    FormFlutterOption(value: 'phd', label: 'PhD'),
    FormFlutterOption(value: 'other', label: 'Other'),
  ];

  static const employmentTypes = [
    FormFlutterOption(value: 'full_time', label: 'Full-time'),
    FormFlutterOption(value: 'part_time', label: 'Part-time'),
    FormFlutterOption(value: 'contract', label: 'Contract'),
    FormFlutterOption(value: 'internship', label: 'Internship'),
    FormFlutterOption(value: 'freelance', label: 'Freelance'),
    FormFlutterOption(value: 'temporary', label: 'Temporary'),
    FormFlutterOption(value: 'remote', label: 'Remote'),
    FormFlutterOption(value: 'hybrid', label: 'Hybrid'),
    FormFlutterOption(value: 'on_site', label: 'On-site'),
  ];

  static const relationships = [
    FormFlutterOption(value: 'father', label: 'Father'),
    FormFlutterOption(value: 'mother', label: 'Mother'),
    FormFlutterOption(value: 'brother', label: 'Brother'),
    FormFlutterOption(value: 'sister', label: 'Sister'),
    FormFlutterOption(value: 'spouse', label: 'Spouse'),
    FormFlutterOption(value: 'friend', label: 'Friend'),
    FormFlutterOption(value: 'relative', label: 'Relative'),
    FormFlutterOption(value: 'guardian', label: 'Guardian'),
    FormFlutterOption(value: 'other', label: 'Other'),
  ];

  static const contactMethods = [
    FormFlutterOption(value: 'email', label: 'Email'),
    FormFlutterOption(value: 'phone', label: 'Phone'),
    FormFlutterOption(value: 'sms', label: 'SMS'),
    FormFlutterOption(value: 'whatsapp', label: 'WhatsApp'),
  ];

  static const themes = [
    FormFlutterOption(value: 'light', label: 'Light'),
    FormFlutterOption(value: 'dark', label: 'Dark'),
    FormFlutterOption(value: 'system', label: 'System default'),
  ];

  static const foodPreferences = [
    FormFlutterOption(value: 'vegetarian', label: 'Vegetarian'),
    FormFlutterOption(value: 'non_vegetarian', label: 'Non-vegetarian'),
    FormFlutterOption(value: 'vegan', label: 'Vegan'),
    FormFlutterOption(value: 'halal', label: 'Halal'),
    FormFlutterOption(value: 'kosher', label: 'Kosher'),
    FormFlutterOption(value: 'other', label: 'Other'),
  ];

  static const ageRanges = [
    FormFlutterOption(value: 'under_18', label: 'Under 18'),
    FormFlutterOption(value: '18_24', label: '18-24'),
    FormFlutterOption(value: '25_34', label: '25-34'),
    FormFlutterOption(value: '35_44', label: '35-44'),
    FormFlutterOption(value: '45_54', label: '45-54'),
    FormFlutterOption(value: '55_plus', label: '55+'),
  ];

  static const educationLevels = [
    FormFlutterOption(value: 'primary', label: 'Primary'),
    FormFlutterOption(value: 'secondary', label: 'Secondary'),
    FormFlutterOption(value: 'higher_secondary', label: 'Higher Secondary'),
    FormFlutterOption(value: 'diploma', label: 'Diploma'),
    FormFlutterOption(value: 'undergraduate', label: 'Undergraduate'),
    FormFlutterOption(value: 'graduate', label: 'Graduate'),
    FormFlutterOption(value: 'postgraduate', label: 'Postgraduate'),
    FormFlutterOption(value: 'doctorate', label: 'Doctorate'),
    FormFlutterOption(value: 'other', label: 'Other'),
  ];

  static const satisfaction = [
    FormFlutterOption(value: 'very_satisfied', label: 'Very satisfied'),
    FormFlutterOption(value: 'satisfied', label: 'Satisfied'),
    FormFlutterOption(value: 'neutral', label: 'Neutral'),
    FormFlutterOption(value: 'dissatisfied', label: 'Dissatisfied'),
    FormFlutterOption(value: 'very_dissatisfied', label: 'Very dissatisfied'),
  ];

  static const ratings = [
    FormFlutterOption(value: '1', label: '1 star'),
    FormFlutterOption(value: '2', label: '2 stars'),
    FormFlutterOption(value: '3', label: '3 stars'),
    FormFlutterOption(value: '4', label: '4 stars'),
    FormFlutterOption(value: '5', label: '5 stars'),
  ];

  static const sizes = [
    FormFlutterOption(value: 'xs', label: 'XS'),
    FormFlutterOption(value: 's', label: 'S'),
    FormFlutterOption(value: 'm', label: 'M'),
    FormFlutterOption(value: 'l', label: 'L'),
    FormFlutterOption(value: 'xl', label: 'XL'),
    FormFlutterOption(value: 'xxl', label: 'XXL'),
  ];

  static const paymentMethods = [
    FormFlutterOption(value: 'cod', label: 'Cash on delivery'),
    FormFlutterOption(value: 'credit_card', label: 'Credit card'),
    FormFlutterOption(value: 'debit_card', label: 'Debit card'),
    FormFlutterOption(value: 'mobile_banking', label: 'Mobile banking'),
    FormFlutterOption(value: 'bank_transfer', label: 'Bank transfer'),
    FormFlutterOption(value: 'paypal', label: 'PayPal'),
    FormFlutterOption(value: 'stripe', label: 'Stripe'),
  ];

  static const meetingModes = [
    FormFlutterOption(value: 'in_person', label: 'In person'),
    FormFlutterOption(value: 'online', label: 'Online'),
    FormFlutterOption(value: 'offline', label: 'Offline'),
    FormFlutterOption(value: 'phone_call', label: 'Phone call'),
    FormFlutterOption(value: 'video_call', label: 'Video call'),
  ];

  static const industries = [
    FormFlutterOption(value: 'technology', label: 'Technology'),
    FormFlutterOption(value: 'finance', label: 'Finance'),
    FormFlutterOption(value: 'healthcare', label: 'Healthcare'),
    FormFlutterOption(value: 'education', label: 'Education'),
    FormFlutterOption(value: 'retail', label: 'Retail'),
    FormFlutterOption(value: 'manufacturing', label: 'Manufacturing'),
    FormFlutterOption(value: 'hospitality', label: 'Hospitality'),
    FormFlutterOption(value: 'government', label: 'Government'),
    FormFlutterOption(value: 'non_profit', label: 'Non-profit'),
    FormFlutterOption(value: 'other', label: 'Other'),
  ];

  static const priorities = [
    FormFlutterOption(value: 'low', label: 'Low'),
    FormFlutterOption(value: 'medium', label: 'Medium'),
    FormFlutterOption(value: 'high', label: 'High'),
    FormFlutterOption(value: 'urgent', label: 'Urgent'),
  ];

  static const yesNo = [
    FormFlutterOption(value: 'yes', label: 'Yes'),
    FormFlutterOption(value: 'no', label: 'No'),
  ];
}

/// Built-in field preset collections grouped by common form domains.
abstract final class FormFlutterCatalog {
  static const List<FormFlutterFieldPreset> personalInformation = [
    FormFlutterFieldPreset(
      key: 'full_name',
      label: 'Full name',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.personal,
      isRequired: true,
      validationNotes: ['required', 'minimum length'],
    ),
    FormFlutterFieldPreset(
      key: 'date_of_birth',
      label: 'Date of birth',
      kind: FormFlutterFieldKind.date,
      category: FormFlutterFieldCategory.personal,
      validationNotes: ['required', 'minimum age'],
    ),
    FormFlutterFieldPreset(
      key: 'gender',
      label: 'Gender',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.personal,
      options: FormFlutterOptionSets.gender,
    ),
    FormFlutterFieldPreset(
      key: 'marital_status',
      label: 'Marital status',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.personal,
      options: FormFlutterOptionSets.maritalStatus,
    ),
    FormFlutterFieldPreset(
      key: 'blood_group',
      label: 'Blood group',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.personal,
      options: FormFlutterOptionSets.bloodGroups,
    ),
    FormFlutterFieldPreset(
      key: 'profile_photo',
      label: 'Profile photo',
      kind: FormFlutterFieldKind.image,
      category: FormFlutterFieldCategory.personal,
    ),
    FormFlutterFieldPreset(
      key: 'signature',
      label: 'Signature',
      kind: FormFlutterFieldKind.signature,
      category: FormFlutterFieldCategory.personal,
    ),
  ];

  static const List<FormFlutterFieldPreset> contactInformation = [
    FormFlutterFieldPreset(
      key: 'email',
      label: 'Email address',
      kind: FormFlutterFieldKind.email,
      category: FormFlutterFieldCategory.contact,
      isRequired: true,
      validationNotes: ['required', 'email format'],
    ),
    FormFlutterFieldPreset(
      key: 'phone',
      label: 'Phone number',
      kind: FormFlutterFieldKind.phone,
      category: FormFlutterFieldCategory.contact,
      validationNotes: ['phone format'],
    ),
    FormFlutterFieldPreset(
      key: 'website',
      label: 'Website',
      kind: FormFlutterFieldKind.url,
      category: FormFlutterFieldCategory.contact,
      validationNotes: ['URL format'],
    ),
    FormFlutterFieldPreset(
      key: 'linkedin',
      label: 'LinkedIn profile',
      kind: FormFlutterFieldKind.url,
      category: FormFlutterFieldCategory.contact,
    ),
    FormFlutterFieldPreset(
      key: 'github',
      label: 'GitHub profile',
      kind: FormFlutterFieldKind.url,
      category: FormFlutterFieldCategory.contact,
    ),
  ];

  static const List<FormFlutterFieldPreset> addressInformation = [
    FormFlutterFieldPreset(
      key: 'street_address',
      label: 'Street address',
      kind: FormFlutterFieldKind.multiline,
      category: FormFlutterFieldCategory.address,
    ),
    FormFlutterFieldPreset(
      key: 'city',
      label: 'City',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.address,
    ),
    FormFlutterFieldPreset(
      key: 'state',
      label: 'State/Province',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.address,
    ),
    FormFlutterFieldPreset(
      key: 'postal_code',
      label: 'Postal code / ZIP code',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.address,
      validationNotes: ['regex pattern'],
    ),
    FormFlutterFieldPreset(
      key: 'country',
      label: 'Country',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.address,
    ),
  ];

  static const List<FormFlutterFieldPreset> accountFields = [
    FormFlutterFieldPreset(
      key: 'username',
      label: 'Username',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.account,
      validationNotes: ['required', 'minimum length'],
    ),
    FormFlutterFieldPreset(
      key: 'password',
      label: 'Password',
      kind: FormFlutterFieldKind.password,
      category: FormFlutterFieldCategory.account,
      validationNotes: ['required', 'password strength'],
    ),
    FormFlutterFieldPreset(
      key: 'confirm_password',
      label: 'Confirm password',
      kind: FormFlutterFieldKind.password,
      category: FormFlutterFieldCategory.account,
      validationNotes: ['match another field'],
    ),
    FormFlutterFieldPreset(
      key: 'otp',
      label: 'OTP / verification code',
      kind: FormFlutterFieldKind.otp,
      category: FormFlutterFieldCategory.account,
      validationNotes: ['exact length', 'number only'],
    ),
  ];

  static const List<FormFlutterFieldPreset> academicFields = [
    FormFlutterFieldPreset(
      key: 'student_id',
      label: 'Student ID',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.academic,
    ),
    FormFlutterFieldPreset(
      key: 'degree',
      label: 'Degree',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.academic,
      options: FormFlutterOptionSets.degrees,
    ),
    FormFlutterFieldPreset(
      key: 'department',
      label: 'Department',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.academic,
    ),
    FormFlutterFieldPreset(
      key: 'cgpa',
      label: 'CGPA',
      kind: FormFlutterFieldKind.number,
      category: FormFlutterFieldCategory.academic,
      validationNotes: ['min value', 'max value'],
    ),
  ];

  static const List<FormFlutterFieldPreset> professionalFields = [
    FormFlutterFieldPreset(
      key: 'company_name',
      label: 'Company name',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.professional,
    ),
    FormFlutterFieldPreset(
      key: 'designation',
      label: 'Designation',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.professional,
    ),
    FormFlutterFieldPreset(
      key: 'employment_type',
      label: 'Employment type',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.professional,
      options: FormFlutterOptionSets.employmentTypes,
    ),
    FormFlutterFieldPreset(
      key: 'industry',
      label: 'Industry',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.professional,
      options: FormFlutterOptionSets.industries,
    ),
    FormFlutterFieldPreset(
      key: 'skills',
      label: 'Skills',
      kind: FormFlutterFieldKind.multiSelect,
      category: FormFlutterFieldCategory.professional,
      validationNotes: ['dynamic repeatable fields'],
    ),
    FormFlutterFieldPreset(
      key: 'resume',
      label: 'Resume / CV upload',
      kind: FormFlutterFieldKind.file,
      category: FormFlutterFieldCategory.professional,
      validationNotes: ['file size limit', 'file type restriction'],
    ),
  ];

  static const List<FormFlutterFieldPreset> familyFields = [
    FormFlutterFieldPreset(
      key: 'father_name',
      label: 'Father’s name',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.family,
    ),
    FormFlutterFieldPreset(
      key: 'mother_name',
      label: 'Mother’s name',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.family,
    ),
    FormFlutterFieldPreset(
      key: 'emergency_contact_person',
      label: 'Emergency contact person',
      kind: FormFlutterFieldKind.text,
      category: FormFlutterFieldCategory.family,
    ),
    FormFlutterFieldPreset(
      key: 'relationship',
      label: 'Relationship with emergency contact',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.family,
      options: FormFlutterOptionSets.relationships,
    ),
  ];

  static const List<FormFlutterFieldPreset> preferenceFields = [
    FormFlutterFieldPreset(
      key: 'preferred_contact_method',
      label: 'Preferred contact method',
      kind: FormFlutterFieldKind.radio,
      category: FormFlutterFieldCategory.preferences,
      options: FormFlutterOptionSets.contactMethods,
    ),
    FormFlutterFieldPreset(
      key: 'theme_preference',
      label: 'Theme preference',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.preferences,
      options: FormFlutterOptionSets.themes,
    ),
    FormFlutterFieldPreset(
      key: 'food_preference',
      label: 'Food preference',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.preferences,
      options: FormFlutterOptionSets.foodPreferences,
    ),
    FormFlutterFieldPreset(
      key: 'interests',
      label: 'Interests',
      kind: FormFlutterFieldKind.multiSelect,
      category: FormFlutterFieldCategory.preferences,
    ),
  ];

  static const List<FormFlutterFieldPreset> surveyFields = [
    FormFlutterFieldPreset(
      key: 'rating',
      label: 'Rating',
      kind: FormFlutterFieldKind.radio,
      category: FormFlutterFieldCategory.survey,
      options: FormFlutterOptionSets.ratings,
    ),
    FormFlutterFieldPreset(
      key: 'satisfaction',
      label: 'Satisfaction level',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.survey,
      options: FormFlutterOptionSets.satisfaction,
    ),
    FormFlutterFieldPreset(
      key: 'feedback',
      label: 'Feedback message',
      kind: FormFlutterFieldKind.multiline,
      category: FormFlutterFieldCategory.survey,
    ),
  ];

  static const List<FormFlutterFieldPreset> commerceFields = [
    FormFlutterFieldPreset(
      key: 'quantity',
      label: 'Quantity',
      kind: FormFlutterFieldKind.number,
      category: FormFlutterFieldCategory.commerce,
      validationNotes: ['min value'],
    ),
    FormFlutterFieldPreset(
      key: 'size',
      label: 'Size',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.commerce,
      options: FormFlutterOptionSets.sizes,
    ),
    FormFlutterFieldPreset(
      key: 'payment_method',
      label: 'Payment method',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.commerce,
      options: FormFlutterOptionSets.paymentMethods,
    ),
    FormFlutterFieldPreset(
      key: 'special_instructions',
      label: 'Special instructions',
      kind: FormFlutterFieldKind.multiline,
      category: FormFlutterFieldCategory.commerce,
    ),
  ];

  static const List<FormFlutterFieldPreset> appointmentFields = [
    FormFlutterFieldPreset(
      key: 'appointment_date',
      label: 'Appointment date',
      kind: FormFlutterFieldKind.date,
      category: FormFlutterFieldCategory.appointment,
    ),
    FormFlutterFieldPreset(
      key: 'appointment_time',
      label: 'Appointment time',
      kind: FormFlutterFieldKind.time,
      category: FormFlutterFieldCategory.appointment,
    ),
    FormFlutterFieldPreset(
      key: 'meeting_mode',
      label: 'Meeting mode',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.appointment,
      options: FormFlutterOptionSets.meetingModes,
    ),
    FormFlutterFieldPreset(
      key: 'reason',
      label: 'Reason for appointment',
      kind: FormFlutterFieldKind.multiline,
      category: FormFlutterFieldCategory.appointment,
    ),
    FormFlutterFieldPreset(
      key: 'priority',
      label: 'Priority',
      kind: FormFlutterFieldKind.dropdown,
      category: FormFlutterFieldCategory.appointment,
      options: FormFlutterOptionSets.priorities,
    ),
  ];

  static const List<FormFlutterFieldPreset> consentFields = [
    FormFlutterFieldPreset(
      key: 'terms_accepted',
      label: 'I agree to the Terms and Conditions',
      kind: FormFlutterFieldKind.checkbox,
      category: FormFlutterFieldCategory.consent,
      isRequired: true,
      validationNotes: ['must be accepted'],
    ),
    FormFlutterFieldPreset(
      key: 'privacy_accepted',
      label: 'I accept the Privacy Policy',
      kind: FormFlutterFieldKind.checkbox,
      category: FormFlutterFieldCategory.consent,
      isRequired: true,
      validationNotes: ['must be accepted'],
    ),
    FormFlutterFieldPreset(
      key: 'newsletter',
      label: 'Subscribe to newsletter',
      kind: FormFlutterFieldKind.switchField,
      category: FormFlutterFieldCategory.consent,
    ),
  ];

  static List<FormFlutterFieldPreset> all() {
    return [
      ...personalInformation,
      ...contactInformation,
      ...addressInformation,
      ...accountFields,
      ...academicFields,
      ...professionalFields,
      ...familyFields,
      ...preferenceFields,
      ...surveyFields,
      ...commerceFields,
      ...appointmentFields,
      ...consentFields,
    ];
  }

  static List<FormFlutterFieldPreset> byCategory(
    FormFlutterFieldCategory category,
  ) {
    return [
      for (final preset in all())
        if (preset.category == category) preset,
    ];
  }

  static FormFlutterFieldPreset? maybeByKey(String key) {
    for (final preset in all()) {
      if (preset.key == key) {
        return preset;
      }
    }
    return null;
  }

  static FormFlutterFieldPreset byKey(String key) {
    final preset = maybeByKey(key);
    if (preset == null) {
      throw ArgumentError.value(key, 'key', 'Unknown form_flutter preset key');
    }
    return preset;
  }

  static List<FormFlutterFieldPreset> search(String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return all();
    }
    return [
      for (final preset in all())
        if (preset.key.toLowerCase().contains(normalizedQuery) ||
            preset.label.toLowerCase().contains(normalizedQuery) ||
            (preset.description?.toLowerCase().contains(normalizedQuery) ??
                false))
          preset,
    ];
  }
}

/// Higher-level validator presets built from the core validator helpers.
abstract final class FormFlutterPresetValidators {
  static FormFlutterValidator<String> emailAddress() {
    return FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.email(),
    ]);
  }

  static FormFlutterValidator<String> phoneNumber() {
    return FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.phone(),
    ]);
  }

  static FormFlutterValidator<String> password({int minLength = 8}) {
    return FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.mediumPassword(minLength: minLength),
    ]);
  }

  static FormFlutterValidator<String> strongPassword({int minLength = 10}) {
    return FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.strongPassword(minLength: minLength),
    ]);
  }

  static FormFlutterValidator<String> highStrengthPassword({
    int minLength = 12,
  }) {
    return FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.highStrengthPassword(minLength: minLength),
    ]);
  }

  static FormFlutterValidator<String> confirmPassword(
    String passwordFieldName,
  ) {
    return FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.sameAsField(
        passwordFieldName,
        message: 'Passwords do not match.',
      ),
    ]);
  }

  static FormFlutterValidator<String> otp({int length = 6}) {
    return FormFlutterValidators.combine([
      FormFlutterValidators.requiredText(),
      FormFlutterValidators.numericText(),
      FormFlutterValidators.exactLength(length),
    ]);
  }

  static FormFlutterAsyncValidator<String> uniqueUsername(
    Future<bool> Function(String username, FormFlutterValues values)
    isAvailable,
  ) {
    return FormFlutterValidators.uniqueUsername(
      isAvailable,
      debounce: const Duration(milliseconds: 250),
    );
  }

  static FormFlutterAsyncValidator<String> uniqueEmail(
    Future<bool> Function(String email, FormFlutterValues values) isAvailable,
  ) {
    return FormFlutterValidators.uniqueEmail(
      isAvailable,
      debounce: const Duration(milliseconds: 250),
    );
  }
}
