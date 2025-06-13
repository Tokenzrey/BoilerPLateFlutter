import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/data/sharedpref/constants/preferences.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/presentation/store/theme/theme_store.dart';
import 'package:boilerplate/utils/routes/routes_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ThemeStore _themeStore = getIt<ThemeStore>();
  final AuthStore _authStore = getIt<AuthStore>();

  @override
  void initState() {
    super.initState();
    _authStore.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Observer(
        builder: (_) {
          final user = _authStore.currentUser;
          if (_authStore.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (user == null) {
            return Center(
              child: AppText('No user data.', variant: TextVariant.titleLarge),
            );
          }
          debugPrint('User: $user');
          return _buildUserDetail(user);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: AppText('Home', variant: TextVariant.headlineMedium),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return <Widget>[
      _buildThemeButton(),
      _buildLogoutButton(),
    ];
  }

  Widget _buildThemeButton() {
    return Observer(
      builder: (context) {
        return IconButton(
          onPressed: () {
            _themeStore.changeBrightnessToDark(!_themeStore.darkMode);
          },
          icon: Icon(
            _themeStore.darkMode ? Icons.brightness_5 : Icons.brightness_3,
          ),
        );
      },
    );
  }

  Widget _buildLogoutButton() {
    return IconButton(
      onPressed: () {
        SharedPreferences.getInstance().then((preference) {
          preference.setBool(Preferences.isLoggedIn, false);
          _authStore.logout();
          if (!mounted) return;
          context.go(RoutePaths.unauthorized);
        });
      },
      icon: const Icon(Icons.power_settings_new),
    );
  }

  Widget _buildUserDetail(User user) {
    final formKey = GlobalKey<FormState>();
    final usernameController = TextEditingController(text: user.username);
    final fullNameController = TextEditingController(text: user.fullName);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: ListView(
          children: [
            AppText('User Profile', variant: TextVariant.titleLarge),
            const SizedBox(height: 16),
            AppText('Email (not editable)', variant: TextVariant.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: user.email,
              enabled: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            AppText('Username', variant: TextVariant.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Username',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter username'
                  : null,
            ),
            const SizedBox(height: 16),
            AppText('Full Name', variant: TextVariant.bodyMedium),
            const SizedBox(height: 4),
            TextFormField(
              controller: fullNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Full Name',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Enter full name'
                  : null,
            ),
            const SizedBox(height: 24),
            Observer(
              builder: (_) => ElevatedButton(
                onPressed: _authStore.isLoading
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          final newUsername = usernameController.text.trim();
                          final newFullName = fullNameController.text.trim();
                          final success = await _authStore.updateUserData(
                            newFullName,
                            newUsername,
                            null,
                          );
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profile updated!')),
                            );
                          } else if (_authStore.errorMessage != null &&
                              mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(_authStore.errorMessage!)),
                            );
                          }
                        }
                      },
                child: _authStore.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : AppText('Update Profile', variant: TextVariant.bodyLarge),
              ),
            ),
            if (_authStore.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: AppText(
                  _authStore.errorMessage ?? '',
                  variant: TextVariant.bodyMedium,
                  color: Colors.red,
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 32),
            AppText('Roles: ${user.roles.join(', ')}',
                variant: TextVariant.bodySmall, color: Colors.grey[700]),
            AppText('Created At: ${user.createdAt}',
                variant: TextVariant.bodySmall, color: Colors.grey[700]),
            if (user.lastLogin != null)
              AppText('Last Login: ${user.lastLogin}',
                  variant: TextVariant.bodySmall, color: Colors.grey[700]),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              icon: const Icon(Icons.science),
              label: AppText('Go to Sandbox', variant: TextVariant.bodyLarge),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              ),
              onPressed: () {
                context.goNamed('sandbox');
              },
            ),
          ],
        ),
      ),
    );
  }
}
