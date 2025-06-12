import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';

class TypographySandbox extends StatelessWidget {
  const TypographySandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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

        // Text alignment examples
        _buildSectionTitle('Text Alignment Examples'),
        _buildAlignmentExamples(),
        const SizedBox(height: 32),

        // Text overflow examples
        _buildSectionTitle('Text Overflow Examples'),
        _buildOverflowExamples(),
        const SizedBox(height: 32),

        // Text decoration examples
        _buildSectionTitle('Text Decoration Examples'),
        _buildDecorationExamples(),
        const SizedBox(height: 40),

        // Rich text examples
        _buildSectionTitle('Rich Text & TextSpan Examples'),
        _buildRichTextExamples(),
        const SizedBox(height: 40),

        // Usage reference
        _buildUsageReference(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const AppText(
            'Typography Sandbox',
            variant: TextVariant.displayLarge,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: AppText(
            title,
            variant: TextVariant.headlineSmall,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDisplayVariants() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Display Large
        _buildTypographyCard(
          'displayLarge',
          const AppText(
            'Display Large (57.0)',
            variant: TextVariant.displayLarge,
          ),
        ),

        const SizedBox(height: 16),

        // Display Medium
        _buildTypographyCard(
          'displayMedium',
          const AppText(
            'Display Medium (45.0)',
            variant: TextVariant.displayMedium,
          ),
        ),

        const SizedBox(height: 16),

        // Display Small
        _buildTypographyCard(
          'displaySmall',
          const AppText(
            'Display Small (36.0)',
            variant: TextVariant.displaySmall,
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
        _buildTypographyCard(
          'headlineLarge',
          const AppText(
            'Headline Large (32.0)',
            variant: TextVariant.headlineLarge,
          ),
        ),

        const SizedBox(height: 16),

        // Headline Medium
        _buildTypographyCard(
          'headlineMedium',
          const AppText(
            'Headline Medium (28.0)',
            variant: TextVariant.headlineMedium,
          ),
        ),

        const SizedBox(height: 16),

        // Headline Small
        _buildTypographyCard(
          'headlineSmall',
          const AppText(
            'Headline Small (24.0)',
            variant: TextVariant.headlineSmall,
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
        _buildTypographyCard(
          'titleLarge',
          const AppText(
            'Title Large (22.0)',
            variant: TextVariant.titleLarge,
          ),
        ),

        const SizedBox(height: 16),

        // Title Medium
        _buildTypographyCard(
          'titleMedium',
          const AppText(
            'Title Medium (16.0)',
            variant: TextVariant.titleMedium,
          ),
        ),

        const SizedBox(height: 16),

        // Title Small
        _buildTypographyCard(
          'titleSmall',
          const AppText(
            'Title Small (14.0)',
            variant: TextVariant.titleSmall,
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
        _buildTypographyCard(
          'bodyLarge',
          const AppText(
            'Body Large (16.0) - This size is ideal for primary paragraph text, emphasized descriptions, or important information blocks.',
            variant: TextVariant.bodyLarge,
          ),
        ),

        const SizedBox(height: 16),

        // Body Medium
        _buildTypographyCard(
          'bodyMedium',
          const AppText(
            'Body Medium (14.0) - The standard text size for most application content. This is typically used for the main body text throughout the app.',
            variant: TextVariant.bodyMedium,
          ),
        ),

        const SizedBox(height: 16),

        // Body Small
        _buildTypographyCard(
          'bodySmall',
          const AppText(
            'Body Small (12.0) - Used for secondary information, captions, or helper text that provides additional context without being intrusive.',
            variant: TextVariant.bodySmall,
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
        _buildTypographyCard(
          'labelLarge',
          const AppText(
            'Label Large (14.0) - Used for form field labels, interactive elements, and medium-emphasis UI components.',
            variant: TextVariant.labelLarge,
          ),
        ),

        const SizedBox(height: 16),

        // Label Medium
        _buildTypographyCard(
          'labelMedium',
          const AppText(
            'Label Medium (12.0) - Commonly used for secondary labels, badges, and metadata display.',
            variant: TextVariant.labelMedium,
          ),
        ),

        const SizedBox(height: 16),

        // Label Small
        _buildTypographyCard(
          'labelSmall',
          const AppText(
            'Label Small (11.0) - The smallest text size, suitable for timestamps, metadata, and minor annotations.',
            variant: TextVariant.labelSmall,
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
            color: Colors.white,
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Font Weight Examples',
                variant: TextVariant.labelLarge,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              const Divider(),
              _buildWeightExample('Thin (w100)', FontWeight.w100),
              _buildWeightExample('Extra Light (w200)', FontWeight.w200),
              _buildWeightExample('Light (w300)', FontWeight.w300),
              _buildWeightExample('Regular (w400)', FontWeight.w400),
              _buildWeightExample('Medium (w500)', FontWeight.w500),
              _buildWeightExample('SemiBold (w600)', FontWeight.w600),
              _buildWeightExample('Bold (w700)', FontWeight.w700),
              _buildWeightExample('Extra Bold (w800)', FontWeight.w800),
              _buildWeightExample('Black (w900)', FontWeight.w900),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Color examples
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Color Examples',
                variant: TextVariant.labelLarge,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              const Divider(),
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
                'Secondary Color',
                variant: TextVariant.bodyLarge,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 8),
              AppText(
                'Custom Blue',
                variant: TextVariant.bodyLarge,
                color: AppColors.blue,
              ),
              const SizedBox(height: 8),
              AppText(
                'Custom Red',
                variant: TextVariant.bodyLarge,
                color: AppColors.red,
              ),
              const SizedBox(height: 8),
              AppText(
                'Custom Green',
                variant: TextVariant.bodyLarge,
                color: AppColors.green,
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
            color: Colors.white,
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Height & Letter Spacing',
                variant: TextVariant.labelLarge,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              const Divider(),
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
            color: Colors.white,
            border: Border.all(color: AppColors.slate),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Font Style',
                variant: TextVariant.labelLarge,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              const Divider(),
              const AppText(
                'Normal font style (default)',
                variant: TextVariant.bodyLarge,
                fontStyle: FontStyle.normal,
              ),
              const SizedBox(height: 12),
              const AppText(
                'Italic font style - Adds emphasis or indicates titles, quotes, or foreign terms',
                variant: TextVariant.bodyLarge,
                fontStyle: FontStyle.italic,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeightExample(String label, FontWeight weight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: AppText(
              label,
              variant: TextVariant.labelMedium,
              color: AppColors.slate,
            ),
          ),
          Expanded(
            child: AppText(
              'The quick brown fox jumps over the lazy dog',
              variant: TextVariant.bodyLarge,
              fontWeight: weight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontFamilyExamples() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Font Family Examples',
            variant: TextVariant.labelLarge,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          const Divider(),
          _buildFontFamilyExample('Default Font Family', null),
          _buildFontFamilyExample('Poppins Font Family', 'poppins'),
          _buildFontFamilyExample('Roboto Font Family', 'roboto'),
          _buildFontFamilyExample('Helvetica Font Family', 'helvetica'),
        ],
      ),
    );
  }

  Widget _buildFontFamilyExample(String label, String? fontFamily) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 4),
          AppText(
            'The quick brown fox jumps over the lazy dog',
            variant: TextVariant.bodyLarge,
            fontFamily: fontFamily,
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentExamples() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Text Alignment Examples',
            variant: TextVariant.labelLarge,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          const Divider(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AppText(
              'Left aligned text (default). This text is aligned to the left edge of its container.',
              variant: TextVariant.bodyMedium,
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AppText(
              'Center aligned text. This text is aligned to the center of its container.',
              variant: TextVariant.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AppText(
              'Right aligned text. This text is aligned to the right edge of its container.',
              variant: TextVariant.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AppText(
              'Justified text. This longer paragraph of text is stretched to fill the width of its container. This is useful for blocks of text that should have a clean edge on both the left and right sides.',
              variant: TextVariant.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverflowExamples() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Overflow Examples',
            variant: TextVariant.labelLarge,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          const Divider(),
          AppText(
            'TextOverflow.clip',
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 4),
          Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.slate.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AppText(
              'This text is limited to one line and will be clipped if it exceeds the available width.',
              variant: TextVariant.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ),
          const SizedBox(height: 16),
          AppText(
            'TextOverflow.ellipsis (single line)',
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 4),
          Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.slate.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AppText(
              'This text is limited to one line and will show ellipsis (...) if it exceeds the available width.',
              variant: TextVariant.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          AppText(
            'TextOverflow.ellipsis (multi-line)',
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 4),
          Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.slate.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AppText(
              'This text is limited to two lines and will show ellipsis (...) if it exceeds the available height. This demonstrates how to handle multi-line text that might be too long.',
              variant: TextVariant.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          AppText(
            'TextOverflow.fade',
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 4),
          Container(
            width: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.slate.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const AppText(
              'This text will fade out at the end if it exceeds the available width.',
              variant: TextVariant.bodyMedium,
              maxLines: 1,
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorationExamples() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Text Decoration Examples',
            variant: TextVariant.labelLarge,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          const Divider(),
          _buildDecorationExample('No Decoration (Default)', null),
          _buildDecorationExample('Underlined Text', TextDecoration.underline),
          _buildDecorationExample(
              'Line-through Text (Strikethrough)', TextDecoration.lineThrough),
          _buildDecorationExample('Overlined Text', TextDecoration.overline),
          const SizedBox(height: 16),
          AppText(
            'Decorated with Style',
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 4),
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
              decorationThickness: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorationExample(String label, TextDecoration? decoration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 4),
          AppText(
            'The quick brown fox jumps over the lazy dog',
            variant: TextVariant.bodyLarge,
            decoration: decoration,
          ),
        ],
      ),
    );
  }

  Widget _buildRichTextExamples() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Rich Text Examples',
            variant: TextVariant.labelLarge,
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
          const Divider(),
          const SizedBox(height: 8),

          // Example of how to use TextSpan with the AppText widget
          AppText(
            'Using TextSpan',
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'You can use ',
                  style: TextStyle(fontSize: 16),
                ),
                TextSpan(
                  text: 'different styles ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(
                  text: 'for ',
                  style: TextStyle(fontSize: 16),
                ),
                TextSpan(
                  text: 'different parts ',
                  style: TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    color: AppColors.secondary,
                  ),
                ),
                const TextSpan(
                  text: 'of the same text.',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          AppText(
            'Advanced Styling',
            variant: TextVariant.labelMedium,
            color: AppColors.slate,
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '🔥 ',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.warning,
                  ),
                ),
                TextSpan(
                  text: 'Hot Deal: ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
                const TextSpan(
                  text: 'Save ',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
                TextSpan(
                  text: '50% ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const TextSpan(
                  text: 'on all products!',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageReference() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue[50]!,
            Colors.blue[100]!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            '📚 How to Use AppText',
            variant: TextVariant.titleLarge,
            fontWeight: FontWeight.bold,
          ),
          const Divider(color: Colors.blue),
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
          const SizedBox(height: 8),
          const AppText(
            '• With alignment: AppText("Hello", textAlign: TextAlign.center)',
            variant: TextVariant.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyCard(String variantName, Widget example) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.slate),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AppText(
              variantName,
              variant: TextVariant.labelMedium,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          example,
        ],
      ),
    );
  }
}
