import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/overlay/drawer.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart' hide DrawerController;

class DrawerSandbox extends StatefulWidget {
  const DrawerSandbox({super.key});

  @override
  State<DrawerSandbox> createState() => _DrawerSandboxState();
}

class _DrawerSandboxState extends State<DrawerSandbox> {
  // Controllers for programmatic control
  final DrawerController _leftDrawerController = DrawerController();
  final DrawerController _rightDrawerController = DrawerController();
  final SheetController _bottomSheetController = SheetController();
  final SheetController _snapSheetController = SheetController();

  // Constants for design consistency
  final double _cardBorderRadius = 12.0;
  final double _buttonBorderRadius = 8.0;
  final double _spacing = 16.0;

  // Customization options
  bool _modalDrawers = true;
  bool _barrierDismissible = true;
  bool _draggable = true;
  bool _useSafeArea = true;
  bool _showDragHandle = true;
  bool _resizable = false;
  DrawerPosition _selectedPosition = DrawerPosition.left;
  DrawerAnimationType _selectedAnimationType = DrawerAnimationType.slide;
  bool _withFadeEffect = true;

  @override
  void dispose() {
    _leftDrawerController.dispose();
    _rightDrawerController.dispose;
    _bottomSheetController.dispose;
    _snapSheetController.dispose;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _buildHeader(),
          SizedBox(height: _spacing * 2),

          // Basic drawers section
          _buildSectionTitle(
            title: 'Basic Drawers',
            description: 'Standard drawer types with various positions',
          ),
          _buildBasicDrawersSection(),
          SizedBox(height: _spacing * 2.5),

          // Sheets section
          _buildSectionTitle(
            title: 'Bottom Sheets',
            description: 'Sheets with various configurations and snap points',
          ),
          _buildSheetsSection(),
          SizedBox(height: _spacing * 2.5),

          // Advanced options section
          _buildSectionTitle(
            title: 'Customization',
            description: 'Configure drawer options and see them in action',
          ),
          _buildCustomizationSection(),
          SizedBox(height: _spacing * 2.5),

          // Programmatic control section
          _buildSectionTitle(
            title: 'Programmatic Control',
            description: 'Control drawers using controllers',
          ),
          _buildProgrammaticSection(),
          SizedBox(height: _spacing * 2),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(_spacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.7),
          ],
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
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Drawer System',
            variant: TextVariant.displaySmall,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 8),
          AppText(
            'A comprehensive showcase of drawer components and features',
            variant: TextVariant.bodyLarge,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          variant: TextVariant.headlineSmall,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        const SizedBox(height: 8),
        AppText(
          description,
          variant: TextVariant.bodyMedium,
          color: AppColors.neutral.shade600,
        ),
        SizedBox(height: _spacing),
      ],
    );
  }

  Widget _buildBasicDrawersSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final double availableWidth = constraints.maxWidth;
      final int columns = availableWidth > 600 ? 2 : 1;

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: _spacing,
          mainAxisSpacing: _spacing,
          childAspectRatio: 1.3,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildDrawerCard(
                title: 'Left Drawer',
                description: 'Opens from the left side of the screen',
                icon: Icons.arrow_back,
                color: AppColors.blue,
                onTap: _showLeftDrawer,
              );
            case 1:
              return _buildDrawerCard(
                title: 'Right Drawer',
                description: 'Opens from the right side of the screen',
                icon: Icons.arrow_forward,
                color: AppColors.green,
                onTap: _showRightDrawer,
              );
            case 2:
              return _buildDrawerCard(
                title: 'Top Drawer',
                description: 'Opens from the top of the screen',
                icon: Icons.arrow_upward,
                color: AppColors.orange,
                onTap: _showTopDrawer,
              );
            case 3:
              return _buildDrawerCard(
                title: 'RTL Support',
                description: 'Start/End position for RTL languages',
                icon: Icons.translate,
                color: AppColors.violet,
                onTap: _showRtlDrawer,
              );
            default:
              return const SizedBox();
          }
        },
      );
    });
  }

  Widget _buildSheetsSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final double availableWidth = constraints.maxWidth;
      final int columns = availableWidth > 600 ? 2 : 1;

      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: _spacing,
          mainAxisSpacing: _spacing,
          childAspectRatio: 1.3,
        ),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 4,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return _buildDrawerCard(
                title: 'Basic Sheet',
                description: 'Simple bottom sheet with single height',
                icon: Icons.arrow_upward,
                color: AppColors.primary,
                onTap: _showBasicSheet,
              );
            case 1:
              return _buildDrawerCard(
                title: 'Snap Points',
                description: 'Sheet with multiple snap points',
                icon: Icons.height,
                color: AppColors.blue[800]!,
                onTap: _showSnapPointsSheet,
              );
            case 2:
              return _buildDrawerCard(
                title: 'Header & Footer',
                description: 'Sheet with custom header and actions',
                icon: Icons.view_agenda_outlined,
                color: AppColors.red[500]!,
                onTap: _showHeaderSheet,
              );
            case 3:
              return _buildDrawerCard(
                title: 'Form Sheet',
                description: 'Sheet containing an input form',
                icon: Icons.edit_document,
                color: AppColors.blue[300]!,
                onTap: _showFormSheet,
              );
            default:
              return const SizedBox();
          }
        },
      );
    });
  }

  Widget _buildCustomizationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(_spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Customize Drawer',
              variant: TextVariant.titleMedium,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),

            // Position selection
            const AppText(
              'Position',
              variant: TextVariant.labelLarge,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPositionChip(DrawerPosition.left, 'Left'),
                  const SizedBox(width: 8),
                  _buildPositionChip(DrawerPosition.right, 'Right'),
                  const SizedBox(width: 8),
                  _buildPositionChip(DrawerPosition.top, 'Top'),
                  const SizedBox(width: 8),
                  _buildPositionChip(DrawerPosition.bottom, 'Bottom'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Animation type selection
            const AppText(
              'Animation',
              variant: TextVariant.labelLarge,
              fontWeight: FontWeight.w500,
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildAnimationChip(DrawerAnimationType.slide, 'Slide'),
                  const SizedBox(width: 8),
                  _buildAnimationChip(DrawerAnimationType.scale, 'Scale'),
                  const SizedBox(width: 8),
                  _buildAnimationChip(DrawerAnimationType.fade, 'Fade'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Options
            Wrap(
              spacing: _spacing,
              runSpacing: 8,
              children: [
                _buildOptionSwitch(
                  label: 'Modal',
                  value: _modalDrawers,
                  onChanged: (value) {
                    setState(() {
                      _modalDrawers = value;
                    });
                  },
                ),
                _buildOptionSwitch(
                  label: 'Barrier Dismiss',
                  value: _barrierDismissible,
                  onChanged: (value) {
                    setState(() {
                      _barrierDismissible = value;
                    });
                  },
                ),
                _buildOptionSwitch(
                  label: 'Draggable',
                  value: _draggable,
                  onChanged: (value) {
                    setState(() {
                      _draggable = value;
                    });
                  },
                ),
                _buildOptionSwitch(
                  label: 'Safe Area',
                  value: _useSafeArea,
                  onChanged: (value) {
                    setState(() {
                      _useSafeArea = value;
                    });
                  },
                ),
                _buildOptionSwitch(
                  label: 'Drag Handle',
                  value: _showDragHandle,
                  onChanged: (value) {
                    setState(() {
                      _showDragHandle = value;
                    });
                  },
                ),
                _buildOptionSwitch(
                  label: 'Resizable',
                  value: _resizable,
                  onChanged: (value) {
                    setState(() {
                      _resizable = value;
                    });
                  },
                ),
                _buildOptionSwitch(
                  label: 'Fade',
                  value: _withFadeEffect,
                  onChanged: (value) {
                    setState(() {
                      _withFadeEffect = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Preview button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showCustomDrawer,
                icon: const Icon(Icons.visibility),
                label: const Text('Preview Custom Drawer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_buttonBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgrammaticSection() {
    return LayoutBuilder(builder: (context, constraints) {
      final double availableWidth = constraints.maxWidth;
      final bool useVerticalLayout = availableWidth < 600;

      final leftDrawerCard = Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(_spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.west, color: AppColors.blue),
                  const SizedBox(width: 8),
                  const AppText(
                    'Persistent Left Drawer',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const AppText(
                'A drawer that remains in memory and can be controlled programmatically',
                variant: TextVariant.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      if (_leftDrawerController.isOpen) {
                        _leftDrawerController.close();
                      } else {
                        _openPersistentLeftDrawer();
                      }
                    },
                    child:
                        Text(_leftDrawerController.isOpen ? 'Close' : 'Open'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _openPersistentLeftDrawer,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      final bottomSheetCard = Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(_spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.south, color: AppColors.blue),
                  const SizedBox(width: 8),
                  const AppText(
                    'Controlled Sheet',
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const AppText(
                'A sheet with multiple snap points that can be controlled programmatically',
                variant: TextVariant.bodyMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ValueListenableBuilder(
                    valueListenable:
                        ValueNotifier<bool>(_bottomSheetController.isOpen),
                    builder: (context, isOpen, _) {
                      return TextButton(
                        onPressed: () {
                          if (isOpen) {
                            _bottomSheetController.close();
                          } else {
                            _openControlledSheet();
                          }
                        },
                        child: Text(isOpen ? 'Close' : 'Open'),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (_bottomSheetController.isOpen) {
                        final nextIndex =
                            (_bottomSheetController.currentSnapIndex + 1) % 3;
                        _bottomSheetController.snapTo(nextIndex);
                      } else {
                        _openControlledSheet();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Snap'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      if (useVerticalLayout) {
        return Column(
          children: [
            leftDrawerCard,
            SizedBox(height: _spacing),
            bottomSheetCard,
          ],
        );
      }

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: leftDrawerCard),
          SizedBox(width: _spacing),
          Expanded(child: bottomSheetCard),
        ],
      );
    });
  }

  Widget _buildDrawerCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(_cardBorderRadius),
        child: Padding(
          padding: EdgeInsets.all(_spacing),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 36,
                color: color,
              ),
              const SizedBox(height: 12),
              AppText(
                title,
                variant: TextVariant.titleMedium,
                fontWeight: FontWeight.w600,
              ),
              const Spacer(),
              AppText(
                description,
                variant: TextVariant.bodySmall,
                color: AppColors.neutral.shade600,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionChip(DrawerPosition position, String label) {
    final bool isSelected = _selectedPosition == position;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPosition = position;
          });
        }
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildAnimationChip(DrawerAnimationType animationType, String label) {
    final bool isSelected = _selectedAnimationType == animationType;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedAnimationType = animationType;
          });
        }
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.black87,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildOptionSwitch({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.neutral.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  // Basic drawers
  void _showLeftDrawer() {
    showDrawer(
      context: context,
      position: DrawerPosition.left,
      builder: (context) => _buildDrawerContent(
        'Left Drawer',
        'This drawer opens from the left side of the screen.',
        Icons.arrow_back,
        AppColors.blue,
      ),
    );
  }

  void _showRightDrawer() {
    showDrawer(
      context: context,
      position: DrawerPosition.right,
      builder: (context) => _buildDrawerContent(
        'Right Drawer',
        'This drawer opens from the right side of the screen.',
        Icons.arrow_forward,
        AppColors.green,
      ),
    );
  }

  void _showTopDrawer() {
    showDrawer(
      context: context,
      position: DrawerPosition.top,
      builder: (context) => _buildDrawerContent(
        'Top Drawer',
        'This drawer opens from the top of the screen.',
        Icons.arrow_upward,
        AppColors.orange,
        isVertical: false,
      ),
    );
  }

  void _showRtlDrawer() {
    showDrawer(
      context: context,
      position: DrawerPosition.start,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: _buildDrawerContent(
          'RTL Drawer',
          'This drawer uses start position which adapts to text direction.',
          Icons.translate,
          AppColors.violet,
          rtl: true,
        ),
      ),
    );
  }

  // Sheet examples
  void _showBasicSheet() {
    showSheet(
      context: context,
      builder: (context) => _buildSheetContent(
        'Basic Sheet',
        'A simple bottom sheet with fixed height.',
        Icons.arrow_upward,
        AppColors.primary,
      ),
    );
  }

  void _showSnapPointsSheet() {
    showSheet(
      context: context,
      snapPoints: [0.3, 0.6, 0.9],
      initialSnapIndex: 0,
      onSnapPointChanged: (index) {
        debugPrint('Snapped to point $index');
      },
      builder: (context) => _buildSheetContent(
        'Snap Points Sheet',
        'This sheet has multiple snap points (30%, 60%, 90%). Drag to snap between them.',
        Icons.height,
        AppColors.blue,
        includeSnapInfo: true,
      ),
    );
  }

  void _showHeaderSheet() {
    showSheet(
      context: context,
      headerBuilder: (context, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.view_agenda_outlined, color: AppColors.red[500]),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: AppText(
                      'Custom Header',
                      variant: TextVariant.titleMedium,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => closeSheet(context),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            child,
          ],
        );
      },
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'This sheet has a custom header with a close button.',
              variant: TextVariant.bodyMedium,
            ),
            const SizedBox(height: 16),
            const AppText(
              'Sheet content goes here. You can add any widgets.',
              variant: TextVariant.bodyMedium,
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => closeSheet(context, 'cancelled'),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => closeSheet(context, 'confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red[500],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFormSheet() {
    showSheet(
      context: context,
      snapPoints: [0.5, 0.8],
      initialSnapIndex: 0,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.edit_document, color: AppColors.blue[300]),
                  const SizedBox(width: 8),
                  const AppText(
                    'Form Sheet',
                    variant: TextVariant.titleLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const AppText(
                'This sheet contains a form. The keyboard will not push the sheet up.',
                variant: TextVariant.bodyMedium,
              ),
              const SizedBox(height: 24),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => closeSheet(context, 'submitted'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue[300]!,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_buttonBorderRadius),
                    ),
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Customized drawer
  void _showCustomDrawer() {
    showDrawer(
      context: context,
      position: _selectedPosition,
      modal: _modalDrawers,
      barrierDismissible: _barrierDismissible,
      draggable: _draggable,
      useSafeArea: _useSafeArea,
      showDragHandle: _showDragHandle,
      resizable: _resizable,
      animation: DrawerAnimation(
        type: _selectedAnimationType,
        withFade: _withFadeEffect,
      ),
      width: _selectedPosition == DrawerPosition.left ||
              _selectedPosition == DrawerPosition.right
          ? 300
          : null,
      height: _selectedPosition == DrawerPosition.top ||
              _selectedPosition == DrawerPosition.bottom
          ? 300
          : null,
      builder: (context) => _buildCustomizedContent(),
    );
  }

  // Programmatic examples
  void _openPersistentLeftDrawer() {
    showDrawer(
      context: context,
      position: DrawerPosition.left,
      controller: _leftDrawerController,
      width: 280,
      onOpen: () => debugPrint('Left drawer opened'),
      onClose: () => debugPrint('Left drawer closed'),
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.account_circle, color: AppColors.blue, size: 36),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'User Name',
                        variant: TextVariant.titleMedium,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 4),
                      AppText(
                        'user@example.com',
                        variant: TextVariant.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildDrawerMenuItem(Icons.home, 'Home', AppColors.blue),
          _buildDrawerMenuItem(Icons.person, 'Profile', AppColors.blue),
          _buildDrawerMenuItem(Icons.settings, 'Settings', AppColors.blue),
          _buildDrawerMenuItem(Icons.help, 'Help', AppColors.blue),
          const Spacer(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: OutlinedButton.icon(
              onPressed: () => _leftDrawerController.close(),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.blue,
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openControlledSheet() {
    showSheet(
      context: context,
      controller: _bottomSheetController,
      snapPoints: [0.3, 0.6, 0.9],
      initialSnapIndex: 0,
      onOpen: () => debugPrint('Bottom sheet opened'),
      onClose: () => debugPrint('Bottom sheet closed'),
      onSnapPointChanged: (index) {
        debugPrint('Sheet snapped to point $index');
      },
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.drag_indicator, color: AppColors.blue),
                const SizedBox(width: 8),
                const AppText(
                  'Controlled Sheet',
                  variant: TextVariant.titleLarge,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const AppText(
              'This sheet is controlled programmatically using a SheetController.',
              variant: TextVariant.bodyMedium,
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<int>(
              valueListenable:
                  ValueNotifier<int>(_bottomSheetController.currentSnapIndex),
              builder: (context, snapIndex, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Current snap point: ${snapIndex + 1} of 3',
                      variant: TextVariant.bodyMedium,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (snapIndex > 0)
                          ElevatedButton(
                            onPressed: () =>
                                _bottomSheetController.snapTo(snapIndex - 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.blue.withValues(alpha: 0.8),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Previous'),
                          ),
                        if (snapIndex < 2)
                          ElevatedButton(
                            onPressed: () =>
                                _bottomSheetController.snapTo(snapIndex + 1),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Next'),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _bottomSheetController.close(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.blue,
                ),
                child: const Text('Close Sheet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widgets
  Widget _buildDrawerContent(
    String title,
    String description,
    IconData icon,
    Color color, {
    bool isVertical = true,
    bool rtl = false,
  }) {
    return Container(
      width: isVertical ? 300 : double.infinity,
      height: isVertical ? double.infinity : 300,
      color: Colors.white,
      child: Column(
        crossAxisAlignment:
            rtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: AppText(
                    title,
                    variant: TextVariant.titleLarge,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => closeDrawer(context),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppText(
              description,
              variant: TextVariant.bodyMedium,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Icon(Icons.circle, color: color),
                  title: Text('Item ${index + 1}'),
                  onTap: () {},
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => closeDrawer(context, 'cancelled'),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => closeDrawer(context, 'confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheetContent(
    String title,
    String description,
    IconData icon,
    Color color, {
    bool includeSnapInfo = false,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: AppText(
                  title,
                  variant: TextVariant.titleLarge,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppText(
            description,
            variant: TextVariant.bodyMedium,
          ),
          if (includeSnapInfo) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: color.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: color, size: 20),
                      const SizedBox(width: 8),
                      AppText(
                        'Drag sheet to snap',
                        variant: TextVariant.labelLarge,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try dragging this sheet up or down to see it automatically snap to predefined heights.',
                    style: TextStyle(
                      color: color.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          for (int i = 1; i <= 3; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$i',
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Item $i',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Description for item $i',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => closeSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_buttonBorderRadius),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomizedContent() {
    final Color headerColor;
    final String title;
    final IconData icon;

    switch (_selectedPosition) {
      case DrawerPosition.left:
        headerColor = AppColors.blue;
        title = 'Left Drawer';
        icon = Icons.arrow_back;
        break;
      case DrawerPosition.right:
        headerColor = AppColors.green;
        title = 'Right Drawer';
        icon = Icons.arrow_forward;
        break;
      case DrawerPosition.top:
        headerColor = AppColors.orange;
        title = 'Top Drawer';
        icon = Icons.arrow_upward;
        break;
      case DrawerPosition.bottom:
        headerColor = AppColors.primary;
        title = 'Bottom Drawer';
        icon = Icons.arrow_downward;
        break;
      default:
        headerColor = AppColors.primary;
        title = 'Custom Drawer';
        icon = Icons.drag_indicator;
    }

    final bool isHorizontal = _selectedPosition == DrawerPosition.left ||
        _selectedPosition == DrawerPosition.right;

    return Container(
      width: isHorizontal ? null : double.infinity,
      height: !isHorizontal ? null : double.infinity,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor.withValues(alpha: 0.1),
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: headerColor, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: AppText(
                    title,
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => closeDrawer(context),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Current Configuration:',
                  variant: TextVariant.labelLarge,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 16),
                _buildConfigRow(
                    'Position', _selectedPosition.toString().split('.').last),
                _buildConfigRow('Animation',
                    _selectedAnimationType.toString().split('.').last),
                _buildConfigRow('Modal', _modalDrawers.toString()),
                _buildConfigRow(
                    'Barrier Dismissible', _barrierDismissible.toString()),
                _buildConfigRow('Draggable', _draggable.toString()),
                _buildConfigRow('Safe Area', _useSafeArea.toString()),
                _buildConfigRow('Drag Handle', _showDragHandle.toString()),
                _buildConfigRow('Resizable', _resizable.toString()),
                _buildConfigRow('With Fade', _withFadeEffect.toString()),
              ],
            ),
          ),
          const Divider(),
          if (isHorizontal)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.drag_indicator,
                      size: 48,
                      color: headerColor.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    AppText(
                      _resizable
                          ? 'Try resizing this drawer!'
                          : 'Drawer Content Area',
                      variant: TextVariant.bodyMedium,
                      color: headerColor,
                    ),
                  ],
                ),
              ),
            ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => closeDrawer(context),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    closeDrawer(context);
                    // Change to next animation type
                    setState(() {
                      final types = DrawerAnimationType.values;
                      final nextIndex =
                          (types.indexOf(_selectedAnimationType) + 1) %
                              types.length;
                      _selectedAnimationType = types[nextIndex];
                    });
                    _showCustomDrawer();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Another Animation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: headerColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigRow(String name, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.neutral.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerMenuItem(IconData icon, String label, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      onTap: () {},
    );
  }
}
