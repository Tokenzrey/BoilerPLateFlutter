import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';

class PopoverSandbox extends StatefulWidget {
  const PopoverSandbox({super.key});

  @override
  State<PopoverSandbox> createState() => _PopoverSandboxState();
}

class _PopoverSandboxState extends State<PopoverSandbox> {
  // Controllers
  final _scrollController = ScrollController();
  final _popoverController = PopoverController();
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);
  final Map<String, LayerLink> _links = {};

  // Theme constants
  static const _cardBorderRadius = 16.0;
  static const _buttonBorderRadius = 8.0;
  static const _sectionSpacing = 24.0;
  static const _cardPadding = 16.0;
  static const _buttonSpacing = 12.0;
  static const _popoverOffset = 16.0;
  static const _contentPadding = 20.0;
  static const _featureBoxPadding = 8.0;

  // Grid layout constants
  static const _maxGridCrossAxisCount = 3;
  static const _minTileWidth = 120.0;

  // Colors
  late final _primaryColor = Colors.indigo;
  late final _secondaryColor = Colors.teal.shade700;
  late final _cardColor = Colors.white;
  late final _sectionTitleColor = Colors.blueGrey.shade800;
  late final _sectionDescriptionColor = Colors.blueGrey.shade600;
  late final _featureBoxBgColor = Colors.grey.shade50;
  late final _featureBoxBorderColor = Colors.grey.shade200;

  // Text styles
  late final _sectionTitleStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: _sectionTitleColor,
    height: 1.2,
  );

  late final _sectionDescriptionStyle = TextStyle(
    fontSize: 14,
    color: _sectionDescriptionColor,
    height: 1.4,
  );

  late final _popoverTitleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: _primaryColor,
  );

  late final _popoverBodyStyle = const TextStyle(fontSize: 13);
  late final _popoverFeatureStyle = TextStyle(
    fontSize: 13,
    color: _sectionDescriptionColor,
  );

  // Animation examples data - moved outside build method for performance
  final List<AnimationExample> _animationExamples = [
    AnimationExample(
      title: 'Fade',
      description: 'Simple fade transition',
      enterAnimations: [PopoverAnimationType.fadeIn],
      exitAnimations: [PopoverAnimationType.fadeOut],
    ),
    AnimationExample(
      title: 'Scale',
      description: 'Grow from center',
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.scale
      ],
      exitAnimations: [
        PopoverAnimationType.fadeOut,
        PopoverAnimationType.scale
      ],
      initialScale: 0.7,
    ),
    AnimationExample(
      title: 'Slide Up',
      description: 'Move from bottom',
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.slideUp
      ],
      exitAnimations: [
        PopoverAnimationType.fadeOut,
        PopoverAnimationType.slideDown
      ],
      slideBegin: const Offset(0, 30),
    ),
    AnimationExample(
      title: 'Bounce',
      description: 'Elastic entrance',
      enterAnimations: [
        PopoverAnimationType.scale
      ], // Removed fadeIn - we'll handle it manually
      exitAnimations: [
        PopoverAnimationType.fadeOut,
        PopoverAnimationType.scale
      ],
      enterDuration: const Duration(milliseconds: 500),
      enterCurve: Curves.elasticOut,
      initialScale: 0.5,
      isSpecial: true,
      useSafeOpacity: true, // Flag to handle opacity separately
    ),
    AnimationExample(
      title: 'Rotate',
      description: 'Spin effect',
      enterAnimations: [
        PopoverAnimationType.rotate
      ], // Removed fadeIn - we'll handle it manually
      exitAnimations: [
        PopoverAnimationType.fadeOut,
        PopoverAnimationType.scale
      ],
      rotateBegin: 0.3,
      transformOrigin: Alignment.center,
      useSafeOpacity: true, // Flag to handle opacity separately
    ),
    AnimationExample(
      title: 'Skew',
      description: 'Perspective tilt',
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.skewX
      ],
      exitAnimations: [
        PopoverAnimationType.fadeOut,
        PopoverAnimationType.skewX
      ],
      skewXBegin: -0.3,
      isSpecial: true,
    ),
    AnimationExample(
      title: 'Fast In',
      description: 'Quick entry',
      enterDuration: const Duration(milliseconds: 150),
      exitDuration: const Duration(milliseconds: 350),
      enterCurve: Curves.easeOutQuart,
    ),
    AnimationExample(
      title: 'Combo',
      description: 'Multiple effects',
      enterAnimations: [
        PopoverAnimationType.scale,
        PopoverAnimationType.rotate,
      ], // Removed fadeIn - we'll handle it manually
      exitAnimations: [
        PopoverAnimationType.fadeOut,
        PopoverAnimationType.slideDown,
      ],
      enterDuration: const Duration(milliseconds: 450),
      initialScale: 0.6,
      rotateBegin: 0.2,
      isSpecial: true,
      useSafeOpacity: true, // Flag to handle opacity separately
    ),
    AnimationExample(
      title: 'Custom',
      description: 'Your own effect',
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.slideRight
      ],
      exitAnimations: [
        PopoverAnimationType.fadeOut,
        PopoverAnimationType.slideLeft
      ],
      enterCurve: Curves.fastOutSlowIn,
      slideBegin: const Offset(-30, 0),
    ),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _counter.dispose();
    _popoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        _buildHeader(),
        const SizedBox(height: 32),

        // Basic popovers section
        _buildSection(
          title: 'Basic Popovers',
          description: 'Simple popover examples with various configurations',
          children: [
            _buildResponsiveWrap(
              children: [
                Builder(
                  builder: (ctx) => _buildDemoButton(
                    label: 'Simple Popover',
                    description: 'Default configuration',
                    icon: Icons.touch_app,
                    onPressed: () => _showBasicPopover(ctx),
                  ),
                ),
                Builder(
                  builder: (ctx) => _buildDemoButton(
                    label: 'Return Result',
                    description: 'Passes data back',
                    icon: Icons.keyboard_return,
                    onPressed: () => _showPopoverWithResult(ctx),
                    color: _secondaryColor,
                  ),
                ),
                Builder(
                  builder: (ctx) => _buildDemoButton(
                    label: 'Modal Popover',
                    description: 'Blocks background',
                    icon: Icons.border_all,
                    onPressed: () => _showBasicPopover(
                      ctx,
                      modal: true,
                      alignment: Alignment.center,
                    ),
                    color: _secondaryColor,
                  ),
                ),
                Builder(
                  builder: (ctx) => _buildDemoButton(
                    label: 'Barrier Dismiss',
                    description: 'Tap outside to close',
                    icon: Icons.highlight_off,
                    onPressed: () => _showBasicPopover(
                      ctx,
                      modal: true,
                      barrierDismissable: true,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Positioning section
        _buildSection(
          title: 'Positioning',
          description: 'Alignment, inversion, and positioning options',
          children: [
            _buildAlignmentGrid(),
            const SizedBox(height: 16),
            _buildResponsiveWrap(
              children: [
                Builder(
                  builder: (ctx) => _buildDemoButton(
                    label: 'Screen Edge Inversion',
                    description: 'Try near screen edges',
                    icon: Icons.swap_horiz,
                    onPressed: () => _showBasicPopover(
                      ctx,
                      allowInvertHorizontal: true,
                      allowInvertVertical: true,
                      alignment: Alignment.topLeft,
                    ),
                    color: _secondaryColor,
                  ),
                ),
                Builder(
                  builder: (ctx) => _buildDemoButton(
                    label: 'Fixed Position',
                    description: 'Won\'t follow anchor',
                    icon: Icons.pin_drop,
                    onPressed: () => _showBasicPopover(
                      ctx,
                      follow: false,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Scroll behavior section
        _buildSection(
          title: 'Scrolling Behavior',
          description: 'Control how popovers behave during scrolling',
          children: [
            _buildResponsiveWrap(
              children: [
                Builder(
                  builder: (ctx) => _buildDemoButton(
                    label: 'Stay Visible',
                    description: 'Remains on scroll',
                    icon: Icons.visibility,
                    onPressed: () => _showBasicPopover(
                      ctx,
                      stayVisibleOnScroll: true,
                    ),
                  ),
                ),
                Builder(
                  builder: (ctx) => _buildDemoButton(
                    label: 'Auto Close',
                    description: 'Closes on scroll away',
                    icon: Icons.visibility_off,
                    onPressed: () => _showBasicPopover(
                      ctx,
                      stayVisibleOnScroll: false,
                    ),
                    color: _secondaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildScrollTestArea(),
          ],
        ),

        // Size constraints section
        _buildSection(
          title: 'Size Constraints',
          description: 'Different ways to control popover dimensions',
          children: [
            _buildResponsiveWrap(
              children: [
                Builder(
                  builder: (ctx) => _buildConstraintButton(
                    ctx,
                    label: 'Flexible',
                    description: 'Adjusts to content',
                    constraint: PopoverConstraint.flexible,
                  ),
                ),
                Builder(
                  builder: (ctx) => _buildConstraintButton(
                    ctx,
                    label: 'Intrinsic',
                    description: 'Tight to content',
                    constraint: PopoverConstraint.intrinsic,
                  ),
                ),
                Builder(
                  builder: (ctx) => _buildConstraintButton(
                    ctx,
                    label: 'Fixed Size',
                    description: '200×150 size',
                    constraint: PopoverConstraint.fixed,
                    fixedSize: const Size(200, 150),
                  ),
                ),
                Builder(
                  builder: (ctx) => _buildConstraintButton(
                    ctx,
                    label: 'Full Screen',
                    description: 'Maximum size',
                    constraint: PopoverConstraint.fullScreen,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Controller API section
        _buildSection(
          title: 'Controller API',
          description:
              'Manage popovers programmatically using PopoverController',
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildDemoButton(
                    label: 'Show Multiple',
                    description: 'Three coordinated popovers',
                    icon: Icons.layers,
                    onPressed: () => _showControlledPopovers(),
                    color: _secondaryColor,
                  ),
                ),
                const SizedBox(width: _buttonSpacing),
                Expanded(
                  child: _buildDemoButton(
                    label: 'Close All',
                    description: 'Via controller',
                    icon: Icons.close,
                    onPressed: () => _popoverController.close(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: _buttonSpacing),
            Row(
              children: [
                Expanded(
                  child: _buildDemoButton(
                    label: 'Change Animation',
                    description: 'Modify all popovers',
                    icon: Icons.animation,
                    onPressed: () => _popoverController.setEnterAnimation(
                      [
                        PopoverAnimationType.fadeIn,
                        PopoverAnimationType.rotate
                      ],
                      duration: const Duration(milliseconds: 600),
                    ),
                  ),
                ),
                const SizedBox(width: _buttonSpacing),
                Expanded(
                  child: _buildDemoButton(
                    label: 'Update Position',
                    description: 'Move all popovers',
                    icon: Icons.open_with,
                    onPressed: () {
                      _popoverController.alignment = Alignment.topRight;
                      _popoverController.offset = const Offset(20, 20);
                    },
                    color: _secondaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Animation section
        _buildSection(
          title: 'Animation Examples',
          description: 'Custom animation effects and combinations',
          children: [
            _buildAnimationGrid(),
          ],
        ),
      ],
    );
  }

  // Create a responsive Wrap widget that adapts to smaller screens
  Widget _buildResponsiveWrap({required List<Widget> children}) {
    return Wrap(
      spacing: _buttonSpacing,
      runSpacing: _buttonSpacing,
      children: children,
    );
  }

  // Responsive grid that adapts to screen size
  Widget _buildAnimationGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate how many items can fit per row
      final double availableWidth = constraints.maxWidth;
      final int crossAxisCount =
          (availableWidth / (_minTileWidth + _buttonSpacing))
              .floor()
              .clamp(1, _maxGridCrossAxisCount);

      // Calculate child aspect ratio based on available space
      final double itemWidth =
          (availableWidth - (crossAxisCount - 1) * _buttonSpacing) /
              crossAxisCount;
      final double aspectRatio = itemWidth / 100; // Height roughly 100

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: aspectRatio.clamp(0.8, 1.5), // Reasonable bounds
          crossAxisSpacing: _buttonSpacing,
          mainAxisSpacing: _buttonSpacing,
        ),
        itemCount: _animationExamples.length,
        itemBuilder: (context, index) {
          final example = _animationExamples[index];
          return Builder(
            builder: (ctx) => _buildAnimationTile(
              ctx,
              title: example.title,
              description: example.description,
              example: example,
            ),
          );
        },
      );
    });
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popover Showcase',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Interactive demonstration of popover component capabilities',
          style: TextStyle(
            fontSize: 16,
            color: _sectionDescriptionColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: _sectionSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _sectionTitleStyle),
          const SizedBox(height: 8),
          Text(description, style: _sectionDescriptionStyle),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            color: _cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_cardBorderRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(_cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton({
    required String label,
    required String description,
    required VoidCallback onPressed,
    IconData? icon,
    Color? color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? _primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_buttonBorderRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 24),
            const SizedBox(height: 8),
          ],
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConstraintButton(
    BuildContext context, {
    required String label,
    required String description,
    required PopoverConstraint constraint,
    Size? fixedSize,
  }) {
    return _buildDemoButton(
      label: label,
      description: description,
      icon: _getConstraintIcon(constraint),
      color: constraint == PopoverConstraint.fixed
          ? _secondaryColor
          : _primaryColor,
      onPressed: () => _showConstraintPopover(
        context,
        constraint: constraint,
        fixedSize: fixedSize,
      ),
    );
  }

  IconData _getConstraintIcon(PopoverConstraint constraint) {
    switch (constraint) {
      case PopoverConstraint.flexible:
        return Icons.aspect_ratio;
      case PopoverConstraint.intrinsic:
        return Icons.fit_screen;
      case PopoverConstraint.fixed:
        return Icons.crop_square;
      case PopoverConstraint.fullScreen:
        return Icons.fullscreen;
      case PopoverConstraint.contentSize:
        return Icons.format_size;
      default:
        return Icons.square_foot;
    }
  }

  Widget _buildAnimationTile(
    BuildContext context, {
    required String title,
    required String description,
    required AnimationExample example,
  }) {
    return Card(
      color: example.isSpecial ? _secondaryColor : _primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_buttonBorderRadius),
      ),
      child: InkWell(
        onTap: () => _showAnimatedPopover(
          context,
          enterAnimations: example.enterAnimations,
          exitAnimations: example.exitAnimations,
          enterDuration: example.enterDuration,
          exitDuration: example.exitDuration,
          initialScale: example.initialScale,
          enterCurve: example.enterCurve,
          exitCurve: example.exitCurve,
          transformOrigin: example.transformOrigin,
          slideBegin: example.slideBegin,
          rotateBegin: example.rotateBegin,
          skewXBegin: example.skewXBegin,
          useSafeOpacity:
              example.useSafeOpacity, // Pass through the safe opacity flag
        ),
        borderRadius: BorderRadius.circular(_buttonBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlignmentGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3, // selalu 3 kolom
      crossAxisSpacing: _buttonSpacing,
      mainAxisSpacing: _buttonSpacing,
      childAspectRatio: 1.5, // atau 1.0 untuk kotak, bisa kamu atur sesuai UI
      children: [
        _positionButton(
          label: 'Top Left',
          alignment: Alignment.bottomLeft,
          anchorAlignment: Alignment.topLeft,
          offset: const Offset(0, -_popoverOffset),
        ),
        _positionButton(
          label: 'Top Center',
          alignment: Alignment.bottomCenter,
          anchorAlignment: Alignment.topCenter,
          offset: const Offset(0, -_popoverOffset),
        ),
        _positionButton(
          label: 'Top Right',
          alignment: Alignment.bottomRight,
          anchorAlignment: Alignment.topRight,
          offset: const Offset(0, -_popoverOffset),
        ),
        _positionButton(
          label: 'Center Left',
          alignment: Alignment.centerRight,
          anchorAlignment: Alignment.centerLeft,
          offset: const Offset(-_popoverOffset, 0),
        ),
        _positionButton(
          label: 'Center',
          alignment: Alignment.center,
          anchorAlignment: Alignment.center,
          offset: Offset.zero,
        ),
        _positionButton(
          label: 'Center Right',
          alignment: Alignment.centerLeft,
          anchorAlignment: Alignment.centerRight,
          offset: const Offset(_popoverOffset, 0),
        ),
        _positionButton(
          label: 'Bottom Left',
          alignment: Alignment.topLeft,
          anchorAlignment: Alignment.bottomLeft,
          offset: const Offset(0, _popoverOffset),
        ),
        _positionButton(
          label: 'Bottom Center',
          alignment: Alignment.topCenter,
          anchorAlignment: Alignment.bottomCenter,
          offset: const Offset(0, _popoverOffset),
        ),
        _positionButton(
          label: 'Bottom Right',
          alignment: Alignment.topRight,
          anchorAlignment: Alignment.bottomRight,
          offset: const Offset(0, _popoverOffset),
        ),
      ],
    );
  }

  Widget _positionButton({
    required String label,
    required Alignment alignment,
    required Alignment anchorAlignment,
    required Offset offset,
  }) {
    final link = _links.putIfAbsent(label, () => LayerLink());
    return CompositedTransformTarget(
      link: link,
      child: Builder(
        builder: (ctx) => ElevatedButton(
          onPressed: () => _showBasicPopover(
            ctx,
            alignment: alignment,
            anchorAlignment: anchorAlignment,
            offset: offset,
            layerLink: link,
            popoverId: label,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(_buttonBorderRadius),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollTestArea() {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 200,
        maxHeight: 300,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: 10,
          itemBuilder: (context, index) {
            return Container(
              height: 60,
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color:
                    index.isEven ? Colors.blue.shade50 : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                'Scroll Item ${index + 1}',
                style: TextStyle(
                  color: _sectionTitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Basic popover invocation with options
  void _showBasicPopover(
    BuildContext ctx, {
    Alignment alignment = Alignment.bottomRight,
    Alignment anchorAlignment = Alignment.topRight,
    Offset offset = const Offset(0, -_popoverOffset),
    LayerLink? layerLink,
    bool modal = false,
    bool barrierDismissable = false,
    bool allowInvertHorizontal = false,
    bool allowInvertVertical = false,
    bool stayVisibleOnScroll = true,
    bool follow = true,
    String? popoverId,
  }) {
    showPopover(
      context: ctx,
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      offset: offset,
      follow: follow,
      modal: modal,
      barrierDismissable: barrierDismissable,
      allowInvertHorizontal: allowInvertHorizontal,
      allowInvertVertical: allowInvertVertical,
      stayVisibleOnScroll: stayVisibleOnScroll,
      layerLink: layerLink,
      builder: (_) => _buildPopoverContent(
        popoverId: popoverId,
        features: [
          if (modal) 'Modal',
          if (barrierDismissable) 'Tap outside to close',
          if (allowInvertHorizontal || allowInvertVertical) 'Inversion enabled',
          if (!follow) 'Fixed position',
          if (!stayVisibleOnScroll) 'Closes on scroll',
        ],
      ),
    );
  }

  // Popover with result close
  Future<void> _showPopoverWithResult(BuildContext ctx) async {
    final result = await showPopover<String>(
      context: ctx,
      alignment: Alignment.center,
      anchorAlignment: Alignment.center,
      builder: (builderCtx) {
        return Container(
          width: 200,
          padding: const EdgeInsets.all(_contentPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choose an Option',
                style: _popoverTitleStyle,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      closeOverlay(builderCtx, 'Accepted');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      closeOverlay(builderCtx, 'Declined');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Decline'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ).future;

    if (ctx.mounted && result != null) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text('You $result the request'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Shows multi popovers using controller
  void _showControlledPopovers() {
    // Close any existing popovers first
    _popoverController.close();

    // Show staggered popovers
    _popoverController.show(
      context: context,
      builder: (_) => _buildPopoverContent(
        popoverId: 'Left',
        showCloseButton: false,
      ),
      alignment: Alignment.centerRight,
      anchorAlignment: Alignment.centerLeft,
      offset: const Offset(-16, -30),
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _popoverController.show(
          context: context,
          builder: (_) => _buildPopoverContent(
            popoverId: 'Center',
            showCloseButton: false,
          ),
          alignment: Alignment.centerRight,
          anchorAlignment: Alignment.centerLeft,
          offset: const Offset(-16, 0),
        );
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _popoverController.show(
          context: context,
          builder: (_) => _buildPopoverContent(
            popoverId: 'Right',
            showCloseButton: false,
          ),
          alignment: Alignment.centerRight,
          anchorAlignment: Alignment.centerLeft,
          offset: const Offset(-16, 30),
        );
      }
    });
  }

  // Demonstrates different popover constraints
  void _showConstraintPopover(
    BuildContext ctx, {
    required PopoverConstraint constraint,
    Size? fixedSize,
  }) {
    showPopover(
      context: ctx,
      alignment: Alignment.center,
      anchorAlignment: Alignment.center,
      widthConstraint: constraint,
      heightConstraint: constraint,
      fixedSize: fixedSize,
      builder: (_) => _buildPopoverContent(
        popoverId: constraint.name,
        features: [
          'Constraint: ${constraint.name}',
          if (fixedSize != null)
            'Fixed Size: ${fixedSize.width.round()}×${fixedSize.height.round()}',
        ],
      ),
    );
  }

  // Shows a popover with custom animations - FIXED to handle opacity safely
  void _showAnimatedPopover(
    BuildContext ctx, {
    Alignment alignment = Alignment.bottomCenter,
    Alignment anchorAlignment = Alignment.topCenter,
    Offset offset = const Offset(0, -16.0),
    List<PopoverAnimationType> enterAnimations = const [
      PopoverAnimationType.fadeIn,
      PopoverAnimationType.scale,
    ],
    List<PopoverAnimationType> exitAnimations = const [
      PopoverAnimationType.fadeOut,
      PopoverAnimationType.scale,
    ],
    Duration? enterDuration,
    Duration? exitDuration,
    Curve? enterCurve,
    Curve? exitCurve,
    double initialScale = 0.9,
    Alignment? transformOrigin,
    Offset? slideBegin,
    double rotateBegin = 0.0,
    double rotateEnd = 0.0,
    double skewXBegin = 0.0,
    double skewXEnd = 0.0,
    double skewYBegin = 0.0,
    double skewYEnd = 0.0,
    bool useSafeOpacity = false, // New flag to handle opacity separately
  }) {
    // Important fix: For animations with elastic curves or any curve that might overshoot,
    // we handle the opacity separately so it stays within valid range 0.0-1.0

    // If using safe opacity, create animation config without fade effects
    PopoverAnimationConfig animConfig;

    if (useSafeOpacity) {
      // Create config without fade animations - we'll handle fade separately
      animConfig = PopoverAnimationConfig(
        enterDuration: enterDuration ?? const Duration(milliseconds: 300),
        exitDuration: exitDuration ?? const Duration(milliseconds: 200),
        enterCurve: enterCurve ?? Curves.easeOutCubic,
        exitCurve: exitCurve ?? Curves.easeIn,
        // Remove fadeIn/fadeOut from animations
        enterAnimations: enterAnimations
            .where((a) => a != PopoverAnimationType.fadeIn)
            .toList(),
        exitAnimations: exitAnimations
            .where((a) => a != PopoverAnimationType.fadeOut)
            .toList(),
        initialScale: initialScale,
        transformOrigin: transformOrigin ?? Alignment.center,
        slideBegin: slideBegin ?? const Offset(0, 20),
        rotateBegin: rotateBegin,
        rotateEnd: rotateEnd,
        skewXBegin: skewXBegin,
        skewXEnd: skewXEnd,
        skewYBegin: skewYBegin,
        skewYEnd: skewYEnd,
      );
    } else {
      // Standard config with normal animations
      animConfig = PopoverAnimationConfig(
        enterDuration: enterDuration ?? const Duration(milliseconds: 300),
        exitDuration: exitDuration ?? const Duration(milliseconds: 200),
        enterCurve: enterCurve ?? Curves.easeOutCubic,
        exitCurve: exitCurve ?? Curves.easeIn,
        enterAnimations: enterAnimations,
        exitAnimations: exitAnimations,
        initialScale: initialScale,
        transformOrigin: transformOrigin ?? Alignment.center,
        slideBegin: slideBegin ?? const Offset(0, 20),
        rotateBegin: rotateBegin,
        rotateEnd: rotateEnd,
        skewXBegin: skewXBegin,
        skewXEnd: skewXEnd,
        skewYBegin: skewYBegin,
        skewYEnd: skewYEnd,
      );
    }

    showPopover(
      context: ctx,
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      offset: offset,
      follow: true,
      animationConfig: animConfig,
      builder: (builderCtx) {
        // Base content without handling opacity
        Widget content = _buildPopoverContent(
          popoverId: 'Animation',
          features: [
            'Effects: ${enterAnimations.map((e) => e.name).join(", ")}',
            'Duration: ${enterDuration?.inMilliseconds ?? 300}ms',
            'Curve: ${enterCurve?.toString().split('.').last ?? 'easeOutCubic'}',
          ],
        );

        // For safe opacity mode, we manually wrap with a separate fade animation
        // that ensures opacity is properly clamped between 0.0 and 1.0
        if (useSafeOpacity &&
            enterAnimations.contains(PopoverAnimationType.fadeIn)) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: enterDuration ?? const Duration(milliseconds: 300),
            curve: Curves.easeOut, // Always use a safe curve for opacity!
            builder: (context, value, child) {
              // IMPORTANT: Clamp opacity value to valid range
              final safeOpacity = value.clamp(0.0, 1.0);
              return Opacity(
                opacity: safeOpacity,
                child: child,
              );
            },
            child: content,
          );
        }

        return content;
      },
    );
  }

  // Content inside popover
  Widget _buildPopoverContent({
    String? popoverId,
    bool showCloseButton = true,
    List<String> features = const [],
  }) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 100,
        maxWidth: 300,
        minHeight: 50,
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(_contentPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: _primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  popoverId != null ? 'Popover: $popoverId' : 'Popover Content',
                  style: _popoverTitleStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'This is a popover that can contain any widget. You can customize its appearance, behavior, and animations.',
            style: _popoverBodyStyle,
          ),
          if (features.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(_featureBoxPadding),
              decoration: BoxDecoration(
                color: _featureBoxBgColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _featureBoxBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: features
                    .map((feature) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('• ',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Expanded(
                                child: Text(
                                  feature,
                                  style: _popoverFeatureStyle,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
          if (showCloseButton) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Close'),
                onPressed: () => closeOverlay(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Helper class for animation examples
class AnimationExample {
  final String title;
  final String description;
  final List<PopoverAnimationType> enterAnimations;
  final List<PopoverAnimationType> exitAnimations;
  final Duration enterDuration;
  final Duration exitDuration;
  final Curve enterCurve;
  final Curve exitCurve;
  final double initialScale;
  final Alignment transformOrigin;
  final Offset slideBegin;
  final double rotateBegin;
  final double skewXBegin;
  final bool isSpecial;
  final bool useSafeOpacity; // Added flag for safe opacity handling

  AnimationExample({
    required this.title,
    required this.description,
    this.enterAnimations = const [
      PopoverAnimationType.fadeIn,
      PopoverAnimationType.scale
    ],
    this.exitAnimations = const [
      PopoverAnimationType.fadeOut,
      PopoverAnimationType.scale
    ],
    this.enterDuration = const Duration(milliseconds: 300),
    this.exitDuration = const Duration(milliseconds: 200),
    this.enterCurve = Curves.easeOutCubic,
    this.exitCurve = Curves.easeIn,
    this.initialScale = 0.9,
    this.transformOrigin = Alignment.center,
    this.slideBegin = const Offset(0, 20),
    this.rotateBegin = 0.0,
    this.skewXBegin = 0.0,
    this.isSpecial = false,
    this.useSafeOpacity = false,
  });
}
