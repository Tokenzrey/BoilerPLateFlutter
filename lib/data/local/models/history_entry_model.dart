import 'package:boilerplate/domain/entity/history/history.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'history_entry_model.freezed.dart';
part 'history_entry_model.g.dart';

@freezed
@HiveType(typeId: 4)
class HistoryModel with _$HistoryModel {
  const factory HistoryModel({
    @HiveField(0) required String userId,
    @HiveField(1) required String slug,
    @HiveField(2) required String hid,
    @HiveField(3) required String chap,
    @HiveField(4) required DateTime createdAt,
  }) = _HistoryModel;

  factory HistoryModel.fromJson(Map<String, dynamic> json) =>
      _$HistoryModelFromJson(json);
}

extension HistoryModelX on HistoryModel {
  HistoryEntity toEntity() => HistoryEntity(
        userId: userId,
        slug: slug,
        hid: hid,
        chap: chap,
        createdAt: createdAt,
      );

  static HistoryModel fromEntity(HistoryEntity entity) => HistoryModel(
        userId: entity.userId,
        slug: entity.slug,
        hid: entity.hid,
        chap: entity.chap,
        createdAt: entity.createdAt,
      );
}