import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/history/history_repository.dart';
import 'package:fpdart/fpdart.dart';

class ClearHistoryByIdParams {
  final String userId;
  const ClearHistoryByIdParams(this.userId);
}

class ClearHistoryByIdUsecase
    extends UseCase<Unit, ClearHistoryByIdParams> {
  final HistoryRepository repository;
  const ClearHistoryByIdUsecase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(ClearHistoryByIdParams params) {
    return repository.clearAll(params.userId);
  }
}
