import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:boilerplate/domain/entity/history/history.dart';
import 'package:fpdart/fpdart.dart';

abstract class HistoryRepository {
  /// Fetch Recent History
  Future<Either<Failure, List<HistoryEntity>>> fetchRecentHistory(String userId);

  /// Add or Update Entry
  Future<Either<Failure, Unit>> addOrUpdateEntry(HistoryEntity entry);

  /// Delete settings by ID
  Future<Either<Failure, Unit>> deleteById(String userId, String hid);

  /// Delete all settings
  Future<Either<Failure, Unit>> clearAll(String userId);
}