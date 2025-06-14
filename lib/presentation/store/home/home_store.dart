import 'package:boilerplate/data/local/models/top_response_model.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/domain/usecase/api/top_api_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'home_store.g.dart';

class HomeStore = HomeStoreBase with _$HomeStore;

abstract class HomeStoreBase with Store {
  final TopApiUseCase _topApiUseCase;

  HomeStoreBase(this._topApiUseCase) {
    _setupReactions();
  }

  List<ReactionDisposer>? _disposers;

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @observable
  TopResponseModel? topData;

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  @computed
  bool get hasData => topData != null;

  @computed
  List<dynamic> get rankingList => topData?.rank ?? [];

  @computed
  List<dynamic> get trendingList =>
      topData?.trending.seven ??
      topData?.trending.thirty ??
      topData?.trending.ninety ??
      [];

  @computed
  List<dynamic> get newsList => topData?.news ?? [];

  /// Fetches trending manga comics (preset)
  @action
  Future<void> fetchTrendingManga() async {
    _setLoading(true);
    _resetError();

    final params = TopApiParams.trendingManga();
    final result = await _topApiUseCase.execute(params);

    result.fold(
      (failure) => _setErrorMessage(failure.message),
      (data) => topData = data,
    );

    _setLoading(false);
  }

  /// Fetches comics popular with female readers (preset)
  @action
  Future<void> fetchPopularForFemaleReaders() async {
    _setLoading(true);
    _resetError();

    final params = TopApiParams.popularForFemaleReaders();
    final result = await _topApiUseCase.execute(params);

    result.fold(
      (failure) => _setErrorMessage(failure.message),
      (data) => topData = data,
    );

    _setLoading(false);
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
      (failure) => _setErrorMessage(failure.message),
      (data) => topData = data,
    );

    _setLoading(false);
  }

  @action
  void _setLoading(bool value) {
    isLoading = value;
  }

  @action
  void _setErrorMessage(String? message) {
    errorMessage = message;
  }

  @action
  void _resetError() {
    errorMessage = null;
  }

  void _setupReactions() {
    _disposers = [
      reaction((_) => topData, (_) {
        if (kDebugMode) {
          print("Top data loaded with ${topData?.rank.length ?? 0} rank items");
        }
      }),
    ];
  }

  void dispose() {
    _disposers?.forEach((disposer) => disposer());
  }
}
