import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/image.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';

class AvatarPickerDialog extends StatefulWidget {
  final Function(String) onAvatarSelected;
  final String selectedAvatar;

  const AvatarPickerDialog({
    super.key,
    required this.onAvatarSelected,
    required this.selectedAvatar,
  });

  @override
  State<AvatarPickerDialog> createState() => _AvatarPickerDialogState();
}

class _AvatarPickerDialogState extends State<AvatarPickerDialog> {
  late String _selectedAvatar;

  // Complete list of avatars from 0 to 15
  final List<String> _avatars = [
    'assets/images/avatar/avatar1.png', // Avatar ID: 0
    'assets/images/avatar/avatar2.png', // Avatar ID: 1
    'assets/images/avatar/avatar3.png', // Avatar ID: 2
    'assets/images/avatar/avatar4.png', // Avatar ID: 3
    'assets/images/avatar/avatar5.png', // Avatar ID: 4
    'assets/images/avatar/avatar6.png', // Avatar ID: 5
    'assets/images/avatar/avatar7.png', // Avatar ID: 6
    'assets/images/avatar/avatar8.png', // Avatar ID: 7
    'assets/images/avatar/avatar9.png', // Avatar ID: 8
    'assets/images/avatar/avatar10.png', // Avatar ID: 9
    'assets/images/avatar/avatar11.png', // Avatar ID: 10
    'assets/images/avatar/avatar12.png', // Avatar ID: 11
    'assets/images/avatar/avatar13.png', // Avatar ID: 12
    'assets/images/avatar/avatar14.png', // Avatar ID: 13
    'assets/images/avatar/avatar15.png', // Avatar ID: 14
  ];

  @override
  void initState() {
    super.initState();
    _selectedAvatar = widget.selectedAvatar;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Adjust grid based on screen size
    final crossAxisCount = screenWidth > 600 ? 4 : 3;

    return StandardDialog(
      title: 'Choose an Avatar',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppText(
            'Select your favorite avatar from the options below',
            variant: TextVariant.bodySmall,
            color: AppColors.neutral[800],
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
              minHeight: 150,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: GridView.builder(
                padding: const EdgeInsets.all(4),
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  final avatar = _avatars[index];
                  final isSelected = avatar == _selectedAvatar;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50),
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatar;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.primary.withValues(alpha: .3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  )
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: AppImage.avatar(
                            src: avatar,
                            size: 80,
                            source: ImageSource.asset,
                            key: ValueKey('avatar-asset-$index'),
                            errorWidget: Container(
                              decoration: BoxDecoration(
                                color: AppColors.neutral.shade800,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: AppColors.neutral.shade400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      actions: [
        Button(
          text: 'Cancel',
          variant: ButtonVariant.ghost,
          onPressed: () => closeOverlayWithResult(context),
        ),
        Button(
          text: 'Select',
          variant: ButtonVariant.primary,
          onPressed: () {
            widget.onAvatarSelected(_selectedAvatar);
            closeOverlayWithResult(context, true);
          },
        ),
      ],
    );
  }
}
