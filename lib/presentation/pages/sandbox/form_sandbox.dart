import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/input.dart';
import 'package:boilerplate/core/widgets/components/forms/checkbox_widget.dart';
import 'package:boilerplate/core/widgets/components/forms/chip.dart';
import 'package:boilerplate/core/widgets/components/forms/radio_button.dart';
import 'package:boilerplate/core/widgets/components/forms/select.dart';
import 'package:boilerplate/core/widgets/components/forms/switch.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/constants/colors.dart';

/// Model for the basic form example
class BasicFormModel {
  final String name;
  final String email;

  BasicFormModel({
    this.name = '',
    this.email = '',
  });

  factory BasicFormModel.fromJson(Map<String, dynamic> json) {
    return BasicFormModel(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
    };
  }
}

/// Model for the validation modes example
class ValidationModesModel {
  final String onSubmitField;
  final String onChangeField;
  final String onBlurField;

  ValidationModesModel({
    this.onSubmitField = '',
    this.onChangeField = '',
    this.onBlurField = '',
  });

  factory ValidationModesModel.fromJson(Map<String, dynamic> json) {
    return ValidationModesModel(
      onSubmitField: json['onSubmitField'] as String? ?? '',
      onChangeField: json['onChangeField'] as String? ?? '',
      onBlurField: json['onBlurField'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'onSubmitField': onSubmitField,
      'onChangeField': onChangeField,
      'onBlurField': onBlurField,
    };
  }
}

/// Model for the validation rules example
class ValidationRulesModel {
  final String required;
  final String minLength;
  final String email;
  final String pattern;

  ValidationRulesModel({
    this.required = '',
    this.minLength = '',
    this.email = '',
    this.pattern = '',
  });

  factory ValidationRulesModel.fromJson(Map<String, dynamic> json) {
    return ValidationRulesModel(
      required: json['required'] as String? ?? '',
      minLength: json['minLength'] as String? ?? '',
      email: json['email'] as String? ?? '',
      pattern: json['pattern'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'required': required,
      'minLength': minLength,
      'email': email,
      'pattern': pattern,
    };
  }
}

/// Complex form model with various field types
class ComplexFormModel {
  final String fullName;
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String address;
  final int age;
  final bool acceptTerms;

  ComplexFormModel({
    this.fullName = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phoneNumber = '',
    this.address = '',
    this.age = 0,
    this.acceptTerms = false,
  });

  factory ComplexFormModel.fromJson(Map<String, dynamic> json) {
    return ComplexFormModel(
      fullName: json['fullName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      confirmPassword: json['confirmPassword'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      address: json['address'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      acceptTerms: json['acceptTerms'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
      'phoneNumber': phoneNumber,
      'address': address,
      'age': age,
      'acceptTerms': acceptTerms,
    };
  }
}

/// Model for checkbox examples
class CheckboxFormModel {
  final bool singleCheckbox;
  final List<String> multiCheckbox;
  final bool termsAccepted;
  final List<String> groupedOptions;

  CheckboxFormModel({
    this.singleCheckbox = false,
    this.multiCheckbox = const [],
    this.termsAccepted = false,
    this.groupedOptions = const [],
  });

  factory CheckboxFormModel.fromJson(Map<String, dynamic> json) {
    List<String> safeList(List? raw) =>
        raw?.where((e) => e != null).map((e) => e as String).toList() ?? [];
    return CheckboxFormModel(
      singleCheckbox: json['singleCheckbox'] as bool? ?? false,
      multiCheckbox: safeList(json['multiCheckbox'] as List?),
      termsAccepted: json['termsAccepted'] as bool? ?? false,
      groupedOptions: safeList(json['groupedOptions'] as List?),
    );
  }

  Map<String, dynamic> toJson() {
    List<String> cleanList(List<String> l) => l.toList();
    return {
      'singleCheckbox': singleCheckbox,
      'multiCheckbox': cleanList(multiCheckbox),
      'termsAccepted': termsAccepted,
      'groupedOptions': cleanList(groupedOptions),
    };
  }
}

/// Model for chip examples
class ChipFormModel {
  final List<String> selectedLanguages;
  final List<String> selectedFrameworks;
  final List<String> tags;

  ChipFormModel({
    this.selectedLanguages = const [],
    this.selectedFrameworks = const [],
    this.tags = const [],
  });

  factory ChipFormModel.fromJson(Map<String, dynamic> json) {
    return ChipFormModel(
      selectedLanguages: (json['selectedLanguages'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      selectedFrameworks: (json['selectedFrameworks'] as List?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      tags: (json['tags'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'selectedLanguages': selectedLanguages,
      'selectedFrameworks': selectedFrameworks,
      'tags': tags,
    };
  }
}

/// Model for radio button examples
class RadioFormModel {
  final String gender;
  final String contactPreference;
  final String paymentMethod;

  RadioFormModel({
    this.gender = '',
    this.contactPreference = '',
    this.paymentMethod = '',
  });

  factory RadioFormModel.fromJson(Map<String, dynamic> json) {
    return RadioFormModel(
      gender: json['gender'] as String? ?? '',
      contactPreference: json['contactPreference'] as String? ?? '',
      paymentMethod: json['paymentMethod'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'contactPreference': contactPreference,
      'paymentMethod': paymentMethod,
    };
  }
}

/// Model for select examples
class SelectFormModel {
  final String country;
  final List<String> interests;
  final String education;
  final List<String> skills;

  SelectFormModel({
    this.country = '',
    this.interests = const [],
    this.education = '',
    this.skills = const [],
  });

  factory SelectFormModel.fromJson(Map<String, dynamic> json) {
    return SelectFormModel(
      country: json['country'] as String? ?? '',
      interests:
          (json['interests'] as List?)?.map((e) => e as String).toList() ?? [],
      education: json['education'] as String? ?? '',
      skills: (json['skills'] as List?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'interests': interests,
      'education': education,
      'skills': skills,
    };
  }
}

/// Model for switch examples
class SwitchFormModel {
  final bool notifications;
  final bool darkMode;
  final bool locationServices;
  final bool autoSave;

  SwitchFormModel({
    this.notifications = false,
    this.darkMode = false,
    this.locationServices = false,
    this.autoSave = true,
  });

  factory SwitchFormModel.fromJson(Map<String, dynamic> json) {
    return SwitchFormModel(
      notifications: json['notifications'] as bool? ?? false,
      darkMode: json['darkMode'] as bool? ?? false,
      locationServices: json['locationServices'] as bool? ?? false,
      autoSave: json['autoSave'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'darkMode': darkMode,
      'locationServices': locationServices,
      'autoSave': autoSave,
    };
  }
}

/// Custom validation rule to confirm password fields match
class ConfirmPasswordRule extends ValidationRule<String> {
  final String Function() getPassword;
  final String message;

  ConfirmPasswordRule({
    required this.getPassword,
    this.message = 'Passwords do not match',
  });

  @override
  String? validate(String? value, String fieldName) {
    if (value != getPassword()) {
      return message;
    }
    return null;
  }
}

/// Custom validation rule for phone numbers
class PhoneNumberRule extends ValidationRule<String> {
  final String message;

  PhoneNumberRule({
    this.message = 'Please enter a valid phone number',
  });

  @override
  String? validate(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Simple phone validation - at least 10 digits
    if (!RegExp(r'^\d{10,}$').hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return message;
    }
    return null;
  }
}

/// Custom validation rule untuk memastikan checkbox "acceptTerms" dicentang
class AcceptTermsRule extends ValidationRule<bool> {
  final String message;
  AcceptTermsRule({this.message = 'You must accept terms'});

  @override
  String? validate(bool? value, String fieldName) {
    return (value ?? false) ? null : message;
  }
}

/// Custom rule to ensure auto-save is enabled
class AutoSaveRequiredRule extends ValidationRule<bool> {
  final String message;

  AutoSaveRequiredRule({this.message = 'This feature must be enabled'});

  @override
  String? validate(bool? value, String fieldName) {
    return (value ?? false) ? null : message;
  }
}

/// Custom checkbox field widget
class AppCheckboxField extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  final String? errorText;

  const AppCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: value,
              onChanged: (newValue) => onChanged(newValue ?? false),
              activeColor: AppColors.primary,
              checkColor: AppColors.primaryForeground,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(!value),
                child: AppText(
                  label,
                  variant: TextVariant.bodyMedium,
                  color: hasError ? AppColors.destructive : null,
                ),
              ),
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 4),
            child: AppText(
              errorText!,
              variant: TextVariant.labelSmall,
              color: AppColors.destructive,
            ),
          ),
      ],
    );
  }
}

/// Main form sandbox class
class FormSandbox extends StatefulWidget {
  const FormSandbox({super.key});

  @override
  State<FormSandbox> createState() => _FormSandboxState();
}

class _FormSandboxState extends State<FormSandbox> {
  // Track success/error messages for form submissions
  String? _basicFormResult;
  String? _validationModesResult;
  String? _validationRulesResult;
  String? _complexFormResult;
  String? _checkboxFormResult;
  String? _chipFormResult;
  String? _radioFormResult;
  String? _selectFormResult;
  String? _switchFormResult;

  // Track selected validation mode for the validation modes example
  ValidationMode _selectedValidationMode = ValidationMode.onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _buildHeader(),
        const SizedBox(height: 32),

        // Original examples
        _buildSectionTitle('Basic Form Example'),
        _buildBasicFormExample(),
        const SizedBox(height: 32),

        _buildSectionTitle('Validation Modes'),
        _buildValidationModesExample(),
        const SizedBox(height: 32),

        _buildSectionTitle('Validation Rules'),
        _buildValidationRulesExample(),
        const SizedBox(height: 32),

        _buildSectionTitle('Form State Monitoring'),
        _buildFormStateMonitoringExample(),
        const SizedBox(height: 32),

        _buildSectionTitle('Complex Form Example'),
        _buildComplexFormExample(),
        const SizedBox(height: 32),

        // New examples for additional form components
        _buildSectionTitle('Checkbox Component Examples'),
        _buildCheckboxExample(),
        const SizedBox(height: 32),

        _buildSectionTitle('Chip Field Component Examples'),
        _buildChipFieldExample(),
        const SizedBox(height: 32),

        _buildSectionTitle('Radio Button Component Examples'),
        _buildRadioButtonExample(),
        const SizedBox(height: 32),

        _buildSectionTitle('Select Field Component Examples'),
        _buildSelectFieldExample(),
        const SizedBox(height: 32),

        _buildSectionTitle('Switch Input Component Examples'),
        _buildSwitchInputExample(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const AppText(
            'Form System Sandbox',
            variant: TextVariant.displayLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        AppText(
          'A comprehensive demonstration of the AppForm system, validation rules, and form state management',
          variant: TextVariant.bodyLarge,
          color: AppColors.neutral[500],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: AppText(
            title,
            variant: TextVariant.headlineSmall,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBasicFormExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'This is a simple form with basic validation',
            variant: TextVariant.bodyLarge,
          ),
          const SizedBox(height: 16),
          FormBuilder<BasicFormModel>(
            validationMode: ValidationMode.onSubmit,
            fromJson: BasicFormModel.fromJson,
            toJson: (model) => model.toJson(),
            builder: (context, controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Using the new FormInputField that auto-registers with the controller
                  FormInputField(
                    formController: controller,
                    name: 'name',
                    label: 'Name',
                    isRequired: true,
                    rules: [RequiredRule(message: 'Name is required')],
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    filled: true,
                  ),
                  const SizedBox(height: 16),
                  FormInputField(
                    formController: controller,
                    name: 'email',
                    label: 'Email',
                    isRequired: true,
                    rules: [
                      RequiredRule(message: 'Email is required'),
                      EmailRule(message: 'Please enter a valid email address'),
                    ],
                    keyboardType: TextInputType.emailAddress,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                    filled: true,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          controller.reset();
                          setState(() {
                            _basicFormResult = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neutral[400]!),
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.handleSubmit(
                            (BasicFormModel data) async {
                              setState(() {
                                _basicFormResult =
                                    'Submitted: ${data.name}, ${data.email}';
                              });
                            },
                            onInvalid: (errors) {
                              setState(() {
                                _basicFormResult = 'Errors: $errors';
                              });
                            },
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_basicFormResult != null)
                    AppText(
                      _basicFormResult!,
                      variant: TextVariant.bodyMedium,
                      color: AppColors.neutral[700],
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildValidationModesExample() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul section
            AppText(
              'Validation Modes',
              variant: TextVariant.headlineSmall,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            AppText(
              'Pilih mode validasi, lalu isi field untuk melihat reaksinya',
              variant: TextVariant.bodyLarge,
              color: AppColors.neutral[600],
            ),
            const SizedBox(height: 16),

            // Pilihan mode validasi sebagai ChoiceChips agar lebih responsif
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: ValidationMode.values.map((mode) {
                final label = mode.toString().split('.').last;
                return ChoiceChip(
                  label: Text(label),
                  selected: _selectedValidationMode == mode,
                  onSelected: (_) {
                    setState(() {
                      _selectedValidationMode = mode;
                      _validationModesResult = null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // FormBuilder dengan mode validasi dinamis
            FormBuilder<ValidationModesModel>(
              validationMode: ValidationMode.onBlur,
              fromJson: ValidationModesModel.fromJson,
              toJson: (m) => m.toJson(),
              builder: (context, controller) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FormInputField(
                      formController: controller,
                      name: 'onSubmitField',
                      label: 'Field (onSubmit)',
                      rules: [RequiredRule(message: 'Harus diisi pada submit')],
                      filled: true,
                    ),
                    const SizedBox(height: 12),
                    FormInputField(
                      formController: controller,
                      name: 'onChangeField',
                      label: 'Field (onChange)',
                      rules: [
                        RequiredRule(message: 'Harus diisi saat berubah')
                      ],
                      filled: true,
                    ),
                    const SizedBox(height: 12),
                    FormInputField(
                      formController: controller,
                      name: 'onBlurField',
                      label: 'Field (onBlur)',
                      rules: [RequiredRule(message: 'Harus diisi saat blur')],
                      filled: true,
                    ),
                    const SizedBox(height: 24),

                    // Tombol aksi: Reset dan Submit
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              controller.reset();
                              setState(() => _validationModesResult = null);
                            },
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              controller.handleSubmit(
                                (ValidationModesModel data) async {
                                  setState(() {
                                    _validationModesResult =
                                        'OK: ${data.onSubmitField}, '
                                        '${data.onChangeField}, '
                                        '${data.onBlurField}';
                                  });
                                },
                                onInvalid: (errors) {
                                  setState(() {
                                    _validationModesResult = 'Errors: $errors';
                                  });
                                },
                              );
                            },
                            child: const Text('Submit'),
                          ),
                        ),
                      ],
                    ),

                    // Hasil submit / error
                    if (_validationModesResult != null) ...[
                      const SizedBox(height: 16),
                      AppText(
                        _validationModesResult!,
                        variant: TextVariant.bodyMedium,
                        color: AppColors.neutral[800],
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationRulesExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Demonstrating built-in validation rules',
            variant: TextVariant.bodyLarge,
          ),
          const SizedBox(height: 16),
          FormBuilder<ValidationRulesModel>(
            validationMode: ValidationMode.onSubmit,
            fromJson: ValidationRulesModel.fromJson,
            toJson: (m) => m.toJson(),
            builder: (context, controller) {
              return Column(
                children: [
                  FormInputField(
                    formController: controller,
                    name: 'required',
                    label: 'Required',
                    rules: [RequiredRule(message: 'This is required')],
                    filled: true,
                  ),
                  const SizedBox(height: 12),
                  FormInputField(
                    formController: controller,
                    name: 'minLength',
                    label: 'Min Length (5)',
                    rules: [MinLengthRule(5, message: 'Min 5 chars')],
                    filled: true,
                  ),
                  const SizedBox(height: 12),
                  FormInputField(
                    formController: controller,
                    name: 'email',
                    label: 'Email',
                    rules: [EmailRule(message: 'Invalid email')],
                    keyboardType: TextInputType.emailAddress,
                    filled: true,
                  ),
                  const SizedBox(height: 12),
                  FormInputField(
                    formController: controller,
                    name: 'pattern',
                    label: 'Pattern (A–Z)',
                    rules: [
                      PatternRule(RegExp(r'^[A-Z]+$'),
                          message: 'Only uppercase letters')
                    ],
                    filled: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          controller.reset();
                          setState(() {
                            _validationRulesResult = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          controller.handleSubmit(
                            (ValidationRulesModel data) async {
                              setState(() {
                                _validationRulesResult =
                                    'OK: ${data.required}, ${data.minLength}, ${data.email}, ${data.pattern}';
                              });
                            },
                            onInvalid: (errors) {
                              setState(() {
                                _validationRulesResult = 'Errors: $errors';
                              });
                            },
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  if (_validationRulesResult != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: AppText(
                        _validationRulesResult!,
                        variant: TextVariant.bodyMedium,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormStateMonitoringExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FormBuilder<BasicFormModel>(
        validationMode: ValidationMode.onChange,
        fromJson: BasicFormModel.fromJson,
        toJson: (m) => m.toJson(),
        builder: (context, controller) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormInputField(
                formController: controller,
                name: 'name',
                label: 'Name',
                rules: [RequiredRule()],
                filled: true,
              ),
              const SizedBox(height: 12),
              FormInputField(
                formController: controller,
                name: 'email',
                label: 'Email',
                rules: [RequiredRule(), EmailRule()],
                keyboardType: TextInputType.emailAddress,
                filled: true,
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder<bool>(
                valueListenable: controller.isValidNotifier,
                builder: (_, isValid, __) {
                  return AppText('Form is valid: $isValid',
                      variant: TextVariant.bodySmall);
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: controller.isDirtyNotifier,
                builder: (_, isDirty, __) {
                  return AppText('Form is dirty: $isDirty',
                      variant: TextVariant.bodySmall);
                },
              ),
              ValueListenableBuilder<bool>(
                valueListenable: controller.isTouchedNotifier,
                builder: (_, isTouched, __) {
                  return AppText('Form is touched: $isTouched',
                      variant: TextVariant.bodySmall);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildComplexFormExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FormBuilder<ComplexFormModel>(
        validationMode: ValidationMode.onSubmit,
        fromJson: ComplexFormModel.fromJson,
        toJson: (m) => m.toJson(),
        builder: (context, controller) {
          // Store a reference to password controller for confirmation rule
          String getPassword() =>
              controller.getValue('password') as String? ?? '';

          return Column(
            children: [
              FormInputField(
                formController: controller,
                name: 'fullName',
                label: 'Full Name',
                rules: [RequiredRule(message: 'Full name required')],
                filled: true,
              ),
              const SizedBox(height: 12),
              FormInputField(
                formController: controller,
                name: 'email',
                label: 'Email',
                rules: [RequiredRule(), EmailRule()],
                keyboardType: TextInputType.emailAddress,
                filled: true,
              ),
              const SizedBox(height: 12),
              FormInputField(
                formController: controller,
                name: 'password',
                label: 'Password',
                rules: [RequiredRule(), MinLengthRule(6)],
                obscureText: true,
                features: [InputFeature.passwordToggle()],
                filled: true,
              ),
              const SizedBox(height: 12),
              FormInputField(
                formController: controller,
                name: 'confirmPassword',
                label: 'Confirm Password',
                rules: [
                  RequiredRule(message: 'Please confirm password'),
                  ConfirmPasswordRule(getPassword: getPassword)
                ],
                obscureText: true,
                features: [InputFeature.passwordToggle()],
                filled: true,
              ),
              const SizedBox(height: 12),
              FormInputField(
                formController: controller,
                name: 'phoneNumber',
                label: 'Phone Number',
                rules: [PhoneNumberRule()],
                keyboardType: TextInputType.phone,
                filled: true,
              ),
              const SizedBox(height: 12),
              FormInputField(
                formController: controller,
                name: 'address',
                label: 'Address',
                maxLines: 3,
                filled: true,
              ),
              const SizedBox(height: 12),
              FormInputField(
                formController: controller,
                name: 'age',
                label: 'Age',
                keyboardType: TextInputType.number,
                rules: [
                  PatternRule(RegExp(r'^\d+$'), message: 'Age must be a number')
                ],
                filled: true,
              ),
              const SizedBox(height: 12),
              // For the checkbox, we still need the custom widget since FormInputField
              // is specialized for text inputs
              ValueListenableBuilder<FieldState<bool>>(
                  valueListenable: controller.register<bool>('acceptTerms',
                      rules: [
                        AcceptTermsRule(message: 'You must accept terms')
                      ]).stateNotifier,
                  builder: (context, fieldState, _) {
                    return AppCheckboxField(
                      label: 'Accept Terms',
                      value: fieldState.value ?? false,
                      errorText: fieldState.error,
                      onChanged: (v) => controller.setValue('acceptTerms', v),
                    );
                  }),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {
                      controller.reset();
                      setState(() {
                        _complexFormResult = null;
                      });
                    },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      controller.handleSubmit(
                        (ComplexFormModel data) async {
                          setState(() {
                            _complexFormResult =
                                'Received: ${data.fullName}, age ${data.age}';
                          });
                        },
                        onInvalid: (errors) {
                          setState(() {
                            _complexFormResult = 'Errors: $errors';
                          });
                        },
                      );
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
              if (_complexFormResult != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: AppText(
                    _complexFormResult!,
                    variant: TextVariant.bodyMedium,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // New methods for the additional form components

  Widget _buildCheckboxExample() {
    final fruitOptions = [
      CheckboxOption<String>(value: 'apple', label: 'Apple'),
      CheckboxOption<String>(value: 'banana', label: 'Banana'),
      CheckboxOption<String>(value: 'cherry', label: 'Cherry'),
      CheckboxOption<String>(value: 'durian', label: 'Durian'),
      CheckboxOption<String>(value: 'elderberry', label: 'Elderberry'),
    ];

    final categoryGroups = [
      CheckboxGroup<String>(
        title: 'Vegetables',
        options: [
          CheckboxOption<String>(value: 'carrot', label: 'Carrot'),
          CheckboxOption<String>(value: 'broccoli', label: 'Broccoli'),
          CheckboxOption<String>(value: 'spinach', label: 'Spinach'),
        ],
        showSelectAll: true,
      ),
      CheckboxGroup<String>(
        title: 'Dairy',
        options: [
          CheckboxOption<String>(value: 'milk', label: 'Milk'),
          CheckboxOption<String>(value: 'cheese', label: 'Cheese'),
          CheckboxOption<String>(value: 'yogurt', label: 'Yogurt'),
        ],
        showSelectAll: true,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Checkbox form component examples',
            variant: TextVariant.bodyLarge,
          ),
          const SizedBox(height: 16),
          FormBuilder<CheckboxFormModel>(
            validationMode: ValidationMode.onSubmit,
            fromJson: CheckboxFormModel.fromJson,
            toJson: (m) => m.toJson(),
            builder: (context, controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Single checkbox example
                  AppText(
                    'Single Checkbox',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormCheckboxField<bool>(
                    formController: controller,
                    name: 'singleCheckbox',
                    label: 'Enable notifications',
                    helperText: 'Receive push notifications on your device',
                  ),
                  const SizedBox(height: 16),

                  // Multi-checkbox example (flat list)
                  AppText(
                    'Multi-select Checkboxes',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormCheckboxField<String>(
                    formController: controller,
                    name: 'multiCheckbox',
                    label: 'Select your favorite fruits',
                    options: fruitOptions,
                    isMulti: true,
                    layout: CheckboxLayout.vertical,
                    showSelectAll: true,
                    rules: [
                      RequiredChipsRule(
                          message: 'Please select at least one fruit'),
                      MaxChipsRule(3,
                          message: 'Please select no more than 3 fruits'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Styled checkbox with error handling
                  AppText(
                    'Styled Checkbox with Validation',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormCheckboxField<bool>(
                    formController: controller,
                    name: 'termsAccepted',
                    label: 'I accept the terms and conditions',
                    // Fix: Remove showBorder parameter which is not available
                    shape: CheckboxShape.rounded,
                    style: CheckboxStyle(
                      activeColor: AppColors.primary,
                      backgroundColor: AppColors.neutral[50],
                      borderColor: AppColors.neutral[300],
                      padding: const EdgeInsets.all(8),
                    ),
                    rules: [
                      AcceptTermsRule(
                          message: 'You must accept the terms to continue')
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grouped checkboxes
                  AppText(
                    'Grouped Checkboxes',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormCheckboxField<String>(
                    formController: controller,
                    name: 'groupedOptions',
                    label: 'Shopping List',
                    groups: categoryGroups,
                    isMulti: true,
                    collapsibleGroups: true,
                  ),
                  const SizedBox(height: 16),

                  // Form submission buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          controller.reset();
                          setState(() {
                            _checkboxFormResult = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neutral[400]!),
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.handleSubmit(
                            (CheckboxFormModel data) async {
                              setState(() {
                                _checkboxFormResult =
                                    'Submitted: Notifications: ${data.singleCheckbox}, '
                                    'Fruits: ${data.multiCheckbox.join(', ')}, '
                                    'Terms Accepted: ${data.termsAccepted}, '
                                    'Shopping Items: ${data.groupedOptions.length} items';
                              });
                            },
                            onInvalid: (errors) {
                              setState(() {
                                _checkboxFormResult = 'Errors: $errors';
                              });
                            },
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  if (_checkboxFormResult != null) ...[
                    const SizedBox(height: 16),
                    AppText(
                      _checkboxFormResult!,
                      variant: TextVariant.bodyMedium,
                      color: AppColors.neutral[700],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChipFieldExample() {
    // Language options for the first chip field
    final languageChips = [
      ChipData(label: 'JavaScript', value: 'javascript'),
      ChipData(label: 'Python', value: 'python'),
      ChipData(label: 'Java', value: 'java'),
      ChipData(label: 'C#', value: 'csharp'),
      ChipData(label: 'PHP', value: 'php'),
      ChipData(label: 'Swift', value: 'swift'),
      ChipData(label: 'Kotlin', value: 'kotlin'),
    ];

    // Framework options with groups
    final frameworkGroups = [
      ChipGroupData(
        title: 'Frontend',
        chips: [
          ChipData(label: 'React', value: 'react'),
          ChipData(label: 'Angular', value: 'angular'),
          ChipData(label: 'Vue', value: 'vue'),
          ChipData(label: 'Svelte', value: 'svelte'),
        ],
      ),
      ChipGroupData(
        title: 'Backend',
        chips: [
          ChipData(label: 'Node.js', value: 'nodejs'),
          ChipData(label: 'Django', value: 'django'),
          ChipData(label: 'Spring', value: 'spring'),
          ChipData(label: 'Laravel', value: 'laravel'),
        ],
      ),
      ChipGroupData(
        title: 'Mobile',
        chips: [
          ChipData(label: 'Flutter', value: 'flutter'),
          ChipData(label: 'React Native', value: 'react-native'),
          ChipData(label: 'Xamarin', value: 'xamarin'),
        ],
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Chip field form component examples',
            variant: TextVariant.bodyLarge,
          ),
          const SizedBox(height: 16),
          FormBuilder<ChipFormModel>(
            validationMode: ValidationMode.onSubmit,
            fromJson: ChipFormModel.fromJson,
            toJson: (m) => m.toJson(),
            builder: (context, controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic chip selection
                  AppText(
                    'Multi-select Chips',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormChipField(
                    formController: controller,
                    name: 'selectedLanguages',
                    label: 'Programming Languages',
                    isRequired: true,
                    chips: languageChips,
                    isMulti: true,
                    rules: [
                      RequiredChipsRule(
                          message: 'Please select at least one language'),
                    ],
                    chipStyle: ChipStyle(
                      backgroundColor: AppColors.neutral[50],
                      borderColor: AppColors.neutral[300],
                      textColor: AppColors.neutral[800],
                    ),
                    chipSelectedStyle: ChipStyle(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      borderColor: AppColors.primary,
                      textColor: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grouped chips
                  AppText(
                    'Grouped Chips',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormChipField(
                    formController: controller,
                    name: 'selectedFrameworks',
                    label: 'Frameworks & Libraries',
                    isRequired: true,
                    groupData: frameworkGroups,
                    isMulti: true,
                    collapsibleGroup: true,
                    helperText:
                        'Select the frameworks you have experience with',
                    rules: [
                      MinChipsRule(2,
                          message: 'Please select at least 2 frameworks'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Input-enabled chip field
                  AppText(
                    'Input Chips (Tags)',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormChipField(
                    formController: controller,
                    name: 'tags',
                    label: 'Skills & Interests',
                    isRequired: false,
                    chips: controller
                            .getValue('tags')
                            ?.map<ChipData>((tag) => ChipData(
                                label: tag, value: tag, deletable: true))
                            .toList() ??
                        [],
                    inputEnabled: true,
                    inputValidator: (value) => value.isEmpty
                        ? 'Tag cannot be empty'
                        : value.length > 20
                            ? 'Tag is too long'
                            : null,
                    maxChips: 5,
                    helperText: 'Add up to 5 skills (press Enter to add)',
                  ),
                  const SizedBox(height: 16),

                  // Form submission buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          controller.reset();
                          setState(() {
                            _chipFormResult = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neutral[400]!),
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.handleSubmit(
                            (ChipFormModel data) async {
                              setState(() {
                                _chipFormResult =
                                    'Submitted: Languages: ${data.selectedLanguages.join(', ')}, '
                                    'Frameworks: ${data.selectedFrameworks.join(', ')}, '
                                    'Skills: ${data.tags.join(', ')}';
                              });
                            },
                            onInvalid: (errors) {
                              setState(() {
                                _chipFormResult = 'Errors: $errors';
                              });
                            },
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  if (_chipFormResult != null) ...[
                    const SizedBox(height: 16),
                    AppText(
                      _chipFormResult!,
                      variant: TextVariant.bodyMedium,
                      color: AppColors.neutral[700],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadioButtonExample() {
    // Gender options
    final genderOptions = [
      RadioOption<String>(value: 'male', label: 'Male'),
      RadioOption<String>(value: 'female', label: 'Female'),
      RadioOption<String>(value: 'other', label: 'Other'),
      RadioOption<String>(
          value: 'prefer_not_to_say', label: 'Prefer not to say'),
    ];

    // Contact preference options
    final contactOptions = [
      RadioOption<String>(
        value: 'email',
        label: 'Email',
        icon: Icons.email,
        enabled: true,
      ),
      RadioOption<String>(
        value: 'phone',
        label: 'Phone',
        icon: Icons.phone,
        enabled: true,
      ),
      RadioOption<String>(
        value: 'text',
        label: 'Text message',
        icon: Icons.sms,
        enabled: true,
      ),
      RadioOption<String>(
        value: 'mail',
        label: 'Physical mail',
        icon: Icons.mail,
        enabled: false,
        tooltip: 'Currently unavailable',
      ),
    ];

    // Payment method groups
    final paymentGroups = [
      RadioOptionGroup<String>(
        title: 'Credit Cards',
        options: [
          RadioOption<String>(value: 'visa', label: 'Visa'),
          RadioOption<String>(value: 'mastercard', label: 'Mastercard'),
          RadioOption<String>(value: 'amex', label: 'American Express'),
        ],
      ),
      RadioOptionGroup<String>(
        title: 'Digital Payments',
        options: [
          RadioOption<String>(value: 'paypal', label: 'PayPal'),
          RadioOption<String>(value: 'apple_pay', label: 'Apple Pay'),
          RadioOption<String>(value: 'google_pay', label: 'Google Pay'),
        ],
      ),
      RadioOptionGroup<String>(
        title: 'Other Methods',
        options: [
          RadioOption<String>(value: 'bank_transfer', label: 'Bank Transfer'),
          RadioOption<String>(
              value: 'crypto', label: 'Cryptocurrency', enabled: false),
        ],
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Radio button form component examples',
            variant: TextVariant.bodyLarge,
          ),
          const SizedBox(height: 16),
          FormBuilder<RadioFormModel>(
            validationMode: ValidationMode.onSubmit,
            fromJson: RadioFormModel.fromJson,
            toJson: (m) => m.toJson(),
            builder: (context, controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic radio selection
                  AppText(
                    'Basic Radio Buttons',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormRadioField<String>(
                    formController: controller,
                    name: 'gender',
                    label: 'Gender',
                    options: genderOptions,
                    isRequired: true,
                    rules: [RequiredRule(message: 'Please select your gender')],
                  ),
                  const SizedBox(height: 16),

                  // Styled radio buttons with icons
                  AppText(
                    'Styled Radio Buttons with Icons',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormRadioField<String>(
                    formController: controller,
                    name: 'contactPreference',
                    label: 'Preferred Contact Method',
                    options: contactOptions,
                    isRequired: true,
                    layout: RadioLayout.horizontal,
                    activeColor: AppColors.primary,
                    optionStyle: RadioOptionStyle(
                      backgroundColor: AppColors.neutral[50],
                      borderColor: AppColors.neutral[300],
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    selectedOptionStyle: RadioOptionStyle(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      borderColor: AppColors.primary,
                      iconColor: AppColors.primary,
                    ),
                    rules: [
                      RequiredRule(
                          message:
                              'Please select your preferred contact method')
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grouped radio options
                  AppText(
                    'Grouped Radio Options',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormRadioField<String>(
                    formController: controller,
                    name: 'paymentMethod',
                    // Fix: Change 'title' to 'label' parameter
                    label: 'Select Payment Method',
                    isRequired: true,
                    groups: paymentGroups,
                    collapsibleGroups: true,
                    rules: [
                      RequiredRule(message: 'Please select a payment method')
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form submission buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          controller.reset();
                          setState(() {
                            _radioFormResult = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neutral[400]!),
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.handleSubmit(
                            (RadioFormModel data) async {
                              setState(() {
                                _radioFormResult =
                                    'Submitted: Gender: ${data.gender}, '
                                    'Contact: ${data.contactPreference}, '
                                    'Payment: ${data.paymentMethod}';
                              });
                            },
                            onInvalid: (errors) {
                              setState(() {
                                _radioFormResult = 'Errors: $errors';
                              });
                            },
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  if (_radioFormResult != null) ...[
                    const SizedBox(height: 16),
                    AppText(
                      _radioFormResult!,
                      variant: TextVariant.bodyMedium,
                      color: AppColors.neutral[700],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectFieldExample() {
    // Country options for single select
    final countryOptions = [
      SelectOption<String>(value: 'us', label: 'United States'),
      SelectOption<String>(value: 'ca', label: 'Canada'),
      SelectOption<String>(value: 'uk', label: 'United Kingdom'),
      SelectOption<String>(value: 'au', label: 'Australia'),
      SelectOption<String>(value: 'de', label: 'Germany'),
      SelectOption<String>(value: 'fr', label: 'France'),
      SelectOption<String>(value: 'jp', label: 'Japan'),
    ];

    // Interest options for multi-select
    final interestOptions = [
      SelectOption<String>(value: 'tech', label: 'Technology'),
      SelectOption<String>(value: 'sports', label: 'Sports'),
      SelectOption<String>(value: 'music', label: 'Music'),
      SelectOption<String>(value: 'movies', label: 'Movies'),
      SelectOption<String>(value: 'books', label: 'Books'),
      SelectOption<String>(value: 'travel', label: 'Travel'),
      SelectOption<String>(value: 'food', label: 'Food'),
      SelectOption<String>(value: 'fashion', label: 'Fashion'),
    ];

    // Education level groups
    final educationGroups = [
      SelectGroup<String>(
        title: 'High School',
        options: [
          SelectOption<String>(
              value: 'high_school', label: 'High School Diploma'),
          SelectOption<String>(value: 'ged', label: 'GED'),
        ],
      ),
      SelectGroup<String>(
        title: 'College',
        options: [
          SelectOption<String>(
              value: 'associates', label: 'Associate\'s Degree'),
          SelectOption<String>(value: 'bachelors', label: 'Bachelor\'s Degree'),
          SelectOption<String>(value: 'masters', label: 'Master\'s Degree'),
          SelectOption<String>(value: 'doctorate', label: 'Doctorate'),
        ],
      ),
      SelectGroup<String>(
        title: 'Other',
        options: [
          SelectOption<String>(
              value: 'vocational', label: 'Vocational Training'),
          SelectOption<String>(
              value: 'certification', label: 'Professional Certification'),
          SelectOption<String>(value: 'other', label: 'Other'),
        ],
      ),
    ];

    // Skills options for grouped multi-select
    final skillGroups = [
      SelectGroup<String>(
        title: 'Programming',
        options: [
          SelectOption<String>(value: 'javascript', label: 'JavaScript'),
          SelectOption<String>(value: 'python', label: 'Python'),
          SelectOption<String>(value: 'java', label: 'Java'),
          SelectOption<String>(value: 'csharp', label: 'C#'),
        ],
      ),
      SelectGroup<String>(
        title: 'Design',
        options: [
          SelectOption<String>(value: 'ui', label: 'UI Design'),
          SelectOption<String>(value: 'ux', label: 'UX Design'),
          SelectOption<String>(value: 'graphic', label: 'Graphic Design'),
          SelectOption<String>(value: 'motion', label: 'Motion Design'),
        ],
      ),
      SelectGroup<String>(
        title: 'Soft Skills',
        options: [
          SelectOption<String>(value: 'communication', label: 'Communication'),
          SelectOption<String>(value: 'teamwork', label: 'Teamwork'),
          SelectOption<String>(
              value: 'problem_solving', label: 'Problem Solving'),
          SelectOption<String>(
              value: 'time_management', label: 'Time Management'),
        ],
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Select field form component examples',
            variant: TextVariant.bodyLarge,
          ),
          const SizedBox(height: 16),
          FormBuilder<SelectFormModel>(
            validationMode: ValidationMode.onSubmit,
            fromJson: SelectFormModel.fromJson,
            toJson: (m) => m.toJson(),
            builder: (context, controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic select field
                  AppText(
                    'Basic Select Field',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormSelectField<String>(
                    formController: controller,
                    name: 'country',
                    label: 'Country',
                    options: countryOptions,
                    isRequired: true,
                    placeholder: 'Select your country',
                    rules: [
                      RequiredRule(message: 'Please select your country')
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Multi-select with search
                  AppText(
                    'Multi-select with Search',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormSelectField<String>(
                    formController: controller,
                    name: 'interests',
                    label: 'Interests',
                    options: interestOptions,
                    isMulti: true,
                    searchable: true,
                    showClear: true,
                    helperText: 'Select all that apply',
                    rules: [
                      MinChipsRule(2,
                          message: 'Please select at least 2 interests'),
                      MaxChipsRule(5,
                          message: 'Please select no more than 5 interests'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grouped select field
                  AppText(
                    'Grouped Select Field',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormSelectField<String>(
                    formController: controller,
                    name: 'education',
                    label: 'Highest Education Level',
                    isRequired: true,
                    groups: educationGroups,
                    triggerType: SelectTriggerType.button,
                    rules: [
                      RequiredRule(
                          message: 'Please select your education level')
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Grouped multi-select with chip display
                  AppText(
                    'Grouped Multi-select with Chip Display',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormSelectField<String>(
                    formController: controller,
                    name: 'skills',
                    label: 'Skills',
                    isRequired: true,
                    groups: skillGroups,
                    isMulti: true,
                    searchable: true,
                    showClear: true,
                    triggerType: SelectTriggerType.chip,
                    helperText: 'Search and select your skills',
                    rules: [
                      RequiredChipsRule(
                          message: 'Please select at least one skill'),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Form submission buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          controller.reset();
                          setState(() {
                            _selectFormResult = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neutral[400]!),
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.handleSubmit(
                            (SelectFormModel data) async {
                              setState(() {
                                _selectFormResult =
                                    'Submitted: Country: ${data.country}, '
                                    'Interests: ${data.interests.join(', ')}, '
                                    'Education: ${data.education}, '
                                    'Skills: ${data.skills.join(', ')}';
                              });
                            },
                            onInvalid: (errors) {
                              setState(() {
                                _selectFormResult = 'Errors: $errors';
                              });
                            },
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  if (_selectFormResult != null) ...[
                    const SizedBox(height: 16),
                    AppText(
                      _selectFormResult!,
                      variant: TextVariant.bodyMedium,
                      color: AppColors.neutral[700],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchInputExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.neutral[200]!),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Switch input form component examples',
            variant: TextVariant.bodyLarge,
          ),
          const SizedBox(height: 16),
          FormBuilder<SwitchFormModel>(
            validationMode: ValidationMode.onSubmit,
            fromJson: SwitchFormModel.fromJson,
            toJson: (m) => m.toJson(),
            builder: (context, controller) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic switch
                  AppText(
                    'Basic Switch',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormSwitchField(
                    formController: controller,
                    name: 'notifications',
                    label: 'Enable Notifications',
                    helperText: 'Receive updates and alerts',
                  ),
                  const SizedBox(height: 16),

                  // Styled switch
                  AppText(
                    'Styled Switch',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormSwitchField(
                    formController: controller,
                    name: 'darkMode',
                    label: 'Dark Mode',
                    shape: SwitchShape.ios,
                    position: SwitchPosition.end,
                    showBorder: true,
                    icon: Icons.dark_mode,
                    style: SwitchStyle(
                      activeColor: AppColors.primary,
                      activeTrackColor:
                          AppColors.primary.withValues(alpha: 0.3),
                      backgroundColor: AppColors.neutral[50],
                      borderColor: AppColors.neutral[300],
                      borderRadius: BorderRadius.circular(8),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Switch with description
                  AppText(
                    'Switch with Description',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormSwitchField(
                    formController: controller,
                    name: 'locationServices',
                    label: 'Location Services',
                    tooltip: 'Enable or disable location tracking',
                    description:
                        'Allow the app to access your location to provide personalized content and nearby services',
                    shape: SwitchShape.material3,
                    icon: Icons.location_on,
                  ),
                  const SizedBox(height: 16),

                  // Required switch with validation
                  AppText(
                    'Required Switch with Validation',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(height: 8),
                  FormSwitchField(
                    formController: controller,
                    name: 'autoSave',
                    label: 'Auto-save',
                    isRequired: true,
                    rules: [
                      // Fix: Replace direct instantiation of ValidationRule with custom class
                      AutoSaveRequiredRule(
                        message: 'This feature must be enabled',
                      ),
                    ],
                    helperText:
                        'This setting is required for proper functionality',
                  ),
                  const SizedBox(height: 16),

                  // Form submission buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {
                          controller.reset();
                          setState(() {
                            _switchFormResult = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.neutral[400]!),
                        ),
                        child: const Text('Reset'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.handleSubmit(
                            (SwitchFormModel data) async {
                              setState(() {
                                _switchFormResult =
                                    'Submitted: Notifications: ${data.notifications}, '
                                    'Dark Mode: ${data.darkMode}, '
                                    'Location Services: ${data.locationServices}, '
                                    'Auto-save: ${data.autoSave}';
                              });
                            },
                            onInvalid: (errors) {
                              setState(() {
                                _switchFormResult = 'Errors: $errors';
                              });
                            },
                          );
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                  if (_switchFormResult != null) ...[
                    const SizedBox(height: 16),
                    AppText(
                      _switchFormResult!,
                      variant: TextVariant.bodyMedium,
                      color: AppColors.neutral[700],
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
