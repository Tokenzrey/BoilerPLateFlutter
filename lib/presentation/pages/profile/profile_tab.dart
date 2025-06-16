import 'package:boilerplate/core/widgets/components/layout/collapsible.dart';
import 'package:boilerplate/core/widgets/components/overlay/confirmation_dialog.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/core/widgets/components/overlay/toast.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart' hide showDialog;
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/image.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/input.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
import 'package:boilerplate/presentation/pages/profile/avatar_picker_dialog.dart';

class UserProfileData {
  final String id;
  String username;
  final String email;
  String fullName;
  String avatar;

  UserProfileData({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.avatar,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatar: json['avatar'] as String? ?? 'assets/images/avatar/avatar1.png',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'avatar': avatar,
    };
  }
}

class PasswordData {
  String oldPassword;
  String newPassword;
  String confirmPassword;

  PasswordData({
    this.oldPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
  });

  factory PasswordData.fromJson(Map<String, dynamic> json) {
    return PasswordData(
      oldPassword: json['oldPassword'] as String? ?? '',
      newPassword: json['newPassword'] as String? ?? '',
      confirmPassword: json['confirmPassword'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }
}

class DeleteAccountData {
  String confirmationId;
  String password;

  DeleteAccountData({
    this.confirmationId = '',
    this.password = '',
  });

  factory DeleteAccountData.fromJson(Map<String, dynamic> json) {
    return DeleteAccountData(
      confirmationId: json['confirmationId'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confirmationId': confirmationId,
      'password': password,
    };
  }
}

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

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late FormController<UserProfileData> _formController;
  late FormController<PasswordData> _passwordFormController;
  late FormController<DeleteAccountData> _deleteAccountFormController;
  bool _isEditing = false;

  // Get auth store instance
  final AuthStore _authStore = getIt<AuthStore>();

  @override
  void initState() {
    super.initState();

    final user = _authStore.currentUser;

    _formController = FormController<UserProfileData>(
      defaultValues: UserProfileData(
        id: user?.id ?? '',
        username: user?.username ?? '',
        email: user?.email ?? '',
        fullName: user?.fullName ?? '',
        avatar: user?.avatar ?? "0",
      ),
      fromJson: UserProfileData.fromJson,
      toJson: (data) => data.toJson(),
      mode: ValidationMode.onBlur,
    );

    _passwordFormController = FormController<PasswordData>(
      defaultValues: PasswordData(),
      fromJson: PasswordData.fromJson,
      toJson: (data) => data.toJson(),
      mode: ValidationMode.onBlur,
    );

    _deleteAccountFormController = FormController<DeleteAccountData>(
      defaultValues: DeleteAccountData(),
      fromJson: DeleteAccountData.fromJson,
      toJson: (data) => data.toJson(),
      mode: ValidationMode.onBlur,
    );
  }

  @override
  void dispose() {
    _formController.dispose();
    _passwordFormController.dispose();
    _deleteAccountFormController.dispose();
    super.dispose();
  }

  // Method to get avatar asset path from avatar ID
  String _getAvatarPath(String avatarId) {
    // Map avatar IDs to asset paths
    final Map<String, String> avatarMap = {
      "1": "assets/images/avatar/avatar1.png",
      "2": "assets/images/avatar/avatar2.png",
      "3": "assets/images/avatar/avatar3.png",
      "4": "assets/images/avatar/avatar4.png",
      "5": "assets/images/avatar/avatar5.png",
      "6": "assets/images/avatar/avatar6.png",
      "7": "assets/images/avatar/avatar7.png",
      "8": "assets/images/avatar/avatar8.png",
      "9": "assets/images/avatar/avatar9.png",
      "10": "assets/images/avatar/avatar10.png",
      "11": "assets/images/avatar/avatar11.png",
      "12": "assets/images/avatar/avatar12.png",
      "13": "assets/images/avatar/avatar13.png",
      "14": "assets/images/avatar/avatar14.png",
      "15": "assets/images/avatar/avatar15.png",
    };

    return avatarMap[avatarId] ?? "assets/images/avatar/avatar1.png";
  }

  // Method to convert asset path to avatar ID
  String _getAvatarId(String assetPath) {
    // Map asset paths to avatar IDs
    final Map<String, String> reverseAvatarMap = {
      "assets/images/avatar/avatar2.png": "1",
      "assets/images/avatar/avatar3.png": "2",
      "assets/images/avatar/avatar4.png": "3",
      "assets/images/avatar/avatar5.png": "4",
      "assets/images/avatar/avatar6.png": "5",
      "assets/images/avatar/avatar7.png": "6",
      "assets/images/avatar/avatar8.png": "7",
      "assets/images/avatar/avatar9.png": "8",
      "assets/images/avatar/avatar10.png": "9",
      "assets/images/avatar/avatar11.png": "10",
      "assets/images/avatar/avatar12.png": "11",
      "assets/images/avatar/avatar13.png": "12",
      "assets/images/avatar/avatar14.png": "13",
      "assets/images/avatar/avatar15.png": "14",
      "assets/images/avatar/avatar16.png": "15",
    };

    return reverseAvatarMap[assetPath] ?? "0";
  }

  void _showAvatarPicker() {
    final userData = _formController.getValues();
    final avatarPath = _getAvatarPath(userData.avatar);
    // Capture the context before the async operation
    final currentContext = context;

    showDialog(
      context: currentContext,
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.scale,
      ],
      builder: (context) => AvatarPickerDialog(
        onAvatarSelected: (avatar) async {
          // Update the form value
          final userData = _formController.getValues();
          userData.avatar = _getAvatarId(avatar);

          // Instead of setValues, we'll update the form field directly
          _formController.setValue('avatar', userData.avatar);

          // Save avatar change immediately
          final success = await _authStore.updateUserData(
            userData.fullName,
            userData.username,
            userData.avatar,
          );

          // Check if the widget is still mounted before using context
          if (currentContext.mounted) {
            if (success) {
              showSuccessToast(
                context: currentContext, // Use captured context
                title: 'Avatar',
                message: 'Avatar updated successfully',
              );
            } else if (_authStore.errorMessage != null) {
              showErrorToast(
                context: currentContext, // Use captured context
                title: 'Avatar',
                message: _authStore.errorMessage!,
              );
            }
          }
        },
        selectedAvatar: avatarPath,
      ),
      dialogBackgroundColor: AppColors.cardForeground,
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      dialogBackgroundColor: AppColors.neutral,
      builder: (BuildContext dialogContext) {
        return ConfirmDialog(
          title: 'Confirm Logout',
          content: 'Are you sure you want to logout?',
          confirmText: 'Logout',
          confirmVariant: ButtonVariant.danger,
          onConfirm: () async {
            // Capture the navigation context
            final navContext = dialogContext;

            final success = await _authStore.logout();

            // Check if widget is still mounted
            if (navContext.mounted) {
              if (success) {
                // Use Navigator.of with the captured context to navigate
                navContext.go('/home');
                showSuccessToast(
                  context: navContext,
                  title: 'Logout',
                  message: 'Logged out successfully',
                );
              } else if (_authStore.errorMessage != null) {
                showErrorToast(
                  context: navContext,
                  title: 'Logout',
                  message: _authStore.errorMessage!,
                );
              }
            }
          },
        );
      },
    );
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {}
    });
  }

  void _saveProfile() async {
    if (_formController.validate()) {
      final userData = _formController.getValues();
      final currentContext = context;

      final success = await _authStore.updateUserData(
        userData.fullName,
        userData.username,
        userData.avatar,
      );

      // Check if widget is still mounted before using context
      if (currentContext.mounted) {
        if (success) {
          _toggleEditing();
          showSuccessToast(
            context: currentContext,
            title: 'Profile',
            message: 'Profile updated successfully',
          );
        } else if (_authStore.errorMessage != null) {
          showErrorToast(
            context: currentContext,
            title: 'Profile',
            message: _authStore.errorMessage!,
          );
        }
      }
    }
  }

  void _changePassword() {
    if (_passwordFormController.validate()) {
      final passwordData = _passwordFormController.getValues();

      showDialog(
        context: context,
        dialogBackgroundColor: AppColors.neutral,
        builder: (BuildContext dialogContext) {
          return ConfirmDialog(
            title: 'Confirm Password Change',
            content: 'Are you sure you want to change your password?',
            confirmText: 'Change',
            confirmVariant: ButtonVariant.primary,
            icon: Icons.lock,
            onConfirm: () async {
              // Capture context before async operation
              final capturedContext = dialogContext;

              final success = await _authStore.updatePassword(
                passwordData.oldPassword,
                passwordData.newPassword,
              );

              // Check if widget is still mounted
              if (capturedContext.mounted) {
                if (success) {
                  _passwordFormController.reset();

                  showSuccessToast(
                    context: capturedContext,
                    title: 'Password Changed',
                    message: 'Your password has been updated successfully',
                  );
                } else if (_authStore.errorMessage != null) {
                  showErrorToast(
                    context: capturedContext,
                    title: 'Password Change',
                    message: _authStore.errorMessage!,
                  );
                }
              }
            },
          );
        },
      );
    }
  }

  void _handleDeleteAccount() {
    if (_deleteAccountFormController.validate()) {
      showDialog(
        context: context,
        dialogBackgroundColor: AppColors.neutral,
        builder: (BuildContext dialogContext) {
          return ConfirmDialog(
            title: 'Delete Account',
            content:
                'Are you sure you want to delete your account? This action cannot be undone.',
            confirmText: 'Proceed',
            confirmVariant: ButtonVariant.danger,
            icon: Icons.delete_forever,
            onConfirm: () {
              Navigator.pop(dialogContext);

              _validateDeleteAccountId();
            },
          );
        },
      );
    }
  }

  void _validateDeleteAccountId() {
    final userData = _formController.getValues();
    final deleteData = _deleteAccountFormController.getValues();

    if (deleteData.confirmationId != userData.id) {
      showErrorToast(
        context: context,
        title: "Delete Account",
        message: "The ID you entered does not match your account ID",
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ConfirmDialog(
          title: 'Delete Account Permanently',
          content:
              'This action cannot be undone. All your data will be permanently deleted.',
          confirmText: 'Delete permanently',
          confirmVariant: ButtonVariant.danger,
          icon: Icons.delete_forever,
          onConfirm: () async {
            // Capture context before async operation
            final capturedContext = dialogContext;

            final success = await _authStore.deleteAccount(deleteData.password);

            // Check if widget is still mounted
            if (capturedContext.mounted) {
              if (success) {
                capturedContext.go('/home');
                _deleteAccountFormController.reset();

                showSuccessToast(
                  context: capturedContext,
                  title: 'Delete Account',
                  message: 'Account deleted successfully',
                );
              } else if (_authStore.errorMessage != null) {
                showErrorToast(
                  context: capturedContext,
                  title: 'Delete Account',
                  message: _authStore.errorMessage!,
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 32),
            FormScope<UserProfileData>(
              controller: _formController,
              child: _buildUserInfoSection(),
            ),
            const SizedBox(height: 32),
            _buildPasswordChangeSection(),
            const SizedBox(height: 32),
            Button(
              text: 'Logout',
              variant: ButtonVariant.danger,
              onPressed: _handleLogout,
              size: ButtonSize.large,
              layout: const ButtonLayout(
                expanded: true,
                height: 50,
              ),
              leftIcon: Icons.exit_to_app,
            ),
            const SizedBox(height: 48),
            FormScope<DeleteAccountData>(
              controller: _deleteAccountFormController,
              child: _buildDeleteAccountSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final userData = _formController.getValues();
    final avatarPath = _getAvatarPath(userData.avatar);

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: .7),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: AppImage.avatar(
                  src: avatarPath,
                  size: 120,
                  source: ImageSource.asset,
                  errorWidget: Container(
                    color: AppColors.neutral.shade800,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.neutral.shade400,
                    ),
                  ),
                ),
              ),
            ),
            InkWell(
              onTap: _showAvatarPicker,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppText(
          _formController.getValue('fullName') as String? ??
              _formController.getValue('username') as String,
          variant: TextVariant.headlineMedium,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    final userData = _formController.getValues();

    return Card(
      elevation: 0,
      color: AppColors.cardForeground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.neutral.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const AppText(
                          'Account Information',
                          variant: TextVariant.titleMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _isEditing
                      ? SizedBox(
                          key: const ValueKey('edit_hide'),
                          width: 0,
                          height: 40,
                        )
                      : TextButton.icon(
                          key: const ValueKey('edit_button'),
                          onPressed: _toggleEditing,
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildInfoRow(
                  label: 'ID',
                  value: userData.id,
                  icon: Icons.fingerprint,
                  isEditable: false,
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  label: 'Email',
                  value: userData.email,
                  icon: Icons.email,
                  isEditable: false,
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: 0.0,
                        child: child,
                      ),
                    );
                  },
                  child: _isEditing
                      ? _buildEditableField(
                          key: const ValueKey('username_edit'),
                          label: 'Username',
                          name: 'username',
                          rules: [
                            RequiredRule(message: 'Username is required'),
                            MinLengthRule(3,
                                message:
                                    'Username must be at least 3 characters'),
                          ],
                          icon: Icons.person,
                        )
                      : _buildInfoRow(
                          key: const ValueKey('username_view'),
                          label: 'Username',
                          value: userData.username,
                          icon: Icons.person,
                        ),
                ),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SizeTransition(
                        sizeFactor: animation,
                        axisAlignment: 0.0,
                        child: child,
                      ),
                    );
                  },
                  child: _isEditing
                      ? _buildEditableField(
                          key: const ValueKey('fullName_edit'),
                          label: 'Full Name',
                          name: 'fullName',
                          rules: [
                            RequiredRule(message: 'Full name is required'),
                            MinLengthRule(2,
                                message:
                                    'Full name must be at least 2 characters'),
                          ],
                          icon: Icons.badge,
                        )
                      : _buildInfoRow(
                          key: const ValueKey('fullName_view'),
                          label: 'Full Name',
                          value: userData.fullName,
                          icon: Icons.badge,
                        ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isEditing
                      ? Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Row(
                            children: [
                              Expanded(
                                child: Button(
                                  text: 'Cancel',
                                  variant: ButtonVariant.outlined,
                                  onPressed: _toggleEditing,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Button(
                                  text: 'Save',
                                  variant: ButtonVariant.primary,
                                  onPressed: _saveProfile,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const SizedBox(height: 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    Key? key,
    required String label,
    required String value,
    required IconData icon,
    bool isEditable = true,
  }) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                label,
                variant: TextVariant.labelSmall,
                color: AppColors.neutral.shade400,
              ),
              const SizedBox(height: 2),
              AppText(
                value,
                variant: TextVariant.bodyLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    Key? key,
    required String label,
    required String name,
    required List<ValidationRule<String>> rules,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Row(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FormInputField(
            formController: _formController,
            name: name,
            label: label,
            keyboardType: keyboardType,
            isRequired: true,
            rules: rules,
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordChangeSection() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardForeground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral.shade800),
      ),
      clipBehavior: Divider.createBorderSide(context).width > 0
          ? Clip.hardEdge
          : Clip.none,
      child: AppCollapsible(
        theme: const CollapsibleTheme(
          animationType: CollapsibleAnimationType.sizeAndFade,
          expansionDirection: ExpansionDirection.down,
        ),
        children: [
          AppCollapsibleTrigger(
            padding: EdgeInsets.only(right: 16),
            iconBuilder: (context, isExpanded) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.lock_outline,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const AppText(
                        'Change Password',
                        variant: TextVariant.titleMedium,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppCollapsibleContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, thickness: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FormScope<PasswordData>(
                    controller: _passwordFormController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FormInputField(
                          formController: _passwordFormController,
                          name: 'oldPassword',
                          label: 'Current Password',
                          isRequired: true,
                          obscureText: true,
                          features: [InputFeature.passwordToggle()],
                          rules: [
                            RequiredRule(
                                message: 'Current password is required')
                          ],
                          filled: false,
                        ),
                        const SizedBox(height: 16),
                        FormInputField(
                          formController: _passwordFormController,
                          name: 'newPassword',
                          label: 'New Password',
                          isRequired: true,
                          obscureText: true,
                          features: [InputFeature.passwordToggle()],
                          rules: [
                            RequiredRule(message: 'New password is required'),
                            MinLengthRule(8,
                                message:
                                    'Password must be at least 8 characters'),
                          ],
                          filled: false,
                        ),
                        const SizedBox(height: 16),
                        FormInputField(
                          formController: _passwordFormController,
                          name: 'confirmPassword',
                          label: 'Confirm New Password',
                          isRequired: true,
                          obscureText: true,
                          features: [InputFeature.passwordToggle()],
                          rules: [
                            RequiredRule(
                                message: 'Please confirm your new password'),
                            ConfirmPasswordRule(
                              getPassword: () =>
                                  _passwordFormController
                                      .getValue('newPassword') as String? ??
                                  '',
                              message: 'Passwords do not match',
                            ),
                          ],
                          filled: false,
                        ),
                        const SizedBox(height: 24),
                        Button(
                          text: 'Change Password',
                          variant: ButtonVariant.primary,
                          leftIcon: Icons.lock,
                          onPressed: _changePassword,
                          layout: const ButtonLayout(
                            expanded: true,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteAccountSection() {
    final userData = _formController.getValues();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    color: AppColors.destructive,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const AppText(
                  'Delete Account',
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.destructive.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.destructive.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber,
                            color: AppColors.destructive,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AppText(
                              'This action cannot be undone',
                              variant: TextVariant.bodyMedium,
                              fontWeight: FontWeight.w600,
                              color: AppColors.destructive,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'All your data will be permanently deleted. You won\'t be able to recover your account.',
                        variant: TextVariant.bodySmall,
                        color: AppColors.neutral.shade300,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppText(
                  'No longer want to use our service? You can delete your account here. This action is not reversible.',
                  variant: TextVariant.bodySmall,
                  color: AppColors.neutral.shade300,
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.neutral.shade700,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.neutral.shade300,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          'Comick doesn\'t hold any of your information except your email address. You can\'t register again for 7 days after deletion.',
                          variant: TextVariant.bodySmall,
                          color: AppColors.neutral.shade300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Confirm Deletion',
                  variant: TextVariant.labelLarge,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                AppText(
                  'Please enter your ID to confirm: ${userData.id}',
                  variant: TextVariant.bodySmall,
                  color: AppColors.neutral.shade300,
                ),
                const SizedBox(height: 12),
                FormInputField(
                  formController: _deleteAccountFormController,
                  name: 'confirmationId',
                  isRequired: true,
                  rules: [
                    RequiredRule(
                        message: 'Please enter your ID to confirm deletion'),
                  ],
                  filled: true,
                ),
                const SizedBox(height: 16),
                const AppText(
                  'Enter your password to confirm',
                  variant: TextVariant.labelLarge,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 8),
                AppText(
                  'For security, please enter your password to proceed with account deletion',
                  variant: TextVariant.bodySmall,
                  color: AppColors.neutral.shade300,
                ),
                const SizedBox(height: 12),
                FormInputField(
                  formController: _deleteAccountFormController,
                  name: 'password',
                  label: 'Password',
                  isRequired: true,
                  obscureText: true,
                  features: [InputFeature.passwordToggle()],
                  rules: [
                    RequiredRule(
                        message: 'Password is required to delete your account'),
                  ],
                  filled: true,
                ),
                const SizedBox(height: 24),
                Button(
                  text: 'Delete My Account',
                  variant: ButtonVariant.danger,
                  leftIcon: Icons.delete_forever,
                  onPressed: _handleDeleteAccount,
                  size: ButtonSize.large,
                  layout: const ButtonLayout(
                    expanded: true,
                    height: 48,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
