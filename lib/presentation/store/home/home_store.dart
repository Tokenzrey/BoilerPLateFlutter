import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/domain/usecase/api/top_api_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  /// UseCase for interacting with comics API
  final TopApiUseCase _topApiUseCase;

  /// Creates a new HomeStore with the provided use case
  HomeStoreBase(this._topApiUseCase) {
    _setupReactions();
  }

  /// List of reaction disposers for cleanup
  List<ReactionDisposer>? _disposers;

  /// Whether data is currently being loaded
  @observable
  bool isLoading = false;

  /// Error message from the most recent operation, null if no error
  @observable
  String? errorMessage;

  /// The fetched comics data
  @observable
  TopResponseModel? topData;

  /// Whether there is currently an error
  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  /// Whether data has been loaded
  @computed
  bool get hasData => topData != null;

  /// List of comics ranked by popularity
  @computed
  List<dynamic> get rankingList => topData?.rank ?? [];

  /// List of trending comics, prioritizing more recent data
  @computed
  List<dynamic> get trendingList =>
      topData?.trending.seven ??
      topData?.trending.thirty ??
      topData?.trending.ninety ??
      [];

  /// List of new comics
  @computed
  List<dynamic> get newsList => topData?.news ?? [];

  /// Fetches trending manga comics
  ///
  /// Updates [isLoading], [errorMessage], and [topData] states
  @action
  Future<void> fetchTrendingManga() async {
    _setLoading(true);
    _resetError();

    final result = await _topApiUseCase.getTrendingManga();

    result.fold(
      (failure) {
        _setErrorMessage(failure.message);
      },
      (data) {
        topData = data;
      },
    );

    _setLoading(false);
  }

  /// Fetches comics popular with female readers
  ///
  /// Updates [isLoading], [errorMessage], and [topData] states
  @action
  Future<void> fetchPopularForFemaleReaders() async {
    _setLoading(true);
    _resetError();

    final result = await _topApiUseCase.getPopularForFemaleReaders();

    result.fold(
      (failure) {
        _setErrorMessage(failure.message);
      },
      (data) {
        topData = data;
      },
    );

    _setLoading(false);
  }

  /// Fetches comics with custom parameters
  ///
  /// Updates [isLoading], [errorMessage], and [topData] states
  @action
  Future<void> fetchCustom({
    required TopGender gender,
    required TopDay day,
    required TopType type,
    required List<ComicType> comicTypes,
    bool acceptMatureContent = false,
  }) async {
    _setLoading(true);
    _resetError();

    final params = TopApiParams(
      gender: gender,
      day: day,
      type: type,
      comicTypes: comicTypes,
      acceptMatureContent: acceptMatureContent,
    );

    final result = await _topApiUseCase.execute(params);

    result.fold(
      (failure) {
        _setErrorMessage(failure.message);
      },
      (data) {
        topData = data;
      },
    );

    _setLoading(false);
  }

  /// Sets the loading state
  @action
  void _setLoading(bool value) {
    isLoading = value;
  }

  /// Sets the error message
  @action
  void _setErrorMessage(String? message) {
    errorMessage = message;
  }

  /// Clears any current error message
  @action
  void _resetError() {
    errorMessage = null;
  }

  /// Sets up MobX reactions
  void _setupReactions() {
    _disposers = [
      reaction((_) => topData, (_) {
        if (kDebugMode) {
          print("Top data loaded with ${topData?.rank.length ?? 0} rank items");
        }
      }),
    ];
  }

  /// Disposes all reactions to prevent memory leaks
  void dispose() {
    _disposers?.forEach((disposer) => disposer());
  }
}
