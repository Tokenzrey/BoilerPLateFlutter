import 'package:boilerplate/core/widgets/components/menu/menu.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
import 'package:boilerplate/core/widgets/components/overlay/drawer.dart';
import 'package:data_widget/data_widget.dart';
import 'package:flutter/material.dart';

class MenuPopup extends StatelessWidget {
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final List<Widget> children;

  const MenuPopup({
    super.key,
    this.surfaceOpacity,
    this.surfaceBlur,
    required this.children,
  });

  Widget _buildIntrinsicContainer(Widget child, Axis direction, bool wrap) {
    if (!wrap) {
      return child;
    }
    if (direction == Axis.vertical) {
      return IntrinsicWidth(child: child);
    }
    return IntrinsicHeight(child: child);
  }

  @override
  Widget build(BuildContext context) {
    final data = Data.maybeOf<MenuGroupData>(context);
    final theme = Theme.of(context);
    final isSheetOverlay = SheetOverlayHandler.isSheetOverlay(context);
    final isDialogOverlay = DialogOverlayHandler.isDialogOverlay(context);
    return DefaultTextStyle.merge(
      child: ModalContainer(
        borderRadius: BorderRadius.circular(12),
        filled: true,
        fillColor: theme.colorScheme.surface,
        borderColor: theme.colorScheme.outline,
        surfaceBlur: surfaceBlur ?? 0.5,
        surfaceOpacity: surfaceOpacity ?? 0.14,
        padding: isSheetOverlay
            ? const EdgeInsets.symmetric(vertical: 12, horizontal: 4)
            : const EdgeInsets.all(4),
        child: SingleChildScrollView(
          scrollDirection: data?.direction ?? Axis.vertical,
          child: _buildIntrinsicContainer(
            Flex(
              direction: data?.direction ?? Axis.vertical,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
            data?.direction ?? Axis.vertical,
            !isSheetOverlay && !isDialogOverlay,
          ),
        ),
      ),
      style: TextStyle(
        fontWeight: FontWeight.w400,
      ),
    );
  }
}
