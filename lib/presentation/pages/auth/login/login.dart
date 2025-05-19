import 'package:another_flushbar/flushbar_helper.dart';
import 'package:boilerplate/constants/assets.dart';
import 'package:boilerplate/core/stores/form/form_store.dart';
import 'package:boilerplate/core/widgets/app_icon_widget.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/core/widgets/progress_indicator_widget.dart';
import 'package:boilerplate/core/widgets/rounded_button_widget.dart';
import 'package:boilerplate/core/widgets/textfield_widget.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
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
  // Controllers
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Stores
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final FormStore _formStore = getIt<FormStore>();
  final AuthStore _authStore = getIt<AuthStore>();

  // Focus
  late FocusNode _passwordFocusNode;

  // Navigation guard
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _passwordFocusNode = FocusNode();
    _authStore.resetError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      primary: true,
      appBar: EmptyAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: <Widget>[
        MediaQuery.of(context).orientation == Orientation.landscape
            ? Row(
                children: <Widget>[
                  Expanded(flex: 1, child: _buildLeftSide()),
                  Expanded(flex: 1, child: _buildRightSide()),
                ],
              )
            : Center(child: _buildRightSide()),
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
        Observer(builder: (_) {
          return Visibility(
            visible: _authStore.isLoading,
            child: CustomProgressIndicatorWidget(),
          );
        }),
      ],
    );
  }

  Widget _buildLeftSide() => SizedBox.expand(
        child: Image.asset(
          Assets.carBackground,
          fit: BoxFit.cover,
        ),
      );

  Widget _buildRightSide() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            AppIconWidget(image: 'assets/icons/ic_appicon.png'),
            const SizedBox(height: 24.0),
            // --- Headline login
            AppText('Sign In', variant: TextVariant.headlineMedium),
            const SizedBox(height: 16.0),
            _buildUserIdField(),
            _buildPasswordField(),
            const SizedBox(height: 16.0),
            _buildSignInButton(),
            _buildRegisterButton(),
            Observer(builder: (_) {
              if (_authStore.hasError && _authStore.errorMessage != null) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16.0),
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
      ),
    );
  }

  Widget _buildUserIdField() {
    return Observer(builder: (_) {
      return TextFieldWidget(
        hint: 'Login with email',
        inputType: TextInputType.emailAddress,
        icon: Icons.person,
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
        hint: 'Login with password',
        isObscure: true,
        padding: const EdgeInsets.only(top: 16.0),
        icon: Icons.lock,
        iconColor: _themeStore.darkMode
            ? Colors.white70
            : const Color.fromARGB(137, 63, 62, 62),
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
      buttonColor: Colors.orangeAccent,
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
    return TextButton(
      child: AppText(
        'Register',
        variant: TextVariant.bodyMedium,
        color: Theme.of(context).colorScheme.secondary,
      ),
      onPressed: () {
        AppRouter.push(context, RoutePaths.register);
      },
    );
  }

  Future<void> _navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(Preferences.isLoggedIn, true);
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
