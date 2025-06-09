import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorsSandbox extends StatelessWidget {
  const ColorsSandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
        _buildSectionTitle(context, 'Base Colors'),
        _buildBaseColorsGrid(),
        const SizedBox(height: 32),
        _buildSectionTitle(context, 'Semantic Colors'),
        _buildSemanticColorsSection(),
        const SizedBox(height: 32),
        _buildSectionTitle(context, 'UI Element Colors'),
        _buildUIElementsGrid(),
        const SizedBox(height: 32),
        _buildSectionTitle(context, 'Status Colors'),
        _buildStatusColorsSection(),
        const SizedBox(height: 32),
        _buildSectionTitle(context, 'Chart Colors'),
        _buildChartColorsSection(),
        const SizedBox(height: 32),
        _buildSectionTitle(context, 'Color Swatches'),
        _buildColorSwatches(),
        const SizedBox(height: 40),
        _buildSectionTitle(context, 'Color Usage Examples'),
        _buildColorExamples(context),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.7),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Colors System',
                variant: TextVariant.displayMedium,
                color: AppColors.neutral,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 8),
              AppText(
                'A comprehensive showcase of the application color system',
                variant: TextVariant.bodyLarge,
                color: AppColors.neutral,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: AppText(
            title,
            variant: TextVariant.headlineSmall,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBaseColorsGrid() {
    List<ColorItem> baseColors = [
      ColorItem('background', AppColors.background),
      ColorItem('foreground', AppColors.foreground),
      ColorItem('card', AppColors.card),
      ColorItem('cardForeground', AppColors.cardForeground),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: baseColors.length,
      itemBuilder: (context, index) {
        return _buildColorCard(
          baseColors[index].name,
          baseColors[index].color,
        );
      },
    );
  }

  Widget _buildSemanticColorsSection() {
    return Column(
      children: [
        _buildSemanticColorGroup(
          'Primary',
          [
            ColorItem('primary', AppColors.primary),
            ColorItem('primaryForeground', AppColors.primaryForeground),
            ColorItem('primaryHover', AppColors.primaryHover),
            ColorItem('primaryActive', AppColors.primaryActive),
          ],
        ),
        const SizedBox(height: 24),
        _buildSemanticColorGroup(
          'Secondary',
          [
            ColorItem('secondary', AppColors.secondary),
            ColorItem('secondaryForeground', AppColors.secondaryForeground),
          ],
        ),
        const SizedBox(height: 24),
        _buildSemanticColorGroup(
          'Accent',
          [
            ColorItem('accent', AppColors.accent),
            ColorItem('accentForeground', AppColors.accentForeground),
            ColorItem('accentHover', AppColors.accentHover),
          ],
        ),
        const SizedBox(height: 24),
        _buildSemanticColorGroup(
          'Muted',
          [
            ColorItem('muted', AppColors.muted),
            ColorItem('mutedForeground', AppColors.mutedForeground),
          ],
        ),
        const SizedBox(height: 24),
        _buildSemanticColorGroup(
          'Destructive',
          [
            ColorItem('destructive', AppColors.destructive),
            ColorItem('destructiveForeground', AppColors.destructiveForeground),
            ColorItem('destructiveHover', AppColors.destructiveHover),
          ],
        ),
      ],
    );
  }

  Widget _buildSemanticColorGroup(String groupName, List<ColorItem> colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.neutral.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            groupName,
            variant: TextVariant.titleMedium,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          ...colors.map((color) => _buildColorRow(color.name, color.color)),
        ],
      ),
    );
  }

  Widget _buildUIElementsGrid() {
    List<ColorItem> uiColors = [
      ColorItem('border', AppColors.border),
      ColorItem('input', AppColors.input),
      ColorItem('inputForeground', AppColors.inputForeground),
      ColorItem('ring', AppColors.ring),
      ColorItem('subtleBackground', AppColors.subtleBackground),
      ColorItem('subtleBorder', AppColors.subtleBorder),
      ColorItem('highlight', AppColors.highlight),
      ColorItem('highlightForeground', AppColors.highlightForeground),
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: uiColors.length,
      itemBuilder: (context, index) {
        return _buildColorCard(
          uiColors[index].name,
          uiColors[index].color,
        );
      },
    );
  }

  Widget _buildStatusColorsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            'Success',
            AppColors.success,
            AppColors.successForeground,
            Icons.check_circle,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Warning',
            AppColors.warning,
            AppColors.warningForeground,
            Icons.warning_amber,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusCard(
            'Error',
            AppColors.destructive,
            AppColors.destructiveForeground,
            Icons.error,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
      String title, Color color, Color foregroundColor, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: foregroundColor, size: 32),
          const SizedBox(height: 8),
          AppText(
            title,
            variant: TextVariant.titleMedium,
            fontWeight: FontWeight.bold,
            color: foregroundColor,
          ),
          const SizedBox(height: 4),
          AppText(
            '0x${color.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')}',
            variant: TextVariant.labelSmall,
            color: foregroundColor.withValues(alpha: 0.8),
          ),
        ],
      ),
    );
  }

  Widget _buildChartColorsSection() {
    List<ColorItem> chartColors = [
      ColorItem('chart1', AppColors.chart1),
      ColorItem('chart2', AppColors.chart2),
      ColorItem('chart3', AppColors.chart3),
      ColorItem('chart4', AppColors.chart4),
      ColorItem('chart5', AppColors.chart5),
      ColorItem('chart6', AppColors.chart6),
      ColorItem('chart7', AppColors.chart7),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.neutral.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Chart Color Palette',
                variant: TextVariant.titleMedium,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: Row(
                  children: List.generate(chartColors.length, (index) {
                    return Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: chartColors[index].color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          AppText(
                            'chart${index + 1}',
                            variant: TextVariant.labelSmall,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Chart example visualization
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(chartColors.length, (index) {
                    // Random heights for the bars
                    final double height = 20.0 + (index % 3 + 1) * 20.0;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: chartColors[index].color,
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSwatches() {
    List<SwatchInfo> swatches = [
      SwatchInfo('slate', AppColors.slate),
      SwatchInfo('neutral', AppColors.neutral),
      SwatchInfo('red', AppColors.red),
      SwatchInfo('orange', AppColors.orange),
      SwatchInfo('green', AppColors.green),
      SwatchInfo('blue', AppColors.blue),
      SwatchInfo('violet', AppColors.violet),
    ];

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: swatches.length,
      separatorBuilder: (context, index) => const SizedBox(height: 24),
      itemBuilder: (context, index) {
        return _buildSwatchRow(swatches[index].name, swatches[index].swatch);
      },
    );
  }

  Widget _buildSwatchRow(String name, MaterialColor swatch) {
    const List<int> shades = [50, 100, 200, 300, 400, 500, 600, 700, 800, 900];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.neutral.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            name,
            variant: TextVariant.titleMedium,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: Row(
              children: List.generate(shades.length, (index) {
                final shade = shades[index];
                final color = swatch[shade]!;

                return Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: index == 0
                          ? const BorderRadius.horizontal(
                              left: Radius.circular(8))
                          : index == shades.length - 1
                              ? const BorderRadius.horizontal(
                                  right: Radius.circular(8))
                              : null,
                    ),
                    alignment: Alignment.center,
                    child: AppText(
                      shade.toString(),
                      variant: TextVariant.labelMedium,
                      color: shade < 500 ? Colors.black : AppColors.neutral,
                      fontWeight:
                          shade == 500 ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                'Light → Dark',
                variant: TextVariant.labelMedium,
                color: AppColors.neutral.withValues(alpha: 0.6),
              ),
              AppText(
                'Primary: ${_colorToHex(swatch[500]!)}',
                variant: TextVariant.labelMedium,
                color: AppColors.neutral.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorExamples(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Buttons example
        const AppText(
          'Buttons',
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.primaryForeground,
                    ),
                    onPressed: () {},
                    child: const Text('Primary'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.secondaryForeground,
                    ),
                    onPressed: () {},
                    child: const Text('Secondary'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.accentForeground,
                    ),
                    onPressed: () {},
                    child: const Text('Accent'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.destructive,
                      foregroundColor: AppColors.destructiveForeground,
                    ),
                    onPressed: () {},
                    child: const Text('Destructive'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () {},
                    child: const Text('Outlined'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: () {},
                    child: const Text('Text Button'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.muted,
                      foregroundColor: AppColors.mutedForeground,
                    ),
                    onPressed: () {},
                    child: const Text('Muted'),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Card examples
        const AppText(
          'Cards',
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Card(
                color: AppColors.card,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Standard Card',
                        variant: TextVariant.titleMedium,
                        color: AppColors.cardForeground,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Using card & cardForeground colors',
                        variant: TextVariant.bodyMedium,
                        color: AppColors.cardForeground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                color: AppColors.primary,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Primary Card',
                        variant: TextVariant.titleMedium,
                        color: AppColors.primaryForeground,
                        fontWeight: FontWeight.bold,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Using primary & primaryForeground colors',
                        variant: TextVariant.bodyMedium,
                        color: AppColors.primaryForeground,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Alert/Message examples
        const AppText(
          'Alerts & Messages',
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        _buildAlertMessage(
          Icons.check_circle,
          'Success',
          'Your changes have been saved successfully.',
          AppColors.success,
          AppColors.successForeground,
        ),
        const SizedBox(height: 12),
        _buildAlertMessage(
          Icons.warning_amber,
          'Warning',
          'Please review your inputs before proceeding.',
          AppColors.warning,
          AppColors.warningForeground,
        ),
        const SizedBox(height: 12),
        _buildAlertMessage(
          Icons.error,
          'Error',
          'An error occurred while processing your request.',
          AppColors.destructive,
          AppColors.destructiveForeground,
        ),

        const SizedBox(height: 24),

        // Form elements
        const AppText(
          'Form Elements',
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Input Field',
                  labelStyle: TextStyle(color: AppColors.inputForeground),
                  filled: true,
                  fillColor: AppColors.input,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.ring, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (_) {},
                    activeColor: AppColors.primary,
                    checkColor: AppColors.primaryForeground,
                  ),
                  const Text('Checkbox'),
                  const SizedBox(width: 24),
                  Switch(
                    value: true,
                    onChanged: (_) {},
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                  ),
                  const Text('Switch'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAlertMessage(IconData icon, String title, String message,
      Color color, Color foreground) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: TextVariant.titleSmall,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                const SizedBox(height: 4),
                AppText(
                  message,
                  variant: TextVariant.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorCard(String name, Color color) {
    return GestureDetector(
      onTap: () => _copyColorToClipboard(color),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neutral.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutral.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            AppText(
              name,
              variant: TextVariant.labelMedium,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            AppText(
              _colorToHex(color),
              variant: TextVariant.labelSmall,
              textAlign: TextAlign.center,
              color: AppColors.neutral.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorRow(String name, Color color) {
    return GestureDetector(
      onTap: () => _copyColorToClipboard(color),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.neutral.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppText(
                name,
                variant: TextVariant.labelMedium,
              ),
            ),
            AppText(
              _colorToHex(color),
              variant: TextVariant.labelSmall,
              fontFamily: 'monospace',
              color: AppColors.neutral.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void _copyColorToClipboard(Color color) {
    final hexCode = _colorToHex(color);
    Clipboard.setData(ClipboardData(text: hexCode));
  }
}

class ColorItem {
  final String name;
  final Color color;

  ColorItem(this.name, this.color);
}

class SwatchInfo {
  final String name;
  final MaterialColor swatch;

  SwatchInfo(this.name, this.swatch);
}
