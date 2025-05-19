import 'package:boilerplate/core/widgets/animation.dart';
import 'package:boilerplate/core/widgets/components/buttons/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimationSandboxPage extends StatefulWidget {
  const AnimationSandboxPage({super.key});

  @override
  State<AnimationSandboxPage> createState() => _AnimationSandboxPageState();
}

class _AnimationSandboxPageState extends State<AnimationSandboxPage> {
  // AnimatedValueBuilder state
  double _sliderValue = 50;
  Color _currentColor = Colors.blue;
  bool _showDetails = false;

  // RepeatedAnimationBuilder state
  bool _isPlaying = true;
  RepeatMode _repeatMode = RepeatMode.pingPong;

  // CrossFadedTransition state
  bool _showFirstContent = true;
  int _contentIndex = 0;
  final List<Widget> _contentExamples = [
    const Padding(
      padding: EdgeInsets.all(16.0),
      child: Icon(Icons.favorite, size: 100, color: Colors.red),
    ),
    Container(
      padding: const EdgeInsets.all(24.0),
      color: Colors.amber,
      child:
          const Text('Hello Animation World!', style: TextStyle(fontSize: 24)),
    ),
    SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) => Container(
          margin: const EdgeInsets.all(8),
          height: 80,
          width: 80,
          color: Colors.green.shade200,
          child: Center(child: Text('${index + 1}')),
        ),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animation Utilities Sandbox'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),

            // === AnimatedValueBuilder Section ===
            _buildSectionTitle(
                'AnimatedValueBuilder', 'One-time value animations'),
            _buildAnimatedValueExamples(),
            const SizedBox(height: 32),

            // === RepeatedAnimationBuilder Section ===
            _buildSectionTitle(
                'RepeatedAnimationBuilder', 'Continuous looping animations'),
            _buildRepeatedAnimationExamples(),
            const SizedBox(height: 32),

            // === IntervalDuration Section ===
            _buildSectionTitle('IntervalDuration', 'Custom timing sequences'),
            _buildIntervalDurationExamples(),
            const SizedBox(height: 32),

            // === CrossFadedTransition Section ===
            _buildSectionTitle(
                'CrossFadedTransition', 'Widget replacement effects'),
            _buildCrossFadedExamples(),
            const SizedBox(height: 48),
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
          'Animation Utilities Sandbox',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 8),
        const AppText(
          'Explore the animation utilities library with interactive examples',
          variant: TextVariant.bodyLarge,
          color: Colors.grey,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String description) {
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
          color: Colors.grey,
        ),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildAnimatedValueExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple numeric animation
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Basic Value Animation',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Change the slider to animate width',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const AppText('0', variant: TextVariant.bodySmall),
                    Expanded(
                      child: Slider(
                        value: _sliderValue,
                        min: 0,
                        max: 300,
                        onChanged: (value) =>
                            setState(() => _sliderValue = value),
                      ),
                    ),
                    const AppText('300', variant: TextVariant.bodySmall),
                  ],
                ),
                const SizedBox(height: 16),

                // The animated container
                Center(
                  child: AnimatedValueBuilder<double>(
                    initialValue: 50,
                    value: _sliderValue,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Container(
                      width: value,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Color animation
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Color Animation',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Tap buttons to animate color changes',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Button(
                      text: 'Blue',
                      leftIcon: Icons.circle,
                      colors: ButtonColors(icon: Colors.blue),
                      onPressed: () =>
                          setState(() => _currentColor = Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Button(
                      text: 'Red',
                      leftIcon: Icons.circle,
                      colors: ButtonColors(icon: Colors.red),
                      onPressed: () =>
                          setState(() => _currentColor = Colors.red),
                    ),
                    const SizedBox(width: 12),
                    Button(
                      text: 'Green',
                      leftIcon: Icons.circle,
                      colors: ButtonColors(icon: Colors.green),
                      onPressed: () =>
                          setState(() => _currentColor = Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // The animated color container
                Center(
                  child: AnimatedValueBuilder<Color>(
                    initialValue: Colors.blue,
                    value: _currentColor,
                    duration: const Duration(milliseconds: 500),
                    lerp: (Color a, Color b, double t) => Color.lerp(a, b, t)!,
                    builder: (context, color, _) => Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.color_lens,
                            color: Colors.white, size: 48),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Details expansion with custom animation
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Advanced Animation',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Custom animation using .raw constructor',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Button(
                        text: _showDetails ? 'Hide Details' : 'Show Details',
                        leftIcon: _showDetails
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onPressed: () =>
                            setState(() => _showDetails = !_showDetails),
                      ),
                      const SizedBox(height: 16),

                      // Advanced animation using raw
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: AnimatedValueBuilder<double>.raw(
                          initialValue: 0.0,
                          value: _showDetails ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubic,
                          builder: (context, start, end, t, child) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info),
                                      const SizedBox(width: 8),
                                      const AppText(
                                        'Item Information',
                                        variant: TextVariant.titleSmall,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const Spacer(),
                                      Transform.rotate(
                                        angle: (1 - t) * -math.pi / 2,
                                        child: const Icon(Icons.chevron_right),
                                      ),
                                    ],
                                  ),
                                ),
                                ClipRect(
                                  child: Align(
                                    heightFactor: t,
                                    child: child,
                                  ),
                                ),
                              ],
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Divider(),
                                SizedBox(height: 8),
                                AppText('Details Section'),
                                SizedBox(height: 8),
                                AppText(
                                  'This content expands and collapses with a custom animation. '
                                  'The chevron rotates as part of the animation effect.',
                                  variant: TextVariant.bodySmall,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                AppText('Additional Information',
                                    variant: TextVariant.labelLarge,
                                    fontWeight: FontWeight.w600),
                                SizedBox(height: 8),
                                AppText(
                                  'This showcases how to build complex expand/collapse '
                                  'animations with proper clipping and rotation effects.',
                                  variant: TextVariant.bodySmall,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRepeatedAnimationExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Spinning animation
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Rotating Animation',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Continuous rotation animation with pause control',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Button(
                      text: _isPlaying ? 'Pause' : 'Play',
                      leftIcon: _isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: () => setState(() => _isPlaying = !_isPlaying),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RepeatedAnimationBuilder<double>(
                          start: 0,
                          end: 2 * math.pi,
                          duration: const Duration(seconds: 2),
                          mode: RepeatMode.repeat,
                          play: _isPlaying,
                          curve: Curves.linear,
                          builder: (context, angle, _) => Transform.rotate(
                            angle: angle,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const AppText(
                          'RepeatMode.repeat',
                          variant: TextVariant.labelMedium,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Pulsating animation with different repeat modes
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Pulsating Animation',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Compare different repeat modes',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Repeat Mode options
                    DropdownButton<RepeatMode>(
                      value: _repeatMode,
                      onChanged: (RepeatMode? newValue) {
                        if (newValue != null) {
                          setState(() => _repeatMode = newValue);
                        }
                      },
                      items: RepeatMode.values
                          .map<DropdownMenuItem<RepeatMode>>(
                              (RepeatMode value) {
                        return DropdownMenuItem<RepeatMode>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        );
                      }).toList(),
                    ),

                    Button(
                      text: _isPlaying ? 'Pause' : 'Play',
                      leftIcon: _isPlaying ? Icons.pause : Icons.play_arrow,
                      onPressed: () => setState(() => _isPlaying = !_isPlaying),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Pulsating heart animation
                Center(
                  child: RepeatedAnimationBuilder<double>(
                    start: 0.8,
                    end: 1.2,
                    duration: const Duration(milliseconds: 800),
                    reverseDuration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutQuad,
                    reverseCurve: Curves.easeIn,
                    mode: _repeatMode,
                    play: _isPlaying,
                    builder: (context, scale, _) => Transform.scale(
                      scale: scale,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 80,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Color pulsation
                Center(
                  child: RepeatedAnimationBuilder<Color>(
                    start: Colors.purpleAccent.shade100,
                    end: Colors.purpleAccent.shade700,
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeInOut,
                    mode: _repeatMode,
                    play: _isPlaying,
                    lerp: (Color a, Color b, double t) => Color.lerp(a, b, t)!,
                    builder: (context, color, _) => Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Advanced custom animation with raw access
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Advanced Animation',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Custom animation with raw animation access',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    height: 150,
                    child: RepeatedAnimationBuilder<double>.animation(
                      start: 0,
                      end: 1,
                      duration: const Duration(seconds: 3),
                      curve: Curves.easeInOut,
                      mode: RepeatMode.pingPong,
                      play: _isPlaying,
                      animationBuilder: (context, animation) {
                        return CustomPaint(
                          size: const Size(300, 150),
                          painter: _WavePainter(
                            animation: animation,
                            color: Colors.blueAccent,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Button(
                    text: _isPlaying ? 'Pause' : 'Play',
                    leftIcon: _isPlaying ? Icons.pause : Icons.play_arrow,
                    onPressed: () => setState(() => _isPlaying = !_isPlaying),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIntervalDurationExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Staggered animation example
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Staggered Animation',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Elements animate in sequence using IntervalDuration',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),

                Center(
                  child: Button(
                    text: 'Reset Animation',
                    leftIcon: Icons.refresh,
                    onPressed: () => setState(() {}),
                  ),
                ),
                const SizedBox(height: 24),

                // Staggered elements container
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // First item - delayed start
                        AnimatedValueBuilder<double>(
                          initialValue: 0.0,
                          value: 1.0,
                          duration: const Duration(milliseconds: 1500),
                          curve: IntervalDuration(
                            start: Duration.zero,
                            end: const Duration(milliseconds: 500),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.elasticOut,
                          ),
                          builder: (context, value, _) => Transform.scale(
                            scale: value,
                            child: Container(
                              height: 50,
                              width: 250,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Second item - middle interval
                        AnimatedValueBuilder<double>(
                          initialValue: 0.0,
                          value: 1.0,
                          duration: const Duration(milliseconds: 1500),
                          curve: IntervalDuration(
                            start: const Duration(milliseconds: 300),
                            end: const Duration(milliseconds: 800),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeOutBack,
                          ),
                          builder: (context, value, _) => Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: Container(
                                height: 50,
                                width: 200,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Third item - late interval
                        AnimatedValueBuilder<double>(
                          initialValue: 0.0,
                          value: 1.0,
                          duration: const Duration(milliseconds: 1500),
                          curve: IntervalDuration(
                            start: const Duration(milliseconds: 600),
                            end: const Duration(milliseconds: 1200),
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.fastOutSlowIn,
                          ),
                          builder: (context, value, _) => Transform.translate(
                            offset: Offset(100 * (1 - value), 0),
                            child: Opacity(
                              opacity: value,
                              child: Container(
                                height: 50,
                                width: 150,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Delayed Animation Example
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Delayed Animation',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Animation with delayed start and early end',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),

                Center(
                  child: Button(
                    text: 'Reset Animation',
                    leftIcon: Icons.refresh,
                    onPressed: () => setState(() {}),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const AppText(
                            'Delayed Start',
                            variant: TextVariant.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          AnimatedValueBuilder<double>(
                            initialValue: 0.0,
                            value: 1.0,
                            duration: const Duration(milliseconds: 2000),
                            curve: IntervalDuration.delayed(
                              startDelay: const Duration(milliseconds: 500),
                              duration: const Duration(milliseconds: 1500),
                            ),
                            builder: (context, value, _) {
                              return Container(
                                height: 20,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: (1 - value) * 200,
                                  color: Colors.white38,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          const AppText(
                            'Waits 500ms before starting',
                            variant: TextVariant.labelSmall,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          const AppText(
                            'Early End',
                            variant: TextVariant.labelLarge,
                          ),
                          const SizedBox(height: 8),
                          AnimatedValueBuilder<double>(
                            initialValue: 0.0,
                            value: 1.0,
                            duration: const Duration(milliseconds: 2000),
                            curve: IntervalDuration.delayed(
                              endDelay: const Duration(milliseconds: 500),
                              duration: const Duration(milliseconds: 1500),
                            ),
                            builder: (context, value, _) {
                              return Container(
                                height: 20,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.purple,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                alignment: Alignment.centerRight,
                                child: Container(
                                  width: (1 - value) * 200,
                                  color: Colors.white38,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          const AppText(
                            'Completes 500ms early',
                            variant: TextVariant.labelSmall,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Both delays
                const AppText(
                  'Combined Delay',
                  variant: TextVariant.labelLarge,
                ),
                const SizedBox(height: 8),
                AnimatedValueBuilder<double>(
                  initialValue: 0.0,
                  value: 1.0,
                  duration: const Duration(milliseconds: 2000),
                  curve: IntervalDuration.delayed(
                    startDelay: const Duration(milliseconds: 500),
                    endDelay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 1000),
                  ),
                  builder: (context, value, _) {
                    return Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: (1 - value) * double.infinity,
                        color: Colors.white38,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const AppText(
                  'Waits 500ms before starting and finishes 500ms early',
                  variant: TextVariant.labelSmall,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCrossFadedExamples() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Simple example
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Basic Cross-Fade',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Smoothly transition between two widgets',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Button(
                        text: 'Toggle Content',
                        leftIcon: Icons.swap_horiz,
                        onPressed: () => setState(
                            () => _showFirstContent = !_showFirstContent),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 280,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CrossFadedTransition(
                          duration: const Duration(milliseconds: 300),
                          child: _showFirstContent
                              ? Container(
                                  color: Colors.blue.shade50,
                                  child: const Center(
                                    child: Icon(Icons.favorite,
                                        size: 80, color: Colors.red),
                                  ),
                                )
                              : Container(
                                  color: Colors.amber.shade50,
                                  child: const Center(
                                    child: Text('Hello World!',
                                        style: TextStyle(fontSize: 32)),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Transition types
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Content Carousel',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Cycle through different content with smooth transitions',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Button(
                            leftIcon: Icons.navigate_before,
                            iconOnly: true,
                            variant: ButtonVariant.outlined,
                            onPressed: () => setState(() {
                              _contentIndex = (_contentIndex -
                                      1 +
                                      _contentExamples.length) %
                                  _contentExamples.length;
                            }),
                          ),
                          const SizedBox(width: 16),
                          Button(
                            leftIcon: Icons.navigate_next,
                            iconOnly: true,
                            variant: ButtonVariant.outlined,
                            onPressed: () => setState(() {
                              _contentIndex =
                                  (_contentIndex + 1) % _contentExamples.length;
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CrossFadedTransition(
                          key: ValueKey(_contentIndex),
                          duration: const Duration(milliseconds: 400),
                          lerp: (a, b, t,
                              {AlignmentGeometry alignment =
                                  Alignment.center}) {
                            // Custom slide-fade transition
                            return Stack(
                              children: [
                                // Out-going widget
                                Positioned.fill(
                                  child: Transform.translate(
                                    offset: Offset(-50.0 * t, 0),
                                    child: Opacity(opacity: 1.0 - t, child: a),
                                  ),
                                ),
                                // In-coming widget
                                Transform.translate(
                                  offset: Offset(50.0 * (1.0 - t), 0),
                                  child: Opacity(opacity: t, child: b),
                                ),
                              ],
                            );
                          },
                          child: _contentExamples[_contentIndex],
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        'Content ${_contentIndex + 1} of ${_contentExamples.length}',
                        variant: TextVariant.labelMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Different transition types
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText('Transition Types',
                    variant: TextVariant.titleMedium),
                const SizedBox(height: 8),
                const AppText(
                  'Different built-in transition styles',
                  variant: TextVariant.bodyMedium,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const AppText('Standard CrossFade',
                              variant: TextVariant.labelLarge),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CrossFadedTransition(
                              duration: const Duration(milliseconds: 400),
                              lerp: CrossFadedTransition.lerpOpacity,
                              child: _showFirstContent
                                  ? const Center(
                                      child: Icon(Icons.light_mode,
                                          size: 40, color: Colors.amber))
                                  : const Center(
                                      child: Icon(Icons.dark_mode,
                                          size: 40, color: Colors.indigo)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          const AppText('Immediate Switch',
                              variant: TextVariant.labelLarge),
                          const SizedBox(height: 8),
                          Container(
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CrossFadedTransition(
                              duration: const Duration(milliseconds: 400),
                              lerp: CrossFadedTransition.lerpStep,
                              child: _showFirstContent
                                  ? const Center(
                                      child: Icon(Icons.light_mode,
                                          size: 40, color: Colors.amber))
                                  : const Center(
                                      child: Icon(Icons.dark_mode,
                                          size: 40, color: Colors.indigo)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Button(
                    text: 'Toggle Icons',
                    leftIcon: Icons.swap_horiz,
                    onPressed: () =>
                        setState(() => _showFirstContent = !_showFirstContent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Custom painter for wave animation
class _WavePainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  _WavePainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final path = Path();
    final height = size.height / 2;
    final width = size.width;

    path.moveTo(0, height);

    for (double i = 0; i < width; i++) {
      final x = i;
      final y = height +
          math.sin(
                  (i / width * 8 * math.pi) + (animation.value * math.pi * 2)) *
              40;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => true;
}
