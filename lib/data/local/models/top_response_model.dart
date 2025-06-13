import 'package:json_annotation/json_annotation.dart';

part 'top_response_model.g.dart';

/// API response model for top comics data
@JsonSerializable()
class TopResponseModel {
  @JsonKey(name: 'rank', defaultValue: [])
  final List<RankModel> rank;

  @JsonKey(name: 'recentRank', defaultValue: [])
  final List<RecentRankModel> recentRank;

  @JsonKey(name: 'trending')
  final TrendingModel trending;

  @JsonKey(name: 'follows', defaultValue: [])
  final List<FollowModel> follows;

  @JsonKey(name: 'news', defaultValue: [])
  final List<NewsModel> news;

  @JsonKey(name: 'extendedNews', defaultValue: [])
  final List<ExtendedNewModel> extendedNews;

  @JsonKey(name: 'completions', defaultValue: [])
  final List<CompletionModel> completions;

  @JsonKey(name: 'topFollowNewComics')
  final TopFollowNewComicsModel topFollowNewComics;

  @JsonKey(name: 'topFollowComics')
  final TopFollowComicsModel topFollowComics;

  @JsonKey(name: 'comicsByCurrentSeason')
  final ComicsByCurrentSeasonModel comicsByCurrentSeason;

  TopResponseModel({
    required this.rank,
    required this.recentRank,
    required this.trending,
    required this.follows,
    required this.news,
    required this.extendedNews,
    required this.completions,
    required this.topFollowNewComics,
    required this.topFollowComics,
    required this.comicsByCurrentSeason,
  });

  factory TopResponseModel.empty() => TopResponseModel(
        rank: [],
        recentRank: [],
        trending: TrendingModel(seven: [], thirty: [], ninety: []),
        follows: [],
        news: [],
        extendedNews: [],
        completions: [],
        topFollowNewComics:
            TopFollowNewComicsModel(seven: [], thirty: [], ninety: []),
        topFollowComics:
            TopFollowComicsModel(seven: [], thirty: [], ninety: []),
        comicsByCurrentSeason:
            ComicsByCurrentSeasonModel(year: '', season: '', data: []),
      );

  factory TopResponseModel.fromJson(Map<String, dynamic> json) {
    // Safely extract nested objects with fallbacks to empty maps
    final trendingJson =
        (json['trending'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final topFollowNewComicsJson =
        (json['topFollowNewComics'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
    final topFollowComicsJson =
        (json['topFollowComics'] as Map<String, dynamic>?) ??
            <String, dynamic>{};
    final comicsByCurrentSeasonJson =
        (json['comicsByCurrentSeason'] as Map<String, dynamic>?) ??
            <String, dynamic>{};

    return _$TopResponseModelFromJson({
      ...json,
      'trending': trendingJson,
      'topFollowNewComics': topFollowNewComicsJson,
      'topFollowComics': topFollowComicsJson,
      'comicsByCurrentSeason': comicsByCurrentSeasonJson,
    });
  }

  Map<String, dynamic> toJson() => _$TopResponseModelToJson(this);
}

@JsonSerializable()
class RankModel {
  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel> mdTitles;

  @JsonKey(name: 'last_chapter')
  final int? lastChapter;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  RankModel({
    required this.slug,
    required this.title,
    this.demographic,
    required this.contentRating,
    required this.genres,
    this.isEnglishTitle,
    required this.mdTitles,
    this.lastChapter = 0,
    required this.mdCovers,
  });

  factory RankModel.fromJson(Map<String, dynamic> json) =>
      _$RankModelFromJson(json);
  Map<String, dynamic> toJson() => _$RankModelToJson(this);
}

@JsonSerializable()
class MdTitleModel {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'lang')
  final String lang;

  MdTitleModel({
    required this.title,
    required this.lang,
  });

  factory MdTitleModel.fromJson(Map<String, dynamic> json) =>
      _$MdTitleModelFromJson(json);
  Map<String, dynamic> toJson() => _$MdTitleModelToJson(this);
}

@JsonSerializable()
class MdCoverModel {
  @JsonKey(name: 'w')
  final int w;

  @JsonKey(name: 'h')
  final int h;

  @JsonKey(name: 'b2key')
  final String b2key;

  MdCoverModel({
    required this.w,
    required this.h,
    required this.b2key,
  });

  factory MdCoverModel.fromJson(Map<String, dynamic> json) =>
      _$MdCoverModelFromJson(json);
  Map<String, dynamic> toJson() => _$MdCoverModelToJson(this);
}

@JsonSerializable()
class RecentRankModel {
  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel> mdTitles;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  RecentRankModel({
    required this.slug,
    required this.title,
    this.demographic,
    required this.contentRating,
    required this.genres,
    this.isEnglishTitle,
    required this.mdTitles,
    required this.mdCovers,
  });

  factory RecentRankModel.fromJson(Map<String, dynamic> json) =>
      _$RecentRankModelFromJson(json);
  Map<String, dynamic> toJson() => _$RecentRankModelToJson(this);
}

@JsonSerializable()
class TrendingModel {
  @JsonKey(name: '7', defaultValue: [])
  final List<TrendingItemModel> seven;

  @JsonKey(name: '30', defaultValue: [])
  final List<TrendingItemModel> thirty;

  @JsonKey(name: '90', defaultValue: [])
  final List<TrendingItemModel> ninety;

  TrendingModel({
    required this.seven,
    required this.thirty,
    required this.ninety,
  });

  factory TrendingModel.fromJson(Map<String, dynamic> json) =>
      _$TrendingModelFromJson(json);
  Map<String, dynamic> toJson() => _$TrendingModelToJson(this);
}

@JsonSerializable()
class TrendingItemModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  TrendingItemModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.contentRating,
    required this.genres,
    this.demographic,
    required this.mdCovers,
  });

  factory TrendingItemModel.empty() => TrendingItemModel(
        id: 0,
        title: '',
        slug: '',
        contentRating: 'safe',
        genres: [],
        demographic: null,
        mdCovers: [],
      );

  factory TrendingItemModel.fromJson(Map<String, dynamic> json) =>
      _$TrendingItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$TrendingItemModelToJson(this);
}

@JsonSerializable()
class FollowModel {
  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'identities')
  final IdentitiesModel identities;

  @JsonKey(name: 'md_comics')
  final MdComicsModel mdComics;

  FollowModel({
    required this.createdAt,
    required this.identities,
    required this.mdComics,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    final identitiesJson =
        (json['identities'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final mdComicsJson =
        (json['md_comics'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return _$FollowModelFromJson({
      ...json,
      'identities': identitiesJson,
      'md_comics': mdComicsJson,
    });
  }

  Map<String, dynamic> toJson() => _$FollowModelToJson(this);
}

@JsonSerializable()
class IdentitiesModel {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'traits')
  final TraitsModel traits;

  IdentitiesModel({
    required this.id,
    required this.traits,
  });

  factory IdentitiesModel.fromJson(Map<String, dynamic> json) {
    final traitsJson =
        (json['traits'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return _$IdentitiesModelFromJson({
      ...json,
      'traits': traitsJson,
    });
  }

  Map<String, dynamic> toJson() => _$IdentitiesModelToJson(this);
}

@JsonSerializable()
class TraitsModel {
  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'gravatar')
  final String gravatar;

  TraitsModel({
    required this.username,
    required this.id,
    required this.gravatar,
  });

  factory TraitsModel.fromJson(Map<String, dynamic> json) =>
      _$TraitsModelFromJson(json);
  Map<String, dynamic> toJson() => _$TraitsModelToJson(this);
}

@JsonSerializable()
class MdComicsModel {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel> mdTitles;

  @JsonKey(name: 'follow_count')
  final int followCount;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  MdComicsModel({
    required this.id,
    required this.title,
    required this.contentRating,
    required this.slug,
    this.isEnglishTitle,
    required this.mdTitles,
    required this.followCount,
    this.demographic,
    required this.genres,
    required this.mdCovers,
  });

  factory MdComicsModel.fromJson(Map<String, dynamic> json) =>
      _$MdComicsModelFromJson(json);
  Map<String, dynamic> toJson() => _$MdComicsModelToJson(this);
}

@JsonSerializable()
class NewsModel {
  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'last_chapter')
  final int? lastChapter;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel> mdTitles;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  NewsModel({
    required this.slug,
    required this.title,
    this.demographic,
    required this.genres,
    required this.contentRating,
    required this.createdAt,
    this.lastChapter = 0,
    this.isEnglishTitle,
    required this.mdTitles,
    required this.mdCovers,
  });

  factory NewsModel.empty() => NewsModel(
        slug: '',
        title: '',
        demographic: null,
        genres: [],
        contentRating: 'safe',
        createdAt: '',
        lastChapter: 0,
        isEnglishTitle: null,
        mdTitles: [],
        mdCovers: [],
      );

  factory NewsModel.fromJson(Map<String, dynamic> json) =>
      _$NewsModelFromJson(json);
  Map<String, dynamic> toJson() => _$NewsModelToJson(this);
}

@JsonSerializable()
class ExtendedNewModel {
  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel> mdTitles;

  @JsonKey(name: 'last_chapter')
  final int? lastChapter;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  ExtendedNewModel({
    required this.slug,
    required this.title,
    this.demographic,
    required this.genres,
    required this.contentRating,
    required this.createdAt,
    this.isEnglishTitle,
    required this.mdTitles,
    this.lastChapter,
    required this.mdCovers,
  });

  factory ExtendedNewModel.fromJson(Map<String, dynamic> json) =>
      _$ExtendedNewModelFromJson(json);
  Map<String, dynamic> toJson() => _$ExtendedNewModelToJson(this);
}

@JsonSerializable()
class CompletionModel {
  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'uploaded_at')
  final String uploadedAt;

  @JsonKey(name: 'last_chapter')
  final int? lastChapter;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel> mdTitles;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  CompletionModel({
    required this.slug,
    required this.title,
    this.demographic,
    required this.genres,
    required this.createdAt,
    required this.uploadedAt,
    this.lastChapter = 0,
    this.isEnglishTitle,
    required this.mdTitles,
    required this.contentRating,
    required this.mdCovers,
  });

  factory CompletionModel.fromJson(Map<String, dynamic> json) =>
      _$CompletionModelFromJson(json);
  Map<String, dynamic> toJson() => _$CompletionModelToJson(this);
}

@JsonSerializable()
class TopFollowNewComicsModel {
  @JsonKey(name: '7', defaultValue: [])
  final List<TopFollowNewComicItemModel> seven;

  @JsonKey(name: '30', defaultValue: [])
  final List<TopFollowNewComicItemModel> thirty;

  @JsonKey(name: '90', defaultValue: [])
  final List<TopFollowNewComicItemModel> ninety;

  TopFollowNewComicsModel({
    required this.seven,
    required this.thirty,
    required this.ninety,
  });

  factory TopFollowNewComicsModel.fromJson(Map<String, dynamic> json) {
    final sevenJson = (json['7'] as List<dynamic>?) ?? [];
    final thirtyJson = (json['30'] as List<dynamic>?) ?? [];
    final ninetyJson = (json['90'] as List<dynamic>?) ?? [];

    return _$TopFollowNewComicsModelFromJson({
      ...json,
      '7': sevenJson,
      '30': thirtyJson,
      '90': ninetyJson,
    });
  }

  Map<String, dynamic> toJson() => _$TopFollowNewComicsModelToJson(this);
}

@JsonSerializable()
class TopFollowNewComicItemModel {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel> mdTitles;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  TopFollowNewComicItemModel({
    required this.title,
    required this.slug,
    required this.contentRating,
    required this.genres,
    this.demographic,
    this.isEnglishTitle,
    required this.mdTitles,
    required this.mdCovers,
  });

  factory TopFollowNewComicItemModel.fromJson(Map<String, dynamic> json) =>
      _$TopFollowNewComicItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$TopFollowNewComicItemModelToJson(this);
}

@JsonSerializable()
class TopFollowComicsModel {
  @JsonKey(name: '7', defaultValue: [])
  final List<TopFollowComicItemModel> seven;

  @JsonKey(name: '30', defaultValue: [])
  final List<TopFollowComicItemModel> thirty;

  @JsonKey(name: '90', defaultValue: [])
  final List<TopFollowComicItemModel> ninety;

  TopFollowComicsModel({
    required this.seven,
    required this.thirty,
    required this.ninety,
  });

  factory TopFollowComicsModel.fromJson(Map<String, dynamic> json) {
    final sevenJson = (json['7'] as List<dynamic>?) ?? [];
    final thirtyJson = (json['30'] as List<dynamic>?) ?? [];
    final ninetyJson = (json['90'] as List<dynamic>?) ?? [];

    return _$TopFollowComicsModelFromJson({
      ...json,
      '7': sevenJson,
      '30': thirtyJson,
      '90': ninetyJson,
    });
  }

  Map<String, dynamic> toJson() => _$TopFollowComicsModelToJson(this);
}

@JsonSerializable()
class TopFollowComicItemModel {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'is_english_title')
  final bool? isEnglishTitle;

  @JsonKey(name: 'md_titles', defaultValue: [])
  final List<MdTitleModel> mdTitles;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  @JsonKey(name: 'count')
  final int count;

  TopFollowComicItemModel({
    required this.title,
    required this.slug,
    required this.contentRating,
    required this.id,
    required this.genres,
    this.isEnglishTitle,
    required this.mdTitles,
    this.demographic,
    required this.mdCovers,
    required this.count,
  });

  factory TopFollowComicItemModel.fromJson(Map<String, dynamic> json) =>
      _$TopFollowComicItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$TopFollowComicItemModelToJson(this);
}

@JsonSerializable()
class ComicsByCurrentSeasonModel {
  @JsonKey(name: 'year')
  final String year;

  @JsonKey(name: 'season')
  final String season;

  @JsonKey(name: 'data', defaultValue: [])
  final List<ComicBySeasonModel> data;

  ComicsByCurrentSeasonModel({
    required this.year,
    required this.season,
    required this.data,
  });

  factory ComicsByCurrentSeasonModel.fromJson(Map<String, dynamic> json) {
    final dataJson = (json['data'] as List<dynamic>?) ?? [];

    return _$ComicsByCurrentSeasonModelFromJson({
      ...json,
      'data': dataJson,
    });
  }

  Map<String, dynamic> toJson() => _$ComicsByCurrentSeasonModelToJson(this);
}

@JsonSerializable()
class ComicBySeasonModel {
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'slug')
  final String slug;

  @JsonKey(name: 'content_rating')
  final String contentRating;

  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'genres', defaultValue: [])
  final List<int> genres;

  @JsonKey(name: 'user_follow_count')
  final int userFollowCount;

  @JsonKey(name: 'follow_rank')
  final int followRank;

  @JsonKey(name: 'demographic')
  final int? demographic;

  @JsonKey(name: 'last_chapter')
  final int? lastChapter;

  @JsonKey(name: 'desc')
  final String desc;

  @JsonKey(name: 'mies')
  final MiesModel mies;

  @JsonKey(name: 'status')
  final int status;

  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(name: 'hid')
  final String hid;

  @JsonKey(name: 'md_covers', defaultValue: [])
  final List<MdCoverModel> mdCovers;

  ComicBySeasonModel({
    required this.title,
    required this.slug,
    required this.contentRating,
    required this.id,
    required this.genres,
    required this.userFollowCount,
    required this.followRank,
    this.demographic,
    this.lastChapter,
    required this.desc,
    required this.mies,
    required this.status,
    required this.createdAt,
    required this.hid,
    required this.mdCovers,
  });

  factory ComicBySeasonModel.fromJson(Map<String, dynamic> json) {
    final miesJson =
        (json['mies'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return _$ComicBySeasonModelFromJson({
      ...json,
      'mies': miesJson,
    });
  }

  Map<String, dynamic> toJson() => _$ComicBySeasonModelToJson(this);
}

@JsonSerializable()
class MiesModel {
  @JsonKey(name: 'ranked')
  final int? ranked;

  @JsonKey(name: 'rating')
  final String? rating;

  @JsonKey(name: 'rating_count')
  final int? ratingCount;

  @JsonKey(name: 'episodes')
  final int? episodes;

  @JsonKey(name: 'myid')
  final int myid;

  @JsonKey(name: 'popularity')
  final int popularity;

  MiesModel({
    this.ranked,
    this.rating,
    this.ratingCount,
    this.episodes,
    required this.myid,
    required this.popularity,
  });

  factory MiesModel.fromJson(Map<String, dynamic> json) =>
      _$MiesModelFromJson(json);
  Map<String, dynamic> toJson() => _$MiesModelToJson(this);
}
