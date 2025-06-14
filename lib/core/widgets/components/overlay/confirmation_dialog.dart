import 'package:boilerplate/constants/colors.dart';
import 'package:flutter/material.dart' hide showDialog;
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';

/// Configuration for the visual style of the confirmation dialog
class ConfirmDialogStyle {
  /// Background color of the dialog
  final Color? backgroundColor;

  /// Border radius of the dialog
  final BorderRadius? borderRadius;

  /// Border color and width
  final Border? border;

  /// Shadow for the dialog
  final List<BoxShadow>? boxShadow;

  /// Title text style
  final TextStyle? titleStyle;

  /// Content text style
  final TextStyle? contentStyle;

  /// Icon color and size
  final Color? iconColor;
  final double? iconSize;

  /// Background color for the icon container
  final Color? iconBackgroundColor;

  /// Border radius for the icon container
  final BorderRadius? iconContainerBorderRadius;

  /// Padding values for different sections
  final EdgeInsetsGeometry? headerPadding;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? footerPadding;

  /// Button size and spacing
  final double? buttonSpacing;
  final ButtonSize? buttonSize;
  final ButtonLayout? confirmButtonLayout;
  final ButtonLayout? cancelButtonLayout;

  const ConfirmDialogStyle({
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.boxShadow,
    this.titleStyle,
    this.contentStyle,
    this.iconColor,
    this.iconSize,
    this.iconBackgroundColor,
    this.iconContainerBorderRadius,
    this.headerPadding,
    this.contentPadding,
    this.footerPadding,
    this.buttonSpacing,
    this.buttonSize,
    this.confirmButtonLayout,
    this.cancelButtonLayout,
  });
}

/// A highly customizable confirmation dialog that prompts the user to confirm or cancel an action
class ConfirmDialog extends StatelessWidget {
  /// Dialog title text
  final String? title;

  /// Optional custom title widget that overrides the title text
  final Widget? titleWidget;

  /// Dialog content/message text
  final String? content;

  /// Optional custom content widget that overrides the content text
  final Widget? contentWidget;

  /// Text for the confirm button
  final String confirmText;

  /// Text for the cancel button
  final String cancelText;

  /// Variant for the confirm button
  final ButtonVariant confirmVariant;

  /// Variant for the cancel button
  final ButtonVariant cancelVariant;

  /// Callback when the user confirms the action
  final VoidCallback onConfirm;

  /// Callback when the user cancels the action
  final VoidCallback? onCancel;

  /// Optional icon to display in the title
  final IconData? icon;

  /// Optional custom icon widget that overrides the icon
  final Widget? iconWidget;

  /// Optional styling for the dialog
  final ConfirmDialogStyle? style;

  /// Whether to show the cancel button
  final bool showCancelButton;

  /// Optional value to return when confirmed (default is true)
  final dynamic confirmResult;

  /// Optional value to return when canceled (default is null)
  final dynamic cancelResult;

  /// Direction for button layout (horizontal or vertical)
  final bool useVerticalButtons;

  /// Alignment for the buttons
  final MainAxisAlignment buttonAlignment;

  /// Builder function for customizing the header
  final Widget Function(BuildContext, String?, Widget?)? headerBuilder;

  /// Builder function for customizing the content
  final Widget Function(BuildContext, String?, Widget?)? contentBuilder;

  /// Builder function for customizing the footer/buttons
  final Widget Function(BuildContext, String, ButtonVariant, String,
      ButtonVariant, VoidCallback, VoidCallback)? footerBuilder;

  /// Whether the content should be scrollable
  final bool scrollableContent;

  /// Optional scroll controller for the content
  final ScrollController? scrollController;

  /// Optional scroll physics for the content
  final ScrollPhysics? scrollPhysics;

  const ConfirmDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.content,
    this.contentWidget,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmVariant = ButtonVariant.primary,
    this.cancelVariant = ButtonVariant.outlined,
    required this.onConfirm,
    this.onCancel,
    this.icon,
    this.iconWidget,
    this.style,
    this.showCancelButton = true,
    this.confirmResult = true,
    this.cancelResult,
    this.useVerticalButtons = false,
    this.buttonAlignment = MainAxisAlignment.end,
    this.headerBuilder,
    this.contentBuilder,
    this.footerBuilder,
    this.scrollableContent = true,
    this.scrollController,
    this.scrollPhysics,
  }) : assert(
            title != null ||
                titleWidget != null ||
                content != null ||
                contentWidget != null,
            'At least one of title, titleWidget, content, or contentWidget must be provided');

  @override
  Widget build(BuildContext context) {
    // Icon widget to display in the dialog
    Widget? dialogIcon;
    if (iconWidget != null) {
      dialogIcon = iconWidget;
    } else if (icon != null) {
      final iconSize = style?.iconSize ?? 24.0;
      final iconColor = style?.iconColor ?? AppColors.primary;
      final iconBgColor = style?.iconBackgroundColor ??
          AppColors.primary.withValues(alpha: 0.1);
      final iconBorderRadius =
          style?.iconContainerBorderRadius ?? BorderRadius.circular(8);

      dialogIcon = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: iconBorderRadius,
        ),
        child: Icon(
          icon,
          size: iconSize,
          color: iconColor,
        ),
      );
    }

    // Build custom header if provided
    Widget? header;
    if (headerBuilder != null) {
      header = headerBuilder!(context, title, dialogIcon);
    }

    // Build custom content if provided
    Widget? dialogContent;
    if (contentBuilder != null) {
      dialogContent = contentBuilder!(context, content, contentWidget);
    } else if (contentWidget != null) {
      dialogContent = contentWidget;
    } else if (content != null) {
      dialogContent = AppText(
        content!,
        variant: TextVariant.bodyMedium,
        color: AppColors.neutral[700],
        textAlign: TextAlign.center,
        style: style?.contentStyle,
      );
    }

    // Handle cancel action
    void handleCancel() {
      if (onCancel != null) {
        onCancel!();
      }
      closeOverlayWithResult(context, cancelResult);
    }

    // Handle confirm action
    void handleConfirm() {
      onConfirm();
      closeOverlayWithResult(context, confirmResult);
    }

    // Build custom footer/buttons if provided
    Widget? footer;
    if (footerBuilder != null) {
      footer = footerBuilder!(context, confirmText, confirmVariant, cancelText,
          cancelVariant, handleConfirm, handleCancel);
    }

    // Build actions list for standard dialog
    List<Widget> actions = [];
    if (!useVerticalButtons && showCancelButton) {
      actions.add(
        Button(
          text: cancelText,
          variant: cancelVariant,
          onPressed: handleCancel,
          size: style?.buttonSize ?? ButtonSize.normal,
          layout: style?.cancelButtonLayout ?? const ButtonLayout(),
        ),
      );
    }

    actions.add(
      Button(
        text: confirmText,
        variant: confirmVariant,
        onPressed: handleConfirm,
        size: style?.buttonSize ?? ButtonSize.normal,
        layout: style?.confirmButtonLayout ?? const ButtonLayout(),
      ),
    );

    if (useVerticalButtons && showCancelButton) {
      actions = actions.reversed.toList();
    }

    // Build dialog using StandardDialog
    return Container(
      decoration: BoxDecoration(
        color: style?.backgroundColor,
        borderRadius: style?.borderRadius,
        border: style?.border,
        boxShadow: style?.boxShadow,
      ),
      child: StandardDialog(
        header: header,
        title: headerBuilder == null ? title : null,
        titleWidget: headerBuilder == null ? titleWidget : null,
        titleStyle: style?.titleStyle,
        leading: headerBuilder == null ? dialogIcon : null,
        content: dialogContent,
        footer: footer,
        actions: footerBuilder == null ? actions : [],
        headerPadding:
            style?.headerPadding ?? const EdgeInsets.fromLTRB(16, 16, 16, 8),
        contentPadding: style?.contentPadding ??
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        footerPadding:
            style?.footerPadding ?? const EdgeInsets.fromLTRB(16, 8, 16, 16),
        scrollable: scrollableContent,
        scrollController: scrollController,
        scrollPhysics: scrollPhysics,
        useVerticalButtonLayout: useVerticalButtons,
        buttonSpacing: style?.buttonSpacing,
        footerAlignment: buttonAlignment,
      ),
    );
  }
}

/// Helper function to create a danger confirmation dialog
ConfirmDialog dangerConfirmDialog({
  required String title,
  required String content,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  String confirmText = 'Delete',
  String cancelText = 'Cancel',
  IconData? icon = Icons.warning,
}) {
  return ConfirmDialog(
    title: title,
    content: content,
    confirmText: confirmText,
    cancelText: cancelText,
    confirmVariant: ButtonVariant.danger,
    onConfirm: onConfirm,
    onCancel: onCancel,
    icon: icon,
    style: ConfirmDialogStyle(
      iconColor: AppColors.red,
      iconBackgroundColor: AppColors.red.withValues(alpha: 0.1),
    ),
  );
}

/// Helper function to create a success confirmation dialog
ConfirmDialog successConfirmDialog({
  required String title,
  required String content,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  String confirmText = 'OK',
  String cancelText = 'Cancel',
  IconData? icon = Icons.check_circle,
  bool showCancelButton = false,
}) {
  return ConfirmDialog(
    title: title,
    content: content,
    confirmText: confirmText,
    cancelText: cancelText,
    showCancelButton: showCancelButton,
    onConfirm: onConfirm,
    onCancel: onCancel,
    icon: icon,
    style: ConfirmDialogStyle(
      iconColor: AppColors.success,
      iconBackgroundColor: AppColors.success.withValues(alpha: 0.1),
    ),
  );
}
