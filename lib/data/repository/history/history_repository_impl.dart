import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/data/local/datasources/history/history_datasource.dart';
import 'package:boilerplate/data/local/models/history_entry_model.dart';
import 'package:boilerplate/domain/entity/history/history.dart';
import 'package:boilerplate/domain/repository/history/history_repository.dart';
import 'package:fpdart/fpdart.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;

  HistoryRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Unit>> addOrUpdateEntry(HistoryEntity entry) async {
    try {
      final model = HistoryModelX.fromEntity(entry);
      await localDataSource.addOrUpdateEntry(model);
      return right(unit);
    } catch (e) {
      return left(CacheFailure('Failed to save history: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteById(String userId, String hid) async {
    try {
      await localDataSource.deleteById(userId, hid);
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HistoryEntity>>> fetchRecentHistory(String userId) async {
    try {
      final history = await localDataSource.fetchRecentHistory(userId);
      return right(history.map((e) => e.toEntity()).toList());
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, Unit>> clearAll(String userId) async {
    try {
      await localDataSource.clearAll(userId);
      return right(unit);
    } catch (e) {
      return left(CacheFailure(e.toString()));
    }
  }
}
