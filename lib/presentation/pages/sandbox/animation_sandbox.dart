import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/buttons/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'dart:math';

class AnimationSandbox extends StatefulWidget {
  const AnimationSandbox({super.key});

  @override
  State<AnimationSandbox> createState() => _AnimationSandboxState();
}

class _AnimationSandboxState extends State<AnimationSandbox>
    with SingleTickerProviderStateMixin {
  // Global animation duration selector
  Duration _selectedDuration = const Duration(milliseconds: 500);
  final List<Duration> _durations = const [
    Duration(milliseconds: 300),
    Duration(milliseconds: 500),
    Duration(milliseconds: 1000),
    Duration(milliseconds: 2000),
  ];

  // Global curve selector
  Curve _selectedCurve = Curves.easeInOut;
  final Map<String, Curve> _curves = {
    'Linear': Curves.linear,
    'EaseInOut': Curves.easeInOut,
    'EaseIn': Curves.easeIn,
    'EaseOut': Curves.easeOut,
    'ElasticIn': Curves.elasticIn,
    'ElasticOut': Curves.elasticOut,
    'BounceIn': Curves.bounceIn,
    'BounceOut': Curves.bounceOut,
    'Decelerate': Curves.decelerate,
  };

  // Implicit animation states
  double _animatedContainerWidth = 100;
  double _animatedContainerHeight = 100;
  Color _animatedContainerColor = AppColors.primary;
  double _animatedContainerBorderRadius = 0;

  double _animatedOpacity = 1.0;
  double _animatedPosition = 0;
  double _animatedScale = 1.0;
  double _animatedRotation = 0.0;

  // Explicit animation controller
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _rotationAnimation;

  // Staggered animation flags
  bool _staggeredAnimationRunning = false;

  // Animation presets
  final List<Map<String, dynamic>> _containerPresets = [];

  // Hero animation state
  bool _showHeroDestination = false;

  @override
  void initState() {
    super.initState();

    // Initialize explicit animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _colorAnimation = ColorTween(
      begin: AppColors.primary,
      end: AppColors.accent,
    ).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * pi,
    ).animate(_controller);

    // Initialize container animation presets
    _containerPresets.addAll([
      {
        'name': 'Default',
        'width': 100.0,
        'height': 100.0,
        'color': AppColors.primary,
        'borderRadius': 0.0,
      },
      {
        'name': 'Circle',
        'width': 150.0,
        'height': 150.0,
        'color': AppColors.accent,
        'borderRadius': 75.0,
      },
      {
        'name': 'Rectangle',
        'width': 200.0,
        'height': 100.0,
        'color': AppColors.secondary,
        'borderRadius': 8.0,
      },
      {
        'name': 'Pill',
        'width': 200.0,
        'height': 80.0,
        'color': AppColors.success,
        'borderRadius': 40.0,
      },
    ]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        // Header
        const AppText(
          'Animation Sandbox',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        AppText(
          'A comprehensive demonstration of Flutter animation capabilities',
          variant: TextVariant.bodyLarge,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 32),

        // Global animation controls
        _buildSection(
          title: 'Animation Controls',
          description: 'Global settings for animation examples',
          children: [
            _buildAnimationControls(),
          ],
        ),

        // Implicit animations
        _buildSection(
          title: 'Implicit Animations',
          description:
              'Widgets that automatically animate changes to their properties',
          children: [
            _buildSubsection(
              title: 'AnimatedContainer',
              description:
                  'Container that automatically animates between different parameters',
              child: _buildAnimatedContainerExample(),
            ),
            _buildSubsection(
              title: 'AnimatedOpacity',
              description: 'Fade in/out animations',
              child: _buildAnimatedOpacityExample(),
            ),
            _buildSubsection(
              title: 'AnimatedPositioned',
              description: 'Animate changes in position',
              child: _buildAnimatedPositionedExample(),
            ),
            _buildSubsection(
              title: 'AnimatedScale & AnimatedRotation',
              description: 'Animate size and rotation changes',
              child: _buildAnimatedTransformExample(),
            ),
          ],
        ),

        // Explicit animations
        _buildSection(
          title: 'Explicit Animations',
          description: 'Animations controlled by an AnimationController',
          children: [
            _buildSubsection(
              title: 'AnimationController basics',
              description: 'Manual control over animation timing',
              child: _buildExplicitAnimationExample(),
            ),
            _buildSubsection(
              title: 'Multiple Animations with one Controller',
              description:
                  'Control multiple animations with the same controller',
              child: _buildMultipleAnimationsExample(),
            ),
          ],
        ),

        // Staggered animations
        _buildSection(
          title: 'Staggered Animations',
          description: 'Sequence of animations that start at different times',
          children: [
            _buildSubsection(
              title: 'Basic Staggered Animation',
              description: 'Multiple animations triggered in sequence',
              child: _buildStaggeredAnimationExample(),
            ),
          ],
        ),

        // Hero animations
        _buildSection(
          title: 'Hero Animations',
          description:
              'Animations that connect two screens with a shared element',
          children: [
            _buildSubsection(
              title: 'Hero Animation',
              description: 'Animation between two screens with shared element',
              child: _buildHeroAnimationExample(),
            ),
          ],
        ),

        // Animated List
        _buildSection(
          title: 'Animated Collection Widgets',
          description: 'Animating items in collections',
          children: [
            _buildSubsection(
              title: 'AnimatedList',
              description:
                  'List widget that animates items when they are inserted or removed',
              child: _buildAnimatedListExample(),
            ),
          ],
        ),

        // Lottie animations
        _buildSection(
          title: 'Lottie Animations',
          description: 'Implementation of Adobe After Effects animations',
          children: [
            _buildSubsection(
              title: 'Lottie Animation Example',
              description: 'Playing and controlling Lottie animations',
              child: _buildLottieExample(),
            ),
          ],
        ),

        // Custom animations
        _buildSection(
          title: 'Custom Animations',
          description: 'Build complex custom animations from scratch',
          children: [
            _buildSubsection(
              title: 'Custom Animated Painter',
              description: 'Custom animation using CustomPainter',
              child: _buildCustomPainterExample(),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAnimationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            'Control animation parameters:',
            variant: TextVariant.labelLarge,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 16),

          // Duration selector
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: AppText('Duration:', variant: TextVariant.labelMedium),
              ),
              DropdownButton<Duration>(
                value: _selectedDuration,
                items: _durations.map((duration) {
                  final ms = duration.inMilliseconds;
                  return DropdownMenuItem<Duration>(
                    value: duration,
                    child: AppText('$ms ms', variant: TextVariant.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDuration = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Curve selector
          Row(
            children: [
              const SizedBox(
                width: 100,
                child: AppText('Curve:', variant: TextVariant.labelMedium),
              ),
              DropdownButton<String>(
                value: _curves.keys
                    .firstWhere((key) => _curves[key] == _selectedCurve),
                items: _curves.keys.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: AppText(name, variant: TextVariant.bodyMedium),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null && _curves.containsKey(value)) {
                    setState(() {
                      _selectedCurve = _curves[value]!;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Preview curve
          const AppText(
            'Curve preview:',
            variant: TextVariant.labelMedium,
          ),
          const SizedBox(height: 8),
          Container(
            height: 100,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: CustomPaint(
              painter: CurvePainter(curve: _selectedCurve),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedContainerExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated container display
          Center(
            child: AnimatedContainer(
              width: _animatedContainerWidth,
              height: _animatedContainerHeight,
              decoration: BoxDecoration(
                color: _animatedContainerColor,
                borderRadius:
                    BorderRadius.circular(_animatedContainerBorderRadius),
              ),
              duration: _selectedDuration,
              curve: _selectedCurve,
              child: Center(
                child: AppText(
                  '${_animatedContainerWidth.toInt()} x ${_animatedContainerHeight.toInt()}',
                  variant: TextVariant.labelSmall,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Preset buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _containerPresets.map((preset) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _animatedContainerWidth = preset['width'];
                    _animatedContainerHeight = preset['height'];
                    _animatedContainerColor = preset['color'];
                    _animatedContainerBorderRadius = preset['borderRadius'];
                  });
                },
                child: Text(preset['name']),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Manual controls
          const AppText(
            'Or customize manually:',
            variant: TextVariant.labelMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Width:', variant: TextVariant.labelSmall),
                    Slider(
                      min: 50,
                      max: 250,
                      value: _animatedContainerWidth,
                      onChanged: (value) {
                        setState(() {
                          _animatedContainerWidth = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Height:', variant: TextVariant.labelSmall),
                    Slider(
                      min: 50,
                      max: 250,
                      value: _animatedContainerHeight,
                      onChanged: (value) {
                        setState(() {
                          _animatedContainerHeight = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Corner Radius:',
                        variant: TextVariant.labelSmall),
                    Slider(
                      min: 0,
                      max: 80,
                      value: _animatedContainerBorderRadius,
                      onChanged: (value) {
                        setState(() {
                          _animatedContainerBorderRadius = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Color:', variant: TextVariant.labelSmall),
                    Row(
                      children: [
                        _buildColorSelector(AppColors.primary),
                        _buildColorSelector(AppColors.secondary),
                        _buildColorSelector(AppColors.accent),
                        _buildColorSelector(AppColors.success),
                        _buildColorSelector(AppColors.destructive),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'AnimatedContainer:\nAutomatically animates between different parameters whenever they change.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            'AnimatedContainer(\n'
            '  width: 150,\n'
            '  height: 150,\n'
            '  decoration: BoxDecoration(\n'
            '    color: Colors.blue,\n'
            '    borderRadius: BorderRadius.circular(10),\n'
            '  ),\n'
            '  duration: Duration(milliseconds: 500),\n'
            '  curve: Curves.easeInOut,\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector(Color color) {
    final isSelected = color.toARGB32() == _animatedContainerColor.toARGB32();

    return GestureDetector(
      onTap: () {
        setState(() {
          _animatedContainerColor = color;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedOpacityExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated opacity display
          Center(
            child: AnimatedOpacity(
              opacity: _animatedOpacity,
              duration: _selectedDuration,
              curve: _selectedCurve,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: AppText(
                    'Fade me',
                    variant: TextVariant.titleMedium,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Button(
                text: 'Fade Out',
                variant: ButtonVariant.outlined,
                onPressed: () {
                  setState(() {
                    _animatedOpacity = 0;
                  });
                },
              ),
              const SizedBox(width: 16),
              Button(
                text: 'Fade In',
                variant: ButtonVariant.outlined,
                onPressed: () {
                  setState(() {
                    _animatedOpacity = 1;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'AnimatedOpacity:\nFade elements in and out with smooth transitions.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            'AnimatedOpacity(\n'
            '  opacity: 1.0, // or 0.0 for fade out\n'
            '  duration: Duration(milliseconds: 500),\n'
            '  curve: Curves.easeInOut,\n'
            '  child: yourWidget,\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedPositionedExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated positioned display
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: _selectedDuration,
                  curve: _selectedCurve,
                  left: _animatedPosition,
                  top: 70,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.arrow_forward, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Position control slider
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Horizontal Position:',
                variant: TextVariant.labelMedium,
              ),
              Slider(
                min: 0,
                max: 300,
                value: _animatedPosition,
                onChanged: (value) {
                  setState(() {
                    _animatedPosition = value;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'AnimatedPositioned:\nAutomatically animates changes in position within a Stack widget.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            'Stack(\n'
            '  children: [\n'
            '    AnimatedPositioned(\n'
            '      duration: Duration(milliseconds: 500),\n'
            '      left: 100,\n'
            '      top: 50,\n'
            '      child: Container(...),\n'
            '    ),\n'
            '  ],\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedTransformExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transform examples
          Center(
            child: SizedBox(
              height: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Scale
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText('Scale', variant: TextVariant.labelMedium),
                      const SizedBox(height: 16),
                      AnimatedScale(
                        scale: _animatedScale,
                        duration: _selectedDuration,
                        curve: _selectedCurve,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Rotation
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText('Rotation',
                          variant: TextVariant.labelMedium),
                      const SizedBox(height: 16),
                      AnimatedRotation(
                        turns: _animatedRotation / (2 * pi),
                        duration: _selectedDuration,
                        curve: _selectedCurve,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child:
                                Icon(Icons.arrow_upward, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Controls
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Scale:', variant: TextVariant.labelSmall),
                    Slider(
                      min: 0.5,
                      max: 2.0,
                      value: _animatedScale,
                      onChanged: (value) {
                        setState(() {
                          _animatedScale = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppText('Rotation:', variant: TextVariant.labelSmall),
                    Slider(
                      min: 0,
                      max: 2 * pi,
                      value: _animatedRotation,
                      onChanged: (value) {
                        setState(() {
                          _animatedRotation = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'AnimatedScale and AnimatedRotation:\nEasily animate scale and rotation transformations.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            'AnimatedScale(\n'
            '  scale: 1.5,\n'
            '  duration: Duration(milliseconds: 500),\n'
            '  child: yourWidget,\n'
            ')\n\n'
            'AnimatedRotation(\n'
            '  turns: 0.25, // 1.0 = 360 degrees\n'
            '  duration: Duration(milliseconds: 500),\n'
            '  child: yourWidget,\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildExplicitAnimationExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animation display
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: 150,
                  height: 150 * _animation.value,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: AppText(
                      '${(_animation.value * 100).toStringAsFixed(0)}%',
                      variant: TextVariant.titleMedium,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Animation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Button(
                text: 'Play',
                variant: ButtonVariant.primary,
                onPressed: () {
                  _controller.reset();
                  _controller.forward();
                },
              ),
              const SizedBox(width: 16),
              Button(
                text: 'Reverse',
                variant: ButtonVariant.outlined,
                onPressed: () {
                  _controller.reverse();
                },
              ),
              const SizedBox(width: 16),
              Button(
                text: 'Stop',
                variant: ButtonVariant.outlined,
                onPressed: () {
                  _controller.stop();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'AnimationController with AnimatedBuilder:\nManually control animations and their lifecycle.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            '// In initState:\n'
            'controller = AnimationController(\n'
            '  duration: Duration(milliseconds: 1500),\n'
            '  vsync: this,\n'
            ');\n\n'
            'animation = CurvedAnimation(\n'
            '  parent: controller,\n'
            '  curve: Curves.easeInOut,\n'
            ');',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleAnimationsExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Multiple animations display
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: _colorAnimation.value,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Animation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Button(
                text: 'Play',
                variant: ButtonVariant.primary,
                onPressed: () {
                  _controller.reset();
                  _controller.forward();
                },
              ),
              const SizedBox(width: 16),
              Button(
                text: 'Reverse',
                variant: ButtonVariant.outlined,
                onPressed: () {
                  _controller.reverse();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'Multiple animations with one controller:\nColor and rotation controlled by the same AnimationController.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            'colorAnimation = ColorTween(\n'
            '  begin: Colors.blue,\n'
            '  end: Colors.orange,\n'
            ').animate(controller);\n\n'
            'rotationAnimation = Tween<double>(\n'
            '  begin: 0,\n'
            '  end: 2 * pi,\n'
            ').animate(controller);',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildStaggeredAnimationExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Staggered animation demonstration
          Center(
            child: SizedBox(
              height: 250,
              child: _staggeredAnimationRunning
                  ? _StaggeredAnimationDemo()
                  : Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: AppText(
                          'Press Play to start',
                          variant: TextVariant.labelMedium,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // Play button
          Center(
            child: Button(
              text: _staggeredAnimationRunning ? 'Reset' : 'Play Animation',
              variant: ButtonVariant.primary,
              onPressed: () {
                setState(() {
                  _staggeredAnimationRunning = !_staggeredAnimationRunning;
                });
              },
            ),
          ),

          const SizedBox(height: 16),
          const AppText(
            'Staggered animations:\nMultiple animations that start at different times but are coordinated together.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            'final controller = AnimationController(...);\n\n'
            '// First animation starts immediately\n'
            'final animation1 = Tween(...).animate(controller);\n\n'
            '// Second animation starts after delay\n'
            'final animation2 = Tween(...).animate(\n'
            '  CurvedAnimation(\n'
            '    parent: controller,\n'
            '    curve: Interval(0.3, 0.8),\n'
            '  ),\n'
            ');',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAnimationExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero animation toggle
          if (_showHeroDestination)
            _buildHeroDestination()
          else
            _buildHeroSource(),

          const SizedBox(height: 16),
          const AppText(
            'Hero animations:\nShared element transitions between screens that create a sense of continuity.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            '// Screen 1\n'
            'Hero(\n'
            '  tag: "imageTag", // Must be the same on both screens\n'
            '  child: Image.asset("image.png"),\n'
            ')\n\n'
            '// Screen 2\n'
            'Hero(\n'
            '  tag: "imageTag",\n'
            '  child: Image.asset("image.png"),\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSource() {
    return Column(
      children: [
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showHeroDestination = true;
              });
            },
            child: Column(
              children: [
                const AppText(
                  'Tap on image to animate',
                  variant: TextVariant.labelMedium,
                ),
                const SizedBox(height: 16),
                Hero(
                  tag: 'heroImage',
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child:
                        const Icon(Icons.photo, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroDestination() {
    return Container(
      color: Colors.white,
      height: 300,
      child: Stack(
        children: [
          Center(
            child: Hero(
              tag: 'heroImage',
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.photo, color: Colors.white, size: 80),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black),
              onPressed: () {
                setState(() {
                  _showHeroDestination = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<String> _listItems = ['Item 0', 'Item 1', 'Item 2'];

  Widget _buildAnimatedListExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Animated list
          SizedBox(
            height: 200,
            child: AnimatedList(
              key: _listKey,
              initialItemCount: _listItems.length,
              itemBuilder: (context, index, animation) {
                return _buildAnimatedListItem(
                    context, _listItems[index], animation, index);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Button(
                text: 'Add Item',
                leftIcon: Icons.add,
                variant: ButtonVariant.primary,
                onPressed: _addItem,
              ),
              const SizedBox(width: 16),
              Button(
                text: 'Remove Last',
                leftIcon: Icons.remove,
                variant: ButtonVariant.outlined,
                onPressed: _listItems.isNotEmpty ? _removeItem : null,
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'AnimatedList:\nA scrollable list that animates items when they are inserted or removed.',
            variant: TextVariant.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedListItem(
    BuildContext context,
    String item,
    Animation<double> animation,
    int index,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset.zero,
      ).animate(animation),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: ListTile(
          title: AppText(item, variant: TextVariant.bodyMedium),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _removeItemAtIndex(index),
          ),
        ),
      ),
    );
  }

  void _addItem() {
    final newIndex = _listItems.length;
    _listItems.add('Item ${_listItems.length}');
    _listKey.currentState?.insertItem(newIndex);
  }

  void _removeItem() {
    if (_listItems.isEmpty) return;
    final index = _listItems.length - 1;
    _removeItemAtIndex(index);
  }

  void _removeItemAtIndex(int index) {
    if (index < 0 || index >= _listItems.length) return;

    final removedItem = _listItems.removeAt(index);

    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildAnimatedListItem(context, removedItem, animation, index),
      duration: const Duration(milliseconds: 300),
    );
  }

  Widget _buildLottieExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // In a real app this would be a Lottie animation
                  Icon(
                    Icons.animation,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const AppText(
                    'Lottie animation would play here',
                    variant: TextVariant.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            'Lottie animations:\nAdobe After Effects animations exported to JSON format and played in Flutter.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            '// Add lottie package to pubspec.yaml first\n'
            'dependencies:\n'
            '  lottie: ^2.3.0\n\n'
            '// Then use it\n'
            'Lottie.asset(\n'
            '  "assets/animation.json",\n'
            '  height: 200,\n'
            '  width: 200,\n'
            '  repeat: true,\n'
            ')',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
    );
  }

  Widget _buildCustomPainterExample() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom animation display
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(200, 200),
                  painter: CircleWavePainter(
                    progress: _controller.value,
                    color: AppColors.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Button(
                text: 'Play',
                variant: ButtonVariant.primary,
                onPressed: () {
                  _controller.reset();
                  _controller.repeat();
                },
              ),
              const SizedBox(width: 16),
              Button(
                text: 'Stop',
                variant: ButtonVariant.outlined,
                onPressed: () {
                  _controller.stop();
                },
              ),
            ],
          ),

          const SizedBox(height: 16),
          const AppText(
            'CustomPainter with Animation:\nCreate custom drawing animations using low-level Flutter graphics APIs.',
            variant: TextVariant.bodySmall,
          ),
          const SizedBox(height: 8),
          const AppText(
            'class CircleWavePainter extends CustomPainter {\n'
            '  final double progress;\n'
            '  final Color color;\n\n'
            '  CircleWavePainter({required this.progress, required this.color});\n\n'
            '  @override\n'
            '  void paint(Canvas canvas, Size size) {\n'
            '    // Draw based on animation progress\n'
            '  }\n'
            '}',
            variant: TextVariant.labelSmall,
            fontFamily: 'monospace',
          ),
        ],
      ),
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

  Widget _buildSubsection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.titleSmall,
          fontWeight: FontWeight.w600,
        ),
        AppText(
          description,
          variant: TextVariant.bodySmall,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 12),
        child,
        const SizedBox(height: 24),
      ],
    );
  }
}

// Custom painter to show the selected animation curve
class CurvePainter extends CustomPainter {
  final Curve curve;

  CurvePainter({required this.curve});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // Draw grid
    for (var i = 0; i <= 4; i++) {
      double x = size.width * i / 4;
      double y = size.height * i / 4;

      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    // Draw curve
    final path = Path();
    path.moveTo(0, size.height);

    for (double x = 0; x <= size.width; x++) {
      final t = x / size.width;
      final y = size.height - (curve.transform(t) * size.height);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CurvePainter oldDelegate) => oldDelegate.curve != curve;
}

// Custom painter for wave animation
class CircleWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleWavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const maxRadius = 100.0;
    final minRadius = maxRadius * 0.3;

    // Draw multiple expanding circles
    for (var i = 0; i < 3; i++) {
      // Offset each circle's progress
      final offsetProgress = (progress + (i / 3)) % 1.0;

      // Calculate current radius and opacity
      final currentRadius =
          minRadius + (maxRadius - minRadius) * offsetProgress;
      final opacity = (1 - offsetProgress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, currentRadius, paint);
    }

    // Draw center circle
    final centerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, minRadius, centerPaint);
  }

  @override
  bool shouldRepaint(CircleWavePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Staggered animation demo widget
class _StaggeredAnimationDemo extends StatefulWidget {
  @override
  _StaggeredAnimationDemoState createState() => _StaggeredAnimationDemoState();
}

class _StaggeredAnimationDemoState extends State<_StaggeredAnimationDemo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _width;
  late Animation<double> _height;
  late Animation<double> _borderRadius;
  late Animation<Color?> _color;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Staggered animations with different intervals
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _width = Tween<double>(
      begin: 50.0,
      end: 200.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      ),
    );

    _height = Tween<double>(
      begin: 50.0,
      end: 200.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    _borderRadius = Tween<double>(
      begin: 0.0,
      end: 100.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    _color = ColorTween(
      begin: AppColors.primary,
      end: AppColors.accent,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animation automatically
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Center(
          child: Opacity(
            opacity: _opacity.value,
            child: Container(
              width: _width.value,
              height: _height.value,
              decoration: BoxDecoration(
                color: _color.value,
                borderRadius: BorderRadius.circular(_borderRadius.value),
              ),
            ),
          ),
        );
      },
    );
  }
}
