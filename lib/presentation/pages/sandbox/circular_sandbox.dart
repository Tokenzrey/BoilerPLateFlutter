import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/circular.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/forms/switch.dart';

class CircularProgressSandbox extends StatefulWidget {
  const CircularProgressSandbox({super.key});

  @override
  State<CircularProgressSandbox> createState() =>
      _CircularProgressSandboxState();
}

class _CircularProgressSandboxState extends State<CircularProgressSandbox> {
  double _progressValue = 0.65;
  bool _showPercentage = true;
  bool _isIndeterminate = false;
  Color _progressColor = AppColors.primary;
  final Color _backgroundColor = AppColors.neutral[200]!;
  bool _showOverlay = false;
  bool _showCustomCenter = false;
  final Widget _centerWidget = Icon(Icons.check, color: AppColors.primary);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Circular Progress Sandbox',
            variant: TextVariant.titleLarge),
      ),
      body: AppCircularProgress.withLoadingOverlay(
        isLoading: _showOverlay,
        overlayColor: AppColors.neutral[900]!.withValues(alpha: 0.3),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader('Circular Progress Component'),
              const SizedBox(height: 24),

              // Interactive Controls
              _buildControls(),
              const SizedBox(height: 32),

              // Standard Sizes Section
              _buildSizesSection(),
              const SizedBox(height: 32),

              // Custom Examples
              _buildCustomExamplesSection(),
              const SizedBox(height: 32),

              // Overlay Example
              _buildOverlaySection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
        progressIndicator: AppCircularProgress.medium(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showOverlay = !_showOverlay),
        tooltip: 'Toggle loading overlay',
        child: Icon(_showOverlay ? Icons.visibility_off : Icons.visibility),
      ),
    );
  }

  Widget _buildHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          'Explore the various options and configurations of the AppCircularProgress component.',
          variant: TextVariant.bodyLarge,
          color: AppColors.neutral[700],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Customize Progress',
                variant: TextVariant.titleMedium, fontWeight: FontWeight.bold),
            const SizedBox(height: 16),

            // Progress value slider
            Row(
              children: [
                const AppText('Progress: ', variant: TextVariant.bodyMedium),
                Expanded(
                  child: Slider(
                    value: _progressValue,
                    onChanged: _isIndeterminate
                        ? null
                        : (value) {
                            setState(() {
                              _progressValue = value;
                            });
                          },
                    activeColor: _progressColor,
                    inactiveColor: _backgroundColor,
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: AppText(
                    '${(_progressValue * 100).toInt()}%',
                    variant: TextVariant.bodyMedium,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Switches row
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildSwitch(
                  label: 'Indeterminate',
                  value: _isIndeterminate,
                  onChanged: (value) {
                    setState(() {
                      _isIndeterminate = value;
                    });
                  },
                ),
                _buildSwitch(
                  label: 'Show Percentage',
                  value: _showPercentage,
                  onChanged: (value) {
                    setState(() {
                      _showPercentage = value;
                    });
                  },
                ),
                _buildSwitch(
                  label: 'Custom Center',
                  value: _showCustomCenter,
                  onChanged: (value) {
                    setState(() {
                      _showCustomCenter = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Color selection row
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildColorButton(AppColors.primary, 'Primary'),
                _buildColorButton(AppColors.secondary, 'Secondary'),
                _buildColorButton(AppColors.accent, 'Accent'),
                _buildColorButton(AppColors.destructive, 'Destructive'),
                _buildColorButton(AppColors.success, 'Success'),
                _buildColorButton(AppColors.neutral[700]!, 'Neutral'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // PERBAIKAN: Meneruskan properti label ke SwitchInputWidget
  Widget _buildSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchInputWidget(
      label: label,
      value: value,
      onChanged: onChanged,
      shape: SwitchShape.ios,
      position: SwitchPosition.start,
    );
  }

  Widget _buildColorButton(Color color, String label) {
    final isSelected = _progressColor == color;
    return InkWell(
      onTap: () => setState(() => _progressColor = color),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppColors.neutral[300]!,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            AppText(
              label,
              variant: TextVariant.bodySmall,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizesSection() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Standard Sizes',
                variant: TextVariant.titleMedium, fontWeight: FontWeight.bold),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    AppCircularProgress.small(
                      value: _isIndeterminate ? null : _progressValue,
                      color: _progressColor,
                      backgroundColor: _backgroundColor,
                    ),
                    const SizedBox(height: 8),
                    AppText('Small', variant: TextVariant.bodySmall),
                  ],
                ),
                Column(
                  children: [
                    AppCircularProgress.medium(
                      value: _isIndeterminate ? null : _progressValue,
                      color: _progressColor,
                      backgroundColor: _backgroundColor,
                    ),
                    const SizedBox(height: 8),
                    AppText('Medium', variant: TextVariant.bodySmall),
                  ],
                ),
                Column(
                  children: [
                    AppCircularProgress.large(
                      value: _isIndeterminate ? null : _progressValue,
                      color: _progressColor,
                      backgroundColor: _backgroundColor,
                    ),
                    const SizedBox(height: 8),
                    AppText('Large', variant: TextVariant.bodySmall),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppText('Current Configuration:',
                variant: TextVariant.bodyMedium, fontWeight: FontWeight.w500),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.neutral[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.neutral[300]!),
              ),
              child: AppText(
                'AppCircularProgress.medium(\n'
                '  value: ${_isIndeterminate ? 'null' : _progressValue.toStringAsFixed(2)},\n'
                '  color: $_progressColor,\n'
                '  backgroundColor: $_backgroundColor,\n'
                '  showPercentage: $_showPercentage,\n'
                ')',
                variant: TextVariant.bodySmall,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomExamplesSection() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Custom Examples',
                variant: TextVariant.titleMedium, fontWeight: FontWeight.bold),
            const SizedBox(height: 16),
            Wrap(
              spacing: 32,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                // With percentage text
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: AppCircularProgress(
                        value: _isIndeterminate ? null : _progressValue,
                        color: _progressColor,
                        backgroundColor: _backgroundColor,
                        showPercentage: true,
                        strokeWidth: 8.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppText('With Percentage', variant: TextVariant.bodySmall),
                  ],
                ),

                // With custom center
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: AppCircularProgress(
                        value: _isIndeterminate ? null : _progressValue,
                        color: _progressColor,
                        backgroundColor: _backgroundColor,
                        center: _showCustomCenter ? _centerWidget : null,
                        strokeWidth: 8.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppText('With Custom Center',
                        variant: TextVariant.bodySmall),
                  ],
                ),

                // Custom colors
                Column(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: AppCircularProgress(
                        value: _isIndeterminate ? null : _progressValue,
                        color: AppColors.accent,
                        backgroundColor:
                            AppColors.accent.withValues(alpha: 0.2),
                        strokeWidth: 8.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppText('Custom Colors', variant: TextVariant.bodySmall),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlaySection() {
    return AppCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Loading Overlay',
                variant: TextVariant.titleMedium, fontWeight: FontWeight.bold),
            const SizedBox(height: 16),
            AppText(
              'The AppCircularProgress.withLoadingOverlay utility method provides a convenient way to show a loading state over any widget.',
              variant: TextVariant.bodyMedium,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.neutral[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppCircularProgress.withLoadingOverlay(
                isLoading: true,
                overlayColor: AppColors.neutral[900]!.withValues(alpha: 0.3),
                child: Center(
                  child: AppText(
                    'Content behind overlay',
                    variant: TextVariant.titleMedium,
                    color: AppColors.neutral[700],
                  ),
                ),
                progressIndicator: AppCircularProgress(
                  value: _isIndeterminate ? null : _progressValue,
                  color: _progressColor,
                  backgroundColor: _backgroundColor,
                  showPercentage: _showPercentage,
                ),
              ),
            ),
            const SizedBox(height: 16),
            AppText(
              'Use the floating action button to toggle the overlay on this entire page.',
              variant: TextVariant.bodySmall,
              fontStyle: FontStyle.italic,
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple card widget for consistent styling across the sandbox
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color ?? theme.cardColor,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        boxShadow: boxShadow ??
            [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
      ),
      child: child,
    );
  }
}
