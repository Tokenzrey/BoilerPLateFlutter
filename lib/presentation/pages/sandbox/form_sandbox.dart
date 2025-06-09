import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/input.dart';
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

  // Track selected validation mode for the validation modes example
  ValidationMode _selectedValidationMode = ValidationMode.onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
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
}
