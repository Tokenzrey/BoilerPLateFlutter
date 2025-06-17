import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/history/history.dart';
import 'package:boilerplate/domain/repository/history/history_repository.dart';
import 'package:fpdart/fpdart.dart';

class FetchRecentHistoryParams {
  final String userId;
  const FetchRecentHistoryParams(this.userId);
}

class FetchRecentHistoryUsecase extends UseCase<List<HistoryEntity>, FetchRecentHistoryParams> {
  final HistoryRepository repository;
  const FetchRecentHistoryUsecase(this.repository);

  @override
  Future<Either<Failure, List<HistoryEntity>>> execute(FetchRecentHistoryParams params) {
    return repository.fetchRecentHistory(params.userId);
  }
}
