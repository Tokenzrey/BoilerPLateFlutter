/// {@template animation_library}
/// # Animation Utilities for Flutter
///
/// A comprehensive animation toolkit providing simple, powerful abstractions for creating
/// fluid animations in Flutter applications. This library offers type-safe value interpolation,
/// repeating animations with various patterns, custom timing controls, and transition effects.
///
/// ## Features
/// - Type-safe value interpolation with custom lerp functions
/// - Stateful animations that handle rebuilds gracefully
/// - Repeating animations with ping-pong, reverse, and standard repeat patterns
/// - Interval-based timing controls for sequenced animations
/// - Widget cross-fading with various transition styles
/// - Flexible builder patterns for different animation use cases
///
/// ## Basic Example
/// ```dart
/// // Simple numeric animation:
/// AnimatedValueBuilder<double>(
///   initialValue: 0.0,
///   value: 100.0,
///   duration: Duration(milliseconds: 500),
///   curve: Curves.easeOut,
///   builder: (context, value, _) => Container(
///     width: value,
///     height: 50,
///     color: Colors.blue,
///   ),
/// )
/// ```
///
/// ## Animation Types
/// | Widget | Purpose | Use Case |
/// |--------|---------|----------|
/// | AnimatedValueBuilder | One-time value animations | Transitions, reveals, metrics changes |
/// | RepeatedAnimationBuilder | Continuous looping animations | Spinners, pulses, background effects |
/// | IntervalDuration | Custom timing sequences | Staggered animations, delayed effects |
/// | CrossFadedTransition | Widget replacement effects | Page transitions, content updates |
///
/// {@endtemplate}
library;

import 'package:flutter/widgets.dart';

/// {@template animated_child_builder}
/// Function to build a widget based on an animated value.
///
/// Receives the current animated value and an optional child widget.
///
/// *Example*:
/// ```dart
/// (context, value, child) => Container(
///   width: value,
///   height: 50,
///   child: child,
/// )
/// ```
/// {@endtemplate}
typedef AnimatedChildBuilder<T> = Widget Function(
    BuildContext context, T value, Widget? child);

/// {@template animation_builder}
/// Function to build a widget with direct access to the animation object.
///
/// Provides full access to the raw [Animation<T>] for advanced use cases.
///
/// *Example*:
/// ```dart
/// (context, animation) => CustomPaint(
///   painter: MyAnimatedPainter(animation: animation),
/// )
/// ```
/// {@endtemplate}
typedef AnimationBuilder<T> = Widget Function(
    BuildContext context, Animation<T> animation);

/// {@template animated_child_value_builder}
/// Function to build a widget with access to old and new values and progress.
///
/// Provides both the start and end values, along with the progress (t).
///
/// *Example*:
/// ```dart
/// (context, oldValue, newValue, t, child) => Opacity(
///   opacity: t,
///   child: Transform.translate(
///     offset: Offset(0, (1-t) * 20),
///     child: child,
///   ),
/// )
/// ```
/// {@endtemplate}
typedef AnimatedChildValueBuilder<T> = Widget Function(
    BuildContext context, T oldValue, T newValue, double t, Widget? child);

/// {@template animated_value_builder}
/// # AnimatedValueBuilder
///
/// A powerful, type-safe widget that smoothly animates between values of any type.
///
/// This widget handles the complexities of animations, allowing you to focus on the visual
/// presentation of your changing values. It's particularly useful for animating:
///
/// - Size and position properties (width, height, offsets)
/// - Color transitions
/// - Opacity and transform values
/// - Custom data types with appropriate lerp functions
///
/// ## Key Features
///
/// - **Type Safety**: Works with any value type (with appropriate lerp function)
/// - **Smooth Transitions**: Handles value changes with configurable animations
/// - **Multiple Builder Options**: Different constructors for various animation needs
/// - **Completion Callbacks**: Execute code when animations complete
/// - **Custom Interpolation**: Support for any data type with custom lerp functions
///
/// ## Standard Usage
///
/// ```dart
/// AnimatedValueBuilder<double>(
///   initialValue: 0.0,
///   value: _sliderValue,
///   duration: const Duration(milliseconds: 300),
///   curve: Curves.easeOut,
///   builder: (context, value, _) {
///     return Container(
///       width: 100,
///       height: value,
///       color: Colors.blue,
///     );
///   },
/// )
/// ```
///
/// ## Raw Animation Access
///
/// ```dart
/// AnimatedValueBuilder.animation<Color>(
///   initialValue: Colors.red,
///   value: Colors.blue,
///   duration: const Duration(milliseconds: 500),
///   lerp: Color.lerp,
///   builder: (context, animation) {
///     return AnimatedBuilder(
///       animation: animation,
///       builder: (context, _) => Container(
///         color: animation.value,
///         height: 100,
///         width: 100,
///       ),
///     );
///   },
/// )
/// ```
///
/// ## Custom Value Transitions
///
/// ```dart
/// AnimatedValueBuilder.raw<Offset>(
///   initialValue: Offset.zero,
///   value: Offset(100, 50),
///   duration: const Duration(seconds: 1),
///   lerp: Offset.lerp,
///   builder: (context, oldValue, newValue, t, child) {
///     return Transform.translate(
///       offset: Offset.lerp(oldValue, newValue, t)!,
///       child: child,
///     );
///   },
///   child: const FlutterLogo(size: 100),
/// )
/// ```
/// {@endtemplate}
class AnimatedValueBuilder<T> extends StatefulWidget {
  /// {@template animated_value_builder_initialValue}
  /// The initial value for the animation (if null, value is used).
  ///
  /// *Type*: `T?`
  ///
  /// When not provided, the animation starts with the [value], resulting in no
  /// visible animation on first build.
  ///
  /// When provided, the animation starts from this value and transitions to [value].
  ///
  /// *Example*: `initialValue: 0.0`
  /// {@endtemplate}
  final T? initialValue;

  /// {@template animated_value_builder_value}
  /// The target value to animate to.
  ///
  /// *Type*: `T`
  ///
  /// This is the end value that the animation will progress toward.
  /// When this value changes, the widget will automatically animate from the current
  /// animated value to this new target value.
  ///
  /// *Example*: `value: 100.0`
  /// {@endtemplate}
  final T value;

  /// {@template animated_value_builder_duration}
  /// Animation duration - how long the transition takes.
  ///
  /// *Type*: `Duration`
  ///
  /// Controls the speed of the animation from the current value to the target value.
  /// Shorter durations create faster animations.
  ///
  /// *Example*: `duration: const Duration(milliseconds: 300)`
  /// {@endtemplate}
  final Duration duration;

  /// {@template animated_value_builder_builder}
  /// Builder function that receives the interpolated value.
  ///
  /// *Type*: `AnimatedChildBuilder<T>?`
  ///
  /// This function rebuilds with the current animated value on each animation frame.
  /// Only present in the standard constructor.
  ///
  /// *Example*:
  /// ```dart
  /// builder: (context, value, child) => Container(
  ///   width: value,
  ///   height: 50,
  ///   child: child,
  /// )
  /// ```
  /// {@endtemplate}
  final AnimatedChildBuilder<T>? builder;

  /// {@template animated_value_builder_animationBuilder}
  /// Builder function that receives the raw animation.
  ///
  /// *Type*: `AnimationBuilder<T>?`
  ///
  /// Provides direct access to the Animation`<`T`>` object for advanced use cases.
  /// Only present in the .animation constructor.
  ///
  /// *Example*:
  /// ```dart
  /// animationBuilder: (context, animation) => CustomPaint(
  ///   painter: MyAnimatedPainter(animation: animation),
  /// )
  /// ```
  /// {@endtemplate}
  final AnimationBuilder<T>? animationBuilder;

  /// {@template animated_value_builder_rawBuilder}
  /// Raw builder with access to old/new values and progress.
  ///
  /// *Type*: `AnimatedChildValueBuilder<T>?`
  ///
  /// Provides full access to the animation parameters for custom transitions.
  /// Only present in the .raw constructor.
  ///
  /// *Example*:
  /// ```dart
  /// rawBuilder: (context, oldValue, newValue, t, child) => Opacity(
  ///   opacity: t,
  ///   child: child,
  /// )
  /// ```
  /// {@endtemplate}
  final AnimatedChildValueBuilder<T>? rawBuilder;

  /// {@template animated_value_builder_onEnd}
  /// Callback when animation completes.
  ///
  /// *Type*: `void Function(T value)?`
  ///
  /// Called with the final value when the animation reaches its target.
  /// Useful for triggering events after a transition completes.
  ///
  /// *Example*: `onEnd: (value) => print('Animation completed with: $value')`
  /// {@endtemplate}
  final void Function(T value)? onEnd;

  /// {@template animated_value_builder_curve}
  /// Animation curve that defines the pacing of the animation.
  ///
  /// *Type*: `Curve`
  ///
  /// - Standard curves like [Curves.easeIn], [Curves.elasticOut], etc.
  /// - Controls how the animation interpolates between values over time.
  /// - Default is [Curves.linear] (constant pace)
  ///
  /// *Example*: `curve: Curves.easeInOutCubic`
  /// {@endtemplate}
  final Curve curve;

  /// {@template animated_value_builder_lerp}
  /// Custom interpolation function for type T.
  ///
  /// *Type*: `T Function(T a, T b, double t)?`
  ///
  /// Defines how to interpolate between values of type T. Required for custom types.
  /// For built-in types like double, int, it uses standard mathematical interpolation.
  ///
  /// *Example*: `lerp: Color.lerp`
  /// {@endtemplate}
  final T Function(T a, T b, double t)? lerp;

  /// {@template animated_value_builder_child}
  /// Optional child widget passed to builder.
  ///
  /// *Type*: `Widget?`
  ///
  /// This widget is passed to the builder function and can be used for optimizing
  /// rebuilds of child widgets that don't depend on the animated value.
  ///
  /// *Example*: `child: const Text('Hello')`
  /// {@endtemplate}
  final Widget? child;

  /// Creates an AnimatedValueBuilder with a standard builder.
  ///
  /// {@macro animated_value_builder}
  ///
  /// This constructor uses a builder that receives the current interpolated value.
  ///
  /// ## Parameters:
  /// {@macro animated_value_builder_initialValue}
  /// {@macro animated_value_builder_value}
  /// {@macro animated_value_builder_duration}
  /// {@macro animated_value_builder_builder}
  /// {@macro animated_value_builder_onEnd}
  /// {@macro animated_value_builder_curve}
  /// {@macro animated_value_builder_lerp}
  /// {@macro animated_value_builder_child}
  ///
  /// ## Example:
  /// ```dart
  /// AnimatedValueBuilder<double>(
  ///   initialValue: 0.0,
  ///   value: 200.0,
  ///   duration: const Duration(milliseconds: 500),
  ///   curve: Curves.easeOut,
  ///   builder: (context, value, _) => Container(
  ///     width: value,
  ///     height: 100,
  ///     color: Colors.blue,
  ///   ),
  ///   onEnd: (_) => print('Animation completed'),
  /// )
  /// ```
  const AnimatedValueBuilder({
    super.key,
    this.initialValue,
    required this.value,
    required this.duration,
    required AnimatedChildBuilder<T> this.builder,
    this.onEnd,
    this.curve = Curves.linear,
    this.lerp,
    this.child,
  })  : animationBuilder = null,
        rawBuilder = null;

  /// Creates an AnimatedValueBuilder with access to raw animation.
  ///
  /// This variant provides direct access to the underlying Animation`<`T`>` object,
  /// useful for custom animation implementations or integrating with other animation widgets.
  ///
  /// ## Parameters:
  /// {@macro animated_value_builder_initialValue}
  /// {@macro animated_value_builder_value}
  /// {@macro animated_value_builder_duration}
  /// {@macro animated_value_builder_animationBuilder}
  /// {@macro animated_value_builder_onEnd}
  /// {@macro animated_value_builder_curve}
  /// {@macro animated_value_builder_lerp}
  ///
  /// ## Example:
  /// ```dart
  /// AnimatedValueBuilder.animation<Color>(
  ///   initialValue: Colors.red,
  ///   value: Colors.blue,
  ///   duration: const Duration(milliseconds: 300),
  ///   lerp: Color.lerp,
  ///   builder: (context, animation) {
  ///     return ColorFiltered(
  ///       colorFilter: ColorFilter.mode(
  ///         animation.value,
  ///         BlendMode.srcATop,
  ///       ),
  ///       child: myImage,
  ///     );
  ///   },
  /// )
  /// ```
  const AnimatedValueBuilder.animation({
    super.key,
    this.initialValue,
    required this.value,
    required this.duration,
    required AnimationBuilder<T> builder,
    this.onEnd,
    this.curve = Curves.linear,
    this.lerp,
  })  : builder = null,
        animationBuilder = builder,
        child = null,
        rawBuilder = null;

  /// Creates an AnimatedValueBuilder with access to old and new values.
  ///
  /// This variant provides the most control, giving access to both the start and end values,
  /// along with the current progress factor for custom transitions.
  ///
  /// ## Parameters:
  /// {@macro animated_value_builder_initialValue}
  /// {@macro animated_value_builder_value}
  /// {@macro animated_value_builder_duration}
  /// {@macro animated_value_builder_rawBuilder}
  /// {@macro animated_value_builder_onEnd}
  /// {@macro animated_value_builder_curve}
  /// {@macro animated_value_builder_child}
  /// {@macro animated_value_builder_lerp}
  ///
  /// ## Example:
  /// ```dart
  /// AnimatedValueBuilder.raw<Offset>(
  ///   initialValue: const Offset(0, 0),
  ///   value: const Offset(100, 50),
  ///   duration: const Duration(seconds: 1),
  ///   curve: Curves.easeInOutBack,
  ///   lerp: Offset.lerp,
  ///   builder: (context, oldOffset, newOffset, progress, child) {
  ///     // Custom transition using all parameters
  ///     final currentOffset = Offset.lerp(oldOffset, newOffset, progress)!;
  ///     final scale = 1.0 + (progress - 0.5).abs();
  ///
  ///     return Transform.translate(
  ///       offset: currentOffset,
  ///       child: Transform.scale(
  ///         scale: scale,
  ///         child: child,
  ///       ),
  ///     );
  ///   },
  ///   child: const FlutterLogo(size: 100),
  /// )
  /// ```
  const AnimatedValueBuilder.raw({
    super.key,
    this.initialValue,
    required this.value,
    required this.duration,
    required AnimatedChildValueBuilder<T> builder,
    this.onEnd,
    this.curve = Curves.linear,
    this.child,
    this.lerp,
  })  : animationBuilder = null,
        rawBuilder = builder,
        builder = null;

  @override
  State<StatefulWidget> createState() => _AnimatedValueBuilderState<T>();
}

/// A tween class that handles interpolation between two values of type T
class _AnimatableValue<T> extends Animatable<T> {
  final T start;
  final T end;
  final T Function(T a, T b, double t) lerp;

  const _AnimatableValue({
    required this.start,
    required this.end,
    required this.lerp,
  });

  @override
  T transform(double t) {
    return lerp(start, end, t);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _AnimatableValue<T> &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(start, end);
}

class _AnimatedValueBuilderState<T> extends State<AnimatedValueBuilder<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<T> _animation;
  T _currentValue = null as T; // Will be initialized in initState

  /// Method to interpolate between values of type T
  T _lerpValue(T a, T b, double t) {
    if (widget.lerp != null) {
      return widget.lerp!(a, b, t);
    }

    try {
      // Try dynamic interpolation (works for num types)
      return (a as dynamic) + ((b as dynamic) - (a as dynamic)) * t;
    } catch (e) {
      throw UnsupportedError(
        'Cannot interpolate values of type ${T.toString()}. '
        'Provide a custom lerp function.',
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? widget.value;

    // Setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Setup animation with curved animation
    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _animation = curvedAnimation.drive(
      _AnimatableValue<T>(
        start: _currentValue,
        end: widget.value,
        lerp: _lerpValue,
      ),
    );

    // Listen for animation completion
    _controller.addStatusListener(_handleAnimationStatus);

    // Start animation if initialValue is provided
    if (widget.initialValue != null) {
      _controller.forward();
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.onEnd != null) {
      widget.onEnd!(widget.value);
    }
  }

  @override
  void didUpdateWidget(AnimatedValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Capture current animated value
    _currentValue = _animation.value;

    // Update animation duration if changed
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }

    // Update animation if target value or lerp function changed
    if (oldWidget.value != widget.value || oldWidget.lerp != widget.lerp) {
      // Create new animation with current value as starting point
      final Animation<double> curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      );

      _animation = curvedAnimation.drive(
        _AnimatableValue<T>(
          start: _currentValue,
          end: widget.value,
          lerp: _lerpValue,
        ),
      );

      // Reset and start animation
      _controller.value = 0.0;
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If animation builder is provided, use it directly
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!(context, _animation);
    }

    // Otherwise use AnimatedBuilder
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        if (widget.rawBuilder != null) {
          return widget.rawBuilder!(
            context,
            _currentValue,
            widget.value,
            _controller.value,
            child,
          );
        }
        return widget.builder!(context, _animation.value, child);
      },
      child: widget.child,
    );
  }
}

/// {@template repeat_mode}
/// # RepeatMode
///
/// Defines how a repeating animation should behave after completing a cycle.
///
/// - **repeat**: Animation restarts from the beginning after reaching the end
/// - **reverse**: Animation always plays backward (from end to start)
/// - **pingPong**: Animation alternates between forward and reverse directions
/// - **pingPongReverse**: Same as pingPong, but starts with reverse direction
///
/// ## Usage Examples
///
/// ### Standard Repeat
/// ```dart
/// RepeatedAnimationBuilder<double>(
///   start: 0.0,
///   end: 100.0,
///   mode: RepeatMode.repeat, // ← Restart from 0 when reaching 100
///   duration: Duration(seconds: 2),
///   builder: (context, value, _) => Container(width: value),
/// )
/// ```
///
/// ### Ping-pong (Alternating)
/// ```dart
/// RepeatedAnimationBuilder<double>(
///   start: 1.0,
///   end: 1.5,
///   mode: RepeatMode.pingPong, // ← Bounce between 1.0 and 1.5
///   duration: Duration(seconds: 1),
///   builder: (context, value, _) => Transform.scale(
///     scale: value,
///     child: myWidget,
///   ),
/// )
/// ```
/// {@endtemplate}
enum RepeatMode {
  /// Animation repeats from the beginning after completion.
  ///
  /// **Behavior**: 0→1→0→1→0→1...
  ///
  /// Use for continuous spinning, growing/shrinking, or any effect that
  /// should seamlessly repeat from its starting point.
  repeat,

  /// Animation always plays in reverse (from end to start).
  ///
  /// **Behavior**: 1→0→1→0→1→0...
  ///
  /// Useful when the natural motion appears better in reverse or for
  /// countdown-like animations.
  reverse,

  /// Animation alternates between forward and reverse.
  ///
  /// **Behavior**: 0→1→0→1→0...
  ///
  /// Perfect for pulsating effects, breathing animations, or any
  /// motion that should smoothly oscillate between two states.
  pingPong,

  /// Same as pingPong, but starts with reverse animation.
  ///
  /// **Behavior**: 1→0→1→0→1...
  ///
  /// Like pingPong, but starting from the end value. Useful when the
  /// initial state should be the "expanded" or "highlighted" state.
  pingPongReverse,
}

/// {@template repeated_animation_builder}
/// # RepeatedAnimationBuilder
///
/// A widget that continuously animates between two values with various repeating behaviors.
///
/// This widget handles continuous animations that repeat indefinitely with configurable
/// patterns (repeat, reverse, ping-pong). Useful for creating loading spinners, pulsating
/// effects, breathing animations, and other continuous visual feedback elements.
///
/// ## Key Features
///
/// - **Multiple Repeat Modes**: Standard repeat, reverse, ping-pong, and ping-pong-reverse
/// - **Type-Safety**: Works with any type that can be interpolated
/// - **Play/Pause Control**: Animation can be paused and resumed
/// - **Custom Timing**: Separate forward and reverse durations with individual curves
///
/// ## Basic Usage
///
/// ```dart
/// // Pulsating circle
/// RepeatedAnimationBuilder<double>(
///   start: 0.8,
///   end: 1.2,
///   mode: RepeatMode.pingPong,
///   duration: Duration(seconds: 1),
///   curve: Curves.easeInOut,
///   builder: (context, scale, _) => Transform.scale(
///     scale: scale,
///     child: Container(
///       width: 100,
///       height: 100,
///       decoration: BoxDecoration(
///         shape: BoxShape.circle,
///         color: Colors.blue,
///       ),
///     ),
///   ),
/// )
/// ```
///
/// ## Animation Control
///
/// ```dart
/// RepeatedAnimationBuilder<double>(
///   start: 0.0,
///   end: 360.0,
///   play: _isPlaying, // Control animation with boolean
///   mode: RepeatMode.repeat,
///   duration: Duration(seconds: 2),
///   lerp: (a, b, t) => a + (b - a) * t, // Custom lerp for degrees
///   builder: (context, degrees, _) => Transform.rotate(
///     angle: degrees * 3.14 / 180, // Convert degrees to radians
///     child: Icon(Icons.refresh, size: 48),
///   ),
/// )
/// ```
///
/// ## Advanced: Different Forward/Reverse Durations
///
/// ```dart
/// RepeatedAnimationBuilder<Color>(
///   start: Colors.blue,
///   end: Colors.red,
///   mode: RepeatMode.pingPong,
///   duration: Duration(milliseconds: 1000),    // Forward duration
///   reverseDuration: Duration(milliseconds: 500), // Reverse duration (faster)
///   curve: Curves.easeOut,            // Forward curve
///   reverseCurve: Curves.bounceIn,    // Different reverse curve
///   lerp: Color.lerp,
///   builder: (context, color, _) => Container(
///     width: 100,
///     height: 100,
///     color: color,
///   ),
/// )
/// ```
/// {@endtemplate}
class RepeatedAnimationBuilder<T> extends StatefulWidget {
  /// {@template repeated_animation_builder_start}
  /// Start value of the animation.
  ///
  /// *Type*: `T`
  ///
  /// This is the initial value of the animation cycle.
  /// For [RepeatMode.pingPong], the animation cycles between [start] and [end].
  /// For [RepeatMode.repeat], the animation begins at this value.
  ///
  /// *Example*: `start: 0.0`
  /// {@endtemplate}
  final T start;

  /// {@template repeated_animation_builder_end}
  /// End value of the animation.
  ///
  /// *Type*: `T`
  ///
  /// This is the target value that the animation progresses toward.
  /// For [RepeatMode.pingPong], the animation cycles between [start] and [end].
  /// For [RepeatMode.repeat], the animation completes at this value before restarting.
  ///
  /// *Example*: `end: 1.0`
  /// {@endtemplate}
  final T end;

  /// {@template repeated_animation_builder_duration}
  /// Duration for forward animation.
  ///
  /// *Type*: `Duration`
  ///
  /// Controls how long the animation takes to go from [start] to [end].
  /// For [RepeatMode.pingPong], this is the time for the forward half of the cycle.
  ///
  /// *Example*: `duration: const Duration(milliseconds: 500)`
  /// {@endtemplate}
  final Duration duration;

  /// {@template repeated_animation_builder_reverseDuration}
  /// Optional different duration for reverse animation.
  ///
  /// *Type*: `Duration?`
  ///
  /// When provided, this controls the duration of the reverse phase (from [end] back to [start]).
  /// If not provided, [duration] is used for both forward and reverse phases.
  ///
  /// *Example*: `reverseDuration: const Duration(milliseconds: 800)`
  /// {@endtemplate}
  final Duration? reverseDuration;

  /// {@template repeated_animation_builder_curve}
  /// Curve for forward animation.
  ///
  /// *Type*: `Curve`
  ///
  /// Controls the rate of change for the forward phase of the animation.
  /// Default is [Curves.linear] for a constant rate of change.
  ///
  /// *Example*: `curve: Curves.easeOut`
  /// {@endtemplate}
  final Curve curve;

  /// {@template repeated_animation_builder_reverseCurve}
  /// Optional different curve for reverse animation.
  ///
  /// *Type*: `Curve?`
  ///
  /// When provided, controls the rate of change for the reverse phase of animation.
  /// If not provided, [curve] is used for both forward and reverse phases.
  ///
  /// *Example*: `reverseCurve: Curves.easeIn`
  /// {@endtemplate}
  final Curve? reverseCurve;

  /// {@template repeated_animation_builder_mode}
  /// How the animation should repeat.
  ///
  /// *Type*: `RepeatMode`
  ///
  /// - [RepeatMode.repeat] - Animation restarts from beginning (default)
  /// - [RepeatMode.reverse] - Animation always plays backwards
  /// - [RepeatMode.pingPong] - Animation alternates direction
  /// - [RepeatMode.pingPongReverse] - Like pingPong, but starts with reverse
  ///
  /// *Example*: `mode: RepeatMode.pingPong`
  /// {@endtemplate}
  final RepeatMode mode;

  /// {@template repeated_animation_builder_builder}
  /// Builder function receiving the interpolated value.
  ///
  /// *Type*: `Widget Function(BuildContext, T, Widget?)?`
  ///
  /// This function rebuilds with the current animated value on each frame.
  /// The third parameter is the optional [child] widget for optimization.
  ///
  /// *Example*:
  /// ```dart
  /// builder: (context, value, child) => Opacity(
  ///   opacity: value,
  ///   child: child,
  /// )
  /// ```
  /// {@endtemplate}
  final Widget Function(BuildContext context, T value, Widget? child)? builder;

  /// {@template repeated_animation_builder_animationBuilder}
  /// Builder function receiving the raw animation.
  ///
  /// *Type*: `Widget Function(BuildContext, Animation<T>)?`
  ///
  /// Provides direct access to the Animation`<`T`>` object for advanced use cases.
  /// Only present in the .animation constructor.
  ///
  /// *Example*:
  /// ```dart
  /// animationBuilder: (context, animation) => CustomPaint(
  ///   painter: MyAnimationPainter(animation),
  /// )
  /// ```
  /// {@endtemplate}
  final Widget Function(BuildContext context, Animation<T> animation)?
      animationBuilder;

  /// {@template repeated_animation_builder_child}
  /// Optional child widget passed to builder.
  ///
  /// *Type*: `Widget?`
  ///
  /// This widget is passed to the builder function and can be used to optimize
  /// rebuilds of child widgets that don't depend on the animated value.
  ///
  /// *Example*: `child: const Text('Hello')`
  /// {@endtemplate}
  final Widget? child;

  /// {@template repeated_animation_builder_lerp}
  /// Custom interpolation function for type T.
  ///
  /// *Type*: `T Function(T a, T b, double t)?`
  ///
  /// Defines how to interpolate between values of type T. Required for custom types.
  /// For built-in types like double or int, it uses standard mathematical interpolation.
  ///
  /// *Example*: `lerp: Color.lerp`
  /// {@endtemplate}
  final T Function(T a, T b, double t)? lerp;

  /// {@template repeated_animation_builder_play}
  /// Whether the animation is playing or paused.
  ///
  /// *Type*: `bool`
  ///
  /// - `true`: Animation plays normally (default)
  /// - `false`: Animation is paused at current position
  ///
  /// *Example*: `play: _isAnimating`
  /// {@endtemplate}
  final bool play;

  /// Creates a RepeatedAnimationBuilder with a standard builder.
  ///
  /// {@macro repeated_animation_builder}
  ///
  /// Use this constructor for typical repeated animations with interpolated values.
  ///
  /// ## Parameters:
  /// {@macro repeated_animation_builder_start}
  /// {@macro repeated_animation_builder_end}
  /// {@macro repeated_animation_builder_duration}
  /// {@macro repeated_animation_builder_curve}
  /// {@macro repeated_animation_builder_reverseCurve}
  /// {@macro repeated_animation_builder_mode}
  /// {@macro repeated_animation_builder_builder}
  /// {@macro repeated_animation_builder_child}
  /// {@macro repeated_animation_builder_lerp}
  /// {@macro repeated_animation_builder_play}
  /// {@macro repeated_animation_builder_reverseDuration}
  ///
  /// ## Example:
  /// ```dart
  /// RepeatedAnimationBuilder<double>(
  ///   start: 0.0,
  ///   end: 2 * pi,
  ///   duration: const Duration(seconds: 2),
  ///   mode: RepeatMode.repeat,
  ///   curve: Curves.linear,
  ///   builder: (context, angle, child) => Transform.rotate(
  ///     angle: angle,
  ///     child: child,
  ///   ),
  ///   child: const Icon(Icons.refresh, size: 48),
  /// )
  /// ```
  const RepeatedAnimationBuilder({
    super.key,
    required this.start,
    required this.end,
    required this.duration,
    this.curve = Curves.linear,
    this.reverseCurve,
    this.mode = RepeatMode.repeat,
    required this.builder,
    this.child,
    this.lerp,
    this.play = true,
    this.reverseDuration,
  }) : animationBuilder = null;

  /// Creates a RepeatedAnimationBuilder with access to the raw animation.
  ///
  /// This constructor provides direct access to the underlying Animation`<`T`>` object,
  /// which is useful for advanced animation scenarios like custom painters or
  /// integrating with other animation systems.
  ///
  /// ## Parameters:
  /// {@macro repeated_animation_builder_start}
  /// {@macro repeated_animation_builder_end}
  /// {@macro repeated_animation_builder_duration}
  /// {@macro repeated_animation_builder_curve}
  /// {@macro repeated_animation_builder_reverseCurve}
  /// {@macro repeated_animation_builder_mode}
  /// {@macro repeated_animation_builder_animationBuilder}
  /// {@macro repeated_animation_builder_child}
  /// {@macro repeated_animation_builder_lerp}
  /// {@macro repeated_animation_builder_play}
  /// {@macro repeated_animation_builder_reverseDuration}
  ///
  /// ## Example:
  /// ```dart
  /// RepeatedAnimationBuilder.animation<double>(
  ///   start: 0.0,
  ///   end: 1.0,
  ///   duration: const Duration(seconds: 1),
  ///   mode: RepeatMode.pingPong,
  ///   animationBuilder: (context, animation) {
  ///     return CustomPaint(
  ///       painter: WavePainter(animation: animation),
  ///       child: const SizedBox.expand(),
  ///     );
  ///   },
  /// )
  /// ```
  const RepeatedAnimationBuilder.animation({
    super.key,
    required this.start,
    required this.end,
    required this.duration,
    this.curve = Curves.linear,
    this.reverseCurve,
    this.mode = RepeatMode.repeat,
    required this.animationBuilder,
    this.child,
    this.lerp,
    this.play = true,
    this.reverseDuration,
  }) : builder = null;

  @override
  State<RepeatedAnimationBuilder<T>> createState() =>
      _RepeatedAnimationBuilderState<T>();
}

class _RepeatedAnimationBuilderState<T>
    extends State<RepeatedAnimationBuilder<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<T> _animation;
  bool _reverse = false;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  void _setupAnimation() {
    // Create animation controller
    _controller = AnimationController(vsync: this);

    // Configure based on repeat mode
    _reverse = widget.mode == RepeatMode.reverse ||
        widget.mode == RepeatMode.pingPongReverse;

    final Duration forwardDuration = _reverse
        ? (widget.reverseDuration ?? widget.duration)
        : widget.duration;

    final Duration reverseDuration = _reverse
        ? widget.duration
        : (widget.reverseDuration ?? widget.duration);

    _controller.duration = forwardDuration;
    _controller.reverseDuration = reverseDuration;

    // Setup curved animation
    final curve =
        _reverse ? (widget.reverseCurve ?? widget.curve) : widget.curve;
    final reverseCurve =
        _reverse ? widget.curve : (widget.reverseCurve ?? widget.curve);

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    // Setup animation with start and end values
    final T startValue = _reverse ? widget.end : widget.start;
    final T endValue = _reverse ? widget.start : widget.end;

    _animation = curvedAnimation.drive(
      _AnimatableValue<T>(
        start: startValue,
        end: endValue,
        lerp: _lerpValue,
      ),
    );

    // Setup repeat behavior
    _controller.addStatusListener(_handleAnimationStatus);

    // Start animation if play is true
    if (widget.play) {
      _controller.forward();
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    // Handle different repeat modes
    if (!widget.play) return;

    if (status == AnimationStatus.completed) {
      if (widget.mode == RepeatMode.pingPong ||
          widget.mode == RepeatMode.pingPongReverse) {
        _controller.reverse();
        _reverse = true;
      } else {
        _controller.reset();
        _controller.forward();
      }
    } else if (status == AnimationStatus.dismissed) {
      if (widget.mode == RepeatMode.pingPong ||
          widget.mode == RepeatMode.pingPongReverse) {
        _controller.forward();
        _reverse = false;
      } else {
        _controller.reset();
        _controller.forward();
      }
    }
  }

  T _lerpValue(T a, T b, double t) {
    if (widget.lerp != null) {
      return widget.lerp!(a, b, t);
    }

    try {
      // Try dynamic interpolation (works for num types)
      return (a as dynamic) + ((b as dynamic) - (a as dynamic)) * t;
    } catch (e) {
      throw UnsupportedError(
        'Cannot interpolate values of type ${T.toString()}. '
        'Provide a custom lerp function.',
      );
    }
  }

  @override
  void didUpdateWidget(covariant RepeatedAnimationBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needsRebuild = false;

    // Check if core animation properties changed
    if (oldWidget.start != widget.start ||
        oldWidget.end != widget.end ||
        oldWidget.curve != widget.curve ||
        oldWidget.reverseCurve != widget.reverseCurve ||
        oldWidget.mode != widget.mode ||
        oldWidget.duration != widget.duration ||
        oldWidget.reverseDuration != widget.reverseDuration) {
      needsRebuild = true;
    }

    // Handle play/pause state changes
    if (oldWidget.play != widget.play) {
      if (widget.play) {
        if (_reverse) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      } else {
        _controller.stop();
      }
    }

    // Rebuild animation if needed
    if (needsRebuild) {
      _controller.removeStatusListener(_handleAnimationStatus);
      _controller.dispose();
      _setupAnimation();
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!(context, _animation);
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return widget.builder!(context, _animation.value, child);
      },
      child: widget.child,
    );
  }
}

/// {@template interval_duration}
/// # IntervalDuration
///
/// A custom curve that maps animation progress to specific time intervals.
///
/// This class allows you to control how animations progress within precise time windows,
/// enabling effects like delayed starts, early completions, or isolating animations
/// to specific segments of a duration. This is particularly useful for creating
/// sequential or staggered animations.
///
/// ## Key Features
///
/// - **Time-Based Animation Control**: Define start/end points as durations
/// - **Delayed Animation Segments**: Easily create animations that wait before starting
/// - **Proportional Timing**: Map animation progress to specific time windows
/// - **Compound Curve Support**: Apply additional easing to the remapped interval
///
/// ## Basic Usage
///
/// ```dart
/// // Animation that only uses the middle 50% of duration:
/// AnimatedValueBuilder<double>(
///   value: 100.0,
///   duration: Duration(seconds: 2),
///   curve: IntervalDuration(
///     start: Duration(milliseconds: 500),
///     end: Duration(milliseconds: 1500),
///     duration: Duration(seconds: 2),
///   ),
///   builder: (context, value, _) => Container(width: value),
/// )
/// ```
///
/// ## Common Patterns
///
/// ### Delayed Start
/// ```dart
/// IntervalDuration.delayed(
///   startDelay: Duration(milliseconds: 500),
///   duration: Duration(seconds: 2),
/// )
/// ```
///
/// ### Early Completion
/// ```dart
/// IntervalDuration(
///   start: Duration.zero,
///   end: Duration(milliseconds: 1500),
///   duration: Duration(seconds: 2),
/// )
/// ```
///
/// ### With Additional Easing
/// ```dart
/// IntervalDuration(
///   start: Duration(milliseconds: 200),
///   end: Duration(milliseconds: 800),
///   duration: Duration(seconds: 1),
///   curve: Curves.easeOutBack,
/// )
/// ```
/// {@endtemplate}
class IntervalDuration extends Curve {
  /// {@template interval_duration_start}
  /// The start time of the active animation interval.
  ///
  /// *Type*: `Duration?`
  ///
  /// - Defines when the animation should begin within the total duration.
  /// - If `null`, animation starts immediately (at 0).
  /// - Any time before this is treated as 0% progress.
  ///
  /// *Example*: `start: Duration(milliseconds: 200)`
  /// {@endtemplate}
  final Duration? start;

  /// {@template interval_duration_end}
  /// The end time of the active animation interval.
  ///
  /// *Type*: `Duration?`
  ///
  /// - Defines when the animation should complete within the total duration.
  /// - If `null`, animation ends at the total duration.
  /// - Any time after this is treated as 100% progress.
  ///
  /// *Example*: `end: Duration(milliseconds: 800)`
  /// {@endtemplate}
  final Duration? end;

  /// {@template interval_duration_duration}
  /// The total duration of the animation context.
  ///
  /// *Type*: `Duration`
  ///
  /// - The full time span in which the interval is defined.
  /// - Start and end times are relative to this duration.
  ///
  /// *Example*: `duration: Duration(seconds: 1)`
  /// {@endtemplate}
  final Duration duration;

  /// {@template interval_duration_curve}
  /// Optional curve to apply within the interval.
  ///
  /// *Type*: `Curve?`
  ///
  /// - Additional easing to apply to the remapped time.
  /// - Applied after the time interval mapping.
  /// - If `null`, linear progression is used within the interval.
  ///
  /// *Example*: `curve: Curves.easeOut`
  /// {@endtemplate}
  final Curve? curve;

  /// Creates an [IntervalDuration] with the provided configuration.
  ///
  /// {@macro interval_duration}
  ///
  /// Use this constructor to precisely define start and end times for your animation interval.
  ///
  /// ## Parameters:
  /// {@macro interval_duration_start}
  /// {@macro interval_duration_end}
  /// {@macro interval_duration_duration}
  /// {@macro interval_duration_curve}
  ///
  /// ## Example:
  /// ```dart
  /// // Animation progresses only between 0.25s and 0.75s of a 1s animation
  /// IntervalDuration(
  ///   start: Duration(milliseconds: 250),
  ///   end: Duration(milliseconds: 750),
  ///   duration: Duration(seconds: 1),
  ///   curve: Curves.easeInOut,
  /// )
  /// ```
  const IntervalDuration({
    this.start,
    this.end,
    required this.duration,
    this.curve,
  });

  /// Creates an interval with delays at the start and/or end of the animation.
  ///
  /// This factory constructor makes it easy to create common delay patterns:
  /// - Delay before starting the animation
  /// - Early completion of the animation
  /// - Both start and end delays
  ///
  /// ## Parameters:
  /// - **startDelay**: How long to wait before beginning the animation
  /// - **endDelay**: How long before the total duration to complete the animation
  /// - **duration**: The context duration for the animation
  ///
  /// ## Examples:
  /// ```dart
  /// // Delay animation start by 200ms
  /// IntervalDuration.delayed(
  ///   startDelay: Duration(milliseconds: 200),
  ///   duration: Duration(seconds: 1),
  /// )
  ///
  /// // Complete animation 200ms early
  /// IntervalDuration.delayed(
  ///   endDelay: Duration(milliseconds: 200),
  ///   duration: Duration(seconds: 1),
  /// )
  ///
  /// // Animation runs only in the middle 600ms of a 1s duration
  /// IntervalDuration.delayed(
  ///   startDelay: Duration(milliseconds: 200),
  ///   endDelay: Duration(milliseconds: 200),
  ///   duration: Duration(seconds: 1),
  /// )
  /// ```
  factory IntervalDuration.delayed({
    Duration? startDelay,
    Duration? endDelay,
    required Duration duration,
  }) {
    final totalDuration =
        duration + (startDelay ?? Duration.zero) + (endDelay ?? Duration.zero);

    return IntervalDuration(
      start: startDelay,
      end: endDelay == null ? null : totalDuration - endDelay,
      duration: totalDuration,
    );
  }

  @override
  double transform(double t) {
    // Calculate interval boundaries as fractions of total duration
    final double startFraction = start?.inMicroseconds.toDouble() ?? 0.0;
    final double endFraction =
        end?.inMicroseconds.toDouble() ?? duration.inMicroseconds.toDouble();

    final double normalizedStart = startFraction / duration.inMicroseconds;
    final double normalizedEnd = endFraction / duration.inMicroseconds;

    // Map input time to interval
    final double intervalRange = normalizedEnd - normalizedStart;
    final double mappedProgress =
        ((t - normalizedStart) / intervalRange).clamp(0.0, 1.0);

    // Apply additional curve if provided
    return curve != null ? curve!.transform(mappedProgress) : mappedProgress;
  }
}

/// {@template cross_faded_transition}
/// # CrossFadedTransition
///
/// A widget that intelligently cross-fades between children when they change.
///
/// This widget detects child changes and automatically creates a smooth transition
/// between the previous and new child. It's perfect for content that changes based
/// on state, user input, or data loading, providing a polished user experience.
///
/// ## Key Features
///
/// - **Automatic Detection**: Automatically cross-fades when child widget changes
/// - **Customizable Transitions**: Choose from built-in transition styles or create your own
/// - **Size Animation**: Smoothly animates between differently sized children
/// - **Alignment Control**: Define how children align during the transition
///
/// ## Built-in Transition Types
///
/// - **lerpOpacity**: Standard cross-fade with opacity (default)
/// - **lerpStep**: Immediate switch with no blending
///
/// ## Basic Usage
///
/// ```dart
/// CrossFadedTransition(
///   duration: Duration(milliseconds: 300),
///   child: _isLoading
///     ? CircularProgressIndicator()
///     : Text('Content Loaded!'),
/// )
/// ```
///
/// ## Custom Transition Effects
///
/// ```dart
/// CrossFadedTransition(
///   duration: Duration(milliseconds: 400),
///   alignment: Alignment.centerLeft,
///   lerp: (oldChild, newChild, t, {alignment}) {
///     return Stack(
///       children: [
///         Positioned.fill(
///           child: Transform.translate(
///             offset: Offset(-100 * (1-t), 0),
///             child: Opacity(opacity: 1-t, child: oldChild),
///           ),
///         ),
///         Transform.translate(
///           offset: Offset(100 * (1-t), 0),
///           child: Opacity(opacity: t, child: newChild),
///         ),
///       ],
///     );
///   },
///   child: _currentPage,
/// )
/// ```
/// {@endtemplate}
class CrossFadedTransition extends StatefulWidget {
  /// Cross-fade transition with opacity.
  ///
  /// *Type*: `static Widget Function(Widget, Widget, double, {AlignmentGeometry alignment})`
  ///
  /// Standard cross-fade effect where one widget fades out while the other fades in.
  /// First widget fades out from t=0.0 to t=0.5, then second widget fades in from t=0.5 to t=1.0.
  ///
  /// *Parameters:*
  /// - **a**: First (outgoing) widget
  /// - **b**: Second (incoming) widget
  /// - **t**: Progress from 0.0 to 1.0
  /// - **alignment**: How to align widgets during transition
  ///
  /// *Example:*
  /// ```dart
  /// CrossFadedTransition(
  ///   lerp: CrossFadedTransition.lerpOpacity,
  ///   child: myWidget,
  /// )
  /// ```
  static Widget lerpOpacity(Widget a, Widget b, double t,
      {AlignmentGeometry alignment = Alignment.center}) {
    // Optimize for boundary cases
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;

    // Calculate opacities for cross-fade effect
    final double startOpacity = 1.0 - (t.clamp(0.0, 0.5) * 2.0);
    final double endOpacity = (t.clamp(0.5, 1.0) * 2.0) - 1.0;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: Opacity(
            opacity: startOpacity,
            child: Align(
              alignment: alignment,
              child: a,
            ),
          ),
        ),
        Opacity(
          opacity: endOpacity,
          child: b,
        ),
      ],
    );
  }

  /// Immediate transition with no blending.
  ///
  /// *Type*: `static Widget Function(Widget, Widget, double, {AlignmentGeometry alignment})`
  ///
  /// Simple transition that switches immediately at the halfway point (t=0.5).
  /// Shows first widget for t < 0.5, then switches to second widget.
  ///
  /// *Parameters:*
  /// - **a**: First (outgoing) widget
  /// - **b**: Second (incoming) widget
  /// - **t**: Progress from 0.0 to 1.0
  /// - **alignment**: How to align widgets during transition
  ///
  /// *Example:*
  /// ```dart
  /// CrossFadedTransition(
  ///   lerp: CrossFadedTransition.lerpStep,
  ///   child: myWidget,
  /// )
  /// ```
  static Widget lerpStep(Widget a, Widget b, double t,
      {AlignmentGeometry alignment = Alignment.center}) {
    return t < 0.5 ? a : b;
  }

  /// {@template cross_faded_transition_child}
  /// The current child widget to show.
  ///
  /// *Type*: `Widget`
  ///
  /// When this widget changes (compared by key), a transition will automatically
  /// occur between the previous and new child.
  ///
  /// *Example*: `child: _isLoading ? LoadingSpinner() : ContentView()`
  /// {@endtemplate}
  final Widget child;

  /// {@template cross_faded_transition_duration}
  /// Duration of the transition.
  ///
  /// *Type*: `Duration`
  ///
  /// Controls how long the transition animation takes to complete.
  /// Default is 300 milliseconds.
  ///
  /// *Example*: `duration: const Duration(milliseconds: 500)`
  /// {@endtemplate}
  final Duration duration;

  /// {@template cross_faded_transition_alignment}
  /// Alignment for the transition.
  ///
  /// *Type*: `AlignmentGeometry`
  ///
  /// Controls how the child widgets are aligned during the transition.
  /// Default is center alignment.
  ///
  /// *Example*: `alignment: Alignment.bottomLeft`
  /// {@endtemplate}
  final AlignmentGeometry alignment;

  /// {@template cross_faded_transition_lerp}
  /// Function to interpolate between widgets.
  ///
  /// *Type*: `Widget Function(Widget a, Widget b, double t, {AlignmentGeometry alignment})`
  ///
  /// Controls the visual transition between widgets:
  /// - **a**: The outgoing (previous) widget
  /// - **b**: The incoming (new) widget
  /// - **t**: Animation progress from 0.0 to 1.0
  ///
  /// Default is [lerpOpacity].
  ///
  /// *Example*:
  /// ```dart
  /// lerp: (a, b, t, {alignment}) => Stack(
  ///   children: [
  ///     Opacity(opacity: 1-t, child: a),
  ///     Opacity(opacity: t, child: b),
  ///   ],
  /// )
  /// ```
  /// {@endtemplate}
  final Widget Function(Widget a, Widget b, double t,
      {AlignmentGeometry alignment}) lerp;

  /// Creates a [CrossFadedTransition] with the provided configuration.
  ///
  /// {@macro cross_faded_transition}
  ///
  /// ## Parameters:
  /// {@macro cross_faded_transition_child}
  /// {@macro cross_faded_transition_duration}
  /// {@macro cross_faded_transition_alignment}
  /// {@macro cross_faded_transition_lerp}
  ///
  /// ## Example:
  /// ```dart
  /// CrossFadedTransition(
  ///   duration: const Duration(milliseconds: 400),
  ///   alignment: Alignment.center,
  ///   child: _showDetails
  ///     ? DetailView(product: product)
  ///     : SummaryView(product: product),
  /// )
  /// ```
  const CrossFadedTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.alignment = Alignment.center,
    this.lerp = lerpOpacity,
  });

  @override
  State<CrossFadedTransition> createState() => _CrossFadedTransitionState();
}

class _CrossFadedTransitionState extends State<CrossFadedTransition> {
  Widget? _oldChild;
  late Widget _currentChild;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
  }

  @override
  void didUpdateWidget(covariant CrossFadedTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only transition if the child widget actually changed
    if (oldWidget.child.key != widget.child.key) {
      _oldChild = _currentChild;
      _currentChild = widget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    // If no transition is needed, just return the current child
    if (_oldChild == null) {
      return widget.child;
    }

    // Otherwise animate between old and new child
    return AnimatedSize(
      alignment: widget.alignment,
      duration: widget.duration,
      child: AnimatedValueBuilder<Widget>(
        value: _currentChild,
        initialValue: _oldChild,
        duration: widget.duration,
        lerp: (a, b, t) => widget.lerp(a, b, t, alignment: widget.alignment),
        onEnd: (_) => setState(() => _oldChild = null),
        builder: (context, value, _) => value,
      ),
    );
  }
}
