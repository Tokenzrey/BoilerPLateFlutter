import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/forms/app_form.dart';
import 'package:boilerplate/core/widgets/components/forms/checkbox_widget.dart';
import 'package:boilerplate/core/widgets/components/forms/radio_button.dart';
import 'package:boilerplate/core/widgets/components/layout/collapsible.dart';
import 'package:boilerplate/presentation/store/settings/settings_store.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:boilerplate/di/service_locator.dart';

class SettingsData {
  List<String> contentTypes;
  String demographic;
  List<String> matureContent;

  SettingsData({
    required this.contentTypes,
    required this.demographic,
    required this.matureContent,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      contentTypes: List<String>.from(json['contentTypes'] ?? []),
      demographic: json['demographic'] as String? ?? 'male',
      matureContent: List<String>.from(json['matureContent'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'contentTypes': contentTypes,
      'demographic': demographic,
      'matureContent': matureContent,
    };
  }

  SettingsEntity toEntity() => SettingsEntity(
        id: '',
        contentTypes: contentTypes,
        demographic: demographic,
        matureContent: matureContent,
      );

  static SettingsData fromEntity(SettingsEntity e) => SettingsData(
        contentTypes: e.contentTypes,
        demographic: e.demographic,
        matureContent: e.matureContent,
      );
}

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late final SettingsStore _settingsStore;
  late FormController<SettingsData> _formController;

  final CollapsibleController _contentTypeController =
      CollapsibleController(initialExpanded: true);
  final CollapsibleController _demographicController =
      CollapsibleController(initialExpanded: true);
  final CollapsibleController _matureContentController =
      CollapsibleController(initialExpanded: true);

  final contentTypeOptions = [
    CheckboxOption<String>(
      value: 'manga',
      label: 'Manga',
    ),
    CheckboxOption<String>(
      value: 'manhwa',
      label: 'Manhwa',
    ),
    CheckboxOption<String>(
      value: 'manhua',
      label: 'Manhua',
    ),
  ];

  final demographicOptions = [
    RadioOption<String>(
      value: 'male',
      label: 'Male (Shounen + Seinen)',
      tooltip: 'Content targeting male audiences',
      icon: Icons.man,
    ),
    RadioOption<String>(
      value: 'female',
      label: 'Female (Shoujo + Josei)',
      tooltip: 'Content targeting female audiences',
      icon: Icons.woman,
    ),
    RadioOption<String>(
      value: 'none',
      label: 'None (Not Set)',
      tooltip: 'Content without specified demographic',
      icon: Icons.person,
    ),
  ];

  final matureContentOptions = [
    CheckboxOption<String>(
      value: 'mature',
      label: 'Mature Content',
      description: 'Shows content with mature themes',
    ),
    CheckboxOption<String>(
      value: 'horror_gore',
      label: 'Frequent Horror & Gore',
      description: 'Shows content with horror and gore elements',
    ),
    CheckboxOption<String>(
      value: 'adult',
      label: 'Adult Only Content',
      description: 'Shows explicit/adult content (18+)',
    ),
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _settingsStore = getIt<SettingsStore>();
    _initFormFromSettings();
  }

  Future<void> _initFormFromSettings() async {
    await _settingsStore.getSettings();
    final entity = _settingsStore.settings;
    final defaultData = entity != null
        ? SettingsData.fromEntity(entity)
        : SettingsData(
            contentTypes: ['manga', 'manhwa', 'manhua'],
            demographic: 'male',
            matureContent: ['mature', 'horror_gore', 'adult'],
          );
    _formController = FormController<SettingsData>(
      defaultValues: defaultData,
      fromJson: SettingsData.fromJson,
      toJson: (data) => data.toJson(),
      mode: ValidationMode.onBlur,
    );
    _formController.watchAll().listen((map) {
      final data = SettingsData.fromJson(map);
      _onFormChanged(data);
    });
    if (mounted) setState(() {});
  }

  Future<void> _onFormChanged(SettingsData data) async {
    setState(() => _isSaving = true);
    await _settingsStore.saveOrUpdateSettings(data.toEntity());
    setState(() => _isSaving = false);
  }

  @override
  void dispose() {
    _formController.dispose();
    _contentTypeController.dispose();
    _demographicController.dispose();
    _matureContentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FormScope<SettingsData>(
      controller: _formController,
      child: AbsorbPointer(
        absorbing: _isSaving,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          children: [
            _buildSettingsSummary(),
            const SizedBox(height: 24),
            _buildContentTypeSection(),
            const SizedBox(height: 16),
            _buildDemographicSection(),
            const SizedBox(height: 16),
            _buildMatureContentSection(),
            const SizedBox(height: 24),
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        "Saving preferences...",
                        variant: TextVariant.bodySmall,
                        color: AppColors.primary,
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

  Widget _buildSettingsSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const AppText(
                'Content Preferences',
                variant: TextVariant.titleMedium,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const AppText(
            'Customize your reading experience by selecting your preferences below. Changes are saved automatically.',
            variant: TextVariant.bodySmall,
            color: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeSection() {
    return _buildCollapsibleSection(
      controller: _contentTypeController,
      title: 'Manga/Manhwa/Manhua',
      icon: Icons.book,
      description: 'Select the content types you want to see',
      content: FormCheckboxField<String>(
        formController: _formController,
        name: 'contentTypes',
        options: contentTypeOptions,
        showBorder: false,
        enabled: !_isSaving,
        style: _getCheckboxStyle(),
        spacing: 12,
        verticalSpacing: 8,
        layout: CheckboxLayout.vertical,
      ),
    );
  }

  Widget _buildDemographicSection() {
    return _buildCollapsibleSection(
      controller: _demographicController,
      title: 'Demographic',
      icon: Icons.people,
      description: 'Choose your preferred demographic content',
      content: ValueListenableBuilder<FieldState>(
        valueListenable:
            _formController.register<String>('demographic').stateNotifier,
        builder: (context, fieldState, child) {
          final selectedValue = fieldState.value as String? ?? 'male';

          return Column(
            children: demographicOptions.map((option) {
              return _buildCustomRadioOption(
                option: option,
                isSelected: selectedValue == option.value,
                enabled: !_isSaving,
                onChanged: (_) {
                  if (!_isSaving) {
                    _formController.setValue('demographic', option.value);
                  }
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildMatureContentSection() {
    return _buildCollapsibleSection(
      controller: _matureContentController,
      title: 'Mature Content',
      icon: Icons.warning_amber,
      description: 'Select mature content filter settings',
      content: FormCheckboxField<String>(
        formController: _formController,
        name: 'matureContent',
        options: matureContentOptions,
        showBorder: false,
        enabled: !_isSaving,
        style: _getCheckboxStyle(),
        spacing: 12,
        verticalSpacing: 8,
        layout: CheckboxLayout.vertical,
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required CollapsibleController controller,
    required String title,
    required IconData icon,
    required String description,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardForeground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.neutral.shade800),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: AppCollapsible(
        controller: controller,
        children: [
          AppCollapsibleTrigger(
            padding: const EdgeInsets.only(right: 16),
            iconBuilder: (context, isExpanded) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          title,
                          variant: TextVariant.titleMedium,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 4),
                        AppText(
                          description,
                          variant: TextVariant.bodySmall,
                          color: AppColors.neutral.shade400,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          AppCollapsibleContent(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: content,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomRadioOption({
    required RadioOption<String> option,
    required bool isSelected,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      onTap: enabled ? () => onChanged(true) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.cardForeground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.neutral.shade800,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.neutral.shade600,
                  width: 2,
                ),
              ),
              child: Center(
                child: isSelected
                    ? Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            if (option.icon != null) ...[
              Icon(
                option.icon,
                color:
                    isSelected ? AppColors.primary : AppColors.neutral.shade400,
                size: 20,
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    option.label,
                    variant: TextVariant.bodyMedium,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected
                        ? AppColors.highlightForeground
                        : AppColors.subtleBackground,
                  ),
                  if (option.tooltip != null) ...[
                    const SizedBox(height: 4),
                    AppText(
                      option.tooltip!,
                      variant: TextVariant.bodySmall,
                      color: AppColors.neutral.shade400,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  CheckboxStyle _getCheckboxStyle() {
    return CheckboxStyle(
      backgroundColor: AppColors.cardForeground,
      selectedBackgroundColor: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      borderColor: AppColors.neutral.shade800,
      padding: const EdgeInsets.all(16),
      activeColor: AppColors.primary,
      labelStyle: const TextStyle(
        fontWeight: FontWeight.w500,
      ),
      descriptionStyle: TextStyle(
        color: AppColors.neutral.shade400,
        fontSize: 12,
      ),
    );
  }
}
