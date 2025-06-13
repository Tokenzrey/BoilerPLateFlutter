import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:flutter/material.dart' hide showDialog;
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';

class DialogSandbox extends StatefulWidget {
  const DialogSandbox({super.key});

  @override
  State<DialogSandbox> createState() => _DialogSandboxState();
}

class _DialogSandboxState extends State<DialogSandbox> {
  // Dialog controller for programmatic control
  final _dialogController = DialogController();

  // State for step dialog
  int _currentStep = 1;

  // Constants for design consistency
  final double _cardBorderRadius = 12.0;
  final double _buttonBorderRadius = 8.0;
  final double _spacing = 16.0;
  final Color _backdropColor = AppColors.neutral;

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildHeader(),
          SizedBox(height: _spacing * 2),

          // Basic dialogs section
          _buildSectionTitle(
            title: 'Basic Dialogs',
            description: 'Standard dialog types with various themes',
          ),
          _buildBasicDialogsGrid(),
          SizedBox(height: _spacing * 2.5),

          // Confirmation dialogs section
          _buildSectionTitle(
            title: 'Confirmation Dialogs',
            description: 'Dialogs that require user confirmation',
          ),
          _buildConfirmationDialogsSection(),
          SizedBox(height: _spacing * 2.5),

          // Step dialog section
          _buildSectionTitle(
            title: 'Multi-Step Dialogs',
            description: 'Wizard-style dialogs for complex flows',
          ),
          _buildStepDialogSection(),
          SizedBox(height: _spacing * 2.5),

          // Custom dialogs section
          _buildSectionTitle(
            title: 'Custom Dialogs',
            description: 'Dialogs with custom content and styling',
          ),
          _buildCustomDialogsSection(),
          SizedBox(height: _spacing * 2.5),

          // Dialog controller section
          _buildSectionTitle(
            title: 'Programmatic Control',
            description: 'Manage dialogs with DialogController',
          ),
          _buildControllerSection(),
          SizedBox(height: _spacing * 2),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Dialog System',
            variant: TextVariant.displaySmall,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 8),
          AppText(
            'A comprehensive showcase of dialog components and features',
            variant: TextVariant.bodyLarge,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      {required String title, required String description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.headlineSmall,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        AppText(
          description,
          variant: TextVariant.bodyMedium,
          color: AppColors.neutral.shade600,
        ),
        SizedBox(height: _spacing),
      ],
    );
  }

  Widget _buildBasicDialogsGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      // Responsive grid - adjust columns based on available width
      final double availableWidth = constraints.maxWidth;
      final int columns = availableWidth > 600 ? 2 : 1;

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: _spacing,
          mainAxisSpacing: _spacing,
          childAspectRatio: 1.3,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildDialogCard(
                title: 'Success Dialog',
                description: 'Indicates a successful operation',
                icon: Icons.check_circle,
                color: AppColors.green,
                onTap: _showSuccessDialog,
              );
            case 1:
              return _buildDialogCard(
                title: 'Warning Dialog',
                description: 'Alerts user about potential issues',
                icon: Icons.warning_amber_rounded,
                color: AppColors.orange,
                onTap: _showWarningDialog,
              );
            case 2:
              return _buildDialogCard(
                title: 'Danger Dialog',
                description: 'Confirms destructive actions',
                icon: Icons.error_outline,
                color: AppColors.red,
                onTap: _showDangerDialog,
              );
            case 3:
              return _buildDialogCard(
                title: 'Information Dialog',
                description: 'Presents neutral information',
                icon: Icons.info_outline,
                color: AppColors.blue,
                onTap: _showInfoDialog,
              );
            default:
              return const SizedBox();
          }
        },
      );
    });
  }

  Widget _buildDialogCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(_spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 36,
                color: color,
              ),
              const SizedBox(height: 8),
              AppText(
                title,
                variant: TextVariant.titleMedium,
                fontWeight: FontWeight.w600,
              ),
              const Spacer(),
              AppText(
                description,
                variant: TextVariant.bodySmall,
                color: AppColors.neutral.shade600,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmationDialogsSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool useVerticalLayout = constraints.maxWidth < 600;

      if (useVerticalLayout) {
        return Column(
          children: [
            _buildActionButton(
              label: 'Simple Confirmation',
              icon: Icons.help_outline,
              onPressed: _showSimpleConfirmation,
            ),
            SizedBox(height: _spacing),
            _buildActionButton(
              label: 'Delete Confirmation',
              icon: Icons.delete_outline,
              color: AppColors.red,
              onPressed: _showDeleteConfirmation,
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Simple Confirmation',
              icon: Icons.help_outline,
              onPressed: _showSimpleConfirmation,
            ),
          ),
          SizedBox(width: _spacing),
          Expanded(
            child: _buildActionButton(
              label: 'Delete Confirmation',
              icon: Icons.delete_outline,
              color: AppColors.red,
              onPressed: _showDeleteConfirmation,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStepDialogSection() {
    return _buildActionButton(
      label: 'Start Multi-Step Process',
      icon: Icons.list_alt,
      color: AppColors.blue,
      onPressed: () {
        setState(() {
          _currentStep = 1; // Reset to first step
        });
        _showStepDialog(_currentStep);
      },
    );
  }

  Widget _buildCustomDialogsSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool useVerticalLayout = constraints.maxWidth < 600;

      if (useVerticalLayout) {
        return Column(
          children: [
            _buildActionButton(
              label: 'Image Preview Dialog',
              icon: Icons.image_outlined,
              color: AppColors.violet,
              onPressed: _showImageDialog,
            ),
            SizedBox(height: _spacing),
            _buildActionButton(
              label: 'Form Dialog',
              icon: Icons.edit_document,
              color: AppColors.primary,
              onPressed: _showFormDialog,
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Image Preview Dialog',
              icon: Icons.image_outlined,
              color: AppColors.violet,
              onPressed: _showImageDialog,
            ),
          ),
          SizedBox(width: _spacing),
          Expanded(
            child: _buildActionButton(
              label: 'Form Dialog',
              icon: Icons.edit_document,
              color: AppColors.primary,
              onPressed: _showFormDialog,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildControllerSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final bool useVerticalLayout = constraints.maxWidth < 600;

      if (useVerticalLayout) {
        return Column(
          children: [
            _buildActionButton(
              label: 'Show Multiple Dialogs',
              icon: Icons.layers,
              color: AppColors.secondary,
              onPressed: _showMultipleDialogs,
            ),
            SizedBox(height: _spacing),
            _buildActionButton(
              label: 'Close All Dialogs',
              icon: Icons.close,
              color: AppColors.neutral.shade700,
              onPressed: () => _dialogController.close(),
            ),
          ],
        );
      }

      return Row(
        children: [
          Expanded(
            child: _buildActionButton(
              label: 'Show Multiple Dialogs',
              icon: Icons.layers,
              color: AppColors.secondary,
              onPressed: _showMultipleDialogs,
            ),
          ),
          SizedBox(width: _spacing),
          Expanded(
            child: _buildActionButton(
              label: 'Close All Dialogs',
              icon: Icons.close,
              color: AppColors.neutral.shade700,
              onPressed: () => _dialogController.close(),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
        ),
      ),
    );
  }

  // Dialog display methods
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Success',
        icon: Icon(
          Icons.check_circle,
          color: AppColors.green,
          size: 28,
        ),
        content: const AppText(
          'Operation completed successfully. Your changes have been saved.',
          variant: TextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context),
            child: const Text('OK'),
          ),
        ],
      ),
      animationType: DialogAnimationType.scale,
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.scale,
      ],
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
    );
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Warning',
        icon: Icon(
          Icons.warning_amber_rounded,
          color: AppColors.orange,
          size: 28,
        ),
        content: const AppText(
          'Please review your inputs before proceeding. Some fields may require attention.',
          variant: TextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.neutral.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () => closeOverlayWithResult(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
            ),
            child: const Text('Review'),
          ),
        ],
      ),
      animationType: DialogAnimationType.slideUp,
      barrierColor: _backdropColor.withValues(alpha: 0.5),
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
    );
  }

  void _showDangerDialog() {
    showDialog(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Danger',
        icon: Icon(
          Icons.error_outline,
          color: AppColors.red,
          size: 28,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              'This action cannot be undone. Are you sure you want to proceed?',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _spacing),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppColors.red.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppText(
                      'You will lose all associated data permanently.',
                      variant: TextVariant.bodySmall,
                      color: AppColors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => closeOverlayWithResult(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: const Text('Proceed'),
          ),
        ],
      ),
      animationType: DialogAnimationType.scale,
      barrierColor: _backdropColor.withValues(alpha: 0.6),
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogBoxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Information',
        icon: Icon(
          Icons.info_outline,
          color: AppColors.blue,
          size: 28,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              'This is an informational message to notify you about system status.',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _spacing),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'System Details',
                    variant: TextVariant.labelMedium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue.shade800,
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow('Status', 'Online', Icons.circle, Colors.green),
                  _buildInfoRow('Last Update', '2 hours ago', Icons.update,
                      AppColors.blue),
                  _buildInfoRow('Version', '1.2.5', Icons.tag, AppColors.blue),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () => closeOverlayWithResult(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.blue,
            ),
            child: const Text('View Details'),
          ),
        ],
      ),
      animationType: DialogAnimationType.scale,
      barrierColor: _backdropColor.withValues(alpha: 0.5),
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          AppText(
            label,
            variant: TextVariant.bodySmall,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: AppText(
              value,
              variant: TextVariant.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showSimpleConfirmation() {
    showDialog<bool>(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Confirm Action',
        icon: Icon(
          Icons.help_outline,
          color: AppColors.primary,
          size: 28,
        ),
        content: const AppText(
          'Are you sure you want to proceed with this action?',
          variant: TextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context, false),
            child: Text(
              'No',
              style: TextStyle(color: AppColors.neutral.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () => closeOverlayWithResult(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
      accessibility: DialogAccessibility(
        label: 'Confirmation Dialog',
        escDismissible: true,
        trapFocus: true,
      ),
    ).then((value) {
      if (value == true) {
        _showResponseDialog(
          'Action Confirmed',
          'You confirmed the action. Proceeding with the operation.',
          Icons.check_circle,
          AppColors.green,
        );
      }
    });
  }

  void _showDeleteConfirmation() {
    showDialog<bool>(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Delete Item',
        icon: Icon(
          Icons.delete_outline,
          color: AppColors.red,
          size: 28,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              'Are you sure you want to delete this item? This action cannot be undone.',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _spacing),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.red, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: AppText(
                      'Type "DELETE" to confirm',
                      variant: TextVariant.bodySmall,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Type DELETE',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => closeOverlayWithResult(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogBoxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ).then((value) {
      if (value == true) {
        _showResponseDialog(
          'Item Deleted',
          'The item has been permanently deleted from the system.',
          Icons.delete_forever,
          AppColors.red,
        );
      }
    });
  }

  void _showStepDialog(int step) {
    // Content for each step
    final stepContents = [
      // Step 1
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            'Welcome to the setup wizard. This will help you configure your account.',
            variant: TextVariant.bodyMedium,
          ),
          SizedBox(height: _spacing),
          _buildStepProgress(1, 4),
        ],
      ),
      // Step 2
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            'Please provide your personal information.',
            variant: TextVariant.bodyMedium,
          ),
          SizedBox(height: _spacing),
          Material(
            color: Colors.transparent,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade200,
                    prefixIcon: const Icon(Icons.email),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _spacing),
          _buildStepProgress(2, 4),
        ],
      ),
      // Step 3
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            'Select your preferences',
            variant: TextVariant.bodyMedium,
          ),
          SizedBox(height: _spacing),
          _buildPreferenceOption('Dark Mode', Icons.dark_mode),
          _buildPreferenceOption('Notifications', Icons.notifications_active),
          _buildPreferenceOption('Data Sync', Icons.sync),
          _buildPreferenceOption('Analytics', Icons.analytics),
          SizedBox(height: _spacing),
          _buildStepProgress(3, 4),
        ],
      ),
      // Step 4
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppText(
            'Setup complete! Your account has been configured successfully.',
            variant: TextVariant.bodyMedium,
          ),
          const SizedBox(height: 20),
          Center(
            child: Icon(
              Icons.check_circle,
              color: AppColors.green,
              size: 64,
            ),
          ),
          const SizedBox(height: 20),
          const AppText(
            'You can now start using all features of the application.',
            variant: TextVariant.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: _spacing),
          _buildStepProgress(4, 4),
        ],
      ),
    ];

    // Determine button actions based on step
    List<Widget> actions = [];
    if (step > 1) {
      actions.add(
        TextButton(
          onPressed: () {
            closeOverlayWithResult(context);
            setState(() {
              _currentStep -= 1;
            });
            _showStepDialog(_currentStep);
          },
          child: const Text('Back'),
        ),
      );
    }

    if (step < 4) {
      actions.add(
        ElevatedButton(
          onPressed: () {
            closeOverlayWithResult(context);
            setState(() {
              _currentStep += 1;
            });
            _showStepDialog(_currentStep);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.blue,
          ),
          child: const Text('Next'),
        ),
      );
    } else {
      actions.add(
        ElevatedButton(
          onPressed: () => closeOverlayWithResult(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.green,
          ),
          child: const Text('Finish'),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Step $step of 4',
        icon: Icon(
          _getStepIcon(step),
          color: _getStepColor(step),
          size: 28,
        ),
        content: stepContents[step - 1],
        actions: actions,
      ),
      animationType: DialogAnimationType.slideLeft,
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 1:
        return Icons.waving_hand;
      case 2:
        return Icons.person_outline;
      case 3:
        return Icons.settings_suggest_outlined;
      case 4:
        return Icons.check_circle_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getStepColor(int step) {
    switch (step) {
      case 1:
        return AppColors.blue;
      case 2:
        return AppColors.secondary;
      case 3:
        return AppColors.violet;
      case 4:
        return AppColors.green;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildStepProgress(int currentStep, int totalSteps) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index < currentStep;
        final isLast = index == totalSteps - 1;

        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _getStepColor(currentStep)
                        : AppColors.neutral.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (!isLast) const SizedBox(width: 4),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPreferenceOption(String label, IconData icon) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.neutral.shade200),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: Icon(icon, color: AppColors.primary),
          title: AppText(label, variant: TextVariant.bodyMedium),
          trailing: Switch(
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.primary,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        ),
      ),
    );
  }

  void _showImageDialog() {
    showDialog(
      context: context,
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: SurfaceCard(
            clipBehavior: Clip.antiAlias,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1682687220198-88e9bdea9931',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        width: double.infinity,
                        color: AppColors.neutral.shade200,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: AppColors.neutral.shade400,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => closeOverlayWithResult(context),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(_spacing),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Mountain Landscape',
                        variant: TextVariant.titleLarge,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      const AppText(
                        'A beautiful mountain landscape with clouds and sunset.',
                        variant: TextVariant.bodyMedium,
                      ),
                      SizedBox(height: _spacing),
                      Row(
                        children: [
                          _buildImageStat(Icons.remove_red_eye, '2.5k views'),
                          SizedBox(width: _spacing),
                          _buildImageStat(Icons.favorite, '543 likes'),
                          SizedBox(width: _spacing),
                          _buildImageStat(Icons.download, '128 downloads'),
                        ],
                      ),
                      SizedBox(height: _spacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => closeOverlayWithResult(context),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            onPressed: () => closeOverlayWithResult(context),
                            icon: const Icon(Icons.download),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      animationType: DialogAnimationType.scale,
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.scale,
      ],
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderWidth: 0,
      dialogClipBehavior: Clip.antiAlias,
      dialogSurfaceBlur: 0.5,
      dialogSurfaceOpacity: 1.0,
    );
  }

  Widget _buildImageStat(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.neutral.shade600),
        const SizedBox(width: 4),
        AppText(
          text,
          variant: TextVariant.bodySmall,
          color: AppColors.neutral.shade600,
        ),
      ],
    );
  }

  void _showFormDialog() {
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          child: SurfaceCard(
            borderRadius: BorderRadius.circular(16),
            filled: true,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Icons.edit_document,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: AppText(
                        'Add New Contact',
                        variant: TextVariant.titleLarge,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => closeOverlayWithResult(context),
                      tooltip: 'Close',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: const Icon(Icons.email),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Phone Number',
                              prefixIcon: const Icon(Icons.phone),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Category',
                              prefixIcon: const Icon(Icons.category),
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                            items: ['Work', 'Personal', 'Family', 'Other']
                                .map((e) =>
                                    DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                            onChanged: (value) {},
                            value: 'Work',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => closeOverlayWithResult(context),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.neutral.shade700,
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          closeOverlayWithResult(context, true);
                          _showResponseDialog(
                            'Contact Added',
                            'The new contact has been added to your address book successfully.',
                            Icons.check_circle,
                            AppColors.green,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('Save Contact'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierColor: Colors.transparent,
      animationType: DialogAnimationType.scale,
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.slideUp,
      ],
    );
  }

  void _showMultipleDialogs() {
    // Close any existing dialogs first
    _dialogController.close();

    // Show first dialog
    _dialogController.show(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Dialog 1',
        content: const AppText(
          'This is the first dialog. You can open multiple dialogs in sequence.',
          variant: TextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Show second dialog after a short delay
              closeOverlayWithResult(context);
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _showMultipleDialogTwo();
                }
              });
            },
            child: const Text('Next Dialog'),
          ),
        ],
      ),
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
    );
  }

  void _showMultipleDialogTwo() {
    _dialogController.show(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Dialog 2',
        icon: Icon(
          Icons.notifications,
          color: AppColors.orange,
          size: 28,
        ),
        content: const AppText(
          'This is the second dialog, managed by DialogController.',
          variant: TextVariant.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Show third dialog after a short delay
              closeOverlayWithResult(context);
              Future.delayed(const Duration(milliseconds: 300), () {
                if (mounted) {
                  _showMultipleDialogThree();
                }
              });
            },
            child: const Text('Final Dialog'),
          ),
        ],
      ),
      animationType: DialogAnimationType.slideLeft,
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
    );
  }

  void _showMultipleDialogThree() {
    _dialogController.show(
      context: context,
      builder: (context) => StandardDialog(
        title: 'Dialog 3',
        icon: Icon(
          Icons.check_circle,
          color: AppColors.green,
          size: 28,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppText(
              'This is the final dialog in the sequence.',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _spacing),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: AppColors.green, size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: AppText(
                      'You can close all dialogs at once with DialogController',
                      variant: TextVariant.bodySmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => closeOverlayWithResult(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _dialogController.close(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.green,
            ),
            child: const Text('Close All'),
          ),
        ],
      ),
      animationType: DialogAnimationType.slideUp,
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
    );
  }

  void _showResponseDialog(
      String title, String message, IconData icon, Color color) {
    showDialog(
      context: context,
      builder: (context) => StandardDialog(
        title: title,
        icon: Icon(
          icon,
          color: color,
          size: 28,
        ),
        content: AppText(
          message,
          variant: TextVariant.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => closeOverlayWithResult(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
      animationType: DialogAnimationType.scale,
      barrierColor: Colors.transparent,
      dialogBackgroundColor: Colors.white,
      dialogBorderRadius: BorderRadius.circular(16),
      dialogBorderWidth: 0,
      dialogElevation: 5,
    );
  }
}
