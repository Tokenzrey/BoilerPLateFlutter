import 'package:boilerplate/domain/entity/history/history.dart';
import 'package:boilerplate/domain/usecase/history/add_update_history_usecase.dart';
import 'package:boilerplate/domain/usecase/history/clear_history_usecase.dart';
import 'package:boilerplate/domain/usecase/history/delete_history_usecase.dart';
import 'package:boilerplate/domain/usecase/history/fetch_recent_history_usecase.dart';
import 'package:boilerplate/presentation/store/auth_firebase/auth_store.dart';
import 'package:mobx/mobx.dart';

part 'history_store.g.dart';

class HistoryStore = HistoryStoreBase with _$HistoryStore;

abstract class HistoryStoreBase with Store {
  final AuthStore authStore;
  final FetchRecentHistoryUsecase fetchRecentHistoryUseCase;
  final AddUpdateHistoryUsecase addUpdateHistoryUseCase;
  final DeleteHistoryByIdUsecase deleteByIdUseCase;
  final ClearHistoryByIdUsecase clearHistoryByIdUsecase;

  HistoryStoreBase({
    required this.authStore,
    required this.fetchRecentHistoryUseCase,
    required this.addUpdateHistoryUseCase,
    required this.deleteByIdUseCase,
    required this.clearHistoryByIdUsecase,
  });

  @observable
  HistoryEntity? history;

  @observable
  ObservableList<HistoryEntity> historyList = ObservableList<HistoryEntity>();

  @observable
  bool isLoading = false;

  @observable
  String? errorMessage;

  @computed
  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;

  String get _currentId {
    final user = authStore.currentUser;
    return (authStore.isLoggedIn && user != null && user.id.isNotEmpty)
        ? user.id
        : 'guest';
  }

  @action
  Future<void> fetchRecentHistory() async {
    isLoading = true;
    errorMessage = null;

    final userId = _currentId;

    try {
      final result = await fetchRecentHistoryUseCase(FetchRecentHistoryParams(userId));
      result.fold(
        (failure) => errorMessage = failure.message,
        (list) {
          print('Fetched ${list.length} history items');
          historyList.clear();
          historyList.addAll(list);
        }
      );
    } catch (e) {
      errorMessage = 'Unexpected error fetching: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addOrUpdateHistory(
    String slug,
    String hid,
    String chap,
  ) async {
    isLoading = true;
    errorMessage = null;

    final userId = _currentId;
    final updatedHistory = HistoryEntity.create(
      userId: userId,
      slug: slug,
      hid: hid,
      chap: chap,
    );

    try {
      await addUpdateHistoryUseCase(updatedHistory);

      await fetchRecentHistory();
    } catch (e) {
      errorMessage = 'Failed to save/update history: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> deleteHistory(
    String hid,
  ) async {
    isLoading = true;
    errorMessage = null;

    final userId = _currentId;

    try {
      await deleteByIdUseCase(DeleteHistoryByIdParams(userId, hid));

      await fetchRecentHistory();
    } catch (e) {
      errorMessage = 'Failed to delete history: $e';
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> clearHistory() async {
    isLoading = true;
    errorMessage = null;

    final userId = _currentId;

    try {
      await clearHistoryByIdUsecase(ClearHistoryByIdParams(userId));

      await fetchRecentHistory();
    } catch (e) {
      errorMessage = 'Failed to clear history: $e';
    } finally {
      isLoading = false;
    }
  }
}
