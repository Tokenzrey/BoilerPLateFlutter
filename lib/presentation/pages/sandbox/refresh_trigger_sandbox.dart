import 'dart:async';

import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/refresh_trigger.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';

class RefreshTriggerSandbox extends StatefulWidget {
  const RefreshTriggerSandbox({super.key});

  @override
  State<RefreshTriggerSandbox> createState() => _RefreshTriggerSandboxState();
}

class _RefreshTriggerSandboxState extends State<RefreshTriggerSandbox>
    with TickerProviderStateMixin {
  // Configuration options
  Axis _direction = Axis.vertical;
  bool _reverse = false;
  double _minExtent = 75.0;
  double _maxExtent = 150.0;
  int _indicatorIndex = 0;
  int _contentIndex = 0;
  bool _simulateError = false;
  bool _triggerOnlyAtEdge = true;
  bool _enableSnapEffect = false;
  bool _enableFloating = false;
  bool _enableDebounce = false;
  bool _maintainScrollPosition = true;
  int? _notificationDepth;
  Duration _debounceDuration = const Duration(milliseconds: 300);

  // Placement configuration
  final double _indicatorOffset = 0.0;
  final Alignment _indicatorAlignment = Alignment.center;
  final EdgeInsets _indicatorPadding = EdgeInsets.zero;

  // Animation configuration
  Curve _curve = Curves.easeOutSine;
  Duration _completeDuration = const Duration(milliseconds: 500);
  Duration _transitionDuration = const Duration(milliseconds: 300);
  final Duration _snapBackDuration = const Duration(milliseconds: 200);

  // Demo data
  final List<String> _items = List.generate(20, (i) => 'Item ${i + 1}');
  TriggerStage _currentStage = TriggerStage.idle;
  int _refreshCount = 0;
  DateTime? _lastRefreshTime;
  List<RefreshHistoryItem> _refreshHistory = [];

  // Controller to manually refresh
  final GlobalKey<RefreshTriggerState> _refreshKey =
      GlobalKey<RefreshTriggerState>();

  // Stream for observing refresh state changes
  late final StreamController<bool> _refreshingStreamController;
  late final Stream<bool> _refreshingStream;

  // Spacing constants for consistent layout
  final double _spacingS = 8.0;
  final double _spacingM = 16.0;
  final double _spacingL = 24.0;
  final double _spacingXL = 32.0;
  final double _cardBorderRadius = 12.0;

  @override
  void initState() {
    super.initState();
    _refreshingStreamController = StreamController<bool>.broadcast();
    _refreshingStream = _refreshingStreamController.stream;

    // Listen to refreshing state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_refreshKey.currentState != null) {
        _refreshKey.currentState!.refreshingNotifier.addListener(() {
          _refreshingStreamController
              .add(_refreshKey.currentState!.isRefreshing);
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshingStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final bool isNarrow = constraints.maxWidth < 600;

      return ListView(
        padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? _spacingM : _spacingXL, vertical: _spacingL),
        children: [
          _buildHeader(),
          SizedBox(height: _spacingXL),

          // Configuration section
          _buildSectionHeader('Basic Configuration'),
          _buildConfigurationSection(isNarrow),
          SizedBox(height: _spacingL),

          // Demo Section
          _buildSectionHeader('Live Demo'),
          _buildDemoSection(),
          SizedBox(height: _spacingL),

          // Indicators section
          _buildSectionHeader('Indicator Types'),
          _buildIndicatorsSection(),
          SizedBox(height: _spacingL),

          // Advanced options section
          _buildSectionHeader('Advanced Options'),
          _buildAdvancedOptionsSection(isNarrow),
          SizedBox(height: _spacingL),

          // Refresh history section
          if (_refreshHistory.isNotEmpty) ...[
            _buildSectionHeader('Refresh History'),
            _buildHistorySection(),
            SizedBox(height: _spacingXL),
          ],
        ],
      );
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(_spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AppText(
                  'Refresh Trigger',
                  variant: TextVariant.displaySmall,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Chip(
                label: Text(_currentStage.toString().split('.').last),
                backgroundColor: _getStateColor()!.withValues(alpha: 0.2),
                labelStyle: TextStyle(fontSize: 12, color: _getStateColor()),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          SizedBox(height: _spacingS),
          const AppText(
            'Pull-to-refresh implementation with customizable animations and indicators',
            variant: TextVariant.bodyLarge,
            color: Colors.white,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (_lastRefreshTime != null) ...[
            SizedBox(height: _spacingM),
            Row(
              children: [
                const Icon(Icons.refresh, color: Colors.white70, size: 16),
                SizedBox(width: _spacingS),
                Expanded(
                  child: Text(
                    'Last refresh: ${_formatDateTime(_lastRefreshTime!)} • Count: $_refreshCount',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: _spacingM),
      child: AppText(
        title,
        variant: TextVariant.headlineSmall,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildConfigurationSection(bool isNarrow) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(_spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Direction and reverse controls
            if (isNarrow)
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _buildDirectionControl(),
                SizedBox(height: _spacingM),
                _buildOrientationControl(),
                SizedBox(height: _spacingM),
              ])
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildDirectionControl()),
                  SizedBox(width: _spacingM),
                  Expanded(child: _buildOrientationControl()),
                ],
              ),

            // Content type
            const AppText(
              'Content Type',
              variant: TextVariant.titleSmall,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: _spacingS),
            Wrap(
              spacing: _spacingS,
              runSpacing: _spacingS,
              children: [
                ChoiceChip(
                  label: const Text('List View'),
                  avatar: const Icon(Icons.view_list, size: 18),
                  selected: _contentIndex == 0,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _contentIndex = 0);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Grid View'),
                  avatar: const Icon(Icons.grid_view, size: 18),
                  selected: _contentIndex == 1,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _contentIndex = 1);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Page View'),
                  avatar: const Icon(Icons.view_carousel, size: 18),
                  selected: _contentIndex == 2,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _contentIndex = 2);
                    }
                  },
                ),
                ChoiceChip(
                  label: const Text('Nested Scroll'),
                  avatar: const Icon(Icons.view_agenda, size: 18),
                  selected: _contentIndex == 3,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _contentIndex = 3);
                    }
                  },
                ),
              ],
            ),

            SizedBox(height: _spacingM),
            const Divider(),
            SizedBox(height: _spacingM),

            // Quick options
            Wrap(
              spacing: _spacingS,
              runSpacing: _spacingS,
              children: [
                FilterChip(
                  label: const Text('Edge Only'),
                  selected: _triggerOnlyAtEdge,
                  onSelected: (value) {
                    setState(() {
                      _triggerOnlyAtEdge = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Snap Effect'),
                  selected: _enableSnapEffect,
                  onSelected: (value) {
                    setState(() {
                      _enableSnapEffect = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Floating'),
                  selected: _enableFloating,
                  onSelected: (value) {
                    setState(() {
                      _enableFloating = value;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Simulate Error'),
                  selected: _simulateError,
                  onSelected: (value) {
                    setState(() {
                      _simulateError = value;
                    });
                  },
                  showCheckmark: false,
                  selectedColor: AppColors.red.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.red,
                ),
              ],
            ),

            SizedBox(height: _spacingM),

            // Pull extent configuration
            const AppText(
              'Pull Distance',
              variant: TextVariant.titleSmall,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: _spacingS),
            Row(
              children: [
                const AppText(
                  'Min:',
                  variant: TextVariant.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: _minExtent,
                    min: 50,
                    max: 200,
                    divisions: 15,
                    label: '${_minExtent.toInt()}',
                    onChanged: (value) {
                      setState(() {
                        _minExtent = value;
                        if (_maxExtent < _minExtent) {
                          _maxExtent = _minExtent * 1.5;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: AppText(
                    '${_minExtent.toInt()}px',
                    variant: TextVariant.bodySmall,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const AppText(
                  'Max:',
                  variant: TextVariant.bodySmall,
                ),
                Expanded(
                  child: Slider(
                    value: _maxExtent,
                    min: _minExtent,
                    max: 300,
                    divisions: 25,
                    label: '${_maxExtent.toInt()}',
                    onChanged: (value) {
                      setState(() {
                        _maxExtent = value;
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: AppText(
                    '${_maxExtent.toInt()}px',
                    variant: TextVariant.bodySmall,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Direction',
          variant: TextVariant.titleSmall,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: _spacingS),
        SegmentedButton<Axis>(
          segments: const [
            ButtonSegment(
              value: Axis.vertical,
              icon: Icon(Icons.swap_vert),
              label: Text('Vertical'),
            ),
            ButtonSegment(
              value: Axis.horizontal,
              icon: Icon(Icons.swap_horiz),
              label: Text('Horizontal'),
            ),
          ],
          selected: {_direction},
          onSelectionChanged: (value) {
            setState(() {
              _direction = value.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildOrientationControl() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Orientation',
          variant: TextVariant.titleSmall,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: _spacingS),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              icon: Icon(Icons.arrow_upward),
              label: Text('Normal'),
            ),
            ButtonSegment(
              value: true,
              icon: Icon(Icons.arrow_downward),
              label: Text('Reverse'),
            ),
          ],
          selected: {_reverse},
          onSelectionChanged: (value) {
            setState(() {
              _reverse = value.first;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDemoSection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(_spacingM),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Pull to Refresh Demo',
                        variant: TextVariant.titleMedium,
                        fontWeight: FontWeight.bold,
                      ),
                      Text(
                        'Current state: ${_currentStage.toString().split('.').last}',
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStateColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                StreamBuilder<bool>(
                  stream: _refreshingStream,
                  initialData: false,
                  builder: (context, snapshot) {
                    final isRefreshing = snapshot.data ?? false;
                    return ElevatedButton.icon(
                      onPressed: isRefreshing
                          ? null
                          : () => _refreshContent(manual: true),
                      icon: isRefreshing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.refresh),
                      label:
                          Text(isRefreshing ? 'Refreshing...' : 'Refresh Now'),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            height: 400,
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildRefreshTrigger(),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(_spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Indicator Type',
              variant: TextVariant.titleMedium,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: _spacingM),

            // FIXED: Improved horizontal scrolling for indicator types
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: 5, // Number of indicator options
                itemBuilder: (context, index) => _buildIndicatorOption(
                    index,
                    index == 0
                        ? 'Default'
                        : index == 1
                            ? 'Modern'
                            : index == 2
                                ? 'Water Drop'
                                : index == 3
                                    ? 'Lottie Style'
                                    : 'Custom Styled'),
              ),
            ),

            SizedBox(height: _spacingL),

            // Preview by stage
            const AppText(
              'Preview by Stage',
              variant: TextVariant.titleSmall,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: _spacingM),

            // FIXED: Improved horizontal scrolling for stage previews
            SizedBox(
              height: 140, // Increased height slightly
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: TriggerStage.values.length,
                itemBuilder: (context, index) {
                  final stage = TriggerStage.values[index];
                  return Container(
                    width: 120, // Fixed width for consistent layout
                    padding: EdgeInsets.only(right: _spacingS),
                    child: Column(
                      children: [
                        Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color:
                                  _getStageColor(stage)!.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SizedBox(
                            width: 110, // Slightly smaller to prevent overflow
                            height: 80,
                            child: Center(
                              child: _buildIndicatorStagePreview(stage),
                            ),
                          ),
                        ),
                        SizedBox(height: _spacingS),
                        Text(
                          stage.toString().split('.').last,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: _getStageColor(stage),
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorOption(int index, String label) {
    final isSelected = _indicatorIndex == index;
    return Padding(
      padding: EdgeInsets.only(right: _spacingM),
      child: InkWell(
        onTap: () {
          setState(() {
            _indicatorIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 100,
          padding: EdgeInsets.all(_spacingS),
          decoration: BoxDecoration(
            border: Border.all(
              color:
                  isSelected ? AppColors.primary : AppColors.neutral.shade300,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 60,
                width: 100, // Ensure fixed width
                child: Center(
                  child: ClipRect(
                    // Add clipping to prevent overflow
                    child: SizedBox(
                      width: 80, // Constrain indicator width
                      child: _buildIndicatorTypePreview(index),
                    ),
                  ),
                ),
              ),
              SizedBox(height: _spacingS),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.neutral.shade700,
                  fontSize: 12, // Smaller font size to prevent overflow
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdvancedOptionsSection(bool isNarrow) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(_spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Animation Settings',
              variant: TextVariant.titleMedium,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: _spacingM),

            // Animation controls
            _buildAnimationOptions(isNarrow),
            SizedBox(height: _spacingL),

            const Divider(),
            SizedBox(height: _spacingM),

            const AppText(
              'Other Options',
              variant: TextVariant.titleMedium,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: _spacingM),

            // Advanced switches
            SwitchListTile(
              title: const AppText(
                'Maintain Scroll Position',
                variant: TextVariant.bodyMedium,
              ),
              subtitle: const Text('Preserve scroll offset during refresh'),
              value: _maintainScrollPosition,
              onChanged: (value) {
                setState(() {
                  _maintainScrollPosition = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            SwitchListTile(
              title: const AppText(
                'Enable Debounce',
                variant: TextVariant.bodyMedium,
              ),
              subtitle: Text(
                  'Prevents multiple rapid refreshes (${_debounceDuration.inMilliseconds}ms)'),
              value: _enableDebounce,
              onChanged: (value) {
                setState(() {
                  _enableDebounce = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),

            if (_enableDebounce) ...[
              SizedBox(height: _spacingS),
              Padding(
                padding: EdgeInsets.only(left: _spacingM),
                child: Row(
                  children: [
                    Expanded(
                      flex: isNarrow ? 1 : 2,
                      child: const Text('Debounce Duration:'),
                    ),
                    SizedBox(width: _spacingS),
                    Expanded(
                      flex: isNarrow ? 1 : 3,
                      child: DropdownButtonFormField<Duration>(
                        value: _debounceDuration,
                        isExpanded: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: Duration(milliseconds: 300),
                            child: Text('300ms'),
                          ),
                          DropdownMenuItem(
                            value: Duration(milliseconds: 500),
                            child: Text('500ms'),
                          ),
                          DropdownMenuItem(
                            value: Duration(milliseconds: 1000),
                            child: Text('1000ms'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _debounceDuration = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationOptions(bool isNarrow) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Animation curve
        Row(
          children: [
            Expanded(
              flex: isNarrow ? 1 : 2,
              child: const AppText(
                'Animation Curve:',
                variant: TextVariant.bodyMedium,
              ),
            ),
            SizedBox(width: _spacingS),
            Expanded(
              flex: isNarrow ? 1 : 3,
              child: DropdownButtonFormField<Curve>(
                value: _curve,
                isExpanded: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem(
                    value: Curves.easeOutSine,
                    child: Text(
                      'easeOutSine',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const DropdownMenuItem(
                    value: Curves.easeOutQuad,
                    child: Text('easeOutQuad'),
                  ),
                  const DropdownMenuItem(
                    value: Curves.easeOutCubic,
                    child: Text('easeOutCubic'),
                  ),
                  const DropdownMenuItem(
                    value: Curves.easeOutBack,
                    child: Text('easeOutBack'),
                  ),
                  const DropdownMenuItem(
                    value: Curves.bounceOut,
                    child: Text('bounceOut'),
                  ),
                  const DropdownMenuItem(
                    value: Curves.elasticOut,
                    child: Text('elasticOut'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _curve = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: _spacingM),

        // Animation durations
        Row(
          children: [
            Expanded(
              flex: isNarrow ? 1 : 2,
              child: const AppText(
                'Complete Duration:',
                variant: TextVariant.bodyMedium,
              ),
            ),
            SizedBox(width: _spacingS),
            Expanded(
              flex: isNarrow ? 1 : 3,
              child: DropdownButtonFormField<Duration>(
                value: _completeDuration,
                isExpanded: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                    value: Duration(milliseconds: 300),
                    child: Text('300ms'),
                  ),
                  DropdownMenuItem(
                    value: Duration(milliseconds: 500),
                    child: Text('500ms'),
                  ),
                  DropdownMenuItem(
                    value: Duration(milliseconds: 1000),
                    child: Text('1000ms'),
                  ),
                  DropdownMenuItem(
                    value: Duration(milliseconds: 2000),
                    child: Text('2000ms'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _completeDuration = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
        SizedBox(height: _spacingM),

        // Transition duration
        Row(
          children: [
            Expanded(
              flex: isNarrow ? 1 : 2,
              child: const AppText(
                'Transition Duration:',
                variant: TextVariant.bodyMedium,
              ),
            ),
            SizedBox(width: _spacingS),
            Expanded(
              flex: isNarrow ? 1 : 3,
              child: DropdownButtonFormField<Duration>(
                value: _transitionDuration,
                isExpanded: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(
                    value: Duration(milliseconds: 200),
                    child: Text('200ms'),
                  ),
                  DropdownMenuItem(
                    value: Duration(milliseconds: 300),
                    child: Text('300ms'),
                  ),
                  DropdownMenuItem(
                    value: Duration(milliseconds: 500),
                    child: Text('500ms'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _transitionDuration = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(_spacingM),
            child: Row(
              children: [
                const AppText(
                  'Refresh History',
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(width: _spacingS),
                Badge(
                  label: Text('$_refreshCount'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _refreshHistory.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          // Only show the latest 5 history items to avoid large lists
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _refreshHistory.length.clamp(0, 5),
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = _refreshHistory[index];
              final isSuccess = item.result == RefreshResult.success;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSuccess
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.red.withValues(alpha: 0.2),
                  child: Icon(
                    isSuccess ? Icons.check : Icons.close,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                title:
                    Text(isSuccess ? 'Successful refresh' : 'Failed refresh'),
                subtitle: Text(_formatDateTime(item.timestamp)),
                trailing: index == 0
                    ? const Chip(
                        label: Text('Latest'),
                        visualDensity: VisualDensity.compact,
                      )
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRefreshTrigger() {
    // Create animation config
    final animationConfig = RefreshAnimationConfig(
      curve: _curve,
      completeDuration: _completeDuration,
      transitionDuration: _transitionDuration,
      fadeDuration: const Duration(milliseconds: 200),
      enableSnapEffect: _enableSnapEffect,
      snapBackDuration: _snapBackDuration,
    );

    // Create placement config
    final placementConfig = IndicatorPlacementConfig(
      offset: _indicatorOffset,
      alignment: _indicatorAlignment,
      floating: _enableFloating,
      padding: _indicatorPadding,
    );

    return RefreshTrigger(
      key: _refreshKey,
      direction: _direction,
      reverse: _reverse,
      minExtent: _minExtent,
      maxExtent: _maxExtent,
      triggerOnlyAtEdge: _triggerOnlyAtEdge,
      animationConfig: animationConfig,
      placementConfig: placementConfig,
      indicatorBuilder: _getIndicatorBuilder(),
      indicatorMargin: _direction == Axis.horizontal
          ? (_reverse
              ? EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.38)
              : EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.38))
          : EdgeInsets.zero,
      onRefresh: _refreshContent,
      debounceDuration: _enableDebounce ? _debounceDuration : null,
      notificationDepth: _notificationDepth,
      maintainScrollPosition: _maintainScrollPosition,
      semanticLabel: "Pull to refresh demo",
      onStateChanged: (stage) {
        setState(() {
          _currentStage = stage;
        });
      },
      errorBuilder: (context, error) {
        return _simulateError ? _buildErrorWidget(error) : const SizedBox();
      },
      showIndicatorOnManualRefresh: true,
      onRefreshHistory: (timestamp, result) {
        setState(() {
          _lastRefreshTime = timestamp;
          _refreshHistory.insert(
              0,
              RefreshHistoryItem(
                timestamp: timestamp,
                result: result,
                error: result == RefreshResult.error
                    ? 'Simulated refresh failure'
                    : null,
              ));

          // Keep history to a reasonable size
          if (_refreshHistory.length > 20) {
            _refreshHistory = _refreshHistory.sublist(0, 20);
          }
        });
      },
      child: _buildContent(),
    );
  }

  // Get appropriate content based on selected type
  Widget _buildContent() {
    switch (_contentIndex) {
      case 0: // ListView
        return ListView.builder(
          scrollDirection: _direction, // Respects the direction setting
          itemCount: _items.length,
          itemBuilder: (context, index) {
            // For horizontal mode, we need a different layout
            if (_direction == Axis.horizontal) {
              return Container(
                width: 200,
                margin: EdgeInsets.all(_spacingS),
                decoration: BoxDecoration(
                  color: _getItemColor(index)?.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: _getItemColor(index)!.withValues(alpha: 0.3)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: _getItemColor(index),
                      child: Text('${index + 1}',
                          style: const TextStyle(color: Colors.white)),
                    ),
                    SizedBox(height: _spacingS),
                    Text(_items[index], overflow: TextOverflow.ellipsis),
                    Text('Pull to refresh • Count: $_refreshCount',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              );
            }

            // Default vertical list item
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: _getItemColor(index),
                child: Text('${index + 1}',
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(_items[index], overflow: TextOverflow.ellipsis),
              subtitle: Text('Pull to refresh • Count: $_refreshCount',
                  overflow: TextOverflow.ellipsis),
            );
          },
        );

      case 1: // GridView
        return GridView.builder(
          scrollDirection: _direction, // Respects the direction setting
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _direction == Axis.vertical ? 2 : 1,
            childAspectRatio: _direction == Axis.vertical ? 1.2 : 0.8,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          padding: EdgeInsets.all(_spacingS),
          itemCount: _items.length,
          itemBuilder: (context, index) => Card(
            color: _getItemColor(index)!.withValues(alpha: 0.2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundColor: _getItemColor(index),
                  child: Text('${index + 1}',
                      style: const TextStyle(color: Colors.white)),
                ),
                SizedBox(height: _spacingS),
                Text(_items[index], overflow: TextOverflow.ellipsis),
                Text('Refresh #$_refreshCount',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );

      case 3: // Nested Scroll View
        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                title: const Text('Nested Scroll Demo'),
                pinned: true,
                forceElevated: innerBoxIsScrolled,
                backgroundColor: Theme.of(context).colorScheme.surface,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(_spacingM),
                  child: Text(
                    'This demonstrates a nested scroll view. The refresh trigger works '
                    'with nested scrollable content. Pull from the very top to trigger refresh.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverHeaderDelegate(
                  minHeight: 60,
                  maxHeight: 60,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Center(
                      child: Text(
                        'Items (pull to refresh)',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ),
            ];
          },
          body: ListView.builder(
            padding: EdgeInsets.all(_spacingS),
            itemCount: _items.length,
            itemBuilder: (context, index) => ListTile(
              leading: CircleAvatar(
                backgroundColor: _getItemColor(index),
                child: Text('${index + 1}',
                    style: const TextStyle(color: Colors.white)),
              ),
              title: Text(_items[index], overflow: TextOverflow.ellipsis),
              subtitle: Text('Pull to refresh • Count: $_refreshCount',
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        );

      case 2: // PageView
      default:
        return PageView.builder(
          scrollDirection: _direction, // Respects the direction setting
          itemCount: _items.length,
          itemBuilder: (context, index) => Card(
            margin: EdgeInsets.all(_spacingM),
            color: _getItemColor(index)!.withValues(alpha: 0.1),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: _getItemColor(index),
                    child: Text('${index + 1}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24)),
                  ),
                  SizedBox(height: _spacingM),
                  Text(_items[index],
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis),
                  Text('Refresh count: $_refreshCount',
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: _spacingL),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: _spacingM),
                    child: Text(
                      'Pull to refresh ${_direction == Axis.vertical ? (_reverse ? 'from bottom' : 'from top') : (_reverse ? 'from right' : 'from left')}',
                      style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  // Get an item color based on index
  Color? _getItemColor(int index) {
    final colors = [
      AppColors.blue,
      AppColors.green,
      AppColors.orange,
      AppColors.red,
      AppColors.violet,
      AppColors.blue[300],
      AppColors.orange,
    ];
    return colors[index % colors.length];
  }

  // Get color for current state indicator
  Color? _getStateColor() {
    return _getStageColor(_currentStage);
  }

  // Get color for any state
  Color? _getStageColor(TriggerStage stage) {
    switch (stage) {
      case TriggerStage.idle:
        return Colors.grey;
      case TriggerStage.pulling:
        return AppColors.blue;
      case TriggerStage.refreshing:
        return AppColors.blue[900];
      case TriggerStage.completed:
        return AppColors.green;
      case TriggerStage.error:
        return AppColors.red;
    }
  }

  // Get the appropriate indicator builder based on index
  RefreshIndicatorBuilder _getIndicatorBuilder() {
    switch (_indicatorIndex) {
      case 0:
        return RefreshTrigger.defaultIndicatorBuilder;
      case 1:
        return RefreshTriggerIndicators.modernIndicator;
      case 2:
        return RefreshTriggerIndicators.waterDropIndicator;
      case 3:
        return RefreshTriggerIndicators.lottieStyleIndicator;
      case 4:
        // Return a custom styled indicator based on the Modern indicator
        return RefreshTriggerIndicators.custom(
          baseIndicator: RefreshTriggerIndicators.modernIndicator,
          style: {
            'primaryColor': Theme.of(context).colorScheme.tertiary,
            'height': 60.0,
            'indicatorSize': 28.0,
            'fontSize': 16.0,
          },
        );
      default:
        return RefreshTrigger.defaultIndicatorBuilder;
    }
  }

  // Build a preview of an indicator type
  Widget _buildIndicatorTypePreview(int index) {
    // Create a mock stage
    final mockStage = RefreshTriggerStage(
      TriggerStage.refreshing,
      const AlwaysStoppedAnimation(1.0),
      _direction,
      reverse: _reverse,
      style: index == 4
          ? {
              'primaryColor': Theme.of(context).colorScheme.tertiary,
              'height': 40.0,
              'indicatorSize': 20.0,
              'fontSize': 12.0,
            }
          : null,
    );

    // Get indicator builder
    RefreshIndicatorBuilder indicatorBuilder;
    switch (index) {
      case 0:
        indicatorBuilder = RefreshTrigger.defaultIndicatorBuilder;
        break;
      case 1:
        indicatorBuilder = RefreshTriggerIndicators.modernIndicator;
        break;
      case 2:
        indicatorBuilder = RefreshTriggerIndicators.waterDropIndicator;
        break;
      case 3:
        indicatorBuilder = RefreshTriggerIndicators.lottieStyleIndicator;
        break;
      case 4:
        indicatorBuilder = RefreshTriggerIndicators.custom(
          baseIndicator: RefreshTriggerIndicators.modernIndicator,
          style: {
            'primaryColor': Theme.of(context).colorScheme.tertiary,
            'height': 60.0,
            'indicatorSize': 28.0,
            'fontSize': 16.0,
          },
        );
        break;
      default:
        indicatorBuilder = RefreshTrigger.defaultIndicatorBuilder;
    }

    return SizedBox(
      width: 80,
      height: 40,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: indicatorBuilder(context, mockStage),
      ),
    );
  }

  // Build indicator in specific stage for preview
  Widget _buildIndicatorStagePreview(TriggerStage stage) {
    final mockValue = stage == TriggerStage.pulling ? 0.7 : 1.0;

    final mockStage = RefreshTriggerStage(
      stage,
      AlwaysStoppedAnimation(mockValue),
      _direction,
      reverse: _reverse,
      error: stage == TriggerStage.error ? 'Simulated error' : null,
      lastRefreshTime: DateTime.now(),
      refreshCount: _refreshCount,
      style: _indicatorIndex == 4
          ? {
              'primaryColor': Theme.of(context).colorScheme.tertiary,
              'height': 60.0,
              'indicatorSize': 28.0,
              'fontSize': 16.0,
            }
          : null,
    );

    return SizedBox(
      width: 80,
      height: 50,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: _getIndicatorBuilder()(context, mockStage),
      ),
    );
  }

  // Handle refresh operation
  Future<void> _refreshContent({bool manual = false}) async {
    if (manual && _refreshKey.currentState != null) {
      return _refreshKey.currentState!.refresh();
    }

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate error if enabled
    if (_simulateError) {
      throw Exception('Simulated refresh failure');
    }

    // Update state
    setState(() {
      _refreshCount++;
      _lastRefreshTime = DateTime.now();

      // Shuffle items to simulate new data
      _items.shuffle();
    });
  }

  // Error widget to show when refresh fails
  Widget _buildErrorWidget(dynamic error) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _spacingM, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.white,
          ),
          SizedBox(width: _spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Refresh Failed',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  error.toString(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _simulateError = false;
              });
              // Show indicator when retry
              _refreshContent(manual: true);
            },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
            label: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Format a DateTime for display
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}

// Helper class to track refresh history
class RefreshHistoryItem {
  final DateTime timestamp;
  final RefreshResult result;
  final dynamic error;

  RefreshHistoryItem({
    required this.timestamp,
    required this.result,
    this.error,
  });
}

// Sliver header delegate for nested scroll view
class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _SliverHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
