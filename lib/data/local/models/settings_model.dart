import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';

part 'settings_model.freezed.dart';
part 'settings_model.g.dart';

@freezed
@HiveType(typeId: 2)
class SettingsModel with _$SettingsModel {
  const factory SettingsModel({
    @HiveField(0) required String id,
    @HiveField(1) @Default([]) List<String> contentTypes,
    @HiveField(2) @Default('male') String demographic,
    @HiveField(3) @Default([]) List<String> matureContent,
  }) = _SettingsModel;

  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);
}

extension SettingsModelX on SettingsModel {
  SettingsEntity toEntity() => SettingsEntity(
        id: id,
        contentTypes: List<String>.from(contentTypes),
        demographic: demographic,
        matureContent: List<String>.from(matureContent),
      );

  static SettingsModel fromEntity(SettingsEntity entity) => SettingsModel(
        id: entity.id,
        contentTypes: List<String>.from(entity.contentTypes),
        demographic: entity.demographic,
        matureContent: List<String>.from(entity.matureContent),
      );
}
