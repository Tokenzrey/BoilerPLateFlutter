import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../../../di/service_locator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthStore _authStore = getIt<AuthStore>();
  final _formKey = GlobalKey<FormState>();
  String emailForm = '';
  String passwordForm = '';
  String usernameForm = '';
  String fullNameForm = '';

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final success = await _authStore.register(
        emailForm,
        passwordForm,
        usernameForm,
        fullNameForm,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );
          Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AppText('Register', variant: TextVariant.headlineMedium),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Observer(
          builder: (_) => Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText('Create an Account', variant: TextVariant.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value?.contains('@') == true
                      ? null
                      : 'Enter a valid email',
                  onSaved: (value) => emailForm = value?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter a username'
                      : null,
                  onSaved: (value) => usernameForm = value?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Enter your full name'
                      : null,
                  onSaved: (value) => fullNameForm = value?.trim() ?? '',
                ),
                const SizedBox(height: 12),
                TextFormField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (value) =>
                      (value?.length ?? 0) >= 6 ? null : 'Password min 6 chars',
                  onSaved: (value) => passwordForm = value ?? '',
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _authStore.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _authStore.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : AppText('Register', variant: TextVariant.bodyLarge),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
