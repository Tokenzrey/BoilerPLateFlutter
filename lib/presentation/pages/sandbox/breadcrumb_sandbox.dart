import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/layout/breadcrumb.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/forms/switch.dart';
import 'package:boilerplate/core/widgets/components/forms/select.dart';

class BreadcrumbSandbox extends StatefulWidget {
  const BreadcrumbSandbox({super.key});

  @override
  State<BreadcrumbSandbox> createState() => _BreadcrumbSandboxState();
}

class _BreadcrumbSandboxState extends State<BreadcrumbSandbox> {
  // Example paths for demonstrations
  final List<String> _filePath = [
    'Home',
    'Documents',
    'Projects',
    'Flutter',
    'App'
  ];
  final List<String> _productPath = [
    'Shop',
    'Electronics',
    'Computers',
    'Laptops',
    'Gaming'
  ];

  // Configuration options
  String _separatorType = 'arrow';
  String _overflowBehavior = 'scroll';
  bool _enableScrolling = true;
  int? _maxVisibleItems;
  bool _showIcons = true;
  bool _enableClickable = true;
  bool _showTooltips = true;
  bool _useCustomStyle = false;
  bool _showBackgroundColors = false;
  String _alignmentType = 'start';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AppText('Breadcrumb Sandbox',
            variant: TextVariant.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            // Basic example
            _buildSection(
              title: 'Basic Examples',
              description:
                  'Standard breadcrumb implementations with different data sources.',
              examples: [
                _buildExampleCard(
                  title: 'From String List',
                  description:
                      'Created using Breadcrumb.fromStrings constructor',
                  breadcrumb: _buildBasicBreadcrumb(),
                  codeSnippet: '''
Breadcrumb.fromStrings(
  labels: ['Home', 'Documents', 'Projects', 'Flutter', 'App'],
  separator: Breadcrumb.arrowSeparator,
  enableScrolling: true,
)''',
                ),
                _buildExampleCard(
                  title: 'From BreadcrumbItem List',
                  description: 'Created using BreadcrumbItem objects',
                  breadcrumb: _buildItemsBreadcrumb(),
                  codeSnippet: '''
Breadcrumb(
  items: [
    BreadcrumbItem.text('Shop'),
    BreadcrumbItem.text('Electronics'),
    BreadcrumbItem.text('Computers'),
    BreadcrumbItem.text('Laptops', 
      icon: Icons.laptop),
    BreadcrumbItem.text('Gaming', 
      isActive: true),
  ],
)''',
                ),
                _buildExampleCard(
                  title: 'With Icons',
                  description:
                      'Demonstrates using icons within breadcrumb items',
                  breadcrumb: _buildIconsBreadcrumb(),
                  codeSnippet: '''
Breadcrumb(
  items: [
    BreadcrumbItem.text('Home', 
      icon: Icons.home),
    BreadcrumbItem.text('Settings', 
      icon: Icons.settings),
    BreadcrumbItem.text('Account', 
      icon: Icons.person),
    BreadcrumbItem.text('Security', 
      icon: Icons.security, 
      isActive: true),
  ],
)''',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Separator types
            _buildSection(
              title: 'Separator Types',
              description:
                  'Different separator options between breadcrumb items.',
              examples: [
                _buildExampleCard(
                  title: 'Arrow Separator (Default)',
                  breadcrumb: Breadcrumb.fromStrings(
                    labels: _filePath,
                    separator: Breadcrumb.arrowSeparator,
                  ),
                  codeSnippet: "separator: Breadcrumb.arrowSeparator",
                ),
                _buildExampleCard(
                  title: 'Slash Separator',
                  breadcrumb: Breadcrumb.fromStrings(
                    labels: _filePath,
                    separator: BreadcrumbSeparators.slash,
                  ),
                  codeSnippet: "separator: BreadcrumbSeparators.slash",
                ),
                _buildExampleCard(
                  title: 'Dot Separator',
                  breadcrumb: Builder(
                    builder: (context) => Breadcrumb.fromStrings(
                      labels: _filePath,
                      separator: BreadcrumbSeparators.dot(context),
                    ),
                  ),
                  codeSnippet: "separator: BreadcrumbSeparators.dot(context)",
                ),
                _buildExampleCard(
                  title: 'Custom Text Separator',
                  breadcrumb: Builder(
                    builder: (context) => Breadcrumb.fromStrings(
                      labels: _filePath,
                      separator: BreadcrumbSeparators.text(context, '→'),
                    ),
                  ),
                  codeSnippet:
                      "separator: BreadcrumbSeparators.text(context, '→')",
                ),
                _buildExampleCard(
                  title: 'Custom Icon Separator',
                  breadcrumb: Builder(
                    builder: (context) => Breadcrumb.fromStrings(
                      labels: _filePath,
                      separator: BreadcrumbSeparators.icon(
                          context, Icons.arrow_forward_ios,
                          size: 12),
                    ),
                  ),
                  codeSnippet:
                      "separator: BreadcrumbSeparators.icon(context, Icons.arrow_forward_ios, size: 12)",
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Overflow handling
            _buildSection(
              title: 'Overflow Handling',
              description:
                  'Different ways to handle breadcrumbs that exceed available space.',
              examples: [
                _buildExampleCard(
                  title: 'Scroll Overflow',
                  description:
                      'Enables horizontal scrolling when breadcrumbs exceed width',
                  breadcrumb: Breadcrumb.fromStrings(
                    labels: [
                      ..._filePath,
                      'Components',
                      'Breadcrumb',
                      'Examples',
                      'Overflow'
                    ],
                    enableScrolling: true,
                    overflowBehavior: OverflowBehavior.scroll,
                  ),
                  codeSnippet: '''
Breadcrumb.fromStrings(
  labels: [...],
  enableScrolling: true,
  overflowBehavior: OverflowBehavior.scroll,
)''',
                ),
                _buildExampleCard(
                  title: 'Ellipsis Overflow',
                  description:
                      'Shows first and last items with ellipsis in the middle',
                  breadcrumb: Breadcrumb.fromStrings(
                    labels: [
                      ..._filePath,
                      'Components',
                      'Breadcrumb',
                      'Examples',
                      'Overflow'
                    ],
                    maxVisibleItems: 5,
                    overflowBehavior: OverflowBehavior.ellipsis,
                  ),
                  codeSnippet: '''
Breadcrumb.fromStrings(
  labels: [...],
  maxVisibleItems: 5,
  overflowBehavior: OverflowBehavior.ellipsis,
)''',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Styling
            _buildSection(
              title: 'Custom Styling',
              description:
                  'Apply custom styling to breadcrumb items and separators.',
              examples: [
                _buildExampleCard(
                  title: 'Custom Text Styles',
                  description:
                      'Customizing regular and active item text styles',
                  breadcrumb: Breadcrumb.fromStrings(
                    labels: _filePath,
                    style: BreadcrumbStyle(
                      itemStyle: TextStyle(
                        color: AppColors.neutral[600],
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      activeItemStyle: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  codeSnippet: '''
Breadcrumb.fromStrings(
  labels: [...],
  style: BreadcrumbStyle(
    itemStyle: TextStyle(
      color: AppColors.neutral[600],
      fontSize: 14,
      fontWeight: FontWeight.normal,
    ),
    activeItemStyle: TextStyle(
      color: AppColors.primary,
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
  ),
)''',
                ),
                _buildExampleCard(
                  title: 'Background Colors & Borders',
                  description: 'Adding background colors and borders to items',
                  breadcrumb: Breadcrumb.fromStrings(
                    labels: _filePath,
                    style: BreadcrumbStyle(
                      itemBackgroundColor: AppColors.neutral[100],
                      activeItemBackgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      itemBorderColor: AppColors.neutral[300],
                      itemBorderWidth: 1,
                      itemBorderRadius: BorderRadius.circular(4),
                      itemPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                    ),
                  ),
                  codeSnippet: '''
Breadcrumb.fromStrings(
  labels: [...],
  style: BreadcrumbStyle(
    itemBackgroundColor: AppColors.neutral[100],
    activeItemBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
    itemBorderColor: AppColors.neutral[300],
    itemBorderWidth: 1,
    itemBorderRadius: BorderRadius.circular(4),
    itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
)''',
                ),
                _buildExampleCard(
                  title: 'Custom Separator Styling',
                  description:
                      'Customizing spacing and appearance of separators',
                  breadcrumb: Breadcrumb.fromStrings(
                    labels: _filePath,
                    separatorBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  codeSnippet: '''
Breadcrumb.fromStrings(
  labels: [...],
  separatorBuilder: (context, index) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.accent,
        shape: BoxShape.circle,
      ),
    ),
  ),
)''',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Interactive features
            _buildSection(
              title: 'Interactive Features',
              description: 'Demonstration of click interactions and tooltips.',
              examples: [
                _buildExampleCard(
                  title: 'Clickable Items',
                  description: 'Items with onTap handlers and visual feedback',
                  breadcrumb: Breadcrumb(
                    items: [
                      BreadcrumbItem.text('Home',
                          onTap: () => _showClickMessage(context, 'Home')),
                      BreadcrumbItem.text('Products',
                          onTap: () => _showClickMessage(context, 'Products')),
                      BreadcrumbItem.text('Laptops',
                          onTap: () => _showClickMessage(context, 'Laptops')),
                      BreadcrumbItem.text('Gaming', isActive: true),
                    ],
                  ),
                  codeSnippet: '''
Breadcrumb(
  items: [
    BreadcrumbItem.text('Home', 
      onTap: () => _showClickMessage(context, 'Home')),
    BreadcrumbItem.text('Products', 
      onTap: () => _showClickMessage(context, 'Products')),
    BreadcrumbItem.text('Laptops', 
      onTap: () => _showClickMessage(context, 'Laptops')),
    BreadcrumbItem.text('Gaming', 
      isActive: true),
  ],
)''',
                ),
                _buildExampleCard(
                  title: 'Items with Tooltips',
                  description: 'Hover over items to see tooltips',
                  breadcrumb: Breadcrumb(
                    items: [
                      BreadcrumbItem.text('Home', tooltip: 'Go to Home page'),
                      BreadcrumbItem.text('Products',
                          tooltip: 'Browse all products'),
                      BreadcrumbItem.text('Laptops',
                          tooltip: 'View laptops category'),
                      BreadcrumbItem.text('Gaming',
                          isActive: true, tooltip: 'Gaming laptops'),
                    ],
                  ),
                  codeSnippet: '''
Breadcrumb(
  items: [
    BreadcrumbItem.text('Home', 
      tooltip: 'Go to Home page'),
    BreadcrumbItem.text('Products', 
      tooltip: 'Browse all products'),
    BreadcrumbItem.text('Laptops', 
      tooltip: 'View laptops category'),
    BreadcrumbItem.text('Gaming', 
      isActive: true, 
      tooltip: 'Gaming laptops'),
  ],
)''',
                ),
                _buildExampleCard(
                  title: 'Custom Item Widgets',
                  description: 'Using custom widget instead of text',
                  breadcrumb: Breadcrumb(
                    items: [
                      BreadcrumbItem.text('Home', icon: Icons.home),
                      BreadcrumbItem.widget(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.accent),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sell,
                                  size: 14, color: AppColors.accent),
                              const SizedBox(width: 4),
                              Text('Special Sale',
                                  style: TextStyle(color: AppColors.accent)),
                            ],
                          ),
                        ),
                      ),
                      BreadcrumbItem.text('Gaming Laptops', isActive: true),
                    ],
                  ),
                  codeSnippet: '''
Breadcrumb(
  items: [
    BreadcrumbItem.text('Home', 
      icon: Icons.home),
    BreadcrumbItem.widget(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.accent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sell, size: 14, color: AppColors.accent),
            SizedBox(width: 4),
            Text('Special Sale', style: TextStyle(color: AppColors.accent)),
          ],
        ),
      ),
    ),
    BreadcrumbItem.text('Gaming Laptops', 
      isActive: true),
  ],
)''',
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Playground
            _buildPlayground(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Breadcrumb Component',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          'Explore the various options and configurations of the Breadcrumb component.',
          variant: TextVariant.bodyLarge,
          color: AppColors.neutral[700],
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> examples,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        AppText(
          description,
          variant: TextVariant.bodyMedium,
          color: AppColors.neutral[700],
        ),
        const SizedBox(height: 16),
        ...examples,
      ],
    );
  }

  Widget _buildExampleCard({
    required String title,
    String? description,
    required Widget breadcrumb,
    String? codeSnippet,
  }) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.w600,
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  AppText(
                    description,
                    variant: TextVariant.bodySmall,
                    color: AppColors.neutral[600],
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.neutral[50],
            child: breadcrumb,
          ),
          if (codeSnippet != null) ...[
            const Divider(height: 1),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.neutral[900],
              child: AppText(
                codeSnippet,
                variant: TextVariant.bodySmall,
                color: AppColors.neutral[200],
                fontFamily: 'monospace',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayground() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Interactive Playground',
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        AppText(
          'Experiment with different breadcrumb configurations using the controls below.',
          variant: TextVariant.bodyMedium,
          color: AppColors.neutral[700],
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildPlaygroundControls(),
              ),
              const Divider(height: 1),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.neutral[50],
                child: _buildConfiguredBreadcrumb(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaygroundControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Configuration Controls',
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 24,
          children: [
            SizedBox(
              width: 200,
              child: FormSelectField<String>(
                label: 'Separator Type',
                initialValue: _separatorType,
                options: [
                  SelectOption<String>(value: 'arrow', label: 'Arrow'),
                  SelectOption<String>(value: 'slash', label: 'Slash'),
                  SelectOption<String>(value: 'dot', label: 'Dot'),
                  SelectOption<String>(value: 'text', label: 'Text (→)'),
                  SelectOption<String>(value: 'icon', label: 'Custom Icon'),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _separatorType = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: FormSelectField<String>(
                label: 'Overflow Behavior',
                initialValue: _overflowBehavior,
                options: [
                  SelectOption<String>(value: 'scroll', label: 'Scroll'),
                  SelectOption<String>(value: 'ellipsis', label: 'Ellipsis'),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _overflowBehavior = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: FormSelectField<String>(
                label: 'Alignment',
                initialValue: _alignmentType,
                options: [
                  SelectOption<String>(value: 'start', label: 'Start'),
                  SelectOption<String>(value: 'center', label: 'Center'),
                  SelectOption<String>(value: 'end', label: 'End'),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _alignmentType = value;
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 200,
              child: FormSelectField<int?>(
                label: 'Max Visible Items',
                initialValue: _maxVisibleItems,
                options: [
                  const SelectOption<int?>(value: null, label: 'Show All'),
                  const SelectOption<int?>(value: 3, label: '3 Items'),
                  const SelectOption<int?>(value: 4, label: '4 Items'),
                  const SelectOption<int?>(value: 5, label: '5 Items'),
                ],
                onChanged: (value) {
                  setState(() {
                    _maxVisibleItems = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            SwitchInputWidget(
              label: 'Enable Scrolling',
              value: _enableScrolling,
              onChanged: (value) {
                setState(() {
                  _enableScrolling = value;
                });
              },
            ),
            SwitchInputWidget(
              label: 'Show Icons',
              value: _showIcons,
              onChanged: (value) {
                setState(() {
                  _showIcons = value;
                });
              },
            ),
            SwitchInputWidget(
              label: 'Clickable Items',
              value: _enableClickable,
              onChanged: (value) {
                setState(() {
                  _enableClickable = value;
                });
              },
            ),
            SwitchInputWidget(
              label: 'Show Tooltips',
              value: _showTooltips,
              onChanged: (value) {
                setState(() {
                  _showTooltips = value;
                });
              },
            ),
            SwitchInputWidget(
              label: 'Custom Style',
              value: _useCustomStyle,
              onChanged: (value) {
                setState(() {
                  _useCustomStyle = value;
                });
              },
            ),
            SwitchInputWidget(
              label: 'Background Colors',
              value: _showBackgroundColors,
              onChanged: (value) {
                setState(() {
                  _showBackgroundColors = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfiguredBreadcrumb() {
    // Configure separator based on selection
    Widget separator;
    switch (_separatorType) {
      case 'slash':
        separator = BreadcrumbSeparators.slash;
        break;
      case 'dot':
        separator =
            Builder(builder: (context) => BreadcrumbSeparators.dot(context));
        break;
      case 'text':
        separator = Builder(
            builder: (context) => BreadcrumbSeparators.text(context, '→'));
        break;
      case 'icon':
        separator = Builder(
            builder: (context) => BreadcrumbSeparators.icon(
                context, Icons.arrow_forward_ios,
                size: 12));
        break;
      case 'arrow':
      default:
        separator = Breadcrumb.arrowSeparator;
        break;
    }

    // Configure overflow behavior
    final OverflowBehavior overflowBehavior = _overflowBehavior == 'ellipsis'
        ? OverflowBehavior.ellipsis
        : OverflowBehavior.scroll;

    // Configure alignment
    MainAxisAlignment alignment;
    switch (_alignmentType) {
      case 'center':
        alignment = MainAxisAlignment.center;
        break;
      case 'end':
        alignment = MainAxisAlignment.end;
        break;
      case 'start':
      default:
        alignment = MainAxisAlignment.start;
        break;
    }

    // Configure items with optional icons and interactivity
    final List<BreadcrumbItem> items = [];
    for (int i = 0; i < _productPath.length; i++) {
      final isLast = i == _productPath.length - 1;

      items.add(
        BreadcrumbItem.text(
          _productPath[i],
          icon: _showIcons ? _getIconForItem(_productPath[i]) : null,
          isActive: isLast,
          onTap: _enableClickable && !isLast
              ? () => _showClickMessage(context, _productPath[i])
              : null,
          tooltip: _showTooltips ? 'Navigate to ${_productPath[i]}' : null,
        ),
      );
    }

    // Configure styling
    BreadcrumbStyle? style;
    if (_useCustomStyle) {
      style = BreadcrumbStyle(
        itemStyle: TextStyle(
          color: AppColors.neutral[600],
          fontSize: 14,
        ),
        activeItemStyle: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        itemBackgroundColor:
            _showBackgroundColors ? AppColors.neutral[100] : null,
        activeItemBackgroundColor: _showBackgroundColors
            ? AppColors.primary.withValues(alpha: 0.1)
            : null,
        itemPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBorderRadius: BorderRadius.circular(4),
        itemBorderColor: _showBackgroundColors ? AppColors.neutral[300] : null,
      );
    }

    // Build the configured breadcrumb
    return Breadcrumb(
      items: items,
      separator: separator,
      enableScrolling: _enableScrolling,
      maxVisibleItems: _maxVisibleItems,
      overflowBehavior: overflowBehavior,
      style: style,
      alignment: alignment,
    );
  }

  // Helper method for example breadcrumbs
  Breadcrumb _buildBasicBreadcrumb() {
    return Breadcrumb.fromStrings(
      labels: _filePath,
      separator: Breadcrumb.arrowSeparator,
      enableScrolling: true,
    );
  }

  Breadcrumb _buildItemsBreadcrumb() {
    return Breadcrumb(
      items: [
        BreadcrumbItem.text('Shop'),
        BreadcrumbItem.text('Electronics'),
        BreadcrumbItem.text('Computers'),
        BreadcrumbItem.text('Laptops', icon: Icons.laptop),
        BreadcrumbItem.text('Gaming', isActive: true),
      ],
    );
  }

  Breadcrumb _buildIconsBreadcrumb() {
    return Breadcrumb(
      items: [
        BreadcrumbItem.text('Home', icon: Icons.home),
        BreadcrumbItem.text('Settings', icon: Icons.settings),
        BreadcrumbItem.text('Account', icon: Icons.person),
        BreadcrumbItem.text('Security', icon: Icons.security, isActive: true),
      ],
    );
  }

  void _showClickMessage(BuildContext context, String item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $item'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  IconData? _getIconForItem(String item) {
    switch (item) {
      case 'Home':
        return Icons.home;
      case 'Shop':
        return Icons.shopping_cart;
      case 'Electronics':
        return Icons.devices;
      case 'Computers':
        return Icons.computer;
      case 'Laptops':
        return Icons.laptop;
      case 'Gaming':
        return Icons.sports_esports;
      default:
        return Icons.folder;
    }
  }
}

// Helper method to create AppCard if not already available
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const AppCard({
    super.key,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}
