import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/input.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../di/service_locator.dart';

class RegisterModel {
  final String email;
  final String password;
  final String username;
  final String fullName;

  RegisterModel({
    this.email = '',
    this.password = '',
    this.username = '',
    this.fullName = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'fullName': fullName,
    };
  }

  factory RegisterModel.fromJson(Map<String, dynamic> json) {
    return RegisterModel(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      username: json['username'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthStore _authStore = getIt<AuthStore>();

  @override
  void initState() {
    super.initState();
    _authStore.resetError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Button(
              leftIcon: Icons.arrow_back,
              iconOnly: true,
              density: ButtonDensity.icon,
              variant: ButtonVariant.ghost,
              colors: ButtonColors(
                text: AppColors.neutral[200],
              ),
              onPressed: () {
                context.go('/home');
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: _buildRegisterForm(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        // Logo placeholder
        Image.asset(
          'assets/icons/ic_app.png',
          height: 60,
          width: 60,
        ),
        const SizedBox(height: 16),
        const AppText(
          'Create an Account',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral,
        ),
        const SizedBox(height: 20),
        const Divider(color: AppColors.neutral, thickness: 1, height: 1),
        const SizedBox(height: 32),

        FormBuilder<RegisterModel>(
          validationMode: ValidationMode.onSubmit,
          fromJson: RegisterModel.fromJson,
          toJson: (model) => model.toJson(),
          builder: (context, controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: AppText(
                    'E-Mail *',
                    variant: TextVariant.bodyMedium,
                    color: AppColors.neutral,
                  ),
                ),
                FormInputField(
                  formController: controller,
                  name: 'email',
                  rules: [
                    RequiredRule(message: 'Email is required'),
                    EmailRule(message: 'Please enter a valid email address'),
                  ],
                  keyboardType: TextInputType.emailAddress,
                  filled: true,
                  textStyle: TextStyle(color: AppColors.neutral[950]),
                  borderRadius: 4,
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: AppText(
                    'Username *',
                    variant: TextVariant.bodyMedium,
                    color: AppColors.neutral,
                  ),
                ),
                FormInputField(
                  formController: controller,
                  name: 'username',
                  rules: [RequiredRule(message: 'Username is required')],
                  filled: true,
                  textStyle: TextStyle(color: AppColors.neutral[950]),
                  borderRadius: 4,
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: AppText(
                    'Full Name *',
                    variant: TextVariant.bodyMedium,
                    color: AppColors.neutral,
                  ),
                ),
                FormInputField(
                  formController: controller,
                  name: 'fullName',
                  rules: [RequiredRule(message: 'Full name is required')],
                  filled: true,
                  textStyle: TextStyle(color: AppColors.neutral[950]),
                  borderRadius: 4,
                ),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                  child: AppText(
                    'Password *',
                    variant: TextVariant.bodyMedium,
                    color: AppColors.neutral,
                  ),
                ),
                FormInputField(
                  formController: controller,
                  name: 'password',
                  obscureText: true,
                  features: [InputFeature.passwordToggle()],
                  rules: [
                    RequiredRule(message: 'Password is required'),
                    MinLengthRule(6,
                        message: 'Password must be at least 6 characters'),
                  ],
                  filled: true,
                  textStyle: TextStyle(color: AppColors.neutral[950]),
                  borderRadius: 4,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Observer(
                    builder: (_) => Button(
                      text: 'Register',
                      variant: ButtonVariant.primary,
                      size: ButtonSize.normal,
                      shape: ButtonShape.roundedRectangle,
                      colors: ButtonColors(
                        background: AppColors.blue[600],
                        text: AppColors.neutral[50],
                      ),
                      layout: const ButtonLayout(
                        expanded: true,
                        height: 50,
                      ),
                      loading: ButtonLoadingConfig(
                        isLoading: _authStore.isLoading,
                        widget: SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neutral[50],
                          ),
                        ),
                      ),
                      onPressed: _authStore.isLoading
                          ? null
                          : () {
                              controller.handleSubmit(
                                (RegisterModel data) async {
                                  DeviceUtils.hideKeyboard(context);
                                  try {
                                    final success = await _authStore.register(
                                      data.email,
                                      data.password,
                                      data.username,
                                      data.fullName,
                                    );
                                    if (!context.mounted) return;
                                    if (success && mounted) {
                                      Navigator.of(context).pop();
                                    } else {
                                      // Use generic error message
                                      _authStore.setErrorMessage(
                                          'Register Incorrect');
                                    }
                                  } catch (e) {
                                    // Reset loading state
                                    _authStore.setLoading(false);
                                    // Use generic error message
                                    _authStore
                                        .setErrorMessage('Register Incorrect');
                                  }
                                },
                                onInvalid: (errors) {
                                  // Keep form validation errors as they are
                                  _authStore.setErrorMessage(
                                      'Please fill in all fields correctly');
                                },
                              );
                            },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText(
                        'Already have an account? ',
                        variant: TextVariant.bodySmall,
                        color: AppColors.neutral,
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const AppText(
                          'Login',
                          variant: TextVariant.bodySmall,
                          fontWeight: FontWeight.w500,
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),

        // Error observer
        Observer(builder: (_) {
          if (_authStore.errorMessage != null &&
              _authStore.errorMessage!.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: AppText(
                _authStore.errorMessage!,
                variant: TextVariant.bodyMedium,
                color: AppColors.red,
                textAlign: TextAlign.center,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
        const SizedBox(height: 24),
      ],
    );
  }
}
