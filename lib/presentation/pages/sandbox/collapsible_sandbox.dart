import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/layout/collapsible.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/forms/switch.dart';
import 'package:boilerplate/core/widgets/components/forms/select.dart';

class CollapsibleSandbox extends StatefulWidget {
  const CollapsibleSandbox({super.key});

  @override
  State<CollapsibleSandbox> createState() => _CollapsibleSandboxState();
}

class _CollapsibleSandboxState extends State<CollapsibleSandbox> {
  // Interactive playground state
  bool _playgroundInitialExpanded = false;
  CollapsibleAnimationType _playgroundAnimationType =
      CollapsibleAnimationType.sizeAndFade;
  ExpansionDirection _playgroundDirection = ExpansionDirection.down;
  IconPosition _playgroundIconPosition = IconPosition.end;
  TriggerInteractionMode _playgroundInteractionMode =
      TriggerInteractionMode.tap;
  bool _playgroundShowDivider = false;
  bool _playgroundEnabled = true;

  // Test controllers for monitoring collapsible state
  final CollapsibleController _testController1 = CollapsibleController();
  final CollapsibleController _testController2 = CollapsibleController();
  final CollapsibleController _testController3 = CollapsibleController();

  // Example content for reuse
  final String _loremIpsum =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl. Nullam euismod, nisl eget ultricies aliquam.';
  final String _longContent =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl. Nullam euismod, nisl eget ultricies aliquam. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl. Nullam euismod, nisl eget ultricies aliquam. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, nisl eget ultricies aliquam, nunc nisl aliquet nunc, quis aliquam nisl nunc quis nisl. Nullam euismod, nisl eget ultricies aliquam.';

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      debugPrint('[COLLAPSIBLE] SANDBOX initializing');
    }

    // Add listeners to test controllers
    _testController1.addListener(_handleTestController1);
    _testController2.addListener(_handleTestController2);
    _testController3.addListener(_handleTestController3);
  }

  void _handleTestController1() {
    if (kDebugMode) {
      debugPrint(
          '[COLLAPSIBLE] SANDBOX Test Controller 1 changed: isExpanded=${_testController1.isExpanded}');
    }
  }

  void _handleTestController2() {
    if (kDebugMode) {
      debugPrint(
          '[COLLAPSIBLE] SANDBOX Test Controller 2 changed: isExpanded=${_testController2.isExpanded}');
    }
  }

  void _handleTestController3() {
    if (kDebugMode) {
      debugPrint(
          '[COLLAPSIBLE] SANDBOX Test Controller 3 changed: isExpanded=${_testController3.isExpanded}');
    }
  }

  @override
  void dispose() {
    if (kDebugMode) {
      debugPrint('[COLLAPSIBLE] SANDBOX disposing');
    }

    _testController1.removeListener(_handleTestController1);
    _testController1.dispose();

    _testController2.removeListener(_handleTestController2);
    _testController2.dispose();

    _testController3.removeListener(_handleTestController3);
    _testController3.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      debugPrint('[COLLAPSIBLE] SANDBOX building');
    }

    return Scaffold(
      appBar: AppBar(
        title: const AppText('Collapsible Sandbox',
            variant: TextVariant.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            // Test instances
            _buildTestInstances(),
            const SizedBox(height: 32),

            // Basic examples
            _buildBasicExamples(),
            const SizedBox(height: 32),

            // Animation types
            _buildAnimationExamples(),
            const SizedBox(height: 32),

            // Special implementations
            _buildSpecialImplementations(),
            const SizedBox(height: 32),

            // Advanced features
            _buildAdvancedFeatures(),
            const SizedBox(height: 32),

            // Interactive playground
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
          'Collapsible Component',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          'Explore the various options and configurations of the Collapsible component.',
          variant: TextVariant.bodyLarge,
          color: AppColors.neutral[700],
        ),
      ],
    );
  }

  Widget _buildTestInstances() {
    return _buildSection(
      'Test Instances',
      'Various test collapsibles for debugging and validation.',
      [
        _buildExampleCard(
          'Controlled Collapsible',
          'Using an external controller to track state changes.',
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _testController1.expand();
                    },
                    child: const Text('Expand'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _testController1.collapse();
                    },
                    child: const Text('Collapse'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Controller Test 1'),
                ),
                content: Text(
                    'Controller ID: ${_testController1.debugId}\n$_loremIpsum'),
                controller: _testController1,
                onExpansionChanged: (expanded) {
                  if (kDebugMode) {
                    debugPrint(
                        '[COLLAPSIBLE] SANDBOX Test 1 expansion changed: $expanded');
                  }
                },
              ),
            ],
          ),
          '''
// Create a controller
final controller = CollapsibleController();

// Add listener in initState
controller.addListener(() {
  debugPrint('Controller changed: \${controller.isExpanded}');
});

// Use with a collapsible
AppCollapsibleSection(
  title: Text('Controller Test'),
  content: Text('...'),
  controller: controller,
  onExpansionChanged: (expanded) {
    debugPrint('Expansion changed: \$expanded');
  },
),

// Cleanup in dispose
controller.removeListener(handleControllerChange);
controller.dispose();
''',
        ),
        _buildExampleCard(
          'Nested Collapsibles',
          'Testing proper context and scope for nested components.',
          AppCollapsibleSection(
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Parent Collapsible'),
            ),
            content: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Parent content'),
                  const SizedBox(height: 16),
                  AppCollapsibleSection(
                    title: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Child Collapsible'),
                    ),
                    content: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text('Child content'),
                          const SizedBox(height: 16),
                          AppCollapsibleSection(
                            title: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text('Grandchild Collapsible'),
                            ),
                            content: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(_loremIpsum),
                            ),
                            controller: _testController2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            controller: _testController3,
          ),
          '''
// Nested collapsibles with proper scope
AppCollapsibleSection(
  title: Text('Parent Collapsible'),
  content: Column(
    children: [
      Text('Parent content'),
      AppCollapsibleSection(
        title: Text('Child Collapsible'),
        content: Column(
          children: [
            Text('Child content'),
            AppCollapsibleSection(
              title: Text('Grandchild Collapsible'),
              content: Text('...'),
            ),
          ],
        ),
      ),
    ],
  ),
),
''',
        ),
        _buildExampleCard(
          'Raw Collapsible Components',
          'Using the basic components directly',
          AppCollapsible(
            children: [
              AppCollapsibleTrigger(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.neutral[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Text('Raw Collapsible Components',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              AppCollapsibleContent(
                padding: const EdgeInsets.all(16),
                child: Text(_loremIpsum),
              ),
            ],
          ),
          '''
// Using raw components directly
AppCollapsible(
  children: [
    AppCollapsibleTrigger(
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.neutral[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text('Raw Collapsible Components'),
            Spacer(),
            Icon(Icons.keyboard_arrow_down),
          ],
        ),
      ),
    ),
    AppCollapsibleContent(
      padding: EdgeInsets.all(16),
      child: Text('Lorem ipsum...'),
    ),
  ],
),
''',
        ),
      ],
    );
  }

  Widget _buildBasicExamples() {
    return _buildSection(
      'Basic Examples',
      'Standard collapsible widgets with different configurations.',
      [
        _buildExampleCard(
          'Basic Collapsible',
          'Standard collapsible with trigger and content.',
          AppCollapsible(
            children: [
              AppCollapsibleTrigger(
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Click to expand/collapse',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              AppCollapsibleContent(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(_loremIpsum),
                ),
              ),
            ],
          ),
          '''
AppCollapsible(
  children: [
    AppCollapsibleTrigger(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Click to expand/collapse',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ),
    AppCollapsibleContent(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Lorem ipsum...'),
      ),
    ),
  ],
)''',
        ),
        _buildExampleCard(
          'Pre-built Section',
          'Using the AppCollapsibleSection for simpler implementation.',
          AppCollapsibleSection(
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Collapsible Section',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(_loremIpsum),
            ),
            showDivider: true,
          ),
          '''
AppCollapsibleSection(
  title: Text('Collapsible Section', 
    style: TextStyle(fontWeight: FontWeight.bold)),
  content: Text('Lorem ipsum...'),
  showDivider: true,
)''',
        ),
        _buildExampleCard(
          'Initial Expanded State',
          'Starting in expanded state.',
          AppCollapsibleSection(
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Initially Expanded',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(_loremIpsum),
            ),
            initialExpanded: true,
          ),
          '''
AppCollapsibleSection(
  title: Text('Initially Expanded'),
  content: Text('Lorem ipsum...'),
  initialExpanded: true,
)''',
        ),
        _buildExampleCard(
          'Icon Positions',
          'Different placements for the expand/collapse icon.',
          Column(
            children: [
              const AppText('Icon at End (Default)',
                  variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Icon at End'),
                ),
                content: Text(_loremIpsum),
                iconPosition: IconPosition.end,
              ),
              const SizedBox(height: 16),
              const AppText('Icon at Start', variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Icon at Start'),
                ),
                content: Text(_loremIpsum),
                iconPosition: IconPosition.start,
              ),
            ],
          ),
          '''
// Icon at End (Default)
AppCollapsibleSection(
  title: Text('Icon at End'),
  content: Text('Lorem ipsum...'),
  iconPosition: IconPosition.end,
)

// Icon at Start
AppCollapsibleSection(
  title: Text('Icon at Start'),
  content: Text('Lorem ipsum...'),
  iconPosition: IconPosition.start,
)''',
        ),
      ],
    );
  }

  Widget _buildAnimationExamples() {
    return _buildSection(
      'Animation Types',
      'Different animation styles for expanding and collapsing content.',
      [
        _buildExampleCard(
          'Size and Fade (Default)',
          'Animates both size and opacity.',
          AppCollapsibleSection(
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Size and Fade Animation'),
            ),
            content: Text(_loremIpsum),
            theme: const CollapsibleTheme(
              animationType: CollapsibleAnimationType.sizeAndFade,
            ),
            onExpansionChanged: (expanded) {
              if (kDebugMode) {
                debugPrint(
                    '[COLLAPSIBLE] SANDBOX Size and Fade animation expanded: $expanded');
              }
            },
          ),
          '''
AppCollapsibleSection(
  title: Text('Size and Fade Animation'),
  content: Text('Lorem ipsum...'),
  theme: const CollapsibleTheme(
    animationType: CollapsibleAnimationType.sizeAndFade,
  ),
)''',
        ),
        _buildExampleCard(
          'Size Only',
          'Animates only the size, without fading.',
          AppCollapsibleSection(
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Size Only Animation'),
            ),
            content: Text(_loremIpsum),
            theme: const CollapsibleTheme(
              animationType: CollapsibleAnimationType.sizeOnly,
            ),
          ),
          '''
AppCollapsibleSection(
  title: Text('Size Only Animation'),
  content: Text('Lorem ipsum...'),
  theme: const CollapsibleTheme(
    animationType: CollapsibleAnimationType.sizeOnly,
  ),
)''',
        ),
        _buildExampleCard(
          'Directional Slides',
          'Slide in/out from different directions.',
          Column(
            children: [
              const AppText('Slide From Top', variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Slide From Top'),
                ),
                content: Text(_loremIpsum),
                theme: const CollapsibleTheme(
                  animationType: CollapsibleAnimationType.slideFromTop,
                ),
              ),
              const SizedBox(height: 16),
              const AppText('Slide From Left', variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Slide From Left'),
                ),
                content: Text(_loremIpsum),
                theme: const CollapsibleTheme(
                  animationType: CollapsibleAnimationType.slideFromLeft,
                ),
              ),
            ],
          ),
          '''
// Slide From Top
AppCollapsibleSection(
  title: Text('Slide From Top'),
  content: Text('Lorem ipsum...'),
  theme: const CollapsibleTheme(
    animationType: CollapsibleAnimationType.slideFromTop,
  ),
)

// Slide From Left
AppCollapsibleSection(
  title: Text('Slide From Left'),
  content: Text('Lorem ipsum...'),
  theme: const CollapsibleTheme(
    animationType: CollapsibleAnimationType.slideFromLeft,
  ),
)''',
        ),
        _buildExampleCard(
          'Scale and Rotate',
          'More dramatic animations for emphasis.',
          Column(
            children: [
              const AppText('Scale Animation', variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Scale Animation'),
                ),
                content: Text(_loremIpsum),
                theme: const CollapsibleTheme(
                  animationType: CollapsibleAnimationType.scale,
                ),
              ),
              const SizedBox(height: 16),
              const AppText('Rotate Animation', variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Rotate Animation'),
                ),
                content: Text(_loremIpsum),
                theme: const CollapsibleTheme(
                  animationType: CollapsibleAnimationType.rotate,
                ),
              ),
            ],
          ),
          '''
// Scale Animation
AppCollapsibleSection(
  title: Text('Scale Animation'),
  content: Text('Lorem ipsum...'),
  theme: const CollapsibleTheme(
    animationType: CollapsibleAnimationType.scale,
  ),
)

// Rotate Animation
AppCollapsibleSection(
  title: Text('Rotate Animation'),
  content: Text('Lorem ipsum...'),
  theme: const CollapsibleTheme(
    animationType: CollapsibleAnimationType.rotate,
  ),
)''',
        ),
      ],
    );
  }

  Widget _buildSpecialImplementations() {
    return _buildSection(
      'Special Implementations',
      'Pre-built collapsible components for specific use cases.',
      [
        _buildExampleCard(
          'Expandable Text',
          'Text that expands when truncated.',
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: AppExpandableText(
              text: _longContent,
              maxLines: 2,
              expandText: 'Show more',
              collapseText: 'Show less',
            ),
          ),
          '''
AppExpandableText(
  text: 'Lorem ipsum dolor sit amet...',
  maxLines: 2,
  expandText: 'Show more',
  collapseText: 'Show less',
)''',
        ),
        _buildExampleCard(
          'Interaction Modes',
          'Different ways to trigger expansion',
          Column(
            children: [
              const AppText('Hover Interaction',
                  variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Hover to Expand'),
                ),
                content: Text(_loremIpsum),
                interactionMode: TriggerInteractionMode.hover,
              ),
              const SizedBox(height: 16),
              const AppText('Long Press Interaction',
                  variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Long Press to Expand'),
                ),
                content: Text(_loremIpsum),
                interactionMode: TriggerInteractionMode.longPress,
              ),
              const SizedBox(height: 16),
              const AppText('Double Tap Interaction',
                  variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsibleSection(
                title: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('Double Tap to Expand'),
                ),
                content: Text(_loremIpsum),
                interactionMode: TriggerInteractionMode.doubleTap,
              ),
            ],
          ),
          '''
// Hover Interaction
AppCollapsibleSection(
  title: Text('Hover to Expand'),
  content: Text('Lorem ipsum...'),
  interactionMode: TriggerInteractionMode.hover,
)

// Long Press Interaction
AppCollapsibleSection(
  title: Text('Long Press to Expand'),
  content: Text('Lorem ipsum...'),
  interactionMode: TriggerInteractionMode.longPress,
)

// Double Tap Interaction
AppCollapsibleSection(
  title: Text('Double Tap to Expand'),
  content: Text('Lorem ipsum...'),
  interactionMode: TriggerInteractionMode.doubleTap,
)''',
        ),
        _buildExampleCard(
          'Collapsible Card',
          'Card with collapsible content and hover effects.',
          AppCollapsibleCard(
            title: const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Collapsible Card Title',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            content: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_loremIpsum),
            ),
            elevateOnHover: true,
          ),
          '''
AppCollapsibleCard(
  title: Text('Collapsible Card Title', 
    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  content: Text('Lorem ipsum...'),
  elevateOnHover: true,
)''',
        ),
        _buildExampleCard(
          'Draggable Collapsible',
          'Panel that can be expanded by dragging.',
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: AppDraggableCollapsible(
                header: const Center(
                  child: Text('Drag Me Up/Down',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                content: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Draggable Content'),
                      const SizedBox(height: 16),
                      Text(_loremIpsum),
                    ],
                  ),
                ),
                minHeight: 80,
                maxHeight: 250,
                showDragHandle: true,
                onProgressChanged: (progress) {
                  if (kDebugMode) {
                    debugPrint(
                        '[COLLAPSIBLE] SANDBOX Draggable progress: $progress');
                  }
                },
              ),
            ),
          ),
          '''
AppDraggableCollapsible(
  header: Center(
    child: Text('Drag Me Up/Down', 
      style: TextStyle(fontWeight: FontWeight.bold)),
  ),
  content: Text('Draggable Content...'),
  minHeight: 80,
  maxHeight: 250,
  showDragHandle: true,
  onProgressChanged: (progress) {
    debugPrint('Dragging progress: \$progress');
  },
)''',
        ),
      ],
    );
  }

  Widget _buildAdvancedFeatures() {
    // Create a controller for programmatic control
    final controller = CollapsibleController();

    return _buildSection(
      'Advanced Features',
      'More complex behaviors and customizations.',
      [
        _buildExampleCard(
          'Custom Theme',
          'Styled collapsible with custom colors and borders.',
          AppCollapsibleSection(
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Custom Themed Collapsible',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            content: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_loremIpsum),
            ),
            theme: CollapsibleTheme(
              triggerBackgroundColor: AppColors.accent.withValues(alpha: 0.1),
              contentBackgroundColor: AppColors.neutral[50],
              expandedIconColor: AppColors.accent,
              collapsedIconColor: AppColors.accent,
              triggerBorderRadius: BorderRadius.circular(8),
              contentBorderRadius: BorderRadius.circular(8),
              contentBorder:
                  Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
              triggerBorder: Border.all(color: AppColors.accent),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          '''
AppCollapsibleSection(
  title: Text('Custom Themed Collapsible'),
  content: Text('Lorem ipsum...'),
  theme: CollapsibleTheme(
    triggerBackgroundColor: AppColors.accent.withValues(alpha:0.1),
    contentBackgroundColor: AppColors.neutral[50],
    expandedIconColor: AppColors.accent,
    collapsedIconColor: AppColors.accent,
    triggerBorderRadius: BorderRadius.circular(8),
    contentBorderRadius: BorderRadius.circular(8),
    contentBorder: Border.all(color: AppColors.accent.withValues(alpha:0.3)),
    triggerBorder: Border.all(color: AppColors.accent),
    contentPadding: EdgeInsets.zero,
  ),
)''',
        ),
        _buildExampleCard(
          'Custom Icon Builder',
          'Using custom icons for expanded and collapsed states.',
          AppCollapsibleSection(
            title: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Custom Icons',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            content: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_loremIpsum),
            ),
            iconBuilder: (context, isExpanded) {
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      isExpanded ? AppColors.primary : AppColors.neutral[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  isExpanded ? Icons.remove : Icons.add,
                  color: isExpanded ? Colors.white : AppColors.neutral[800],
                  size: 16,
                ),
              );
            },
          ),
          '''
AppCollapsibleSection(
  title: Text('Custom Icons'),
  content: Text('Lorem ipsum...'),
  iconBuilder: (context, isExpanded) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isExpanded ? AppColors.primary : AppColors.neutral[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        isExpanded ? Icons.remove : Icons.add,
        color: isExpanded ? Colors.white : AppColors.neutral[800],
        size: 16,
      ),
    );
  },
)''',
        ),
        _buildExampleCard(
          'Programmatic Control',
          'Using a controller to manage collapsible state.',
          StatefulBuilder(builder: (context, setState) {
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (kDebugMode) {
                          debugPrint(
                              '[COLLAPSIBLE] SANDBOX Programmatically expanding');
                        }
                        controller.expand();
                        setState(() {});
                      },
                      child: const Text('Expand'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (kDebugMode) {
                          debugPrint(
                              '[COLLAPSIBLE] SANDBOX Programmatically collapsing');
                        }
                        controller.collapse();
                        setState(() {});
                      },
                      child: const Text('Collapse'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppCollapsibleSection(
                  title: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Controller Status: ${controller.isExpanded ? "Expanded" : "Collapsed"}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  content: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_loremIpsum),
                  ),
                  controller: controller,
                  onExpansionChanged: (expanded) {
                    if (kDebugMode) {
                      debugPrint(
                          '[COLLAPSIBLE] SANDBOX Controlled example expansion changed: $expanded');
                    }
                    setState(() {});
                  },
                ),
              ],
            );
          }),
          '''
// Create a controller
final controller = CollapsibleController();

// Use buttons to control expansion
ElevatedButton(
  onPressed: () => controller.expand(),
  child: Text('Expand'),
),
ElevatedButton(
  onPressed: () => controller.collapse(),
  child: Text('Collapse'),
),

// Apply controller to collapsible
AppCollapsibleSection(
  title: Text('Controlled Collapsible'),
  content: Text('Content...'),
  controller: controller,
)''',
        ),
        _buildExampleCard(
          'Different Interaction Modes',
          'Triggering expansion with different interactions.',
          Column(
            children: [
              const AppText('Hover Interaction',
                  variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsible(
                interactionMode: TriggerInteractionMode.hover,
                children: [
                  AppCollapsibleTrigger(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Hover to expand',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  AppCollapsibleContent(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_loremIpsum),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AppText('Long Press Interaction',
                  variant: TextVariant.bodySmall),
              const SizedBox(height: 8),
              AppCollapsible(
                interactionMode: TriggerInteractionMode.longPress,
                children: [
                  AppCollapsibleTrigger(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Long press to expand',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  AppCollapsibleContent(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_loremIpsum),
                    ),
                  ),
                ],
              ),
            ],
          ),
          '''
// Hover Interaction
AppCollapsible(
  interactionMode: TriggerInteractionMode.hover,
  children: [
    AppCollapsibleTrigger(
      child: Text('Hover to expand'),
    ),
    AppCollapsibleContent(
      child: Text('Content...'),
    ),
  ],
)

// Long Press Interaction
AppCollapsible(
  interactionMode: TriggerInteractionMode.longPress,
  children: [
    AppCollapsibleTrigger(
      child: Text('Long press to expand'),
    ),
    AppCollapsibleContent(
      child: Text('Content...'),
    ),
  ],
)''',
        ),
      ],
    );
  }

  Widget _buildPlayground() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Interactive Playground',
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 8),
        AppText(
          'Experiment with different collapsible configurations in real-time.',
          variant: TextVariant.bodyMedium,
          color: AppColors.neutral[700],
        ),
        const SizedBox(height: 16),
        _buildCard(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildConfigControls(),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.all(24),
                color: AppColors.neutral[50],
                child: _buildConfiguredCollapsible(),
              ),
              const Divider(height: 1),
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.neutral[900],
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: AppText(
                    _generatePlaygroundCode(),
                    variant: TextVariant.bodySmall,
                    color: AppColors.neutral[200],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Configuration Controls',
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            SizedBox(
              width: 180,
              child: FormSelectField<CollapsibleAnimationType>(
                label: 'Animation Type',
                initialValue: _playgroundAnimationType,
                options: [
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.sizeAndFade,
                    label: 'Size and Fade',
                  ),
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.sizeOnly,
                    label: 'Size Only',
                  ),
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.fadeOnly,
                    label: 'Fade Only',
                  ),
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.slideFromTop,
                    label: 'Slide From Top',
                  ),
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.slideFromBottom,
                    label: 'Slide From Bottom',
                  ),
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.slideFromLeft,
                    label: 'Slide From Left',
                  ),
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.slideFromRight,
                    label: 'Slide From Right',
                  ),
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.scale,
                    label: 'Scale',
                  ),
                  const SelectOption<CollapsibleAnimationType>(
                    value: CollapsibleAnimationType.rotate,
                    label: 'Rotate',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _playgroundAnimationType = value;
                      if (kDebugMode) {
                        debugPrint(
                            '[COLLAPSIBLE] SANDBOX Animation type changed: $value');
                      }
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: FormSelectField<ExpansionDirection>(
                label: 'Expansion Direction',
                initialValue: _playgroundDirection,
                options: [
                  const SelectOption<ExpansionDirection>(
                    value: ExpansionDirection.down,
                    label: 'Down',
                  ),
                  const SelectOption<ExpansionDirection>(
                    value: ExpansionDirection.up,
                    label: 'Up',
                  ),
                  const SelectOption<ExpansionDirection>(
                    value: ExpansionDirection.left,
                    label: 'Left',
                  ),
                  const SelectOption<ExpansionDirection>(
                    value: ExpansionDirection.right,
                    label: 'Right',
                  ),
                  const SelectOption<ExpansionDirection>(
                    value: ExpansionDirection.center,
                    label: 'Center',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _playgroundDirection = value;
                      if (kDebugMode) {
                        debugPrint(
                            '[COLLAPSIBLE] SANDBOX Direction changed: $value');
                      }
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: FormSelectField<IconPosition>(
                label: 'Icon Position',
                initialValue: _playgroundIconPosition,
                options: [
                  const SelectOption<IconPosition>(
                    value: IconPosition.start,
                    label: 'Start',
                  ),
                  const SelectOption<IconPosition>(
                    value: IconPosition.end,
                    label: 'End',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _playgroundIconPosition = value;
                      if (kDebugMode) {
                        debugPrint(
                            '[COLLAPSIBLE] SANDBOX Icon position changed: $value');
                      }
                    });
                  }
                },
              ),
            ),
            SizedBox(
              width: 180,
              child: FormSelectField<TriggerInteractionMode>(
                label: 'Interaction Mode',
                initialValue: _playgroundInteractionMode,
                options: [
                  const SelectOption<TriggerInteractionMode>(
                    value: TriggerInteractionMode.tap,
                    label: 'Tap',
                  ),
                  const SelectOption<TriggerInteractionMode>(
                    value: TriggerInteractionMode.hover,
                    label: 'Hover',
                  ),
                  const SelectOption<TriggerInteractionMode>(
                    value: TriggerInteractionMode.longPress,
                    label: 'Long Press',
                  ),
                  const SelectOption<TriggerInteractionMode>(
                    value: TriggerInteractionMode.doubleTap,
                    label: 'Double Tap',
                  ),
                  const SelectOption<TriggerInteractionMode>(
                    value: TriggerInteractionMode.drag,
                    label: 'Drag',
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _playgroundInteractionMode = value;
                      if (kDebugMode) {
                        debugPrint(
                            '[COLLAPSIBLE] SANDBOX Interaction mode changed: $value');
                      }
                    });
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            SwitchInputWidget(
              label: 'Initially Expanded',
              value: _playgroundInitialExpanded,
              onChanged: (value) {
                setState(() {
                  _playgroundInitialExpanded = value;
                  if (kDebugMode) {
                    debugPrint(
                        '[COLLAPSIBLE] SANDBOX Initial expanded changed: $value');
                  }
                });
              },
            ),
            SwitchInputWidget(
              label: 'Show Divider',
              value: _playgroundShowDivider,
              onChanged: (value) {
                setState(() {
                  _playgroundShowDivider = value;
                  if (kDebugMode) {
                    debugPrint(
                        '[COLLAPSIBLE] SANDBOX Show divider changed: $value');
                  }
                });
              },
            ),
            SwitchInputWidget(
              label: 'Enabled',
              value: _playgroundEnabled,
              onChanged: (value) {
                setState(() {
                  _playgroundEnabled = value;
                  if (kDebugMode) {
                    debugPrint('[COLLAPSIBLE] SANDBOX Enabled changed: $value');
                  }
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfiguredCollapsible() {
    // Create a theme based on playground options
    final theme = CollapsibleTheme(
      animationType: _playgroundAnimationType,
      expansionDirection: _playgroundDirection,
      triggerBorderRadius: BorderRadius.circular(8),
      contentBorderRadius: BorderRadius.circular(8),
      contentPadding: const EdgeInsets.all(16),
      triggerPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      contentBackgroundColor: Colors.white,
      triggerBackgroundColor: AppColors.neutral[100],
    );

    // Use AppCollapsibleSection for consistent appearance with other examples
    return AppCollapsibleSection(
      initialExpanded: _playgroundInitialExpanded,
      theme: theme,
      showDivider: _playgroundShowDivider,
      enabled: _playgroundEnabled,
      interactionMode: _playgroundInteractionMode,
      iconPosition: _playgroundIconPosition,
      title: const Text(
        'Playground Collapsible',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(_loremIpsum),
      onExpansionChanged: (expanded) {
        if (kDebugMode) {
          debugPrint(
              '[COLLAPSIBLE] SANDBOX Playground expansion changed: $expanded');
        }
      },
    );
  }

  String _generatePlaygroundCode() {
    final StringBuffer code = StringBuffer();

    code.writeln('AppCollapsibleSection(');
    code.writeln('  title: Text(\'Playground Collapsible\'),');
    code.writeln('  content: Text(\'Lorem ipsum...\'),');

    if (_playgroundInitialExpanded) {
      code.writeln('  initialExpanded: true,');
    }

    if (_playgroundShowDivider) {
      code.writeln('  showDivider: true,');
    }

    if (_playgroundIconPosition != IconPosition.end) {
      code.writeln(
          '  iconPosition: IconPosition.${_playgroundIconPosition.toString().split('.').last},');
    }

    if (!_playgroundEnabled) {
      code.writeln('  enabled: false,');
    }

    if (_playgroundInteractionMode != TriggerInteractionMode.tap) {
      code.writeln(
          '  interactionMode: TriggerInteractionMode.${_playgroundInteractionMode.toString().split('.').last},');
    }

    code.writeln('  theme: CollapsibleTheme(');
    code.writeln(
        '    animationType: CollapsibleAnimationType.${_playgroundAnimationType.toString().split('.').last},');
    code.writeln(
        '    expansionDirection: ExpansionDirection.${_playgroundDirection.toString().split('.').last},');
    code.writeln('    triggerBorderRadius: BorderRadius.circular(8),');
    code.writeln('    contentBorderRadius: BorderRadius.circular(8),');
    code.writeln('    contentPadding: EdgeInsets.all(16),');
    code.writeln(
        '    triggerPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),');
    code.writeln('    contentBackgroundColor: Colors.white,');
    code.writeln('    triggerBackgroundColor: AppColors.neutral[100],');
    code.writeln('  ),');

    code.writeln(')');

    return code.toString();
  }

  Widget _buildSection(
      String title, String description, List<Widget> examples) {
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

  Widget _buildExampleCard(
    String title,
    String description,
    Widget content,
    String codeSnippet,
  ) {
    return _buildCard(
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
                const SizedBox(height: 4),
                AppText(
                  description,
                  variant: TextVariant.bodySmall,
                  color: AppColors.neutral[600],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.neutral[50],
            child: content,
          ),
          const Divider(height: 1),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.neutral[900],
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: AppText(
                codeSnippet,
                variant: TextVariant.bodySmall,
                color: AppColors.neutral[200],
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child, EdgeInsetsGeometry? margin}) {
    return Container(
      width: double.infinity,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
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
