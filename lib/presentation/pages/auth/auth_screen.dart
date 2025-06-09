import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
// import 'package:boilerplate/core/widgets/textfield_widget.dart';
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

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<AuthScreen> {
  // final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;
  bool _obscurePassword = true;

  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final AuthStore _authStore = getIt<AuthStore>();

  late FocusNode _passwordFocusNode;
  late FocusNode _usernameFocusNode;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _usernameFocusNode = FocusNode();
    _authStore.resetError();
  }

  Future<void> _submit() async {
    if (_isLoginMode) {
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
    } else {
      if (_formStore.canRegister && _usernameController.text.isNotEmpty) {
        DeviceUtils.hideKeyboard(context);

        final success = await _authStore.register(
          _userEmailController.text,
          _passwordController.text,
          _usernameController.text,
          _usernameController.text,
        );

        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration successful!')),
            );
            setState(() {
              _isLoginMode = true;
            });
          }
        } else {
          if (mounted && _authStore.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(_authStore.errorMessage!)),
            );
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeStore.darkMode;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF17181C) : const Color(0xFFF4F6FB),
      appBar: EmptyAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0.2, 0.0),
            end: Offset.zero,
          ).animate(animation);

          final fade = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

          return SlideTransition(
            position: offsetAnimation,
            child: FadeTransition(
              opacity: fade,
              child: child,
            ),
          );
        },
        child: Center(
          key: _isLoginMode? const ValueKey('login') : const ValueKey('register'),
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
      ),
    );
  }

  Widget _buildFormContents(BuildContext context, bool isDark) {
    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              'https://comick.io/static/icons/55x55-icon.png',
              width: 45,
              height: 45,
            ),
            const SizedBox(height: 24),

            _isLoginMode
                ? _loginForm(isDark: isDark)
                : _registerForm(isDark: isDark),

            // AnimatedSwitcher(
            //   duration: const Duration(milliseconds: 400),
            //   child: _isLoginMode
            //       ? _loginForm(isDark: isDark)
            //       : _registerForm(isDark: isDark),
            //   transitionBuilder: (child, animation) {
            //     return FadeTransition(opacity: animation, child: child);
            //   },
            // ),
            
            const SizedBox(height: 8),
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

  Widget _loginForm({required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: const ValueKey('login'),
      children: [
        AppText(
          'Login',
          variant: TextVariant.titleMedium,
          color: isDark ? Colors.white : Colors.black87,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        AppText(
          'E-Mail',
          variant: TextVariant.labelLarge,
          color: isDark ? Colors.white70 : Colors.black87,
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 8),
        _buildUserIdField(),
        const SizedBox(height: 16),

        AppText(
          'Password',
          variant: TextVariant.labelLarge,
          color: isDark ? Colors.white70 : Colors.black87,
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 8),
        _buildPasswordField(),
        const SizedBox(height: 24),
        _buildAuthButton(),
        const SizedBox(height: 8),
        _buildAuthModeToggle(),
      ]
    );
  }

  Widget _registerForm({bool isDark = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: const ValueKey('register'),
      children:[
        AppText(
          'Registration',
          variant: TextVariant.titleMedium,
          color: isDark ? Colors.white : Colors.black87,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 32),

        AppText(
          'E-Mail',
          variant: TextVariant.labelLarge,
          color: isDark ? Colors.white70 : Colors.black87,
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 8),
        _buildUserIdField(),
        const SizedBox(height: 16),

        AppText(
          'Password',
          variant: TextVariant.labelLarge,
          color: isDark ? Colors.white70 : Colors.black87,
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 8),
        _buildPasswordField(),
        const SizedBox(height: 16),

        AppText(
          'Username',
          variant: TextVariant.labelLarge,
          color: isDark ? Colors.white70 : Colors.black87,
          textAlign: TextAlign.left,
        ),

        const SizedBox(height: 8),
        _buildUsernameField(),
        const SizedBox(height: 24),
        _buildAuthButton(),
        const SizedBox(height: 8),
        _buildAuthModeToggle(),        
      ]
    );
  }

  Widget _buildUserIdField(){
    return Observer(builder:  (_) {
      return TextField(
        controller: _userEmailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorText: _formStore.formErrorStore.userEmail,
        ),
        onChanged: (value) => _formStore.setUserId(value),
        onSubmitted: (_) => FocusScope.of(context).requestFocus(_passwordFocusNode),
      );
    });
  }

  Widget _buildPasswordField() {
    return Observer(builder: (_) {
      return TextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: _obscurePassword,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          errorText: _formStore.formErrorStore.password,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
            ),
            onPressed: () => setState(
                () => _obscurePassword = !_obscurePassword),
          ),
        ),
        onChanged: (value) { 
          _formStore.setPassword(value);
          _formStore.setConfirmPassword(value);
        },
        onSubmitted: (_) => FocusScope.of(context).requestFocus(_usernameFocusNode),
      );
    });
  }

  Widget _buildUsernameField(){
    return Observer(builder:  (_) {
      return TextField(
        controller: _usernameController,
        focusNode: _usernameFocusNode,
      );
    });
  }

  Widget _buildAuthButton() {
    return RoundedButtonWidget(
      buttonText: _isLoginMode? 'Sign In' : 'Sign Up',
      buttonColor: Color(0xFF6475F7),
      textColor: Colors.white,
      height: 48,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      onPressed: _submit, 
    );
  }

  Widget _buildAuthModeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          _isLoginMode? 'Don\'t have an account?' : 'Already have an account?', 
          variant: TextVariant.bodySmall
        ),
        TextButton(
          child: AppText(
            _isLoginMode? 'Sign Up' : 'Sign In',
            variant: TextVariant.bodyMedium,
            color: Color(0xFF6475F7),
            fontWeight: FontWeight.bold,
          ),
          onPressed: () => setState(() => _isLoginMode = !_isLoginMode)
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
    _userEmailController.dispose();
    _passwordFocusNode.dispose();
    _usernameFocusNode.dispose();
    super.dispose();
  }
}
