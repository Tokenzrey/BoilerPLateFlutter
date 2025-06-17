import 'package:json_annotation/json_annotation.dart';

part 'comic_details_model.g.dart';

@JsonSerializable()
class ComicDetailResponse {
  @JsonKey(name: 'firstChap')
  final FirstChapModel? firstChap;

  @JsonKey(name: 'comic')
  final ComicModel? comic;

  @JsonKey(name: 'artists')
  final List<ArtistModel>? artists;

  @JsonKey(name: 'authors')
  final List<AuthorModel>? authors;

  @JsonKey(name: 'langList')
  final List<String>? langList;

  @JsonKey(name: 'recommendable')
  final bool? recommendable;

  @JsonKey(name: 'demographic')
  final String? demographic;

  @JsonKey(name: 'englishLink')
  final dynamic englishLink; // Changed back to dynamic as per API def

  @JsonKey(name: 'matureContent')
  final bool? matureContent;

  @JsonKey(name: 'checkVol2Chap1')
  final bool? checkVol2Chap1;

  ComicDetailResponse({
    this.firstChap,
    this.comic,
    this.artists,
    this.authors,
    this.langList,
    this.demographic,
    this.englishLink,
    this.matureContent,
    this.recommendable,
    this.checkVol2Chap1,
  });

  factory ComicDetailResponse.empty() => ComicDetailResponse(
        firstChap: FirstChapModel.empty(),
        comic: ComicModel.empty(),
        artists: [],
        authors: [],
        langList: [],
        recommendable: false,
        matureContent: false,
        checkVol2Chap1: false,
      );

  factory ComicDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$ComicDetailResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ComicDetailResponseToJson(this);
}

@JsonSerializable()
class FirstChapModel {
  @JsonKey(name: 'chap')
  final String? chap;

  @JsonKey(name: 'hid')
  final String? hid;

  @JsonKey(name: 'lang')
  final String? lang;

  @JsonKey(name: 'group_name')
  final List<String>? groupName;

  @JsonKey(name: 'vol')
  final dynamic vol; // Changed back to dynamic as per API definition

  FirstChapModel({
    this.chap,
    this.hid,
    this.lang,
    this.groupName,
    this.vol,
  });

  factory FirstChapModel.empty() => FirstChapModel(
        chap: '',
        hid: '',
        lang: '',
        groupName: [],
      );

  factory FirstChapModel.fromJson(Map<String, dynamic> json) =>
      _$FirstChapModelFromJson(json);

  Map<String, dynamic> toJson() => _$FirstChapModelToJson(this);
}

@JsonSerializable()
class ComicModel {
  @JsonKey(name: 'id')
  final int? id;

  @JsonKey(name: 'hid')
  final String? hid;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'country')
  final String? country;

  @JsonKey(name: 'status')
  final int? status;

  @JsonKey(name: 'links')
  final LinksModel? links;

  @JsonKey(name: 'last_chapter')
  final int? lastChapter;

  @JsonKey(name: 'chapter_count')
  final int? chapterCount;

  @JsonKey(name: 'demographic')
  final int? demographic; // Changed to int to match API definition

  @JsonKey(name: 'user_follow_count')
  final int? userFollowCount;

  @JsonKey(name: 'follow_rank')
  final int? followRank;

  @JsonKey(name: 'follow_count')
  final int? followCount;

  @JsonKey(name: 'desc')
  final String? desc;

  @JsonKey(name: 'parsed')
  final String? parsed;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'mismatch')
  final dynamic mismatch; // Added to match API definition

  @JsonKey(name: 'year')
  final int? year;

  @JsonKey(name: 'bayesian_rating')
  final dynamic bayesianRating; // Changed to dynamic to match API definition

  @JsonKey(name: 'rating_count')
  final int? ratingCount;

  @JsonKey(name: 'content_rating')
  final String? contentRating;

  @JsonKey(name: 'translation_completed')
  final dynamic translationCompleted; // Changed to dynamic to match API

  @JsonKey(name: 'chapter_numbers_reset_on_new_volume_manual')
  final bool? chapterNumbersResetOnNewVolumeManual;

  @JsonKey(name: 'final_chapter')
  final dynamic finalChapter;

  @JsonKey(name: 'final_volume')
  final dynamic finalVolume;

  @JsonKey(name: 'noindex')
  final bool? noindex;

  @JsonKey(name: 'adsense')
  final bool? adsense;

  @JsonKey(name: 'login_required')
  final bool? loginRequired;

  @JsonKey(name: 'recommendations')
  final List<dynamic>? recommendations; // Changed to match API definition

  @JsonKey(name: 'relate_from')
  final List<dynamic>? relateFrom; // Changed to match API definition

  @JsonKey(name: 'md_titles')
  final List<MdTitleModel>? mdTitles;

  @JsonKey(name: 'is_english_title')
  final dynamic isEnglishTitle;

  @JsonKey(name: 'md_comic_md_genres')
  final List<MdComicGenreModel>? mdComicMdGenres;

  @JsonKey(name: 'md_covers')
  final List<MdCoverModel>? mdCovers;

  @JsonKey(name: 'mu_comics')
  final dynamic muComics; // Changed to dynamic to match API definition

  @JsonKey(name: 'iso639_1')
  final String? iso639_1;

  @JsonKey(name: 'lang_name')
  final String? langName;

  @JsonKey(name: 'lang_native')
  final String? langNative;

  @JsonKey(name: 'cover_url')
  final String? coverUrl;

  ComicModel({
    this.id,
    this.hid,
    this.title,
    this.country,
    this.status,
    this.links,
    this.lastChapter,
    this.chapterCount,
    this.demographic,
    this.userFollowCount,
    this.followRank,
    this.followCount,
    this.desc,
    this.parsed,
    this.slug,
    this.mismatch,
    this.year,
    this.bayesianRating,
    this.ratingCount,
    this.contentRating,
    this.translationCompleted,
    this.chapterNumbersResetOnNewVolumeManual,
    this.finalChapter,
    this.finalVolume,
    this.noindex,
    this.adsense,
    this.loginRequired,
    this.recommendations,
    this.relateFrom,
    this.mdTitles,
    this.isEnglishTitle,
    this.mdComicMdGenres,
    this.mdCovers,
    this.muComics,
    this.iso639_1,
    this.langName,
    this.langNative,
    this.coverUrl,
  });

  factory ComicModel.empty() => ComicModel(
        id: 0,
        hid: '',
        title: '',
        country: '',
        status: 0,
        links: LinksModel.empty(),
        lastChapter: 0,
        chapterCount: 0,
        demographic: 0,
        userFollowCount: 0,
        followRank: 0,
        followCount: 0,
        desc: '',
        parsed: '',
        slug: '',
        mismatch: null,
        year: 0,
        bayesianRating: null,
        ratingCount: 0,
        contentRating: 'safe',
        translationCompleted: null,
        chapterNumbersResetOnNewVolumeManual: false,
        finalChapter: null,
        finalVolume: null,
        noindex: false,
        adsense: false,
        loginRequired: false,
        recommendations: [],
        relateFrom: [],
        mdTitles: [],
        mdComicMdGenres: [],
        mdCovers: [],
        muComics: null,
        iso639_1: '',
        langName: '',
        langNative: '',
        coverUrl: '',
      );

  factory ComicModel.fromJson(Map<String, dynamic> json) =>
      _$ComicModelFromJson(json);

  Map<String, dynamic> toJson() => _$ComicModelToJson(this);
}

@JsonSerializable()
class LinksModel {
  @JsonKey(name: 'mu')
  final String? mu; // Simplified to match API definition

  LinksModel({
    this.mu,
  });

  factory LinksModel.empty() => LinksModel(
        mu: '',
      );

  factory LinksModel.fromJson(Map<String, dynamic> json) =>
      _$LinksModelFromJson(json);

  Map<String, dynamic> toJson() => _$LinksModelToJson(this);
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

  factory MdTitleModel.empty() => MdTitleModel(
        title: '',
        lang: '',
      );

  factory MdTitleModel.fromJson(Map<String, dynamic> json) =>
      _$MdTitleModelFromJson(json);

  Map<String, dynamic> toJson() => _$MdTitleModelToJson(this);
}

@JsonSerializable()
class MdComicGenreModel {
  @JsonKey(name: 'md_genres')
  final MdGenresModel? mdGenres;

  MdComicGenreModel({
    this.mdGenres,
  });

  factory MdComicGenreModel.empty() => MdComicGenreModel(
        mdGenres: MdGenresModel.empty(),
      );

  factory MdComicGenreModel.fromJson(Map<String, dynamic> json) =>
      _$MdComicGenreModelFromJson(json);

  Map<String, dynamic> toJson() => _$MdComicGenreModelToJson(this);
}

@JsonSerializable()
class MdGenresModel {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'type')
  final String? type;

  @JsonKey(name: 'slug')
  final String? slug;

  @JsonKey(name: 'group')
  final String? group;

  MdGenresModel({
    this.name,
    this.type,
    this.slug,
    this.group,
  });

  factory MdGenresModel.empty() => MdGenresModel(
        name: '',
        type: '',
        slug: '',
        group: '',
      );

  factory MdGenresModel.fromJson(Map<String, dynamic> json) =>
      _$MdGenresModelFromJson(json);

  Map<String, dynamic> toJson() => _$MdGenresModelToJson(this);
}

@JsonSerializable()
class MdCoverModel {
  @JsonKey(name: 'vol')
  final String? vol; // Added to match API definition

  @JsonKey(name: 'w')
  final int? w;

  @JsonKey(name: 'h')
  final int? h;

  @JsonKey(name: 'b2key')
  final String? b2key;

  MdCoverModel({
    this.vol,
    this.w,
    this.h,
    this.b2key,
  });

  factory MdCoverModel.empty() => MdCoverModel(
        vol: '',
        w: 0,
        h: 0,
        b2key: '',
      );

  factory MdCoverModel.fromJson(Map<String, dynamic> json) =>
      _$MdCoverModelFromJson(json);

  Map<String, dynamic> toJson() => _$MdCoverModelToJson(this);
}

@JsonSerializable()
class ArtistModel {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'slug')
  final String? slug;

  ArtistModel({
    this.name,
    this.slug,
  });

  factory ArtistModel.empty() => ArtistModel(
        name: '',
        slug: '',
      );

  factory ArtistModel.fromJson(Map<String, dynamic> json) =>
      _$ArtistModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArtistModelToJson(this);
}

@JsonSerializable()
class AuthorModel {
  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'slug')
  final String? slug;

  AuthorModel({
    this.name,
    this.slug,
  });

  factory AuthorModel.empty() => AuthorModel(
        name: '',
        slug: '',
      );

  factory AuthorModel.fromJson(Map<String, dynamic> json) =>
      _$AuthorModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorModelToJson(this);
}
