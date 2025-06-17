import 'dart:async';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/data/local/models/chapter_hot_model.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/chapter_top_service.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/domain/entity/comic/comic.dart';
import 'package:boilerplate/domain/usecase/api/chapter_top_usecase.dart';
import 'package:boilerplate/domain/usecase/api/top_api_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_current_user_usecase.dart';
import 'package:boilerplate/domain/usecase/comic/followed_comic_usecase.dart';
import 'package:boilerplate/presentation/store/settings/settings_store.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter/foundation.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

enum TopPeriod { seven, thirty, ninety }

abstract class HomeStoreBase with Store {
  final TopApiUseCase _topApiUseCase;
  final GetFollowedComicsUseCase _getFollowedComicsUseCase;
  final LatestChaptersUseCase _latestChaptersUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SettingsStore settingsStore;

  HomeStoreBase(
    this._topApiUseCase,
    this._latestChaptersUseCase,
    this._getFollowedComicsUseCase,
    this._getCurrentUserUseCase,
    this.settingsStore,
  ) {
    _setupReactions();
  }

  List<ReactionDisposer>? _disposers;

  // Top State
  @observable
  bool isTopLoading = false;
  @observable
  String? topErrorMessage;
  @observable
  TopResponseModel? topData;

  // Chapters State
  @observable
  bool isHotChaptersLoading = false;
  @observable
  bool isNewChaptersLoading = false;
  @observable
  String? chaptersErrorMessage;
  @observable
  ObservableList<ChapterResponseModel> hotChapters = ObservableList();
  @observable
  ObservableList<ChapterResponseModel> newChapters = ObservableList();

  @observable
  int hotChaptersPage = 1;
  @observable
  int newChaptersPage = 1;
  @observable
  bool hasMoreHotChapters = true;
  @observable
  bool hasMoreNewChapters = true;

  // Followed Comics State
  @observable
  bool isFollowedLoading = false;
  @observable
  String? followedErrorMessage;
  @observable
  ObservableList<FollowedComicEntity> followedComics = ObservableList();
  @observable
  int followedPage = 1;
  @observable
  bool hasMoreFollowedComics = true;
  @observable
  String? currentUserId;

  // General State
  @observable
  bool isInitialized = false;

  // Computed Properties
  @computed
  bool get hasTopError => topErrorMessage?.isNotEmpty == true;

  @computed
  bool get hasTopData => topData != null;

  @computed
  Map<TopPeriod, List<dynamic>> get topFollowComicsMap => {
        TopPeriod.seven: topData?.topFollowComics.seven ?? [],
        TopPeriod.thirty: topData?.topFollowComics.thirty ?? [],
        TopPeriod.ninety: topData?.topFollowComics.ninety ?? [],
      };

  @computed
  Map<TopPeriod, List<dynamic>> get topFollowNewComicsMap => {
        TopPeriod.seven: topData?.topFollowNewComics.seven ?? [],
        TopPeriod.thirty: topData?.topFollowNewComics.thirty ?? [],
        TopPeriod.ninety: topData?.topFollowNewComics.ninety ?? [],
      };

  @computed
  bool get hasChaptersError => chaptersErrorMessage?.isNotEmpty == true;

  @computed
  bool get hasHotChaptersData => hotChapters.isNotEmpty;

  @computed
  bool get hasNewChaptersData => newChapters.isNotEmpty;

  @computed
  bool get hasFollowedError => followedErrorMessage?.isNotEmpty == true;

  @computed
  bool get hasFollowedData => followedComics.isNotEmpty;

  @computed
  bool get isUserLoggedIn => currentUserId != null && currentUserId!.isNotEmpty;

  @computed
  List<Map<String, dynamic>> get followedComicsForUI => followedComics
      .map((comic) => {
            'title': comic.title,
            'cover': comic.imageUrl,
            'slug': comic.slug,
            'chapter': comic.chap,
            'time': comic.updatedAt,
            'id': comic.id,
            'hid': comic.hid,
          })
      .toList();

  @action
  Future<void> initialize() async {
    if (isInitialized) return;
    resetState();

    // Check if user is logged in
    await _checkCurrentUser();

    // Load all sections
    await Future.wait([
      fetchTrendingWithSettings(),
      fetchLatestChaptersWithSettings(),
      if (isUserLoggedIn) fetchFollowedComics(),
    ]);

    isInitialized = true;
  }

  @action
  Future<void> _checkCurrentUser() async {
    try {
      final userResult = await _getCurrentUserUseCase.execute(NoParams());
      userResult.fold(
        (failure) {
          if (kDebugMode) {
            print("Failed to get user: ${failure.message}");
          }
          currentUserId = null;
        },
        (user) {
          currentUserId = user?.id;
          if (kDebugMode) {
            print("Current user ID: ${currentUserId ?? 'Not logged in'}");
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error checking user: $e");
      }
      currentUserId = null;
    }
  }

  @action
  void resetState() {
    topData = null;
    topErrorMessage = null;
    isTopLoading = false;

    resetChaptersPagination();
    chaptersErrorMessage = null;

    resetFollowedComics();

    isInitialized = false;
  }

  @action
  void resetChaptersPagination() {
    hotChaptersPage = 1;
    newChaptersPage = 1;
    hotChapters.clear();
    newChapters.clear();
    hasMoreHotChapters = true;
    hasMoreNewChapters = true;
    isHotChaptersLoading = false;
    isNewChaptersLoading = false;
  }

  // Helper untuk set data secara batch biar hemat observable notification
  void _replaceList<T>(ObservableList<T> list, List<T> newItems) {
    list
      ..clear()
      ..addAll(newItems);
  }

  // --- FOLLOWED COMICS
  @action
  Future<void> fetchFollowedComics({bool appendResults = false}) async {
    if (isFollowedLoading || (appendResults && !hasMoreFollowedComics)) return;
    if (!isUserLoggedIn) {
      followedErrorMessage = "You need to login to see your followed comics";
      return;
    }

    isFollowedLoading = true;
    if (!appendResults) followedErrorMessage = null;

    try {
      final result = await _getFollowedComicsUseCase
          .execute(GetFollowedComicParams(userId: currentUserId!));

      result.fold(
        (failure) => followedErrorMessage = failure.message,
        (comics) {
          if (comics.isEmpty) {
            hasMoreFollowedComics = false;
          } else {
            final sortedComics = List<FollowedComicEntity>.from(comics)
              ..sort((a, b) {
                try {
                  final dateA = DateTime.parse(a.updatedAt);
                  final dateB = DateTime.parse(b.updatedAt);
                  return dateB.compareTo(dateA);
                } catch (e) {
                  return 0;
                }
              });
            if (appendResults) {
              followedComics.addAll(sortedComics);
            } else {
              _replaceList(followedComics, sortedComics);
            }
            // If pagination is implemented for followed comics
            // followedPage++;
          }
        },
      );
    } catch (e) {
      followedErrorMessage = "Failed to load followed comics: $e";
    }

    isFollowedLoading = false;
  }

  @action
  void resetFollowedComics() {
    followedComics.clear();
    followedPage = 1;
    hasMoreFollowedComics = true;
    isFollowedLoading = false;
    followedErrorMessage = null;
  }

  @action
  Future<void> refreshFollowedComics() async {
    if (!isUserLoggedIn) return;
    followedPage = 1;
    hasMoreFollowedComics = true;
    await fetchFollowedComics();
  }

  // --- TOP
  @action
  Future<void> fetchTrendingWithSettings() async {
    if (isTopLoading) return;
    isTopLoading = true;
    topErrorMessage = null;
    try {
      await settingsStore.getSettings();
      final settings = settingsStore.settings;

      TopGender gender = TopGender.male;
      List<ComicType>? comicTypes;
      bool acceptMatureContent = false;
      if (settings != null) {
        gender = settings.demographic == 'female'
            ? TopGender.female
            : TopGender.male;
        final types = settings.contentTypes;
        const allTypes = ['manga', 'manhwa', 'manhua'];
        if (types.length != allTypes.length ||
            !allTypes.every(types.contains)) {
          comicTypes = types.map((e) {
            switch (e) {
              case 'manga':
                return ComicType.manga;
              case 'manhwa':
                return ComicType.manhwa;
              case 'manhua':
                return ComicType.manhua;
              default:
                throw ArgumentError('Unknown comic type: $e');
            }
          }).toList();
        }
        acceptMatureContent = settings.matureContent.contains('mature');
      }

      final params = TopApiParams(
        gender: gender,
        comicTypes: comicTypes,
        acceptMatureContent: acceptMatureContent,
      );

      final result = await _topApiUseCase.execute(params);
      result.fold(
        (failure) => topErrorMessage = failure.message,
        (data) => topData = data,
      );
    } catch (e) {
      topErrorMessage = 'Failed to load trending: $e';
    }
    isTopLoading = false;
  }

  @action
  Future<void> fetchTrendingManga() =>
      _fetchTopPreset(TopApiParams.trendingManga(), 'trending manga');

  @action
  Future<void> fetchPopularForFemaleReaders() => _fetchTopPreset(
      TopApiParams.popularForFemaleReaders(), 'female-targeted content');

  @action
  Future<void> fetchCustom({
    TopGender gender = TopGender.male,
    TopDay? day,
    TopType? type,
    List<ComicType>? comicTypes,
    bool acceptMatureContent = true,
  }) =>
      _fetchTopPreset(
        TopApiParams(
          gender: gender,
          day: day,
          type: type,
          comicTypes: comicTypes,
          acceptMatureContent: acceptMatureContent,
        ),
        'custom content',
      );

  Future<void> _fetchTopPreset(TopApiParams params, String contextText) async {
    if (isTopLoading) return;
    isTopLoading = true;
    topErrorMessage = null;
    try {
      final result = await _topApiUseCase.execute(params);
      result.fold(
        (failure) => topErrorMessage = failure.message,
        (data) => topData = data,
      );
    } catch (e) {
      topErrorMessage = 'Failed to load $contextText: $e';
    }
    isTopLoading = false;
  }

  // --- CHAPTERS (PAGINATION)
  @action
  Future<void> fetchLatestChaptersWithSettings() async {
    resetChaptersPagination();
    await Future.wait([
      fetchHotChaptersWithSettings(),
      fetchNewChaptersWithSettings(),
    ]);
  }

  @action
  Future<void> fetchHotChaptersWithSettings(
      {bool appendResults = false}) async {
    if (isHotChaptersLoading || (appendResults && !hasMoreHotChapters)) return;
    isHotChaptersLoading = true;
    if (!appendResults) chaptersErrorMessage = null;
    try {
      await settingsStore.getSettings();
      final settings = settingsStore.settings;

      ChapterGender gender = ChapterGender.male;
      List<ChapterType>? types;
      bool acceptEroticContent = false;
      const lang = ['en'];
      if (settings != null) {
        gender = settings.demographic == 'female'
            ? ChapterGender.female
            : ChapterGender.male;
        const allTypes = ['manga', 'manhwa', 'manhua'];
        final contentTypes = settings.contentTypes;
        if (contentTypes.length != allTypes.length ||
            !allTypes.every(contentTypes.contains)) {
          types = contentTypes.map((e) {
            switch (e) {
              case 'manga':
                return ChapterType.manga;
              case 'manhwa':
                return ChapterType.manhwa;
              case 'manhua':
                return ChapterType.manhua;
              default:
                throw ArgumentError('Unknown comic type: $e');
            }
          }).toList();
        }
        acceptEroticContent = settings.matureContent.contains('mature');
      }

      final params = LatestChaptersParams(
        gender: gender,
        order: ChapterOrderType.hot,
        types: types,
        acceptEroticContent: acceptEroticContent,
        lang: lang,
        page: hotChaptersPage,
      );
      final result = await _latestChaptersUseCase.execute(params);
      result.fold(
        (failure) => chaptersErrorMessage = failure.message,
        (data) {
          if (data.isEmpty) {
            hasMoreHotChapters = false;
          } else {
            if (appendResults) {
              hotChapters.addAll(data);
            } else {
              _replaceList(hotChapters, data);
            }
            hotChaptersPage++;
          }
        },
      );
    } catch (e) {
      chaptersErrorMessage = 'Failed to load hot chapters: $e';
    }
    isHotChaptersLoading = false;
  }

  @action
  Future<void> fetchNewChaptersWithSettings(
      {bool appendResults = false}) async {
    if (isNewChaptersLoading || (appendResults && !hasMoreNewChapters)) return;
    isNewChaptersLoading = true;
    if (!appendResults) chaptersErrorMessage = null;
    try {
      await settingsStore.getSettings();
      final settings = settingsStore.settings;

      ChapterGender gender = ChapterGender.male;
      List<ChapterType>? types;
      bool acceptEroticContent = false;
      const lang = ['en'];
      if (settings != null) {
        gender = settings.demographic == 'female'
            ? ChapterGender.female
            : ChapterGender.male;
        const allTypes = ['manga', 'manhwa', 'manhua'];
        final contentTypes = settings.contentTypes;
        if (contentTypes.length != allTypes.length ||
            !allTypes.every(contentTypes.contains)) {
          types = contentTypes.map((e) {
            switch (e) {
              case 'manga':
                return ChapterType.manga;
              case 'manhwa':
                return ChapterType.manhwa;
              case 'manhua':
                return ChapterType.manhua;
              default:
                throw ArgumentError('Unknown comic type: $e');
            }
          }).toList();
        }
        acceptEroticContent = settings.matureContent.contains('mature');
      }

      final params = LatestChaptersParams(
        gender: gender,
        order: ChapterOrderType.new_,
        types: types,
        acceptEroticContent: acceptEroticContent,
        lang: lang,
        page: newChaptersPage,
      );
      final result = await _latestChaptersUseCase.execute(params);
      result.fold(
        (failure) => chaptersErrorMessage = failure.message,
        (data) {
          if (data.isEmpty) {
            hasMoreNewChapters = false;
          } else {
            if (appendResults) {
              newChapters.addAll(data);
            } else {
              _replaceList(newChapters, data);
            }
            newChaptersPage++;
          }
        },
      );
    } catch (e) {
      chaptersErrorMessage = 'Failed to load new chapters: $e';
    }
    isNewChaptersLoading = false;
  }

  @action
  Future<void> loadMoreChapters(bool isHot) async {
    if (isHot) {
      if (!isHotChaptersLoading && hasMoreHotChapters) {
        await fetchHotChaptersWithSettings(appendResults: true);
      }
    } else {
      if (!isNewChaptersLoading && hasMoreNewChapters) {
        await fetchNewChaptersWithSettings(appendResults: true);
      }
    }
  }

  // -- MobX Reaction (untuk debugging/refresh di UI)
  void _setupReactions() {
    _disposers = [
      reaction((_) => topData, (_) {
        if (kDebugMode) {
          print("Top data loaded with ${topData?.rank.length ?? 0} rank items");
        }
      }),
      reaction((_) => hotChapters.length, (_) {
        if (kDebugMode) {
          print("Hot chapters loaded with ${hotChapters.length} items");
        }
      }),
      reaction((_) => newChapters.length, (_) {
        if (kDebugMode) {
          print("New chapters loaded with ${newChapters.length} items");
        }
      }),
      reaction((_) => followedComics.length, (_) {
        if (kDebugMode) {
          print("Followed comics loaded with ${followedComics.length} items");
        }
      }),
      reaction((_) => isInitialized, (initialized) {
        if (kDebugMode) print("HomeStore initialized: $initialized");
      }),
      reaction((_) => currentUserId, (userId) {
        if (kDebugMode) print("User ID changed: ${userId ?? 'Not logged in'}");
        if (userId != null && userId.isNotEmpty) {
          fetchFollowedComics();
        } else {
          resetFollowedComics();
        }
      }),
    ];
  }

  void dispose() {
    _disposers?.forEach((d) => d());
    _disposers = null;
  }
}
