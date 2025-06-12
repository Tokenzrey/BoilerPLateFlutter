import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

// ======================= TYPE DEFINITIONS =======================
/// Builder function for animated child widgets
typedef AnimatedChildBuilder<T> = Widget Function(
    BuildContext context, T value, Widget? child);

/// Builder function for working directly with animations
typedef AnimationBuilder<T> = Widget Function(
    BuildContext context, Animation<T> animation);

/// Builder function for transitions between old and new values
typedef AnimatedChildValueBuilder<T> = Widget Function(
    BuildContext context, T oldValue, T newValue, double t, Widget? child);

/// Lerp function for interpolating between values
typedef PropertyLerp<T> = T? Function(T? a, T? b, double t);

// ======================= VALUE INTERPOLATION =======================
/// Utility class for interpolating between values
class AnimatableValue<T> extends Tween<T> {
  final PropertyLerp<T> lerpFunction;

  AnimatableValue({
    required T begin,
    required T end,
    required this.lerpFunction,
  }) : super(begin: begin, end: end);

  @override
  T lerp(double t) {
    return lerpFunction(begin, end, t)!;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimatableValue<T> &&
        other.begin == begin &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(begin, end);
}

/// Core animation transformers for common types
class Transformers {
  static double? typeDouble(double? a, double? b, double t) {
    if (a == null || b == null) return null;
    return a + (b - a) * t;
  }

  static int? typeInt(int? a, int? b, double t) {
    if (a == null || b == null) return null;
    return (a + (b - a) * t).round();
  }

  static Color? typeColor(Color? a, Color? b, double t) {
    if (a == null || b == null) return null;
    return Color.lerp(a, b, t);
  }

  static Offset? typeOffset(Offset? a, Offset? b, double t) {
    if (a == null || b == null) return null;
    return Offset(
      typeDouble(a.dx, b.dx, t)!,
      typeDouble(a.dy, b.dy, t)!,
    );
  }

  static Size? typeSize(Size? a, Size? b, double t) {
    if (a == null || b == null) return null;
    return Size(
      typeDouble(a.width, b.width, t)!,
      typeDouble(a.height, b.height, t)!,
    );
  }

  static EdgeInsets? typeEdgeInsets(EdgeInsets? a, EdgeInsets? b, double t) {
    if (a == null || b == null) return null;
    return EdgeInsets.lerp(a, b, t);
  }

  static BorderRadius? typeBorderRadius(
      BorderRadius? a, BorderRadius? b, double t) {
    if (a == null || b == null) return null;
    return BorderRadius.lerp(a, b, t);
  }

  static BoxConstraints? typeBoxConstraints(
      BoxConstraints? a, BoxConstraints? b, double t) {
    if (a == null || b == null) return null;
    return BoxConstraints.lerp(a, b, t);
  }

  static Alignment? typeAlignment(Alignment? a, Alignment? b, double t) {
    if (a == null || b == null) return null;
    return Alignment.lerp(a, b, t);
  }

  /// Get a lerp function for a specific type
  static PropertyLerp<T> getLerpForType<T>() {
    if (T == double) return typeDouble as PropertyLerp<T>;
    if (T == int) return typeInt as PropertyLerp<T>;
    if (T == Color) return typeColor as PropertyLerp<T>;
    if (T == Offset) return typeOffset as PropertyLerp<T>;
    if (T == Size) return typeSize as PropertyLerp<T>;
    if (T == EdgeInsets) return typeEdgeInsets as PropertyLerp<T>;
    if (T == BorderRadius) return typeBorderRadius as PropertyLerp<T>;
    if (T == BoxConstraints) return typeBoxConstraints as PropertyLerp<T>;
    if (T == Alignment) return typeAlignment as PropertyLerp<T>;

    // Default lerp for numeric types
    return defaultLerp as PropertyLerp<T>;
  }

  /// Default lerp for numeric types using dynamic casting
  static T? defaultLerp<T>(T? a, T? b, double t) {
    if (a == null || b == null) return null;
    try {
      return (a as dynamic) + ((b as dynamic) - (a as dynamic)) * t;
    } catch (e) {
      throw UnsupportedError(
        'Cannot interpolate values of type ${T.toString()}. '
        'Provide a custom lerp function.',
      );
    }
  }
}

// ======================= ANIMATION CONTROLS =======================
/// Controlled animation that wraps an AnimationController
class ControlledAnimation extends Animation<double> {
  final AnimationController _controller;

  ControlledAnimation(this._controller);

  double _from = 0;
  double _to = 1;
  Curve _curve = Curves.linear;

  /// Move the animation forward to a specified value
  TickerFuture forward(double to, [Curve? curve]) {
    _from = value;
    _to = to;
    _curve = curve ?? Curves.linear;
    return _controller.forward(from: 0);
  }

  /// Immediately set the animation's value
  set value(double value) {
    _from = value;
    _to = value;
    _curve = Curves.linear;
    _controller.value = 0;
  }

  @override
  void addListener(VoidCallback listener) {
    _controller.addListener(listener);
  }

  @override
  void addStatusListener(AnimationStatusListener listener) {
    _controller.addStatusListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _controller.removeListener(listener);
  }

  @override
  void removeStatusListener(AnimationStatusListener listener) {
    _controller.removeStatusListener(listener);
  }

  @override
  AnimationStatus get status => _controller.status;

  @override
  double get value =>
      _from + (_to - _from) * _curve.transform(_controller.value);
}

/// Queue-based animation controller
class AnimationQueueController extends ChangeNotifier {
  double _value;

  AnimationQueueController([this._value = 0.0]);

  List<AnimationRequest> _requests = [];
  AnimationRunner? _runner;

  /// Queue an animation request
  void push(AnimationRequest request, [bool queue = true]) {
    if (queue) {
      _requests.add(request);
    } else {
      _runner = null;
      _requests = [request];
    }
    _runner ??= AnimationRunner(
        _value, request.target, request.duration, request.curve);
    notifyListeners();
  }

  /// Set the animation value directly
  set value(double value) {
    _value = value;
    _runner = null;
    _requests.clear();
    notifyListeners();
  }

  double get value => _value;

  bool get shouldTick => _runner != null || _requests.isNotEmpty;

  /// Update the animation based on elapsed time
  void tick(Duration delta) {
    if (_requests.isNotEmpty) {
      final request = _requests.removeAt(0);
      _runner = AnimationRunner(
          _value, request.target, request.duration, request.curve);
    }
    final runner = _runner;
    if (runner != null) {
      if (runner.duration.inMilliseconds <= 0) {
        _value = runner.to;
        _runner = null;
        notifyListeners();
        return;
      }

      runner._progress += delta.inMilliseconds / runner.duration.inMilliseconds;
      _value = runner.from +
          (runner.to - runner.from) *
              runner.curve.transform(runner._progress.clamp(0, 1));
      if (runner._progress >= 1.0) {
        _runner = null;
      }
      notifyListeners();
    }
  }
}

/// An animation request for the queue
class AnimationRequest {
  final double target;
  final Duration duration;
  final Curve curve;

  AnimationRequest(this.target, this.duration, this.curve);
}

/// The runner for an animation request
class AnimationRunner {
  final double from;
  final double to;
  final Duration duration;
  final Curve curve;
  double _progress = 0.0;

  AnimationRunner(this.from, this.to, this.duration, this.curve) {
    assert(duration.inMilliseconds > 0, 'Animation duration must be positive');
  }
}

// ======================= ANIMATED PROPERTIES =======================
/// Mixin for creating animated properties
mixin AnimatedMixin<T extends StatefulWidget> on TickerProviderStateMixin<T> {
  final List<AnimatedProperty> _animatedProperties = [];

  /// Create a new animated property with a custom lerp function
  AnimatedProperty<V> createAnimatedProperty<V>(
    V initialValue,
    PropertyLerp<V> lerp, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final property =
        AnimatedProperty<V>._(this, initialValue, lerp, setState, duration);
    _animatedProperties.add(property);
    return property;
  }

  @override
  void dispose() {
    for (final property in _animatedProperties) {
      property.dispose();
    }
    super.dispose();
  }

  /// Create an animated integer property
  AnimatedProperty<int> createAnimatedInt(
    int value, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return createAnimatedProperty<int>(
      value,
      Transformers.typeInt,
      duration: duration,
    );
  }

  /// Create an animated double property
  AnimatedProperty<double> createAnimatedDouble(
    double value, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return createAnimatedProperty<double>(
      value,
      Transformers.typeDouble,
      duration: duration,
    );
  }

  /// Create an animated color property
  AnimatedProperty<Color> createAnimatedColor(
    Color value, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return createAnimatedProperty<Color>(
      value,
      Transformers.typeColor,
      duration: duration,
    );
  }

  /// Create an animated offset property
  AnimatedProperty<Offset> createAnimatedOffset(
    Offset value, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return createAnimatedProperty<Offset>(
      value,
      Transformers.typeOffset,
      duration: duration,
    );
  }

  /// Create an animated size property
  AnimatedProperty<Size> createAnimatedSize(
    Size value, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return createAnimatedProperty<Size>(
      value,
      Transformers.typeSize,
      duration: duration,
    );
  }
}

/// An animatable property
class AnimatedProperty<T> {
  void _empty() {}
  final TickerProvider _vsync;
  final PropertyLerp<T> _lerp;
  T _value;
  bool _animating = false;
  Duration _duration;
  late T _target;
  late AnimationController _controller;
  Curve _curve = Curves.easeOutCubic;

  AnimatedProperty._(this._vsync, this._value, this._lerp,
      Function(VoidCallback callback) update, this._duration) {
    _controller = AnimationController(vsync: _vsync, duration: _duration);
    _controller.addListener(() {
      update(_empty);
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _value = _target;
        _animating = false;
      }
    });
  }

  /// Get the current animated value
  T get value {
    if (_animating) {
      return _lerp(_value, _target, _controller.value)!;
    }
    return _value;
  }

  /// Set a new target value and animate to it
  set value(T newValue) {
    if (_value == newValue) return;

    _animating = true;
    _target = newValue;
    _controller.stop();
    _controller.duration = _duration;
    _controller.forward(from: 0.0);
  }

  /// Set a new target value with custom duration and curve
  void animateTo(T newValue, {Duration? duration, Curve? curve}) {
    if (_value == newValue) return;

    _animating = true;
    _target = newValue;
    _controller.stop();
    _controller.duration = duration ?? _duration;
    _curve = curve ?? _curve;
    _controller.forward(from: 0.0);
  }

  /// Set the value immediately without animation
  void setValueWithoutAnimation(T newValue) {
    _animating = false;
    _value = newValue;
    _target = newValue;
    _controller.value = 0;
  }

  void cancel() {
    _controller.stop();
    _controller.reset();
  }

  /// Change the default duration for future animations
  set duration(Duration duration) {
    assert(duration.inMilliseconds > 0, 'Animation duration must be positive');
    _duration = duration;
  }

  /// Dispose the animation controller
  void dispose() {
    _controller.dispose();
  }
}

// ======================= ANIMATION WIDGETS =======================
/// Widget for animating between values
class AnimatedValueBuilder<T> extends StatefulWidget {
  final T? initialValue;
  final T value;
  final Duration duration;
  final AnimatedChildBuilder<T>? builder;
  final AnimationBuilder<T>? animationBuilder;
  final AnimatedChildValueBuilder<T>? rawBuilder;
  final void Function(T value)? onEnd;
  final Curve curve;
  final PropertyLerp<T>? lerp;
  final Widget? child;

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

class _AnimatedValueBuilderState<T> extends State<AnimatedValueBuilder<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<T> _animation;
  late T _currentValue;
  late PropertyLerp<T> _lerpFunction;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue ?? widget.value;
    _setupLerpFunction();
    _setupAnimation();

    if (widget.initialValue != null) {
      _controller.forward();
    }
  }

  void _setupLerpFunction() {
    _lerpFunction = widget.lerp ?? Transformers.getLerpForType<T>();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    _animation = AnimatableValue<T>(
      begin: _currentValue,
      end: widget.value,
      lerpFunction: _lerpFunction,
    ).animate(curvedAnimation);

    _controller.addStatusListener(_handleAnimationStatus);
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && widget.onEnd != null) {
      widget.onEnd!(widget.value);
    }
  }

  @override
  void didUpdateWidget(AnimatedValueBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.lerp != oldWidget.lerp) {
      _setupLerpFunction();
    }

    _currentValue = _animation.value;

    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }

    if (oldWidget.value != widget.value || oldWidget.lerp != widget.lerp) {
      final Animation<double> curvedAnimation = CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      );

      _animation = AnimatableValue<T>(
        begin: _currentValue,
        end: widget.value,
        lerpFunction: _lerpFunction,
      ).animate(curvedAnimation);

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
    if (widget.animationBuilder != null) {
      return widget.animationBuilder!(context, _animation);
    }

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

/// Repeat modes for animations
enum RepeatMode {
  repeat, // Restart from beginning
  reverse, // Play in reverse
  pingPong, // Forward then reverse
  pingPongReverse, // Reverse then forward
}

/// Widget for creating repeating animations
class RepeatedAnimationBuilder<T> extends StatefulWidget {
  final T start;
  final T end;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final Curve? reverseCurve;
  final RepeatMode mode;
  final Widget Function(BuildContext context, T value, Widget? child)? builder;
  final Widget Function(BuildContext context, Animation<T> animation)?
      animationBuilder;
  final Widget? child;
  final PropertyLerp<T>? lerp;
  final bool play;

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
  late PropertyLerp<T> _lerpFunction;

  @override
  void initState() {
    super.initState();
    _setupLerpFunction();
    _setupAnimation();
  }

  void _setupLerpFunction() {
    _lerpFunction = widget.lerp ?? Transformers.getLerpForType<T>();
  }

  void _setupAnimation() {
    _controller = AnimationController(vsync: this);

    _reverse = widget.mode == RepeatMode.reverse ||
        widget.mode == RepeatMode.pingPongReverse;

    final Duration forwardDuration = widget.duration;
    final Duration reverseDuration = widget.reverseDuration ?? widget.duration;

    _controller.duration = _reverse ? reverseDuration : forwardDuration;
    _controller.reverseDuration = _reverse ? forwardDuration : reverseDuration;

    final curve =
        _reverse ? (widget.reverseCurve ?? widget.curve) : widget.curve;
    final reverseCurve =
        _reverse ? widget.curve : (widget.reverseCurve ?? widget.curve);

    final curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: curve,
      reverseCurve: reverseCurve,
    );

    final T startValue = _reverse ? widget.end : widget.start;
    final T endValue = _reverse ? widget.start : widget.end;

    _animation = AnimatableValue<T>(
      begin: startValue,
      end: endValue,
      lerpFunction: _lerpFunction,
    ).animate(curvedAnimation);

    _controller.addStatusListener(_handleAnimationStatus);

    if (widget.play) {
      _controller.forward();
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (!widget.play) return;

    switch (widget.mode) {
      case RepeatMode.repeat:
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
        break;
      case RepeatMode.reverse:
        if (status == AnimationStatus.completed) {
          _controller.reset();
          _controller.forward();
        }
        break;
      case RepeatMode.pingPong:
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
        break;
      case RepeatMode.pingPongReverse:
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
        break;
    }
  }

  @override
  void didUpdateWidget(covariant RepeatedAnimationBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool needsRebuild = false;

    if (oldWidget.start != widget.start ||
        oldWidget.end != widget.end ||
        oldWidget.curve != widget.curve ||
        oldWidget.reverseCurve != widget.reverseCurve ||
        oldWidget.mode != widget.mode ||
        oldWidget.duration != widget.duration ||
        oldWidget.reverseDuration != widget.reverseDuration ||
        oldWidget.lerp != widget.lerp) {
      needsRebuild = true;
    }

    if (oldWidget.play != widget.play) {
      if (widget.play) {
        if (_controller.status == AnimationStatus.reverse) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      } else {
        _controller.stop();
      }
    }

    if (needsRebuild) {
      _controller.removeStatusListener(_handleAnimationStatus);
      _controller.dispose();
      _setupLerpFunction();
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

/// A curve that represents an interval within a duration
class IntervalDuration extends Curve {
  final Duration? start;
  final Duration? end;
  final Duration duration;
  final Curve? curve;

  IntervalDuration({
    this.start,
    this.end,
    required this.duration,
    this.curve,
  }) {
    if (duration.inMicroseconds <= 0) {
      throw ArgumentError('Duration must be positive');
    }
  }

  factory IntervalDuration.delayed({
    Duration? startDelay,
    Duration? endDelay,
    required Duration duration,
  }) {
    if (duration.inMicroseconds <= 0) {
      throw ArgumentError('Duration must be positive');
    }

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
    if (duration.inMicroseconds <= 0) return 0.0;

    final double startFraction = start?.inMicroseconds.toDouble() ?? 0.0;
    final double endFraction =
        end?.inMicroseconds.toDouble() ?? duration.inMicroseconds.toDouble();

    final double normalizedStart = startFraction / duration.inMicroseconds;
    final double normalizedEnd = endFraction / duration.inMicroseconds;

    if (normalizedEnd <= normalizedStart) return 0.0;

    final double intervalRange = normalizedEnd - normalizedStart;
    final double mappedProgress =
        ((t - normalizedStart) / intervalRange).clamp(0.0, 1.0);

    return curve != null ? curve!.transform(mappedProgress) : mappedProgress;
  }
}

/// Widget for cross-fading between two widgets
class CrossFadedTransition extends StatefulWidget {
  /// Lerp function for opacity-based crossfade
  static Widget lerpOpacity(Widget a, Widget b, double t,
      {AlignmentGeometry alignment = Alignment.center}) {
    if (t <= 0.0) return a;
    if (t >= 1.0) return b;

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

  /// Lerp function for step-based transition
  static Widget lerpStep(Widget a, Widget b, double t,
      {AlignmentGeometry alignment = Alignment.center}) {
    return t < 0.5 ? a : b;
  }

  final Widget child;
  final Duration duration;
  final AlignmentGeometry alignment;
  final Widget Function(Widget a, Widget b, double t,
      {AlignmentGeometry alignment}) lerp;
  final Object? compareKey;

  const CrossFadedTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.alignment = Alignment.center,
    this.lerp = lerpOpacity,
    this.compareKey,
  });

  @override
  State<CrossFadedTransition> createState() => _CrossFadedTransitionState();
}

class _CrossFadedTransitionState extends State<CrossFadedTransition> {
  Widget? _oldChild;
  late Widget _currentChild;
  Object? _lastCompareKey;

  @override
  void initState() {
    super.initState();
    _currentChild = widget.child;
    _lastCompareKey = widget.compareKey ?? widget.child.key;
  }

  @override
  void didUpdateWidget(covariant CrossFadedTransition oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentKey = widget.compareKey ?? widget.child.key;
    final hasChanged = (_lastCompareKey != currentKey) ||
        (widget.compareKey == null && widget.child != oldWidget.child);

    if (hasChanged) {
      _oldChild = _currentChild;
      _currentChild = widget.child;
      _lastCompareKey = currentKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_oldChild == null) {
      return widget.child;
    }

    return AnimatedSize(
      alignment: widget.alignment,
      duration: widget.duration,
      child: AnimatedValueBuilder<Widget>(
        value: _currentChild,
        initialValue: _oldChild,
        duration: widget.duration,
        lerp: (a, b, t) => widget.lerp(a!, b!, t, alignment: widget.alignment),
        onEnd: (_) => setState(() => _oldChild = null),
        builder: (context, value, _) => value,
      ),
    );
  }
}

// ======================= TIMELINE ANIMATIONS =======================

/// Base class for keyframes
abstract class Keyframe<T> {
  Duration get duration;
  T compute(TimelineAnimation<T> timeline, int index, double t);
}

/// Keyframe with absolute start and end values
class AbsoluteKeyframe<T> implements Keyframe<T> {
  final T from;
  final T to;
  @override
  final Duration duration;

  AbsoluteKeyframe(
    this.duration,
    this.from,
    this.to,
  ) {
    if (duration.inMilliseconds <= 0) {
      throw ArgumentError('Duration must be positive');
    }
  }

  @override
  T compute(TimelineAnimation<T> timeline, int index, double t) {
    return timeline.lerp(from!, to!, t)!;
  }
}

/// Keyframe with a target value relative to the previous keyframe
class RelativeKeyframe<T> implements Keyframe<T> {
  final T target;
  @override
  final Duration duration;

  RelativeKeyframe(
    this.duration,
    this.target,
  ) {
    if (duration.inMilliseconds <= 0) {
      throw ArgumentError('Duration must be positive');
    }
  }

  @override
  T compute(TimelineAnimation<T> timeline, int index, double t) {
    if (index <= 0) {
      // act as still keyframe when there is no previous keyframe
      return target;
    }
    final previous =
        timeline.keyframes[index - 1].compute(timeline, index - 1, 1.0);
    return timeline.lerp(previous!, target!, t)!;
  }
}

/// Keyframe that maintains a value for a duration
class StillKeyframe<T> implements Keyframe<T> {
  final T? value;
  @override
  final Duration duration;

  StillKeyframe(this.duration, [this.value]) {
    if (duration.inMilliseconds <= 0) {
      throw ArgumentError('Duration must be positive');
    }
  }

  @override
  T compute(TimelineAnimation<T> timeline, int index, double t) {
    var value = this.value;
    if (value == null) {
      if (index <= 0) {
        throw ArgumentError(
            'Relative still keyframe must have a previous keyframe');
      }
      value = timeline.keyframes[index - 1].compute(timeline, index - 1, 1.0);
    }
    return value as T;
  }
}

/// Animatable that drives a timeline animation
class TimelineAnimatable<T> extends Animatable<T> {
  final Duration duration;
  final TimelineAnimation<T> animation;

  TimelineAnimatable(this.duration, this.animation) {
    if (duration.inMilliseconds <= 0) {
      throw ArgumentError('Duration must be positive');
    }
  }

  @override
  T transform(double t) {
    t = t.clamp(0.0, 1.0);

    final Duration selfDuration = animation.totalDuration;
    if (selfDuration.inMilliseconds <= 0) {
      return animation.keyframes.first.compute(animation, 0, 0);
    }

    double selfT = (t * selfDuration.inMilliseconds) / duration.inMilliseconds;
    selfT = selfT.clamp(0.0, 1.0);
    return animation.transform(selfT);
  }
}

/// Animation that follows a timeline defined by keyframes
class TimelineAnimation<T> extends Animatable<T> {
  static T defaultLerp<T>(T a, T b, double t) {
    return Transformers.defaultLerp(a, b, t) as T;
  }

  final PropertyLerp<T> lerp;
  final Duration totalDuration;
  final List<Keyframe<T>> keyframes;

  TimelineAnimation._({
    required this.lerp,
    required this.totalDuration,
    required this.keyframes,
  });

  factory TimelineAnimation({
    PropertyLerp<T>? lerp,
    required List<Keyframe<T>> keyframes,
  }) {
    if (keyframes.isEmpty) {
      throw ArgumentError('No keyframes found');
    }

    lerp ??= defaultLerp;
    Duration current = Duration.zero;
    for (var i = 0; i < keyframes.length; i++) {
      final keyframe = keyframes[i];
      if (keyframe.duration.inMilliseconds <= 0) {
        throw ArgumentError('Invalid duration for keyframe $i');
      }
      current += keyframe.duration;
    }
    return TimelineAnimation._(
      lerp: lerp,
      totalDuration: current,
      keyframes: keyframes,
    );
  }

  Duration _computeDuration(double t) {
    final totalDuration = this.totalDuration;
    return Duration(
        milliseconds:
            (t.clamp(0.0, 1.0) * totalDuration.inMilliseconds).floor());
  }

  TimelineAnimatable<T> drive(AnimationController controller) {
    if (controller.duration == null) {
      throw ArgumentError('Controller must have a duration');
    }
    return TimelineAnimatable(controller.duration!, this);
  }

  T transformWithController(AnimationController controller) {
    return drive(controller).transform(controller.value);
  }

  TimelineAnimatable<T> withTotalDuration(Duration duration) {
    if (duration.inMilliseconds <= 0) {
      throw ArgumentError('Duration must be positive');
    }
    return TimelineAnimatable(duration, this);
  }

  @override
  T transform(double t) {
    if (keyframes.isEmpty) {
      throw StateError('No keyframes found');
    }

    t = t.clamp(0.0, 1.0);

    if (totalDuration.inMilliseconds <= 0) {
      return keyframes.first.compute(this, 0, 0.0);
    }

    var duration = _computeDuration(t);
    var current = Duration.zero;
    for (var i = 0; i < keyframes.length; i++) {
      final keyframe = keyframes[i];
      final next = current + keyframe.duration;
      if (duration < next) {
        final localT = keyframe.duration.inMilliseconds > 0
            ? (duration - current).inMilliseconds /
                keyframe.duration.inMilliseconds
            : 1.0;
        return keyframe.compute(this, i, localT.clamp(0.0, 1.0));
      }
      current = next;
    }
    return keyframes.last.compute(this, keyframes.length - 1, 1.0);
  }
}

// ======================= CUSTOM PAINTERS =======================

/// Painter for animated checkmarks
class AnimatedCheckPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  AnimatedCheckPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Define checkmark points
    final Offset firstStrokeStart = Offset(0, size.height * 0.5);
    final Offset firstStrokeEnd = Offset(size.width * 0.35, size.height);
    final Offset secondStrokeStart = firstStrokeEnd;
    final Offset secondStrokeEnd = Offset(size.width, 0);

    // Calculate stroke lengths
    final double firstStrokeLength =
        (firstStrokeEnd - firstStrokeStart).distance;
    final double secondStrokeLength =
        (secondStrokeEnd - secondStrokeStart).distance;
    final double totalLength = firstStrokeLength + secondStrokeLength;

    // Normalize lengths to calculate progress for each stroke
    final double normalizedFirstStrokeLength = firstStrokeLength / totalLength;

    // Calculate progress for each stroke
    final double firstStrokeProgress =
        (progress.clamp(0.0, normalizedFirstStrokeLength) /
                normalizedFirstStrokeLength)
            .clamp(0.0, 1.0);

    final double secondStrokeProgress =
        ((progress - normalizedFirstStrokeLength).clamp(0.0, 1.0) /
                (1.0 - normalizedFirstStrokeLength))
            .clamp(0.0, 1.0);

    // Draw first stroke if there is progress
    if (firstStrokeProgress > 0) {
      final Offset currentPoint =
          Offset.lerp(firstStrokeStart, firstStrokeEnd, firstStrokeProgress)!;

      path.moveTo(firstStrokeStart.dx, firstStrokeStart.dy);
      path.lineTo(currentPoint.dx, currentPoint.dy);

      // Draw second stroke if there is progress
      if (secondStrokeProgress > 0 && progress > normalizedFirstStrokeLength) {
        final Offset secondPoint = Offset.lerp(
          secondStrokeStart,
          secondStrokeEnd,
          secondStrokeProgress,
        )!;
        path.lineTo(secondPoint.dx, secondPoint.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AnimatedCheckPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// ======================= UTILITY FUNCTIONS =======================

/// Returns the maximum of two durations
Duration maxDuration(Duration a, Duration b) {
  return a > b ? a : b;
}

/// Returns the minimum of two durations
Duration minDuration(Duration a, Duration b) {
  return a < b ? a : b;
}

/// Returns the maximum duration of a list of timeline animations
Duration timelineMaxDuration(Iterable<TimelineAnimation> timelines) {
  Duration max = Duration.zero;
  for (final timeline in timelines) {
    max = maxDuration(max, timeline.totalDuration);
  }
  return max;
}
