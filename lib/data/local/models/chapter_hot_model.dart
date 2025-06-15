import 'package:json_annotation/json_annotation.dart';

part 'chapter_hot_model.g.dart';

/// API response model for latest chapters data
@JsonSerializable()
class ChapterResponseModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'status')
  final String? status;

  @JsonKey(name: 'chap')
  final String? chap;

  @JsonKey(name: 'vol')
  final String? vol;

  @JsonKey(name: 'last_at')
  final String? lastAt;

  @JsonKey(name: 'hid')
  final String? hid;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'group_name', defaultValue: [])
  final List<String>? groupName;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'up_count')
  final int? upCount;

  @JsonKey(name: 'lang')
  final String? lang;

  @JsonKey(name: 'down_count')
  final int? downCount;

  @JsonKey(name: 'external_type')
  final String? externalType;

  @JsonKey(name: 'publish_at')
  final String? publishAt;

  @JsonKey(name: 'md_comics')
  final MdComicsModel? mdComics;

  @JsonKey(name: 'count')
  final int? count;

  ChapterResponseModel({
    this.id,
    this.status,
    this.chap,
    this.vol,
    this.lastAt,
    this.hid,
    this.createdAt,
    this.groupName,
    this.updatedAt,
    this.upCount,
    this.lang,
    this.downCount,
    this.externalType,
    this.publishAt,
    this.mdComics,
    this.count,
  });

  factory ChapterResponseModel.empty() => ChapterResponseModel(
        id: 0,
        status: '',
        chap: '',
        vol: '',
        lastAt: '',
        hid: '',
        createdAt: '',
        groupName: [],
        updatedAt: '',
        upCount: 0,
        lang: '',
        downCount: 0,
        externalType: '',
        publishAt: '',
        mdComics: MdComicsModel.empty(),
        count: 0,
      );

  factory ChapterResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final mdComicsJson =
          (json['md_comics'] as Map<String, dynamic>?) ?? <String, dynamic>{};

      return _$ChapterResponseModelFromJson({
        ...json,
        'md_comics': mdComicsJson,
      });
    } catch (e) {
      // Fallback in case of parsing errors
      return ChapterResponseModel.empty();
    }
  }

  Map<String, dynamic> toJson() => _$ChapterResponseModelToJson(this);
}

@JsonSerializable()
class MdComicsModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'hid')
  final String? hid;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'content_rating')
  final String? contentRating;

  @JsonKey(name: 'country')
  final String? country;

  @JsonKey(name: 'status')
  final int? status;

  @JsonKey(name: 'translation_completed')
  final bool? translationCompleted;

  @JsonKey(name: 'last_chapter')
  final int? lastChapter;

  @JsonKey(name: 'final_chapter')
  final String? finalChapter;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int>? genres;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel>? mdTitles;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel>? mdCovers;

  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  MdComicsModel({
    this.id,
    this.hid,
    this.title,
    this.slug,
    this.contentRating,
    this.country,
    this.status,
    this.translationCompleted,
    this.lastChapter,
    this.finalChapter,
    this.createdAt,
    this.genres,
    this.demographic,
    this.isEnglishTitle,
    this.mdTitles,
    this.mdCovers,
    this.coverUrl,
  });

  factory MdComicsModel.empty() => MdComicsModel(
        id: 0,
        hid: '',
        title: '',
        slug: '',
        contentRating: 'safe',
        country: '',
        status: 0,
        translationCompleted: false,
        lastChapter: 0,
        finalChapter: '',
        createdAt: '',
        genres: [],
        demographic: null,
        isEnglishTitle: false,
        mdTitles: [],
        mdCovers: [],
        coverUrl: '',
      );

  factory MdComicsModel.fromJson(Map<String, dynamic> json) =>
      _$MdComicsModelFromJson(json);
  Map<String, dynamic> toJson() => _$MdComicsModelToJson(this);
}

@JsonSerializable()
class MdTitleModel {
  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'lang')
  final String? lang;

  MdTitleModel({
    this.title,
    this.lang,
  });

  factory MdTitleModel.fromJson(Map<String, dynamic> json) =>
      _$MdTitleModelFromJson(json);
  Map<String, dynamic> toJson() => _$MdTitleModelToJson(this);
}

@JsonSerializable()
class MdCoverModel {
  @JsonKey(name: 'w')
  final int? w;

  @JsonKey(name: 'h')
  final int? h;

  @JsonKey(name: 'b2key')
  final String? b2key;

  MdCoverModel({
    this.w,
    this.h,
    this.b2key,
  });

  factory MdCoverModel.fromJson(Map<String, dynamic> json) =>
      _$MdCoverModelFromJson(json);
  Map<String, dynamic> toJson() => _$MdCoverModelToJson(this);
}
