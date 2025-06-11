import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/toast.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';

class ToastSandbox extends StatefulWidget {
  const ToastSandbox({super.key});

  @override
  State<ToastSandbox> createState() => _ToastSandboxState();
}

class _ToastSandboxState extends State<ToastSandbox> {
  // Toast configuration
  ToastPosition _position = ToastPosition.bottomRight;
  ToastAnimationType _entryAnimation = ToastAnimationType.scale;
  ToastAnimationType _exitAnimation = ToastAnimationType.fade;
  ToastLevel _level = ToastLevel.info;
  Set<ToastInteraction> _interactions = {ToastInteraction.swipeToDismiss};
  bool _dismissible = true;
  bool _persistent = false;
  int _durationSeconds = 4;
  int _maxVisibleToasts = 3;

  // Priority settings
  ToastPriority _priority = ToastPriority.normal;

  // Shifting animation settings
  ToastShiftingAnimationType _shiftingAnimationType =
      ToastShiftingAnimationType.slideAndFade;
  int _shiftingAnimationDuration = 300;
  Curve _shiftingAnimationCurve = Curves.easeOutCubic;

  // Accessibility settings
  bool _announceToast = true;

  // Custom configuration
  final TextEditingController _titleController =
      TextEditingController(text: 'Toast Title');
  final TextEditingController _messageController = TextEditingController(
    text: 'This is a toast message with some details.',
  );
  final TextEditingController _semanticLabelController =
      TextEditingController();
  bool _includeActions = false;
  bool _includeIcon = true;
  String? _selectedGroupId;
  ToastGroupBehavior _groupBehavior = ToastGroupBehavior.stack;

  // Style configuration
  Color _backgroundColor = AppColors.primary;
  Color? _textColor;
  double _borderRadius = 8.0;
  double _elevation = 4.0;

  // Toast history
  final List<_ToastHistoryItem> _history = [];

  // Custom position
  Offset _customPosition = const Offset(100, 100);
  bool _isCustomPosition = false;

  // Store active toasts
  final Map<String, ToastOverlay> _activeToasts = {};

  bool get _hasOverlayContext => Overlay.maybeOf(context) != null;

  final double _cardElevation = 1;
  final double _cardBorderRadius = 12;
  final double _sectionSpacing = 24;
  final double _itemSpacing = 16;
  final double _smallSpacing = 8;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _semanticLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: DefaultTabController(
                length: 4,
                child: Column(
                  children: [
                    TabBar(
                      tabs: const [
                        Tab(text: 'Basic'),
                        Tab(text: 'Advanced'),
                        Tab(text: 'Styling'),
                        Tab(text: 'History'),
                      ],
                      isScrollable: true,
                      labelColor: AppColors.primary,
                      indicatorColor: AppColors.primary,
                      unselectedLabelColor: AppColors.neutral.shade700,
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: const ClampingScrollPhysics(),
                        children: [
                          _buildBasicSettings(),
                          _buildAdvancedSettings(),
                          _buildStyleSettings(),
                          _buildHistoryPanel(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              'Toast Sandbox',
              variant: TextVariant.titleLarge,
              fontWeight: FontWeight.w600,
            ),
          ),
          // Quick actions
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.layers, color: AppColors.neutral.shade800),
                tooltip: 'Test Max Visible Toasts',
                onPressed: _testMaxVisibleToasts,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.notifications),
                label: const AppText('Show Toast',
                    variant: TextVariant.labelMedium),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _showCustomizedToast,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        _buildSection(
          title: 'Toast Content',
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Toast Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.neutral.shade50,
              ),
            ),
            SizedBox(height: _itemSpacing),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Toast Message',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.neutral.shade50,
              ),
              maxLines: 2,
            ),
            SizedBox(height: _itemSpacing),
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout for checkboxes
                if (constraints.maxWidth < 500) {
                  return Column(
                    children: [
                      _buildCheckbox(
                        title: 'Include Icon',
                        value: _includeIcon,
                        onChanged: (value) {
                          setState(() {
                            _includeIcon = value ?? true;
                          });
                        },
                      ),
                      _buildCheckbox(
                        title: 'Include Actions',
                        value: _includeActions,
                        onChanged: (value) {
                          setState(() {
                            _includeActions = value ?? false;
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildCheckbox(
                          title: 'Include Icon',
                          value: _includeIcon,
                          onChanged: (value) {
                            setState(() {
                              _includeIcon = value ?? true;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildCheckbox(
                          title: 'Include Actions',
                          value: _includeActions,
                          onChanged: (value) {
                            setState(() {
                              _includeActions = value ?? false;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
        SizedBox(height: _sectionSpacing),
        _buildSection(
          title: 'Toast Type',
          children: [
            Wrap(
              spacing: _smallSpacing,
              runSpacing: _smallSpacing,
              children: [
                _buildToastTypeChip(ToastLevel.info, 'Info'),
                _buildToastTypeChip(ToastLevel.success, 'Success'),
                _buildToastTypeChip(ToastLevel.warning, 'Warning'),
                _buildToastTypeChip(ToastLevel.error, 'Error'),
              ],
            ),
            SizedBox(height: _itemSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.notifications),
                label: const AppText('Show', variant: TextVariant.labelMedium),
                onPressed: () => _showPredefinedToast(_level),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getColorForLevel(_level),
                  foregroundColor: AppColors.foreground,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            SizedBox(height: _itemSpacing),
            const AppText(
              'Quick Actions:',
              variant: TextVariant.labelMedium,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: _smallSpacing),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickActionButton(
                    'Info',
                    Icons.info_outline,
                    ToastLevel.info,
                  ),
                  SizedBox(width: _smallSpacing),
                  _buildQuickActionButton(
                    'Success',
                    Icons.check_circle_outline,
                    ToastLevel.success,
                  ),
                  SizedBox(width: _smallSpacing),
                  _buildQuickActionButton(
                    'Warning',
                    Icons.warning_amber_outlined,
                    ToastLevel.warning,
                  ),
                  SizedBox(width: _smallSpacing),
                  _buildQuickActionButton(
                    'Error',
                    Icons.error_outline,
                    ToastLevel.error,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: _sectionSpacing),
        _buildSection(
          title: 'Toast Position',
          children: [
            Wrap(
              spacing: _smallSpacing,
              runSpacing: _smallSpacing,
              children: [
                _buildPositionChip(ToastPosition.topLeft, 'Top Left'),
                _buildPositionChip(ToastPosition.topCenter, 'Top Center'),
                _buildPositionChip(ToastPosition.topRight, 'Top Right'),
                _buildPositionChip(ToastPosition.bottomLeft, 'Bottom Left'),
                _buildPositionChip(ToastPosition.bottomCenter, 'Bottom Center'),
                _buildPositionChip(ToastPosition.bottomRight, 'Bottom Right'),
              ],
            ),
            SizedBox(height: _smallSpacing),
            SwitchListTile(
              title: const AppText('Custom Position',
                  variant: TextVariant.bodyMedium),
              value: _isCustomPosition,
              onChanged: (value) {
                setState(() {
                  _isCustomPosition = value;
                  if (value) {
                    _position = ToastPosition.custom;
                  } else {
                    _position = ToastPosition.bottomRight;
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
            if (_isCustomPosition)
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: AppColors.neutral.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    const Positioned.fill(
                      child: Center(
                        child: AppText(
                          'Drag to set position',
                          variant: TextVariant.bodyMedium,
                        ),
                      ),
                    ),
                    Positioned(
                      left: _customPosition.dx,
                      top: _customPosition.dy,
                      child: GestureDetector(
                        onPanUpdate: (details) {
                          setState(() {
                            _customPosition = Offset(
                              (_customPosition.dx + details.delta.dx)
                                  .clamp(0, 300),
                              (_customPosition.dy + details.delta.dy)
                                  .clamp(0, 130),
                            );
                          });
                        },
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        SizedBox(height: _sectionSpacing),
        _buildSection(
          title: 'Duration & Behavior',
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                // Responsive layout for switches
                if (constraints.maxWidth < 500) {
                  return Column(
                    children: [
                      _buildSwitch(
                        title: 'Persistent',
                        subtitle: 'Never auto-dismiss',
                        value: _persistent,
                        onChanged: (value) {
                          setState(() {
                            _persistent = value;
                          });
                        },
                      ),
                      _buildSwitch(
                        title: 'Dismissible',
                        subtitle: 'Can be dismissed',
                        value: _dismissible,
                        onChanged: (value) {
                          setState(() {
                            _dismissible = value;
                          });
                        },
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: _buildSwitch(
                          title: 'Persistent',
                          subtitle: 'Never auto-dismiss',
                          value: _persistent,
                          onChanged: (value) {
                            setState(() {
                              _persistent = value;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildSwitch(
                          title: 'Dismissible',
                          subtitle: 'Can be dismissed',
                          value: _dismissible,
                          onChanged: (value) {
                            setState(() {
                              _dismissible = value;
                            });
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            if (!_persistent) ...[
              SizedBox(height: _itemSpacing),
              AppText(
                'Duration: $_durationSeconds seconds',
                variant: TextVariant.bodyMedium,
              ),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.primary,
                  thumbColor: AppColors.primary,
                  inactiveTrackColor: AppColors.neutral.shade300,
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _durationSeconds.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_durationSeconds seconds',
                  onChanged: (value) {
                    setState(() {
                      _durationSeconds = value.toInt();
                    });
                  },
                ),
              ),
            ],
            SizedBox(height: _itemSpacing),
            AppText(
              'Max Visible Toasts: $_maxVisibleToasts',
              variant: TextVariant.bodyMedium,
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                thumbColor: AppColors.primary,
                inactiveTrackColor: AppColors.neutral.shade300,
                trackHeight: 4,
              ),
              child: Slider(
                value: _maxVisibleToasts.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: '$_maxVisibleToasts toasts',
                onChanged: (value) {
                  setState(() {
                    _maxVisibleToasts = value.toInt();
                    // Update global configuration
                    ToastConfig.configure(maxVisibleToasts: _maxVisibleToasts);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        // Priority Section
        _buildSection(
          title: 'Priority',
          children: [
            const AppText(
              'Toast Priority:',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _smallSpacing),
            Wrap(
              spacing: _smallSpacing,
              runSpacing: _smallSpacing,
              children: [
                _buildPriorityChip(ToastPriority.low, 'Low'),
                _buildPriorityChip(ToastPriority.normal, 'Normal'),
                _buildPriorityChip(ToastPriority.high, 'High'),
                _buildPriorityChip(ToastPriority.urgent, 'Urgent'),
              ],
            ),
            SizedBox(height: _smallSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.compare_arrows),
                label: const AppText(
                  'Test Priority Replace',
                  variant: TextVariant.labelMedium,
                ),
                onPressed: _testPriorityReplace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPriorityColor(_priority),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: _sectionSpacing),

        _buildSection(
          title: 'Animation Settings',
          children: [
            const AppText(
              'Entry Animation:',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _smallSpacing),
            Wrap(
              spacing: _smallSpacing,
              runSpacing: _smallSpacing,
              children: [
                _buildAnimationChip(ToastAnimationType.fade, 'Fade', true),
                _buildAnimationChip(ToastAnimationType.scale, 'Scale', true),
                _buildAnimationChip(
                    ToastAnimationType.slideUp, 'Slide Up', true),
                _buildAnimationChip(
                    ToastAnimationType.slideDown, 'Slide Down', true),
                _buildAnimationChip(
                    ToastAnimationType.slideLeft, 'Slide Left', true),
                _buildAnimationChip(
                    ToastAnimationType.slideRight, 'Slide Right', true),
              ],
            ),
            SizedBox(height: _itemSpacing),
            const AppText(
              'Exit Animation:',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _smallSpacing),
            Wrap(
              spacing: _smallSpacing,
              runSpacing: _smallSpacing,
              children: [
                _buildAnimationChip(ToastAnimationType.fade, 'Fade', false),
                _buildAnimationChip(ToastAnimationType.scale, 'Scale', false),
                _buildAnimationChip(
                    ToastAnimationType.slideUp, 'Slide Up', false),
                _buildAnimationChip(
                    ToastAnimationType.slideDown, 'Slide Down', false),
                _buildAnimationChip(
                    ToastAnimationType.slideLeft, 'Slide Left', false),
                _buildAnimationChip(
                    ToastAnimationType.slideRight, 'Slide Right', false),
              ],
            ),
            SizedBox(height: _itemSpacing),
            const AppText(
              'Shifting Animation:',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _smallSpacing),
            Wrap(
              spacing: _smallSpacing,
              runSpacing: _smallSpacing,
              children: ToastShiftingAnimationType.values.map((type) {
                return _buildShiftingAnimationChip(
                    type, _getShiftingAnimationName(type));
              }).toList(),
            ),
            SizedBox(height: _itemSpacing),
            AppText(
              'Shifting Duration: $_shiftingAnimationDuration ms',
              variant: TextVariant.bodyMedium,
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                thumbColor: AppColors.primary,
                inactiveTrackColor: AppColors.neutral.shade300,
                trackHeight: 4,
              ),
              child: Slider(
                value: _shiftingAnimationDuration.toDouble(),
                min: 100,
                max: 1000,
                divisions: 9,
                label: '$_shiftingAnimationDuration ms',
                onChanged: (value) {
                  setState(() {
                    _shiftingAnimationDuration = value.toInt();
                  });
                },
              ),
            ),
            SizedBox(height: _itemSpacing),
            const AppText(
              'Shifting Curve:',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _smallSpacing),
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutral.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<Curve>(
                value: _shiftingAnimationCurve,
                items: _getCurveItems(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _shiftingAnimationCurve = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.neutral.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),
            SizedBox(height: _smallSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.animation),
                label: const AppText(
                  'Test Shifting Animation',
                  variant: TextVariant.labelMedium,
                ),
                onPressed: _testShiftingAnimation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: _sectionSpacing),

        _buildSection(
          title: 'Interaction Settings',
          children: [
            const AppText(
              'Toast Interactions:',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _smallSpacing),
            _buildCheckbox(
              title: 'None (Disable all interactions)',
              value: _interactions.isEmpty,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _interactions = {}; // Empty set = None
                  } else {
                    _interactions = {
                      ToastInteraction.swipeToDismiss
                    }; // Default
                  }
                });
              },
            ),
            _buildCheckbox(
              title: 'Swipe to dismiss',
              value: _interactions.contains(ToastInteraction.swipeToDismiss),
              onChanged: _interactions.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        if (value == true) {
                          _interactions.add(ToastInteraction.swipeToDismiss);
                        } else {
                          _interactions.remove(ToastInteraction.swipeToDismiss);
                        }
                      });
                    },
            ),
            _buildCheckbox(
              title: 'Tap to dismiss',
              value: _interactions.contains(ToastInteraction.tapToDismiss),
              onChanged: _interactions.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        if (value == true) {
                          _interactions.add(ToastInteraction.tapToDismiss);
                        } else {
                          _interactions.remove(ToastInteraction.tapToDismiss);
                        }
                      });
                    },
            ),
            _buildCheckbox(
              title: 'Tap to expand',
              value: _interactions.contains(ToastInteraction.tapToExpand),
              onChanged: _interactions.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        if (value == true) {
                          _interactions.add(ToastInteraction.tapToExpand);
                        } else {
                          _interactions.remove(ToastInteraction.tapToExpand);
                        }
                      });
                    },
            ),
            SizedBox(height: _smallSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.touch_app),
                label: const AppText(
                  'Test Interactions',
                  variant: TextVariant.labelMedium,
                ),
                onPressed: _testInteractions,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: _sectionSpacing),

        _buildSection(
          title: 'Accessibility',
          children: [
            _buildSwitch(
              title: 'Announce Toasts',
              subtitle: 'Announce via screen readers',
              value: _announceToast,
              onChanged: (value) {
                setState(() {
                  _announceToast = value;
                });
              },
            ),
            SizedBox(height: _smallSpacing),
            TextField(
              controller: _semanticLabelController,
              decoration: InputDecoration(
                labelText: 'Custom Semantic Label',
                hintText: 'Leave empty to use title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: AppColors.neutral.shade50,
              ),
            ),
            SizedBox(height: _smallSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.accessibility_new),
                label: const AppText(
                  'Test Accessibility',
                  variant: TextVariant.labelMedium,
                ),
                onPressed: _testAccessibility,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: _sectionSpacing),

        _buildSection(
          title: 'Group Settings',
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.neutral.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<String?>(
                decoration: InputDecoration(
                  labelText: 'Group ID',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.neutral.shade300),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                value: _selectedGroupId,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: AppText('No group', variant: TextVariant.bodyMedium),
                  ),
                  ..._buildGroupItems(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGroupId = value;
                  });
                },
              ),
            ),
            SizedBox(height: _itemSpacing),
            const AppText(
              'Group Behavior:',
              variant: TextVariant.bodyMedium,
            ),
            SizedBox(height: _smallSpacing),
            Wrap(
              spacing: _smallSpacing,
              runSpacing: _smallSpacing,
              children: [
                _buildGroupBehaviorChip(ToastGroupBehavior.stack, 'Stack'),
                _buildGroupBehaviorChip(
                    ToastGroupBehavior.collapse, 'Collapse'),
                _buildGroupBehaviorChip(ToastGroupBehavior.replace, 'Replace'),
              ],
            ),
            SizedBox(height: _itemSpacing),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 500) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const AppText(
                          'Add to Group',
                          variant: TextVariant.labelMedium,
                        ),
                        onPressed:
                            _selectedGroupId == null ? null : _addToastToGroup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.compare),
                        label: const AppText(
                          'Test Group Behaviors',
                          variant: TextVariant.labelMedium,
                        ),
                        onPressed: _testGroupBehaviors,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_circle_outline),
                          label: const AppText(
                            'Add to Group',
                            variant: TextVariant.labelMedium,
                          ),
                          onPressed: _selectedGroupId == null
                              ? null
                              : _addToastToGroup,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.compare),
                          label: const AppText(
                            'Test Group Behaviors',
                            variant: TextVariant.labelMedium,
                          ),
                          onPressed: _testGroupBehaviors,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),

        SizedBox(height: _sectionSpacing),

        _buildSection(
          title: 'Special Toast Types',
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isNarrow = constraints.maxWidth < 500;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: isNarrow
                          ? double.infinity
                          : constraints.maxWidth / 2 - 8,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.build),
                        label: const AppText(
                          'Custom Builder',
                          variant: TextVariant.labelMedium,
                        ),
                        onPressed: _showCustomBuilderToast,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.violet,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isNarrow
                          ? double.infinity
                          : constraints.maxWidth / 2 - 8,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.layers),
                        label: const AppText(
                          'Stack Multiple',
                          variant: TextVariant.labelMedium,
                        ),
                        onPressed: _showStackedToasts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isNarrow
                          ? double.infinity
                          : constraints.maxWidth / 2 - 8,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.update),
                        label: const AppText(
                          'Update Toast',
                          variant: TextVariant.labelMedium,
                        ),
                        onPressed: _showUpdatingToast,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isNarrow
                          ? double.infinity
                          : constraints.maxWidth / 2 - 8,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.timer),
                        label: const AppText(
                          'Progress Toast',
                          variant: TextVariant.labelMedium,
                        ),
                        onPressed: _showProgressToast,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isNarrow
                          ? double.infinity
                          : constraints.maxWidth / 2 - 8,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.more_horiz),
                        label: const AppText(
                          'Multi-Action',
                          variant: TextVariant.labelMedium,
                        ),
                        onPressed: _showMultiActionToast,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.accentForeground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: isNarrow
                          ? double.infinity
                          : constraints.maxWidth / 2 - 8,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.pin),
                        label: const AppText(
                          'Persistent',
                          variant: TextVariant.labelMedium,
                        ),
                        onPressed: _showPersistentToast,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.destructive,
                          foregroundColor: AppColors.destructiveForeground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  // Style settings tab
  Widget _buildStyleSettings() {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const ClampingScrollPhysics(),
      children: [
        _buildSection(
          title: 'Toast Appearance',
          children: [
            const AppText(
              'Background Color:',
              variant: TextVariant.labelMedium,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: _smallSpacing),
            _buildColorPicker(
              value: _backgroundColor,
              onChanged: (color) {
                setState(() {
                  _backgroundColor = color;
                });
              },
            ),
            SizedBox(height: _itemSpacing),
            const AppText(
              'Text Color:',
              variant: TextVariant.labelMedium,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: _smallSpacing),
            _buildSwitch(
              title: 'Use automatic text color',
              value: _textColor == null,
              onChanged: (value) {
                setState(() {
                  _textColor = value ? null : Colors.white;
                });
              },
            ),
            if (_textColor != null) ...[
              SizedBox(height: _smallSpacing),
              _buildColorPicker(
                value: _textColor!,
                onChanged: (color) {
                  setState(() {
                    _textColor = color;
                  });
                },
              ),
            ],
            SizedBox(height: _itemSpacing),
            AppText(
              'Border Radius: ${_borderRadius.toInt()} px',
              variant: TextVariant.labelMedium,
              fontWeight: FontWeight.bold,
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                thumbColor: AppColors.primary,
                inactiveTrackColor: AppColors.neutral.shade300,
                trackHeight: 4,
              ),
              child: Slider(
                value: _borderRadius,
                min: 0,
                max: 24,
                divisions: 12,
                label: '${_borderRadius.toInt()} px',
                onChanged: (value) {
                  setState(() {
                    _borderRadius = value;
                  });
                },
              ),
            ),
            SizedBox(height: _itemSpacing),
            AppText(
              'Elevation: ${_elevation.toInt()} px',
              variant: TextVariant.labelMedium,
              fontWeight: FontWeight.bold,
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.primary,
                thumbColor: AppColors.primary,
                inactiveTrackColor: AppColors.neutral.shade300,
                trackHeight: 4,
              ),
              child: Slider(
                value: _elevation,
                min: 0,
                max: 12,
                divisions: 12,
                label: '${_elevation.toInt()} px',
                onChanged: (value) {
                  setState(() {
                    _elevation = value;
                  });
                },
              ),
            ),
            SizedBox(height: _itemSpacing),
            _buildStylePreview(),
            SizedBox(height: _itemSpacing),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const AppText(
                  'Preview Custom Style',
                  variant: TextVariant.labelMedium,
                ),
                onPressed: _showCustomStyledToast,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: _sectionSpacing),
        _buildSection(
          title: 'Reset Styles',
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const AppText(
                  'Reset to Defaults',
                  variant: TextVariant.labelMedium,
                ),
                onPressed: _resetStyles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neutral.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHistoryPanel() {
    if (_history.isEmpty) {
      return Center(
        child: AppText(
          'No toast history yet.\nTry showing some toasts!',
          variant: TextVariant.bodyLarge,
          textAlign: TextAlign.center,
          color: AppColors.neutral.shade500,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              AppText(
                'Toast History',
                variant: TextVariant.titleMedium,
                fontWeight: FontWeight.bold,
              ),
              const Spacer(),
              // Show active toasts
              AppText(
                'Active: ${_activeToasts.length}',
                variant: TextVariant.labelMedium,
                color: AppColors.neutral.shade600,
              ),
              const SizedBox(width: 16),
              TextButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const AppText(
                  'Clear',
                  variant: TextVariant.labelMedium,
                ),
                onPressed: () {
                  setState(() {
                    _history.clear();
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final item = _history[_history.length - 1 - index];
              final isActive = _activeToasts.containsKey(item.id);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: isActive
                      ? BorderSide(
                          color: _getColorForLevel(item.level),
                          width: 2,
                        )
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading: Icon(
                    _getIconForLevel(item.level),
                    color: _getColorForLevel(item.level),
                  ),
                  title: AppText(
                    item.title,
                    variant: TextVariant.bodyMedium,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  subtitle: item.message != null
                      ? AppText(
                          item.message!,
                          variant: TextVariant.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive)
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: 'Close toast',
                          onPressed: () {
                            if (_activeToasts.containsKey(item.id)) {
                              _activeToasts[item.id]?.close();
                              _activeToasts.remove(item.id);
                              setState(() {});
                            }
                          },
                          color: AppColors.neutral.shade700,
                        ),
                      AppText(
                        _formatTimestamp(item.timestamp),
                        variant: TextVariant.labelSmall,
                        color: AppColors.neutral.shade600,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.titleMedium,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        SizedBox(height: _smallSpacing),
        Card(
          elevation: _cardElevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToastTypeChip(ToastLevel level, String label) {
    final isSelected = _level == level;
    return FilterChip(
      label: AppText(
        label,
        variant: TextVariant.labelMedium,
        color: isSelected ? Colors.white : null,
      ),
      selected: isSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
      backgroundColor: isSelected ? null : AppColors.neutral.shade200,
      selectedColor: _getColorForLevel(level),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _level = level;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildAnimationChip(
      ToastAnimationType animation, String label, bool isEntry) {
    final isSelected =
        isEntry ? _entryAnimation == animation : _exitAnimation == animation;
    return FilterChip(
      label: AppText(
        label,
        variant: TextVariant.labelMedium,
        color: isSelected ? Colors.white : null,
      ),
      selected: isSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
      backgroundColor: isSelected ? null : AppColors.neutral.shade200,
      selectedColor: AppColors.primary,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            if (isEntry) {
              _entryAnimation = animation;
            } else {
              _exitAnimation = animation;
            }
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // Build shifting animation chip
  Widget _buildShiftingAnimationChip(
      ToastShiftingAnimationType type, String label) {
    final isSelected = _shiftingAnimationType == type;
    return FilterChip(
      label: AppText(
        label,
        variant: TextVariant.labelMedium,
        color: isSelected ? Colors.white : null,
      ),
      selected: isSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
      backgroundColor: isSelected ? null : AppColors.neutral.shade200,
      selectedColor: AppColors.primary,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _shiftingAnimationType = type;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildGroupBehaviorChip(ToastGroupBehavior behavior, String label) {
    final isSelected = _groupBehavior == behavior;
    return FilterChip(
      label: AppText(
        label,
        variant: TextVariant.labelMedium,
        color: isSelected ? Colors.white : null,
      ),
      selected: isSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
      backgroundColor: isSelected ? null : AppColors.neutral.shade200,
      selectedColor: AppColors.primary,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _groupBehavior = behavior;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildPositionChip(ToastPosition position, String label) {
    final isSelected = _position == position && !_isCustomPosition;
    return FilterChip(
      label: AppText(
        label,
        variant: TextVariant.labelMedium,
        color: isSelected ? Colors.white : null,
      ),
      selected: isSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
      backgroundColor: isSelected ? null : AppColors.neutral.shade200,
      selectedColor: AppColors.primary,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _position = position;
            _isCustomPosition = false;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // Build priority chip
  Widget _buildPriorityChip(ToastPriority priority, String label) {
    final isSelected = _priority == priority;
    return FilterChip(
      label: AppText(
        label,
        variant: TextVariant.labelMedium,
        color: isSelected ? Colors.white : null,
      ),
      selected: isSelected,
      showCheckmark: false,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
      backgroundColor: isSelected ? null : AppColors.neutral.shade200,
      selectedColor: _getPriorityColor(priority),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _priority = priority;
          });
        }
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  Widget _buildQuickActionButton(
      String label, IconData icon, ToastLevel level) {
    final color = _getColorForLevel(level);
    return ElevatedButton.icon(
      icon: Icon(icon),
      label: AppText(label, variant: TextVariant.labelMedium),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () => _showPredefinedToast(level),
    );
  }

  // Custom checkbox
  Widget _buildCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?>? onChanged,
  }) {
    return CheckboxListTile(
      title: AppText(
        title,
        variant: TextVariant.bodyMedium,
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: AppColors.primary,
    );
  }

  // Custom switch
  Widget _buildSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: AppText(
        title,
        variant: TextVariant.bodyMedium,
      ),
      subtitle: subtitle != null
          ? AppText(
              subtitle,
              variant: TextVariant.bodySmall,
              color: AppColors.neutral.shade600,
            )
          : null,
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
      activeColor: AppColors.primary,
    );
  }

  // Color picker widget
  Widget _buildColorPicker({
    required Color value,
    required ValueChanged<Color> onChanged,
  }) {
    // Predefined colors using AppColors
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.muted,
      AppColors.accent,
      AppColors.destructive,
      AppColors.blue,
      AppColors.green,
      AppColors.red,
      AppColors.success,
      AppColors.warning,
      AppColors.orange,
      AppColors.violet,
      AppColors.chart1,
      AppColors.chart2,
      AppColors.chart3,
      AppColors.chart4,
      AppColors.chart5,
      AppColors.chart6,
      AppColors.chart7,
      AppColors.neutral.shade800,
    ];

    return Wrap(
      spacing: _smallSpacing,
      runSpacing: _smallSpacing,
      children: colors.map((color) {
        // Use color equality check that works properly
        final isSelected = color == value;
        return GestureDetector(
          onTap: () => onChanged(color),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: isSelected ? BoxShape.rectangle : BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 2,
              ),
              borderRadius: isSelected ? BorderRadius.circular(8) : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  // Style preview widget
  Widget _buildStylePreview() {
    // Determine text color based on background brightness
    final effectiveTextColor = _textColor ??
        (ThemeData.estimateBrightnessForColor(_backgroundColor) ==
                Brightness.dark
            ? Colors.white
            : Colors.black);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(_borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: _elevation * 2,
            offset: Offset(0, _elevation / 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.style,
            color: effectiveTextColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AppText(
              'Custom Style Preview',
              variant: TextVariant.bodyMedium,
              color: effectiveTextColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Get dropdown items for curves
  List<DropdownMenuItem<Curve>> _getCurveItems() {
    return [
      DropdownMenuItem(
          value: Curves.easeOutCubic,
          child: AppText('ease-out-cubic', variant: TextVariant.bodyMedium)),
      DropdownMenuItem(
          value: Curves.easeInCubic,
          child: AppText('ease-in-cubic', variant: TextVariant.bodyMedium)),
      DropdownMenuItem(
          value: Curves.easeInOutCubic,
          child: AppText('ease-in-out-cubic', variant: TextVariant.bodyMedium)),
      DropdownMenuItem(
          value: Curves.linear,
          child: AppText('linear', variant: TextVariant.bodyMedium)),
      DropdownMenuItem(
          value: Curves.elasticIn,
          child: AppText('elastic-in', variant: TextVariant.bodyMedium)),
      DropdownMenuItem(
          value: Curves.elasticOut,
          child: AppText('elastic-out', variant: TextVariant.bodyMedium)),
      DropdownMenuItem(
          value: Curves.bounceIn,
          child: AppText('bounce-in', variant: TextVariant.bodyMedium)),
      DropdownMenuItem(
          value: Curves.bounceOut,
          child: AppText('bounce-out', variant: TextVariant.bodyMedium)),
      DropdownMenuItem(
          value: Curves.fastOutSlowIn,
          child: AppText('fast-out-slow-in', variant: TextVariant.bodyMedium)),
    ];
  }

  // Get name for shifting animation type
  String _getShiftingAnimationName(ToastShiftingAnimationType type) {
    switch (type) {
      case ToastShiftingAnimationType.fade:
        return 'Fade';
      case ToastShiftingAnimationType.scale:
        return 'Scale';
      case ToastShiftingAnimationType.slide:
        return 'Slide';
      case ToastShiftingAnimationType.slideAndFade:
        return 'Slide + Fade';
      case ToastShiftingAnimationType.scaleAndFade:
        return 'Scale + Fade';
    }
  }

  List<DropdownMenuItem<String>> _buildGroupItems() {
    return [
      'notifications',
      'updates',
      'errors',
      'custom',
    ].map((String group) {
      return DropdownMenuItem<String>(
        value: group,
        child: AppText(group, variant: TextVariant.bodyMedium),
      );
    }).toList();
  }

  void _showCustomizedToast() {
    if (!_hasOverlayContext) {
      // Use your own error display mechanism instead of ScaffoldMessenger
      showToast(
        context: context,
        title: 'Error',
        message: 'Unable to show toast: No overlay found',
        level: ToastLevel.error,
      );
      return;
    }

    final title = _titleController.text;
    final message = _messageController.text;
    final semanticLabel = _semanticLabelController.text.isNotEmpty
        ? _semanticLabelController.text
        : null;

    // Create actions if enabled
    List<ToastAction>? actions;
    if (_includeActions) {
      actions = [
        ToastAction(
          label: 'Action',
          onPressed: () {
            _addToHistory(
              'Action Pressed',
              'User pressed action button',
              _level,
            );
          },
        ),
        ToastAction(
          label: 'Close',
          onPressed: () {},
          closeOnPressed: true,
        ),
      ];
    }

    // Generate ID for tracking
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    // Show toast
    final toast = showToast(
      context: context,
      title: title,
      message: message,
      level: _level,
      position: _position,
      customPosition: _isCustomPosition ? _customPosition : null,
      entryAnimation: _entryAnimation,
      exitAnimation: _exitAnimation,
      dismissible: _dismissible,
      persistent: _persistent,
      interactions: _interactions,
      duration: Duration(seconds: _durationSeconds),
      actions: actions,
      leading: _includeIcon ? null : const SizedBox(),
      group: _selectedGroupId,
      groupBehavior: _selectedGroupId != null ? _groupBehavior : null,
      priority: _priority,
      semanticLabel: semanticLabel,
      shiftingAnimationType: _shiftingAnimationType,
      shiftingAnimationDuration:
          Duration(milliseconds: _shiftingAnimationDuration),
      shiftingAnimationCurve: _shiftingAnimationCurve,
      announceOnUpdate: _announceToast,
      id: id,
    );

    // Add to history and active toasts
    _addToHistory(
      title,
      message,
      _level,
      id: id,
      priority: _priority,
      persistent: _persistent,
    );

    _activeToasts[id] = toast;
  }

  void _showPredefinedToast(ToastLevel level) {
    String title;
    String message;
    String id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    switch (level) {
      case ToastLevel.info:
        title = 'Information';
        message = 'This is an informational toast message.';
        break;
      case ToastLevel.success:
        title = 'Success';
        message = 'Operation completed successfully!';
        break;
      case ToastLevel.warning:
        title = 'Warning';
        message = 'Please be cautious with this action.';
        break;
      case ToastLevel.error:
        title = 'Error';
        message = 'Something went wrong. Please try again.';
        break;
    }

    ToastOverlay toast;
    switch (level) {
      case ToastLevel.info:
        toast = showInfoToast(
          context: context,
          title: title,
          message: message,
          position: _position,
          priority: _priority,
          persistent: _persistent,
          duration: Duration(seconds: _durationSeconds),
        );
        break;
      case ToastLevel.success:
        toast = showSuccessToast(
          context: context,
          title: title,
          message: message,
          position: _position,
          priority: _priority,
          persistent: _persistent,
          duration: Duration(seconds: _durationSeconds),
        );
        break;
      case ToastLevel.warning:
        toast = showWarningToast(
          context: context,
          title: title,
          message: message,
          position: _position,
          priority: _priority,
          persistent: _persistent,
          duration: Duration(seconds: _durationSeconds),
        );
        break;
      case ToastLevel.error:
        toast = showErrorToast(
          context: context,
          title: title,
          message: message,
          position: _position,
          priority: _priority,
          persistent: _persistent,
          duration: Duration(seconds: _durationSeconds),
        );
        break;
    }

    _addToHistory(
      title,
      message,
      level,
      id: id,
      priority: _priority,
      persistent: _persistent,
    );

    _activeToasts[id] = toast;
  }

  void _addToastToGroup() {
    if (_selectedGroupId == null) return;

    final title = '${_selectedGroupId?.toUpperCase()} Update';
    final message = 'New toast in the $_selectedGroupId group';
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    final toast = showToast(
      context: context,
      title: title,
      message: message,
      level: _level,
      position: _position,
      dismissible: _dismissible,
      persistent: _persistent,
      duration: Duration(seconds: _durationSeconds),
      group: _selectedGroupId,
      groupBehavior: _groupBehavior,
      priority: _priority,
      id: id,
    );

    _addToHistory(
      title,
      message,
      _level,
      id: id,
      group: _selectedGroupId,
      groupBehavior: _groupBehavior,
      priority: _priority,
      persistent: _persistent,
    );

    _activeToasts[id] = toast;
  }

  void _showCustomBuilderToast() {
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    final toast = showCustomToast(
      context: context,
      position: _position,
      priority: _priority,
      persistent: _persistent,
      duration: Duration(seconds: _durationSeconds),
      shiftingAnimationType: _shiftingAnimationType,
      shiftingAnimationDuration:
          Duration(milliseconds: _shiftingAnimationDuration),
      shiftingAnimationCurve: _shiftingAnimationCurve,
      builder: (context, overlay) {
        return Card(
          color: AppColors.violet.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppColors.violet.shade300, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.violet.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.brush,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        'Custom Builder Toast',
                        variant: TextVariant.titleSmall,
                        fontWeight: FontWeight.bold,
                      ),
                      const AppText(
                        'This toast uses a completely custom builder!',
                        variant: TextVariant.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.violet,
                          ),
                          onPressed: () => overlay.close(),
                          child: const AppText(
                            'DISMISS',
                            variant: TextVariant.labelMedium,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    _addToHistory(
      'Custom Builder',
      'This toast uses a completely custom builder!',
      _level,
      id: id,
      priority: _priority,
      persistent: _persistent,
    );

    _activeToasts[id] = toast;
  }

  void _showStackedToasts() {
    for (int i = 1; i <= 3; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        if (!mounted) return;

        final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';
        final levelIndex = i % ToastLevel.values.length;
        final level = ToastLevel.values[levelIndex];

        final toast = showToast(
          context: context,
          title: 'Stacked Toast #$i',
          message: 'This is toast number $i in the stack',
          position: _position,
          level: level,
          priority: _priority,
          duration: Duration(seconds: _durationSeconds),
          id: id,
        );

        _addToHistory(
          'Stacked Toast #$i',
          'This is toast number $i in the stack',
          level,
          id: id,
          priority: _priority,
        );

        _activeToasts[id] = toast;
      });
    }
  }

  void _showUpdatingToast() {
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    final toast = showToast(
      context: context,
      title: 'Updating Toast',
      message: 'Initial message...',
      position: _position,
      level: _level,
      priority: _priority,
      persistent: _persistent,
      duration: const Duration(seconds: 10),
      id: id,
    );

    _addToHistory(
      'Updating Toast',
      'Initial message...',
      _level,
      id: id,
      priority: _priority,
      persistent: _persistent,
    );

    _activeToasts[id] = toast;

    // Update after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      toast.update(
          title: 'Updating Toast', message: 'Message updated after 2 seconds');
      _addToHistory(
        'Toast Updated',
        'Message updated after 2 seconds',
        _level,
        id: id,
        priority: _priority,
        persistent: _persistent,
      );
    });

    // Update after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      toast.update(title: 'Final Update', message: 'This is the final message');
      _addToHistory(
        'Toast Updated Again',
        'This is the final message',
        _level,
        id: id,
        priority: _priority,
        persistent: _persistent,
      );
    });
  }

  void _showProgressToast() {
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    // Initial toast
    final toast = showToast(
      context: context,
      builder: (context, overlay) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.download,
                        color: AppColors.blue.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: AppText(
                        'Download Starting...',
                        variant: TextVariant.titleSmall,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: 0.0,
                  backgroundColor: AppColors.neutral.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
                ),
                const SizedBox(height: 8),
                const AppText(
                  'Initializing download...',
                  variant: TextVariant.bodySmall,
                ),
              ],
            ),
          ),
        );
      },
      position: _position,
      priority: _priority,
      persistent: _persistent,
      duration: const Duration(seconds: 15),
      id: id,
    );

    _addToHistory(
      'Progress Toast',
      'Download starting...',
      ToastLevel.info,
      id: id,
      priority: _priority,
      persistent: _persistent,
    );

    _activeToasts[id] = toast;

    // Update progress
    for (int i = 1; i <= 5; i++) {
      Future.delayed(Duration(seconds: i * 2), () {
        if (!mounted) return;
        final progress = i * 0.2;
        final percentage = (progress * 100).toInt();

        if (!toast.isShowing) return;

        toast.update(
          content: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: i < 5
                              ? AppColors.blue.shade100
                              : AppColors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          i < 5 ? Icons.download : Icons.check,
                          color: i < 5
                              ? AppColors.blue.shade700
                              : AppColors.green.shade700,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppText(
                          i < 5 ? 'Downloading...' : 'Download Complete',
                          variant: TextVariant.titleSmall,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.neutral.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      i < 5 ? AppColors.blue : AppColors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    i < 5 ? '$percentage% complete' : 'File ready to use',
                    variant: TextVariant.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        );

        _addToHistory(
          i < 5 ? 'Download Progress' : 'Download Complete',
          i < 5 ? '$percentage% complete' : 'File ready to use',
          i < 5 ? ToastLevel.info : ToastLevel.success,
          id: id,
          priority: _priority,
          persistent: _persistent,
        );
      });
    }
  }

  // Show a toast with multiple actions
  void _showMultiActionToast() {
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    // Create multiple actions
    final actions = [
      ToastAction(
        label: 'View',
        icon: Icons.visibility,
        onPressed: () {
          _addToHistory(
            'View Action',
            'User pressed View button',
            ToastLevel.info,
          );
        },
        closeOnPressed: false,
      ),
      ToastAction(
        label: 'Edit',
        icon: Icons.edit,
        onPressed: () {
          _addToHistory(
            'Edit Action',
            'User pressed Edit button',
            ToastLevel.info,
          );
        },
        closeOnPressed: false,
      ),
      ToastAction(
        label: 'Delete',
        icon: Icons.delete,
        onPressed: () {
          _addToHistory(
            'Delete Action',
            'User pressed Delete button',
            ToastLevel.warning,
          );
        },
        style: TextButton.styleFrom(
          foregroundColor: AppColors.destructive,
        ),
      ),
    ];

    final toast = showToast(
      context: context,
      title: 'Multiple Actions Toast',
      message: 'This toast has multiple action buttons',
      position: _position,
      level: _level,
      priority: _priority,
      persistent: _persistent,
      duration: Duration(seconds: _durationSeconds),
      actions: actions,
      id: id,
    );

    _addToHistory(
      'Multiple Actions Toast',
      'This toast has multiple action buttons',
      _level,
      id: id,
      priority: _priority,
      persistent: _persistent,
    );

    _activeToasts[id] = toast;
  }

  void _showPersistentToast() {
    if (!_hasOverlayContext) {
      showToast(
        context: context,
        title: 'Error',
        message:
            'No overlay found. Make sure OverlayManagerLayer is in the widget tree.',
        level: ToastLevel.error,
        duration: const Duration(seconds: 5),
      );
      return;
    }

    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    final toast = showToast(
      context: context,
      title: 'Persistent Toast',
      message: 'This toast will remain until manually dismissed',
      position: _position,
      level: _level,
      priority: _priority,
      persistent: true,
      dismissible: true,
      duration: null,
      id: id,
    );

    _addToHistory(
      'Persistent Toast',
      'This toast will remain until manually dismissed',
      _level,
      id: id,
      priority: _priority,
      persistent: true,
    );

    _activeToasts[id] = toast;
  }

  // Test priority replacement
  void _testPriorityReplace() {
    // First display low priority toasts
    for (int i = 1; i <= _maxVisibleToasts; i++) {
      final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

      final toast = showToast(
        context: context,
        title: 'Low Priority Toast #$i',
        message: 'This is a low priority toast',
        position: _position,
        level: ToastLevel.info,
        priority: ToastPriority.low,
        duration: const Duration(seconds: 10),
        id: id,
      );

      _addToHistory(
        'Low Priority Toast #$i',
        'This is a low priority toast',
        ToastLevel.info,
        id: id,
        priority: ToastPriority.low,
      );

      _activeToasts[id] = toast;
    }

    // Delay and then show a high priority toast that will replace
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;

      final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

      final toast = showToast(
        context: context,
        title: 'High Priority Toast',
        message: 'This high priority toast replaced a low priority one',
        position: _position,
        level: ToastLevel.warning,
        priority: ToastPriority.high,
        duration: const Duration(seconds: 10),
        id: id,
      );

      _addToHistory(
        'High Priority Toast',
        'This high priority toast replaced a low priority one',
        ToastLevel.warning,
        id: id,
        priority: ToastPriority.high,
      );

      _activeToasts[id] = toast;
    });

    // Delay and then show an urgent priority toast
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;

      final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

      final toast = showToast(
        context: context,
        title: 'Urgent Priority Toast',
        message: 'This urgent toast should take precedence over all others',
        position: _position,
        level: ToastLevel.error,
        priority: ToastPriority.urgent,
        duration: const Duration(seconds: 10),
        id: id,
      );

      _addToHistory(
        'Urgent Priority Toast',
        'This urgent toast should take precedence over all others',
        ToastLevel.error,
        id: id,
        priority: ToastPriority.urgent,
      );

      _activeToasts[id] = toast;
    });
  }

  // Test shifting animations
  void _testShiftingAnimation() {
    // Show a set of toasts that will demonstrate shifting
    for (int i = 1; i <= _maxVisibleToasts + 2; i++) {
      final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

      final toast = showToast(
        context: context,
        title: 'Shifting Toast #$i',
        message: 'Watch the shifting animation when toasts appear/disappear',
        position: _position,
        level: ToastLevel.info,
        priority: _priority,
        shiftingAnimationType: _shiftingAnimationType,
        shiftingAnimationDuration:
            Duration(milliseconds: _shiftingAnimationDuration),
        shiftingAnimationCurve: _shiftingAnimationCurve,
        duration: Duration(seconds: 3 + i),
        id: id,
      );

      _addToHistory(
        'Shifting Toast #$i',
        'Toast with custom shifting animation',
        ToastLevel.info,
        id: id,
        priority: _priority,
      );

      _activeToasts[id] = toast;

      // Slightly stagger the display
      if (i < _maxVisibleToasts + 2) {
        Future.delayed(const Duration(milliseconds: 500), () {});
      }
    }
  }

  // Test interactions
  void _testInteractions() {
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    String interactionText = '';
    if (_interactions.isEmpty) {
      interactionText = 'No interactions enabled (try swiping or tapping)';
    } else {
      interactionText =
          'Enabled: ${_interactions.map((i) => i.toString().split('.').last).join(', ')}';
    }

    final toast = showToast(
      context: context,
      title: 'Interaction Test',
      message: interactionText,
      position: _position,
      level: _level,
      priority: _priority,
      interactions: _interactions,
      duration: Duration(seconds: _durationSeconds),
      id: id,
    );

    _addToHistory(
      'Interaction Test',
      interactionText,
      _level,
      id: id,
      priority: _priority,
    );

    _activeToasts[id] = toast;
  }

  // Test accessibility features
  void _testAccessibility() {
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    final semanticLabel = _semanticLabelController.text.isNotEmpty
        ? _semanticLabelController.text
        : 'Accessibility Test Toast';

    final semanticHint = 'This toast is designed to be screen reader friendly';

    final toast = showToast(
      context: context,
      title: 'Accessibility Test',
      message: 'This toast is optimized for screen readers',
      position: _position,
      level: _level,
      priority: _priority,
      semanticLabel: semanticLabel,
      semanticHint: semanticHint,
      announceOnUpdate: _announceToast,
      duration: Duration(seconds: _durationSeconds),
      id: id,
    );

    _addToHistory(
      'Accessibility Test',
      'This toast is optimized for screen readers',
      _level,
      id: id,
      priority: _priority,
    );

    _activeToasts[id] = toast;
  }

  // Test group behaviors in comparison
  void _testGroupBehaviors() {
    // Show a demo of all group behaviors side by side
    final groups = ['stack_group', 'collapse_group', 'replace_group'];

    for (final group in groups) {
      final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';
      final behavior = _getGroupBehaviorForName(group);

      final toast = showToast(
        context: context,
        title: '$behavior Group',
        message: 'Initial toast in the group',
        position: _position,
        level: _level,
        priority: _priority,
        group: group,
        groupBehavior: behavior,
        duration: const Duration(seconds: 15),
        id: id,
      );

      _addToHistory(
        '$behavior Group',
        'Initial toast in the group',
        _level,
        id: id,
        priority: _priority,
        group: group,
        groupBehavior: behavior,
      );

      _activeToasts[id] = toast;
    }

    // Add more toasts to each group after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      for (final group in groups) {
        final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';
        final behavior = _getGroupBehaviorForName(group);

        final toast = showToast(
          context: context,
          title: '$behavior Group',
          message: 'Second toast in the group',
          position: _position,
          level: _level,
          priority: _priority,
          group: group,
          groupBehavior: behavior,
          duration: const Duration(seconds: 15),
          id: id,
        );

        _addToHistory(
          '$behavior Group',
          'Second toast in the group',
          _level,
          id: id,
          priority: _priority,
          group: group,
          groupBehavior: behavior,
        );

        _activeToasts[id] = toast;
      }
    });

    // Add a third round of toasts
    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      for (final group in groups) {
        final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';
        final behavior = _getGroupBehaviorForName(group);

        final toast = showToast(
          context: context,
          title: '$behavior Group',
          message: 'Third toast in the group',
          position: _position,
          level: _level,
          priority: _priority,
          group: group,
          groupBehavior: behavior,
          duration: const Duration(seconds: 15),
          id: id,
        );

        _addToHistory(
          '$behavior Group',
          'Third toast in the group',
          _level,
          id: id,
          priority: _priority,
          group: group,
          groupBehavior: behavior,
        );

        _activeToasts[id] = toast;
      }
    });
  }

  // Test max visible toasts
  void _testMaxVisibleToasts() {
    // Show a sequence of toasts to demonstrate max visible limit
    for (int i = 1; i <= _maxVisibleToasts + 3; i++) {
      final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

      Future.delayed(Duration(milliseconds: i * 400), () {
        if (!mounted) return;

        final toast = showToast(
          context: context,
          title: 'Toast #$i',
          message: i <= _maxVisibleToasts
              ? 'This toast is visible'
              : 'This toast is queued (position ${i - _maxVisibleToasts})',
          position: _position,
          level: i <= _maxVisibleToasts ? ToastLevel.success : ToastLevel.info,
          duration: const Duration(seconds: 10),
          id: id,
        );

        _addToHistory(
          'Toast #$i',
          i <= _maxVisibleToasts
              ? 'This toast is visible'
              : 'This toast is queued (position ${i - _maxVisibleToasts})',
          i <= _maxVisibleToasts ? ToastLevel.success : ToastLevel.info,
          id: id,
        );

        _activeToasts[id] = toast;
      });
    }
  }

  // Show a custom styled toast
  void _showCustomStyledToast() {
    final id = 'toast_${DateTime.now().millisecondsSinceEpoch}';

    // Create custom toast style
    final customStyle = ToastStyle(
      backgroundColor: _backgroundColor,
      textColor: _textColor,
      borderRadius: BorderRadius.circular(_borderRadius),
      elevation: _elevation,
    );

    final toast = showToast(
      context: context,
      title: 'Custom Styled Toast',
      message: 'This toast has a completely custom appearance',
      position: _position,
      style: customStyle,
      duration: Duration(seconds: _durationSeconds),
      id: id,
    );

    _addToHistory(
      'Custom Styled Toast',
      'This toast has a completely custom appearance',
      _level,
      id: id,
    );

    _activeToasts[id] = toast;
  }

  // Reset styles to default
  void _resetStyles() {
    setState(() {
      _backgroundColor = AppColors.primary;
      _textColor = null;
      _borderRadius = 8.0;
      _elevation = 4.0;
    });
  }

  // Get group behavior based on name
  ToastGroupBehavior _getGroupBehaviorForName(String name) {
    if (name.contains('stack')) return ToastGroupBehavior.stack;
    if (name.contains('collapse')) return ToastGroupBehavior.collapse;
    if (name.contains('replace')) return ToastGroupBehavior.replace;
    return ToastGroupBehavior.stack;
  }

  void _addToHistory(
    String title,
    String? message,
    ToastLevel level, {
    String? id,
    ToastPriority? priority,
    bool? persistent,
    String? group,
    ToastGroupBehavior? groupBehavior,
  }) {
    setState(() {
      _history.add(_ToastHistoryItem(
        title: title,
        message: message,
        level: level,
        timestamp: DateTime.now(),
        id: id ?? 'history_${DateTime.now().millisecondsSinceEpoch}',
        priority: priority,
        persistent: persistent,
        group: group,
        groupBehavior: groupBehavior,
      ));

      // Limit history size
      if (_history.length > 100) {
        _history.removeAt(0);
      }
    });
  }

  Color _getColorForLevel(ToastLevel level) {
    switch (level) {
      case ToastLevel.info:
        return AppColors.blue;
      case ToastLevel.success:
        return AppColors.success;
      case ToastLevel.warning:
        return AppColors.warning;
      case ToastLevel.error:
        return AppColors.destructive;
    }
  }

  // Get color for priority level
  Color _getPriorityColor(ToastPriority priority) {
    switch (priority) {
      case ToastPriority.low:
        return AppColors.neutral.shade700;
      case ToastPriority.normal:
        return AppColors.blue;
      case ToastPriority.high:
        return AppColors.warning;
      case ToastPriority.urgent:
        return AppColors.destructive;
    }
  }

  IconData _getIconForLevel(ToastLevel level) {
    switch (level) {
      case ToastLevel.info:
        return Icons.info_outline;
      case ToastLevel.success:
        return Icons.check_circle_outline;
      case ToastLevel.warning:
        return Icons.warning_amber_outlined;
      case ToastLevel.error:
        return Icons.error_outline;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class _ToastHistoryItem {
  final String title;
  final String? message;
  final ToastLevel level;
  final DateTime timestamp;
  final String id;
  final ToastPriority? priority;
  final bool? persistent;
  final String? group;
  final ToastGroupBehavior? groupBehavior;

  _ToastHistoryItem({
    required this.title,
    this.message,
    required this.level,
    required this.timestamp,
    required this.id,
    this.priority,
    this.persistent,
    this.group,
    this.groupBehavior,
  });
}
