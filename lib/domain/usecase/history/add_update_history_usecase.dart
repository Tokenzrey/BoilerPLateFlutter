import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/domain/entity/history/history.dart';
import 'package:boilerplate/domain/repository/history/history_repository.dart';
import 'package:fpdart/fpdart.dart';

class AddUpdateHistoryUsecase extends UseCase<Unit, HistoryEntity> {
  final HistoryRepository repository;
  const AddUpdateHistoryUsecase(this.repository);

  @override
  Future<Either<Failure, Unit>> execute(HistoryEntity params) {
    return repository.addOrUpdateEntry(params);
  }
}
