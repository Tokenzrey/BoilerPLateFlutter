import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/buttons/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';

class ButtonSandbox extends StatefulWidget {
  const ButtonSandbox({super.key});

  @override
  State<ButtonSandbox> createState() => _ButtonSandboxState();
}

class _ButtonSandboxState extends State<ButtonSandbox> {
  bool _isLoading = false;
  bool _customLoading = false;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Header
        const AppText(
          'Button Sandbox',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          'A comprehensive demonstration of the Button component and its variants',
          variant: TextVariant.bodyLarge,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 32),

        // Button Variants
        _buildSection(
          title: 'Button Variants',
          description: 'Different visual styles for buttons',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Primary',
                  Button(
                    text: 'Primary',
                    variant: ButtonVariant.primary,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Secondary',
                  Button(
                    text: 'Secondary',
                    variant: ButtonVariant.secondary,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Warning',
                  Button(
                    text: 'Warning',
                    variant: ButtonVariant.warning,
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Neutral',
                  Button(
                    text: 'Neutral',
                    variant: ButtonVariant.neutral,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Danger',
                  Button(
                    text: 'Danger',
                    variant: ButtonVariant.danger,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Light',
                  Button(
                    text: 'Light',
                    variant: ButtonVariant.light,
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Ghost',
                  Button(
                    text: 'Ghost',
                    variant: ButtonVariant.ghost,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Outlined',
                  Button(
                    text: 'Outlined',
                    variant: ButtonVariant.outlined,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Text',
                  Button(
                    text: 'Text',
                    variant: ButtonVariant.text,
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Unstyled',
                  Button(
                    text: 'Unstyled',
                    variant: ButtonVariant.unstyled,
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Button Sizes
        _buildSection(
          title: 'Button Sizes',
          description: 'Different size options for buttons',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'XS',
                  Button(
                    text: 'Extra Small',
                    size: ButtonSize.extraSmall,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'S',
                  Button(
                    text: 'Small',
                    size: ButtonSize.small,
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Normal',
                  Button(
                    text: 'Normal',
                    size: ButtonSize.normal,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'L',
                  Button(
                    text: 'Large',
                    size: ButtonSize.large,
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'XL',
                  Button(
                    text: 'Extra Large',
                    size: ButtonSize.extraLarge,
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Button Densities
        _buildSection(
          title: 'Button Densities',
          description: 'Different spacing densities',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Compact',
                  Button(
                    text: 'Compact',
                    density: ButtonDensity.compact,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Dense',
                  Button(
                    text: 'Dense',
                    density: ButtonDensity.dense,
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Normal',
                  Button(
                    text: 'Normal',
                    density: ButtonDensity.normal,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Comfortable',
                  Button(
                    text: 'Comfortable',
                    density: ButtonDensity.comfortable,
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Button Shapes
        _buildSection(
          title: 'Button Shapes',
          description: 'Different border shapes',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Full Rounded',
                  Button(
                    text: 'Full Rounded',
                    shape: ButtonShape.fullRounded,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Rectangle',
                  Button(
                    text: 'Rectangle',
                    shape: ButtonShape.rectangle,
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Rounded Rect',
                  Button(
                    text: 'Rounded Rectangle',
                    shape: ButtonShape.roundedRectangle,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Custom Rounded',
                  Button(
                    text: 'Custom Rounded',
                    shape: ButtonShape.customRounded,
                    layout: const ButtonLayout(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Icons
        _buildSection(
          title: 'Buttons with Icons',
          description: 'Buttons with left/right icons or icon-only',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Left Icon',
                  Button(
                    text: 'Left Icon',
                    leftIcon: Icons.add,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Right Icon',
                  Button(
                    text: 'Right Icon',
                    rightIcon: Icons.arrow_forward,
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Icon Only',
                  Button(
                    leftIcon: Icons.favorite,
                    iconOnly: true,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Icon Density',
                  Button(
                    leftIcon: Icons.settings,
                    iconOnly: true,
                    density: ButtonDensity.icon,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Comfortable Icon',
                  Button(
                    leftIcon: Icons.add,
                    iconOnly: true,
                    density: ButtonDensity.iconComfortable,
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Typography
        _buildSection(
          title: 'Button Typography',
          description: 'Typography customization options',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Uppercase',
                  Button(
                    text: 'uppercase',
                    typography: const ButtonTypography(
                      transform: TextTransform.uppercase,
                    ),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Lowercase',
                  Button(
                    text: 'LOWERCASE',
                    typography: const ButtonTypography(
                      transform: TextTransform.lowercase,
                    ),
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Capitalize',
                  Button(
                    text: 'capitalize me',
                    typography: const ButtonTypography(
                      transform: TextTransform.capitalize,
                    ),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Bold',
                  Button(
                    text: 'Bold Text',
                    typography: const ButtonTypography(
                      fontWeight: FontWeight.bold,
                    ),
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Custom Font',
                  Button(
                    text: 'Custom Font',
                    typography: const ButtonTypography(
                      fontFamily: 'poppins',
                    ),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Letter Spacing',
                  Button(
                    text: 'Spaced Out',
                    typography: const ButtonTypography(
                      letterSpacing: 2.0,
                    ),
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Colors
        _buildSection(
          title: 'Custom Colors',
          description: 'Color customization options',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Custom BG',
                  Button(
                    text: 'Custom Background',
                    colors: ButtonColors(
                      background: AppColors.violet,
                      text: AppColors.neutral[50],
                    ),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Custom Border',
                  Button(
                    text: 'Custom Border',
                    variant: ButtonVariant.outlined,
                    colors: ButtonColors(
                      border: AppColors.orange,
                      text: AppColors.orange,
                    ),
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Gradient',
                  Button(
                    text: 'Gradient',
                    colors: ButtonColors(
                      gradient: LinearGradient(
                        colors: [AppColors.blue, AppColors.violet],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      text: AppColors.neutral[50],
                    ),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Hover Color',
                  Button(
                    text: 'Hover Me',
                    colors: ButtonColors(
                      background: AppColors.green[500],
                      text: AppColors.neutral[50],
                      hover: AppColors.green[300],
                      pressed: AppColors.green[800],
                    ),
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Layout
        _buildSection(
          title: 'Layout Options',
          description: 'Size, padding and layout options',
          children: [
            _buildLabeledButton(
                'Full Width',
                Button(
                  text: 'Full Width Button',
                  layout: const ButtonLayout(expanded: true),
                  onPressed: () {},
                )),
            const SizedBox(height: 16),
            _buildRow([
              _buildLabeledButton(
                  'Fixed Height',
                  Button(
                    text: 'Fixed Height',
                    layout: const ButtonLayout(
                      height: 64,
                    ),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Custom Padding',
                  Button(
                    text: 'Custom Padding',
                    layout: const ButtonLayout(
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'With Margin',
                  Button(
                    text: 'With Margin',
                    layout: const ButtonLayout(
                      margin: EdgeInsets.all(8),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    colors: ButtonColors(background: AppColors.orange[300]),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Space Between',
                  Button(
                    text: 'Text',
                    leftIcon: Icons.star,
                    rightIcon: Icons.notifications,
                    layout: const ButtonLayout(
                      contentAlignment: MainAxisAlignment.spaceBetween,
                      iconSpacing: 16,
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Effects
        _buildSection(
          title: 'Effects',
          description: 'Elevation and animation effects',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Elevated',
                  Button(
                    text: 'Elevated',
                    effects: ButtonEffects(
                      elevation: 4.0,
                      hoverElevation: 8.0,
                      shadowColor: AppColors.blue.withValues(alpha: 0.5),
                    ),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Animated',
                  Button(
                    text: 'Slow Animation',
                    effects: const ButtonEffects(
                      animationDuration: Duration(milliseconds: 500),
                      animationCurve: Curves.elasticOut,
                    ),
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Loading States
        _buildSection(
          title: 'Loading States',
          description: 'Buttons with loading indicators',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Toggle Loading',
                  Button(
                    text: 'Toggle Loading',
                    loading: ButtonLoadingConfig(
                      isLoading: _isLoading,
                    ),
                    onPressed: () {
                      setState(() {
                        _isLoading = !_isLoading;
                      });
                    },
                  )),
              _buildLabeledButton(
                  'Custom Loading',
                  Button(
                    text: 'Custom Loader',
                    loading: ButtonLoadingConfig(
                      isLoading: _customLoading,
                      widget: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.orange[300]!),
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _customLoading = !_customLoading;
                      });
                    },
                  )),
            ]),
          ],
        ),

        // Disabled State
        _buildSection(
          title: 'Disabled State',
          description: 'Buttons in disabled state',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Disabled',
                  Button(
                    text: 'Disabled Button',
                    disabled: true,
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Custom Disabled',
                  Button(
                    text: 'Custom Disabled',
                    disabled: true,
                    colors: ButtonColors(
                      disabled: AppColors.neutral[300],
                      disabledText: AppColors.neutral[700],
                    ),
                    onPressed: () {},
                  )),
            ]),
            _buildRow([
              _buildLabeledButton(
                  'Disabled Outlined',
                  Button(
                    text: 'Disabled Outlined',
                    variant: ButtonVariant.outlined,
                    disabled: true,
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Custom Builder
        _buildSection(
          title: 'Custom Builder',
          description: 'Using builder function for dynamic content',
          children: [
            _buildRow([
              _buildLabeledButton(
                  'Builder Button',
                  Button(
                    builder: (context, isPressed, isHovered, isFocused) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite,
                              color: isHovered
                                  ? AppColors.red
                                  : AppColors.neutral[500],
                              size: isPressed ? 28 : 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isFocused ? "FOCUSED!" : "Hover me!",
                              style: TextStyle(
                                fontWeight: isPressed
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: isPressed ? 18 : 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Custom Widget',
                  Button(
                    leftWidget: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications,
                          color: AppColors.neutral[50], size: 16),
                    ),
                    text: 'With Badge',
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        // Complex Examples
        _buildSection(
          title: 'Complex Examples',
          description: 'Buttons combining multiple features',
          children: [
            _buildLabeledButton(
                'Feature Button',
                Button(
                  text: 'SUBSCRIBE NOW',
                  leftIcon: Icons.star,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.large,
                  shape: ButtonShape.fullRounded,
                  colors: ButtonColors(
                    gradient: LinearGradient(
                      colors: [AppColors.violet, AppColors.violet[800]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  effects: ButtonEffects(
                    elevation: 3,
                    hoverElevation: 6,
                    shadowColor: AppColors.violet.withValues(alpha: 0.4),
                  ),
                  layout: const ButtonLayout(
                    expanded: true,
                    height: 54,
                  ),
                  onPressed: () {},
                )),
            const SizedBox(height: 16),
            _buildRow([
              _buildLabeledButton(
                  'Delete Button',
                  Button(
                    text: 'Delete Account',
                    leftIcon: Icons.delete_forever,
                    variant: ButtonVariant.outlined,
                    colors: ButtonColors(
                      text: AppColors.red,
                      border: AppColors.red,
                      hover: AppColors.red[50],
                    ),
                    typography: const ButtonTypography(
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: () {},
                  )),
              _buildLabeledButton(
                  'Saving Button',
                  Button(
                    text: 'Saving...',
                    rightIcon: Icons.cloud_upload,
                    colors: ButtonColors(
                      background: AppColors.green[50],
                      text: AppColors.green[400],
                    ),
                    effects: const ButtonEffects(
                      animationDuration: Duration(milliseconds: 300),
                      elevation: 0,
                    ),
                    onPressed: () {},
                  )),
            ]),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 4),
        AppText(
          description,
          variant: TextVariant.bodyMedium,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 32),
        const Divider(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: children,
      ),
    );
  }

  Widget _buildLabeledButton(String label, Widget button) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          label,
          variant: TextVariant.labelMedium,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        button,
      ],
    );
  }
}
