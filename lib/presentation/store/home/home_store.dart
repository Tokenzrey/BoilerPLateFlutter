import 'dart:async';
import 'package:boilerplate/data/local/models/chapter_hot_model.dart';
import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/chapter_top_service.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/domain/usecase/api/chapter_top_usecase.dart';
import 'package:boilerplate/domain/usecase/api/top_api_usecase.dart';
import 'package:boilerplate/presentation/store/settings/settings_store.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

enum TopPeriod { seven, thirty, ninety }

abstract class HomeStoreBase with Store {
  final TopApiUseCase _topApiUseCase;
  final LatestChaptersUseCase _latestChaptersUseCase;
  final SettingsStore settingsStore;

  HomeStoreBase(
    this._topApiUseCase,
    this._latestChaptersUseCase,
    this.settingsStore,
  ) {
    _setupReactions();
  }

  List<ReactionDisposer>? _disposers;
  final List<StreamSubscription> _activeSubscriptions = [];

  // Top comics state
  @observable
  bool isTopLoading = false;

  @observable
  String? topErrorMessage;

  @observable
  TopResponseModel? topData;

  // Latest chapters state
  @observable
  bool isHotChaptersLoading = false;

  @observable
  bool isNewChaptersLoading = false;

  @observable
  String? chaptersErrorMessage;

  @observable
  List<ChapterResponseModel> hotChapters = [];

  @observable
  List<ChapterResponseModel> newChapters = [];

  // Pagination state for chapters
  @observable
  int hotChaptersPage = 1;

  @observable
  int newChaptersPage = 1;

  @observable
  bool hasMoreHotChapters = true;

  @observable
  bool hasMoreNewChapters = true;

  // Initialization state
  @observable
  bool isInitialized = false;

  // Computed properties for top comics
  @computed
  bool get hasTopError =>
      topErrorMessage != null && topErrorMessage!.isNotEmpty;

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

  // Computed properties for latest chapters
  @computed
  bool get hasChaptersError =>
      chaptersErrorMessage != null && chaptersErrorMessage!.isNotEmpty;

  @computed
  bool get hasHotChaptersData => hotChapters.isNotEmpty;

  @computed
  bool get hasNewChaptersData => newChapters.isNotEmpty;

  // Initialize store state
  @action
  Future<void> initialize() async {
    if (isInitialized) return;

    resetState();
    await fetchTrendingWithSettings();
    await fetchLatestChaptersWithSettings();

    isInitialized = true;
  }

  // Reset all state
  @action
  void resetState() {
    // Cancel any ongoing operations
    _cancelActiveOperations();

    // Reset top comics state
    topData = null;
    topErrorMessage = null;
    isTopLoading = false;

    // Reset chapters state
    resetChaptersPagination();
    chaptersErrorMessage = null;

    isInitialized = false;
  }

  // Top comics actions
  @action
  Future<void> fetchTrendingWithSettings() async {
    if (isTopLoading) return;

    _setTopLoading(true);
    _resetTopError();

    try {
      // Get settings first
      await settingsStore.getSettings();
      final settings = settingsStore.settings;

      // Set default values
      TopGender gender = TopGender.male;
      List<ComicType>? comicTypes;
      bool acceptMatureContent = false;

      if (settings != null) {
        // Demographic
        final demographic = settings.demographic;
        gender = demographic == 'female' ? TopGender.female : TopGender.male;

        // contentTypes
        final types = settings.contentTypes;
        final allTypes = ['manga', 'manhwa', 'manhua'];
        if (types.length == allTypes.length &&
            allTypes.every((e) => types.contains(e))) {
          comicTypes = null;
        } else if (types.isEmpty) {
          comicTypes = null;
        } else {
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

        // matureContent
        acceptMatureContent = (settings.matureContent).contains('mature');
      }

      final params = TopApiParams(
        gender: gender,
        comicTypes: comicTypes,
        acceptMatureContent: acceptMatureContent,
      );

      final completer = Completer<void>();
      final subscription =
          Stream.fromFuture(_topApiUseCase.execute(params)).listen((result) {
        result.fold(
          (failure) => _setTopErrorMessage(failure.message),
          (data) => topData = data,
        );
        completer.complete();
      }, onError: (e) {
        _setTopErrorMessage('Failed to load trending: $e');
        completer.complete();
      });

      _activeSubscriptions.add(subscription);
      await completer.future;
    } catch (e) {
      _setTopErrorMessage('Failed to load trending: $e');
    } finally {
      _setTopLoading(false);
    }
  }

  /// Fetches trending manga comics (preset)
  @action
  Future<void> fetchTrendingManga() async {
    if (isTopLoading) return;

    _setTopLoading(true);
    _resetTopError();

    final params = TopApiParams.trendingManga();

    try {
      final result = await _topApiUseCase.execute(params);

      result.fold(
        (failure) => _setTopErrorMessage(failure.message),
        (data) => topData = data,
      );
    } catch (e) {
      _setTopErrorMessage('Failed to load trending manga: $e');
    } finally {
      _setTopLoading(false);
    }
  }

  /// Fetches comics popular with female readers (preset)
  @action
  Future<void> fetchPopularForFemaleReaders() async {
    if (isTopLoading) return;

    _setTopLoading(true);
    _resetTopError();

    final params = TopApiParams.popularForFemaleReaders();

    try {
      final result = await _topApiUseCase.execute(params);

      result.fold(
        (failure) => _setTopErrorMessage(failure.message),
        (data) => topData = data,
      );
    } catch (e) {
      _setTopErrorMessage('Failed to load female-targeted content: $e');
    } finally {
      _setTopLoading(false);
    }
  }

  /// Fetches comics with custom parameters
  @action
  Future<void> fetchCustom({
    TopGender gender = TopGender.male,
    TopDay? day,
    TopType? type,
    List<ComicType>? comicTypes,
    bool acceptMatureContent = true,
  }) async {
    if (isTopLoading) return;

    _setTopLoading(true);
    _resetTopError();

    final params = TopApiParams(
      gender: gender,
      day: day,
      type: type,
      comicTypes: comicTypes,
      acceptMatureContent: acceptMatureContent,
    );

    try {
      final result = await _topApiUseCase.execute(params);

      result.fold(
        (failure) => _setTopErrorMessage(failure.message),
        (data) => topData = data,
      );
    } catch (e) {
      _setTopErrorMessage('Failed to load custom content: $e');
    } finally {
      _setTopLoading(false);
    }
  }

  // Latest chapters actions
  @action
  Future<void> fetchLatestChaptersWithSettings() async {
    // Reset pagination when fetching with settings - this is initial load
    resetChaptersPagination();

    await Future.wait([
      fetchHotChaptersWithSettings(),
      fetchNewChaptersWithSettings(),
    ]);
  }

  // Reset pagination state when settings change
  @action
  void resetChaptersPagination() {
    _cancelActiveOperations();

    hotChaptersPage = 1;
    newChaptersPage = 1;
    hotChapters = [];
    newChapters = [];
    hasMoreHotChapters = true;
    hasMoreNewChapters = true;
    isHotChaptersLoading = false;
    isNewChaptersLoading = false;
  }

  @action
  Future<void> fetchHotChaptersWithSettings(
      {bool appendResults = false}) async {
    // Don't start a new request if we're already loading
    if (isHotChaptersLoading) return;

    // Don't proceed if we already know there are no more items
    if (appendResults && !hasMoreHotChapters) return;

    _setHotChaptersLoading(true);
    if (!appendResults) _resetChaptersError();

    try {
      // Get settings
      await settingsStore.getSettings();
      final settings = settingsStore.settings;

      // Set default values
      ChapterGender gender = ChapterGender.male;
      List<ChapterType>? types;
      bool acceptEroticContent = false;
      List<String> lang = ['en']; // Default to English

      if (settings != null) {
        // Demographic
        final demographic = settings.demographic;
        gender =
            demographic == 'female' ? ChapterGender.female : ChapterGender.male;

        // contentTypes
        final contentTypes = settings.contentTypes;
        final allTypes = ['manga', 'manhwa', 'manhua'];
        if (contentTypes.length == allTypes.length &&
            allTypes.every((e) => contentTypes.contains(e))) {
          types = null;
        } else if (contentTypes.isEmpty) {
          types = null;
        } else {
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

        // matureContent
        acceptEroticContent = (settings.matureContent).contains('mature');
      }

      final params = LatestChaptersParams(
        gender: gender,
        order: ChapterOrderType.hot,
        types: types,
        acceptEroticContent: acceptEroticContent,
        lang: lang,
        page: hotChaptersPage,
      );

      final completer = Completer<void>();
      final subscription =
          Stream.fromFuture(_latestChaptersUseCase.execute(params)).listen(
              (result) {
        result.fold(
          (failure) => _setChaptersErrorMessage(failure.message),
          (data) {
            if (data.isEmpty) {
              // No more data to load
              hasMoreHotChapters = false;
            } else {
              if (appendResults) {
                // Append new results to existing list
                hotChapters = [...hotChapters, ...data];
              } else {
                // Replace with new results
                hotChapters = data;
              }
              // Increment page number for next request
              hotChaptersPage++;
            }
          },
        );
        completer.complete();
      }, onError: (e) {
        _setChaptersErrorMessage('Failed to load hot chapters: $e');
        completer.complete();
      });

      _activeSubscriptions.add(subscription);
      await completer.future;
    } catch (e) {
      _setChaptersErrorMessage('Failed to load hot chapters: $e');
    } finally {
      _setHotChaptersLoading(false);
    }
  }

  @action
  Future<void> fetchNewChaptersWithSettings(
      {bool appendResults = false}) async {
    // Don't start a new request if we're already loading
    if (isNewChaptersLoading) return;

    // Don't proceed if we already know there are no more items
    if (appendResults && !hasMoreNewChapters) return;

    _setNewChaptersLoading(true);
    if (!appendResults) _resetChaptersError();

    try {
      // Get settings
      await settingsStore.getSettings();
      final settings = settingsStore.settings;

      // Set default values
      ChapterGender gender = ChapterGender.male;
      List<ChapterType>? types;
      bool acceptEroticContent = false;
      List<String> lang = ['en']; // Default to English

      if (settings != null) {
        // Demographic
        final demographic = settings.demographic;
        gender =
            demographic == 'female' ? ChapterGender.female : ChapterGender.male;

        // contentTypes
        final contentTypes = settings.contentTypes;
        final allTypes = ['manga', 'manhwa', 'manhua'];
        if (contentTypes.length == allTypes.length &&
            allTypes.every((e) => contentTypes.contains(e))) {
          types = null;
        } else if (contentTypes.isEmpty) {
          types = null;
        } else {
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

        // matureContent
        acceptEroticContent = (settings.matureContent).contains('mature');
      }

      final params = LatestChaptersParams(
        gender: gender,
        order: ChapterOrderType.new_,
        types: types,
        acceptEroticContent: acceptEroticContent,
        lang: lang,
        page: newChaptersPage,
      );

      final completer = Completer<void>();
      final subscription =
          Stream.fromFuture(_latestChaptersUseCase.execute(params)).listen(
              (result) {
        result.fold(
          (failure) => _setChaptersErrorMessage(failure.message),
          (data) {
            if (data.isEmpty) {
              // No more data to load
              hasMoreNewChapters = false;
            } else {
              if (appendResults) {
                // Append new results to existing list
                newChapters = [...newChapters, ...data];
              } else {
                // Replace with new results
                newChapters = data;
              }
              // Increment page number for next request
              newChaptersPage++;
            }
          },
        );
        completer.complete();
      }, onError: (e) {
        _setChaptersErrorMessage('Failed to load new chapters: $e');
        completer.complete();
      });

      _activeSubscriptions.add(subscription);
      await completer.future;
    } catch (e) {
      _setChaptersErrorMessage('Failed to load new chapters: $e');
    } finally {
      _setNewChaptersLoading(false);
    }
  }

  @action
  Future<void> fetchHotEnglishChapters() async {
    if (isHotChaptersLoading) return;

    _setHotChaptersLoading(true);
    _resetChaptersError();

    // Reset pagination
    hotChaptersPage = 1;
    hotChapters = [];
    hasMoreHotChapters = true;

    try {
      final params = LatestChaptersParams.hotEnglish();
      final result = await _latestChaptersUseCase.execute(params);

      result.fold(
        (failure) => _setChaptersErrorMessage(failure.message),
        (data) {
          hotChapters = data;
          if (data.isNotEmpty) {
            hotChaptersPage++;
          } else {
            hasMoreHotChapters = false;
          }
        },
      );
    } catch (e) {
      _setChaptersErrorMessage('Failed to load hot English chapters: $e');
    } finally {
      _setHotChaptersLoading(false);
    }
  }

  @action
  Future<void> fetchLatestMangaUpdates() async {
    if (isNewChaptersLoading) return;

    _setNewChaptersLoading(true);
    _resetChaptersError();

    // Reset pagination
    newChaptersPage = 1;
    newChapters = [];
    hasMoreNewChapters = true;

    try {
      final params = LatestChaptersParams.latestManga();
      final result = await _latestChaptersUseCase.execute(params);

      result.fold(
        (failure) => _setChaptersErrorMessage(failure.message),
        (data) {
          newChapters = data;
          if (data.isNotEmpty) {
            newChaptersPage++;
          } else {
            hasMoreNewChapters = false;
          }
        },
      );
    } catch (e) {
      _setChaptersErrorMessage('Failed to load latest manga updates: $e');
    } finally {
      _setNewChaptersLoading(false);
    }
  }

  @action
  Future<void> fetchCustomChapters({
    List<String>? lang,
    int? page = 1,
    ChapterGender? gender,
    ChapterOrderType order = ChapterOrderType.hot,
    List<ChapterType>? types,
    bool? acceptEroticContent = false,
    bool appendResults = false,
  }) async {
    final isHot = order == ChapterOrderType.hot;

    // Don't start a new request if we're already loading
    if (isHot && isHotChaptersLoading || !isHot && isNewChaptersLoading) {
      return;
    }

    if (!appendResults) {
      // Reset pagination for this type
      if (isHot) {
        hotChaptersPage = 1;
        hotChapters = [];
        hasMoreHotChapters = true;
      } else {
        newChaptersPage = 1;
        newChapters = [];
        hasMoreNewChapters = true;
      }
    }

    // Don't proceed if we know there are no more items
    if (isHot && !hasMoreHotChapters || !isHot && !hasMoreNewChapters) {
      return;
    }

    if (isHot) {
      _setHotChaptersLoading(true);
    } else {
      _setNewChaptersLoading(true);
    }

    if (!appendResults) _resetChaptersError();

    try {
      final params = LatestChaptersParams(
        lang: lang,
        page: isHot ? hotChaptersPage : newChaptersPage,
        gender: gender,
        order: order,
        types: types,
        acceptEroticContent: acceptEroticContent,
      );

      final result = await _latestChaptersUseCase.execute(params);

      result.fold(
        (failure) => _setChaptersErrorMessage(failure.message),
        (data) {
          if (data.isEmpty) {
            if (isHot) {
              hasMoreHotChapters = false;
            } else {
              hasMoreNewChapters = false;
            }
          } else {
            if (isHot) {
              if (appendResults) {
                hotChapters = [...hotChapters, ...data];
              } else {
                hotChapters = data;
              }
              hotChaptersPage++;
            } else {
              if (appendResults) {
                newChapters = [...newChapters, ...data];
              } else {
                newChapters = data;
              }
              newChaptersPage++;
            }
          }
        },
      );
    } catch (e) {
      _setChaptersErrorMessage('Failed to load chapters: $e');
    } finally {
      if (isHot) {
        _setHotChaptersLoading(false);
      } else {
        _setNewChaptersLoading(false);
      }
    }
  }

  // Load next page of data
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

  // Cancel any active operations
  void _cancelActiveOperations() {
    for (var subscription in _activeSubscriptions) {
      subscription.cancel();
    }
    _activeSubscriptions.clear();
  }

  // State management methods for top comics
  @action
  void _setTopLoading(bool value) {
    isTopLoading = value;
  }

  @action
  void _setTopErrorMessage(String? message) {
    topErrorMessage = message;
  }

  @action
  void _resetTopError() {
    topErrorMessage = null;
  }

  // State management methods for latest chapters
  @action
  void _setHotChaptersLoading(bool value) {
    isHotChaptersLoading = value;
  }

  @action
  void _setNewChaptersLoading(bool value) {
    isNewChaptersLoading = value;
  }

  @action
  void _setChaptersErrorMessage(String? message) {
    chaptersErrorMessage = message;
  }

  @action
  void _resetChaptersError() {
    chaptersErrorMessage = null;
  }

  // Utility methods
  void _setupReactions() {
    _disposers = [
      reaction((_) => topData, (_) {
        if (kDebugMode) {
          print("Top data loaded with ${topData?.rank.length ?? 0} rank items");
        }
      }),
      reaction((_) => hotChapters, (_) {
        if (kDebugMode) {
          print("Hot chapters loaded with ${hotChapters.length} items");
        }
      }),
      reaction((_) => newChapters, (_) {
        if (kDebugMode) {
          print("New chapters loaded with ${newChapters.length} items");
        }
      }),
      reaction((_) => isInitialized, (initialized) {
        if (kDebugMode) {
          print("HomeStore initialized: $initialized");
        }
      }),
    ];
  }

  void dispose() {
    _cancelActiveOperations();

    _disposers?.forEach((disposer) => disposer());
    _disposers = null;
  }
}
