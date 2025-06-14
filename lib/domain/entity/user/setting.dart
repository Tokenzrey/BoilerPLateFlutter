import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class SettingsEntity extends Equatable {
  final String id;
  final List<String> contentTypes;
  final String demographic;
  final List<String> matureContent;

  const SettingsEntity({
    required this.id,
    required this.contentTypes,
    required this.demographic,
    required this.matureContent,
  });

  factory SettingsEntity.create({
    List<String> contentTypes = const [],
    String demographic = 'male',
    List<String> matureContent = const [],
  }) {
    return SettingsEntity(
      id: const Uuid().v4(),
      contentTypes: contentTypes,
      demographic: demographic,
      matureContent: matureContent,
    );
  }

  SettingsEntity copyWith({
    String? id,
    List<String>? contentTypes,
    String? demographic,
    List<String>? matureContent,
  }) {
    return SettingsEntity(
      id: id ?? this.id,
      contentTypes: contentTypes ?? this.contentTypes,
      demographic: demographic ?? this.demographic,
      matureContent: matureContent ?? this.matureContent,
    );
  }

  @override
  List<Object?> get props => [id, contentTypes, demographic, matureContent];

  factory SettingsEntity.fromJson(Map<String, dynamic> json) {
    return SettingsEntity(
      id: json['id'] as String? ?? const Uuid().v4(),
      contentTypes: List<String>.from(json['contentTypes'] ?? []),
      demographic: json['demographic'] as String? ?? 'male',
      matureContent: List<String>.from(json['matureContent'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contentTypes': contentTypes,
      'demographic': demographic,
      'matureContent': matureContent,
    };
  }
}
