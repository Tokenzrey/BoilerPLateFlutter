import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/repository/history/history_repository.dart';
import 'package:fpdart/fpdart.dart';

class DeleteHistoryByIdParams {
  final String userId;
  final String hid;
  const DeleteHistoryByIdParams(this.hid, this.userId);
}

class DeleteHistoryByIdUsecase
    extends UseCase<Unit, DeleteHistoryByIdParams> {
  final HistoryRepository repository;
  const DeleteHistoryByIdUsecase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(DeleteHistoryByIdParams params) {
    return repository.deleteById(params.userId, params.hid);
  }
}
