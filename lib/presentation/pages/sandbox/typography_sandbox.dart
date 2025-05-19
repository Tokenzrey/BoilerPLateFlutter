import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';

/// A comprehensive sandbox screen that demonstrates all text variants and properties
/// of the AppText widget without using Scaffold.
///
/// This screen provides visual examples of:
/// - All TextVariant options
/// - Color customization
/// - Font weight and style options
/// - Text overflow handling
/// - Line height and letter spacing
/// - Text decorations
/// - Font family selection
class TypographyExamplePage extends StatelessWidget {
  const TypographyExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: AppColors.neutral,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 32),

              // Display variants
              _buildSectionTitle('Display Variants'),
              _buildDisplayVariants(),
              const SizedBox(height: 32),

              // Headline variants
              _buildSectionTitle('Headline Variants'),
              _buildHeadlineVariants(),
              const SizedBox(height: 32),

              // Title variants
              _buildSectionTitle('Title Variants'),
              _buildTitleVariants(),
              const SizedBox(height: 32),

              // Body variants
              _buildSectionTitle('Body Variants'),
              _buildBodyVariants(),
              const SizedBox(height: 32),

              // Label variants
              _buildSectionTitle('Label Variants'),
              _buildLabelVariants(),
              const SizedBox(height: 32),

              // Custom styling examples
              _buildSectionTitle('Styling Examples'),
              _buildStylingExamples(context),
              const SizedBox(height: 32),

              // Font family examples
              _buildSectionTitle('Font Family Examples'),
              _buildFontFamilyExamples(),
              const SizedBox(height: 32),

              // Text overflow examples
              _buildSectionTitle('Text Overflow Examples'),
              _buildOverflowExamples(),
              const SizedBox(height: 32),

              // Text decoration examples
              _buildSectionTitle('Text Decoration Examples'),
              _buildDecorationExamples(),
              const SizedBox(height: 40),

              // Usage reference
              _buildUsageReference(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Typography Sandbox',
          variant: TextVariant.displayLarge,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          'A comprehensive demonstration of the AppText widget and its variants',
          variant: TextVariant.bodyLarge,
          color: AppColors.neutral[500],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.headlineSmall,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: 4),
        Divider(color: AppColors.slate, thickness: 1),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDisplayVariants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Large
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('displayLarge',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Display Large (57.0)',
                variant: TextVariant.displayLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Display Medium
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('displayMedium',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Display Medium (45.0)',
                variant: TextVariant.displayMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Display Small
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('displaySmall',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Display Small (36.0)',
                variant: TextVariant.displaySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeadlineVariants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline Large
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('headlineLarge',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Headline Large (32.0)',
                variant: TextVariant.headlineLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Headline Medium
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('headlineMedium',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Headline Medium (28.0)',
                variant: TextVariant.headlineMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Headline Small
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('headlineSmall',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Headline Small (24.0)',
                variant: TextVariant.headlineSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitleVariants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Large
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('titleLarge',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Title Large (22.0)',
                variant: TextVariant.titleLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Title Medium
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('titleMedium',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Title Medium (16.0)',
                variant: TextVariant.titleMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Title Small
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('titleSmall',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Title Small (14.0)',
                variant: TextVariant.titleSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyVariants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Body Large
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('bodyLarge',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Body Large (16.0) - This size is ideal for primary paragraph text, emphasized descriptions, or important information blocks.',
                variant: TextVariant.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Body Medium
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('bodyMedium',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Body Medium (14.0) - The standard text size for most application content. This is typically used for the main body text throughout the app.',
                variant: TextVariant.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Body Small
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('bodySmall',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Body Small (12.0) - Used for secondary information, captions, or helper text that provides additional context without being intrusive.',
                variant: TextVariant.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLabelVariants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label Large
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('labelLarge',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Label Large (14.0)',
                variant: TextVariant.labelLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Label Medium
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('labelMedium',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Label Medium (12.0)',
                variant: TextVariant.labelMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Label Small
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('labelSmall',
                  variant: TextVariant.labelMedium, color: AppColors.slate),
              const SizedBox(height: 4),
              const AppText(
                'Label Small (11.0)',
                variant: TextVariant.labelSmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStylingExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font weight examples
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Font Weight Examples',
                  variant: TextVariant.labelLarge, color: AppColors.slate),
              const SizedBox(height: 12),
              const AppText(
                'Thin (w100)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w100,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Extra Light (w200)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w200,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Light (w300)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w300,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Regular (w400)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w400,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Medium (w500)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 8),
              const AppText(
                'SemiBold (w600)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Bold (w700)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Extra Bold (w800)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Black (w900)',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Color examples
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Color Examples',
                  variant: TextVariant.labelLarge, color: AppColors.slate),
              const SizedBox(height: 12),
              const AppText(
                'Default Color',
                variant: TextVariant.bodyLarge,
              ),
              const SizedBox(height: 8),
              AppText(
                'Primary Color',
                variant: TextVariant.bodyLarge,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),
              AppText(
                'Custom Color (Blue)',
                variant: TextVariant.bodyLarge,
                color: AppColors.blue,
              ),
              const SizedBox(height: 8),
              AppText(
                'Custom Color (Red)',
                variant: TextVariant.bodyLarge,
                color: AppColors.red,
              ),
              const SizedBox(height: 8),
              AppText(
                'Grey Color',
                variant: TextVariant.bodyLarge,
                color: AppColors.slate,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Height and Letter Spacing
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Height & Letter Spacing',
                  variant: TextVariant.labelLarge, color: AppColors.slate),
              const SizedBox(height: 12),
              const AppText(
                'Default line height and letter spacing',
                variant: TextVariant.bodyLarge,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Increased line height (1.5) - This text has more vertical space between lines, which can improve readability for longer paragraphs of text.',
                variant: TextVariant.bodyLarge,
                height: 1.5,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Condensed line height (0.9) - Text with reduced line height appears more compact.',
                variant: TextVariant.bodyLarge,
                height: 0.9,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Expanded letter spacing (2.0) - Text with increased space between letters',
                variant: TextVariant.bodyLarge,
                letterSpacing: 2.0,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Condensed letter spacing (-0.5) - Text with reduced space between letters',
                variant: TextVariant.bodyLarge,
                letterSpacing: -0.5,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Font Style
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Font Style',
                  variant: TextVariant.labelLarge, color: AppColors.slate),
              const SizedBox(height: 12),
              const AppText(
                'Normal font style (default)',
                variant: TextVariant.bodyLarge,
                fontStyle: FontStyle.normal,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Italic font style - Adds emphasis to text',
                variant: TextVariant.bodyLarge,
                fontStyle: FontStyle.italic,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFontFamilyExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Font Family Examples',
                  variant: TextVariant.labelLarge, color: AppColors.slate),
              const SizedBox(height: 12),
              const AppText(
                'Default Font Family',
                variant: TextVariant.bodyLarge,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Poppins Font Family',
                variant: TextVariant.bodyLarge,
                fontFamily: 'poppins',
              ),
              const SizedBox(height: 12),
              const AppText(
                'Roboto Font Family',
                variant: TextVariant.bodyLarge,
                fontFamily: 'roboto',
              ),
              const SizedBox(height: 12),
              const AppText(
                'Helvetica Font Family',
                variant: TextVariant.bodyLarge,
                fontFamily: 'helvetica',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverflowExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Overflow Examples',
                  variant: TextVariant.labelLarge, color: AppColors.slate),
              const SizedBox(height: 12),
              Container(
                width: 200,
                padding: const EdgeInsets.all(8),
                color: AppColors.slate,
                child: const AppText(
                  'This text is limited to one line and will be clipped if it exceeds the available width.',
                  variant: TextVariant.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                padding: const EdgeInsets.all(8),
                color: AppColors.slate,
                child: const AppText(
                  'This text is limited to one line and will show ellipsis (...) if it exceeds the available width.',
                  variant: TextVariant.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                padding: const EdgeInsets.all(8),
                color: AppColors.slate,
                child: const AppText(
                  'This text is limited to two lines and will show ellipsis (...) if it exceeds the available height.',
                  variant: TextVariant.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: 200,
                padding: const EdgeInsets.all(8),
                color: AppColors.slate,
                child: const AppText(
                  'This text will fade out at the end if it exceeds the available width.',
                  variant: TextVariant.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecorationExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Text Decoration Examples',
                  variant: TextVariant.labelLarge, color: AppColors.slate),
              const SizedBox(height: 12),
              const AppText(
                'No Decoration (Default)',
                variant: TextVariant.bodyLarge,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Underlined Text',
                variant: TextVariant.bodyLarge,
                decoration: TextDecoration.underline,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Line-through Text (Strikethrough)',
                variant: TextVariant.bodyLarge,
                decoration: TextDecoration.lineThrough,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Overlined Text',
                variant: TextVariant.bodyLarge,
                decoration: TextDecoration.overline,
              ),
              const SizedBox(height: 12),
              AppText(
                'Custom Styled Text',
                variant: TextVariant.bodyLarge,
                style: TextStyle(
                  shadows: [
                    Shadow(
                      color: AppColors.slate,
                      offset: const Offset(2, 2),
                      blurRadius: 2,
                    ),
                  ],
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.blue,
                  decorationStyle: TextDecorationStyle.dotted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageReference() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'How to Use AppText',
            variant: TextVariant.titleMedium,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          const AppText(
            '• Basic usage: AppText("Hello World")',
            variant: TextVariant.bodyMedium,
          ),
          const SizedBox(height: 8),
          const AppText(
            '• With variant: AppText("Hello", variant: TextVariant.headlineLarge)',
            variant: TextVariant.bodyMedium,
          ),
          const SizedBox(height: 8),
          const AppText(
            '• Custom color: AppText("Hello", color: Colors.blue)',
            variant: TextVariant.bodyMedium,
          ),
          const SizedBox(height: 8),
          const AppText(
            '• Custom weight: AppText("Hello", fontWeight: FontWeight.bold)',
            variant: TextVariant.bodyMedium,
          ),
          const SizedBox(height: 8),
          const AppText(
            '• Multi-props: AppText("Hello", variant: TextVariant.titleLarge, color: Colors.red, fontWeight: FontWeight.w600)',
            variant: TextVariant.bodyMedium,
          ),
          const SizedBox(height: 8),
          const AppText(
            '• With overflow: AppText("Long text...", maxLines: 1, overflow: TextOverflow.ellipsis)',
            variant: TextVariant.bodyMedium,
          ),
          const SizedBox(height: 8),
          const AppText(
            '• Custom font: AppText("Hello", fontFamily: "poppins")',
            variant: TextVariant.bodyMedium,
          ),
        ],
      ),
    );
  }
}
