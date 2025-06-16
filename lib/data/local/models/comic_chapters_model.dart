import 'package:json_annotation/json_annotation.dart';

part 'comic_chapters_model.g.dart';

@JsonSerializable()
class ComicChaptersResponse {
  @JsonKey(name: 'chapters')
  final List<ChapterDetailModel>? chapters;

  @JsonKey(name: 'total')
  final int? total;

  @JsonKey(name: 'checkVol2Chap1')
  final bool? checkVol2Chap1;

  @JsonKey(name: 'limit')
  final int? limit;

  ComicChaptersResponse({
    this.chapters,
    this.total,
    this.checkVol2Chap1,
    this.limit,
  });

  factory ComicChaptersResponse.empty() => ComicChaptersResponse(
        chapters: [],
        total: 0,
        checkVol2Chap1: false,
        limit: 0,
      );

  factory ComicChaptersResponse.fromJson(Map<String, dynamic> json) =>
      _$ComicChaptersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ComicChaptersResponseToJson(this);
}

@JsonSerializable()
class ChapterDetailModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'chap')
  final String? chap;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'vol')
  final dynamic vol;

  @JsonKey(name: 'lang')
  final String? lang;

  @JsonKey(name: 'created_at')
  final String? createdAt;

  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  @JsonKey(name: 'up_count')
  final int? upCount;

  @JsonKey(name: 'down_count')
  final int? downCount;

  @JsonKey(name: 'is_the_last_chapter')
  final bool? isTheLastChapter;

  @JsonKey(name: 'publish_at')
  final String? publishAt;

  @JsonKey(name: 'group_name')
  final List<String>? groupName;

  @JsonKey(name: 'hid')
  final String? hid;

  @JsonKey(name: 'identities')
  final dynamic identities;

  @JsonKey(name: 'md_chapters_groups')
  final List<MdChaptersGroupModel>? mdChaptersGroups;

  ChapterDetailModel({
    this.id,
    this.chap,
    this.title,
    this.vol,
    this.lang,
    this.createdAt,
    this.updatedAt,
    this.upCount,
    this.downCount,
    this.isTheLastChapter,
    this.publishAt,
    this.groupName,
    this.hid,
    this.identities,
    this.mdChaptersGroups,
  });

  factory ChapterDetailModel.empty() => ChapterDetailModel(
        id: 0,
        chap: '',
        title: '',
        vol: null,
        lang: '',
        createdAt: '',
        updatedAt: '',
        upCount: 0,
        downCount: 0,
        isTheLastChapter: false,
        publishAt: '',
        groupName: [],
        hid: '',
        identities: null,
        mdChaptersGroups: [],
      );

  factory ChapterDetailModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterDetailModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterDetailModelToJson(this);
}

@JsonSerializable()
class MdChaptersGroupModel {
  @JsonKey(name: 'md_groups')
  final MdGroupsModel? mdGroups;

  MdChaptersGroupModel({
    this.mdGroups,
  });

  factory MdChaptersGroupModel.empty() => MdChaptersGroupModel(
        mdGroups: MdGroupsModel.empty(),
      );

  factory MdChaptersGroupModel.fromJson(Map<String, dynamic> json) =>
      _$MdChaptersGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$MdChaptersGroupModelToJson(this);
}

@JsonSerializable()
class MdGroupsModel {
  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'slug')
  final String? slug;

  MdGroupsModel({
    this.title,
    this.slug,
  });

  factory MdGroupsModel.empty() => MdGroupsModel(
        title: '',
        slug: '',
      );

  factory MdGroupsModel.fromJson(Map<String, dynamic> json) =>
      _$MdGroupsModelFromJson(json);

  Map<String, dynamic> toJson() => _$MdGroupsModelToJson(this);
}
