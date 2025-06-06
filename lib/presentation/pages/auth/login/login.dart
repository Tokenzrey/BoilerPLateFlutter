import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/presentation/store/theme/theme_store.dart';
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

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final AuthStore _authStore = getIt<AuthStore>();

  late FocusNode _passwordFocusNode;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _authStore.resetError();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeStore.darkMode;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF17181C) : const Color(0xFFF4F6FB),
      appBar: EmptyAppBar(),
      body: Center(
        child: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: isDark ? const Color(0xFF22232C) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black45
                      : Colors.grey.withValues(alpha: 0.2),
                  spreadRadius: 3,
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: _buildFormContents(context, isDark),
          ),
        )),
      ),
    );
  }

  Widget _buildFormContents(BuildContext context, bool isDark) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: AppText(
                'Welcome Back!',
                variant: TextVariant.headlineMedium,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: AppText(
                'Sign in to your account',
                variant: TextVariant.bodyMedium,
                color: isDark ? Colors.white70 : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 32),
            _buildUserIdField(),
            const SizedBox(height: 16),
            _buildPasswordField(),
            const SizedBox(height: 24),
            _buildSignInButton(),
            const SizedBox(height: 8),
            _buildRegisterButton(),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                AppRouter.push(context, RoutePaths.sandbox);
              },
              child: const Text("Go to Sandbox"),
            ),
            Observer(builder: (_) {
              if (_authStore.hasError && _authStore.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: AppText(
                    _authStore.errorMessage!,
                    variant: TextVariant.bodyMedium,
                    color: Colors.red,
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        Observer(
          builder: (_) => Visibility(
            visible: _authStore.isLoading,
            child: const Positioned.fill(
              child: Center(child: CustomProgressIndicatorWidget()),
            ),
          ),
        ),
        Observer(builder: (_) {
          if (_authStore.isLoggedIn && !_hasNavigated) {
            _hasNavigated = true;
            _navigateToHome();
          }

          if (_authStore.errorMessage != null &&
              _authStore.errorMessage!.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showErrorMessage(_authStore.errorMessage!);
              _authStore.setErrorMessage(null);
            });
          }
          return Container();
        }),
      ],
    );
  }

  Widget _buildUserIdField() {
    return Observer(builder: (_) {
      return TextFieldWidget(
        hint: 'Email address',
        inputType: TextInputType.emailAddress,
        icon: Icons.email_outlined,
        iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
        textController: _userEmailController,
        inputAction: TextInputAction.next,
        onChanged: (_) => _formStore.setUserId(_userEmailController.text),
        onFieldSubmitted: (_) =>
            FocusScope.of(context).requestFocus(_passwordFocusNode),
        errorText: _formStore.formErrorStore.userEmail,
      );
    });
  }

  Widget _buildPasswordField() {
    return Observer(builder: (_) {
      return TextFieldWidget(
        hint: 'Password',
        isObscure: true,
        icon: Icons.lock_outline,
        iconColor: _themeStore.darkMode ? Colors.white70 : Colors.black54,
        textController: _passwordController,
        focusNode: _passwordFocusNode,
        onChanged: (_) => _formStore.setPassword(_passwordController.text),
        errorText: _formStore.formErrorStore.password,
      );
    });
  }

  Widget _buildSignInButton() {
    return RoundedButtonWidget(
      buttonText: 'Login',
      buttonColor: Colors.deepOrangeAccent,
      textColor: Colors.white,
      onPressed: () async {
        if (_formStore.canLogin) {
          DeviceUtils.hideKeyboard(context);

          final success = await _authStore.login(
            _userEmailController.text,
            _passwordController.text,
          );

          if (!success && !_hasNavigated) {
            _hasNavigated = true;
            _showErrorMessage(_authStore.errorMessage ?? 'Login failed');
          }
        } else {
          _showErrorMessage('Please fill in all fields');
        }
      },
    );
  }

  Widget _buildRegisterButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText('Don\'t have an account?', variant: TextVariant.bodySmall),
        TextButton(
          child: AppText(
            'Register',
            variant: TextVariant.bodyMedium,
            color: Colors.deepOrangeAccent,
            fontWeight: FontWeight.bold,
          ),
          onPressed: () {
            AppRouter.push(context, RoutePaths.register);
          },
        ),
      ],
    );
  }

  Future<void> _navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    if (!mounted) return;
    AppRouter.pushReplacement(context, RoutePaths.home);
  }

  void _showErrorMessage(String message) {
    if (message.isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      FlushbarHelper.createError(
        message: message,
        title: 'Error',
        duration: const Duration(seconds: 3),
      ).show(context);
    });
  }

  @override
  void dispose() {
    _userEmailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}
