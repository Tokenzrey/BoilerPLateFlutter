import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/input.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/utils/device/device_utils.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/routes/routes_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../di/service_locator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginModel {
  final String email;
  final String password;

  LoginModel({
    this.email = '',
    this.password = '',
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  final AuthStore _authStore = getIt<AuthStore>();

  bool _hasNavigated = false;

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
                    child: _buildLoginForm(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
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
          'Login',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.w500,
          color: AppColors.neutral,
        ),
        const SizedBox(height: 20),
        const Divider(color: AppColors.neutral, thickness: 1, height: 1),
        const SizedBox(height: 32),

        FormBuilder<LoginModel>(
          validationMode: ValidationMode.onSubmit,
          fromJson: LoginModel.fromJson,
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
                  rules: [RequiredRule(message: 'Password is required')],
                  filled: true,
                  textStyle: TextStyle(color: AppColors.neutral[950]),
                  borderRadius: 4,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Observer(
                    builder: (_) => Button(
                      text: 'Sign in',
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
                                (LoginModel data) async {
                                  DeviceUtils.hideKeyboard(context);
                                  try {
                                    final success = await _authStore.login(
                                      data.email,
                                      data.password,
                                    );

                                    if (!success && !_hasNavigated && mounted) {
                                      // Use generic error message
                                      _authStore
                                          .setErrorMessage('Login Incorrect');
                                    }
                                  } catch (e) {
                                    // Reset loading state
                                    _authStore.setLoading(false);
                                    // Use generic error message
                                    _authStore
                                        .setErrorMessage('Login Incorrect');
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
                        "Don't have an account? ",
                        variant: TextVariant.bodySmall,
                        color: AppColors.neutral,
                      ),
                      TextButton(
                        onPressed: () {
                          AppRouter.push(context, RoutePaths.register);
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const AppText(
                          'Sign up',
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
          if (_authStore.isLoggedIn && !_hasNavigated) {
            _hasNavigated = true;
            _navigateToHome();
          }

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

  Future<void> _navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    if (!mounted) return;
    AppRouter.pushReplacement(context, RoutePaths.home);
  }
}
