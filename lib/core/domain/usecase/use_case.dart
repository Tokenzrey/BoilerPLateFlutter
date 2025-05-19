import 'dart:async';
import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';

/// Base contract untuk semua Use Cases dalam arsitektur domain layer.
///
/// Use Case merepresentasikan business logic yang spesifik dalam aplikasi.
/// Pattern ini memastikan bahwa logika bisnis terisolasi dan tidak bergantung
/// pada implementasi konkrit dari data sources atau UI.
///
/// Type parameters:
/// * [T] - Tipe data sukses yang dikembalikan oleh use case
/// * [P] - Tipe parameter yang diterima oleh use case
abstract class UseCase<T, P> {
  const UseCase();

  /// Mengeksekusi logika bisnis use case dengan parameter [params].
  ///
  /// Returns [Either]:
  /// * [Failure] di sisi kiri jika terjadi kesalahan
  /// * [T] di sisi kanan jika operasi berhasil
  Future<Either<Failure, T>> execute(P params);

  /// Operator untuk memanggil use case dengan sintaks yang lebih bersih.
  ///
  /// Memungkinkan penggunaan pattern: `final result = await useCase(params);`
  /// sebagai alternatif dari `final result = await useCase.execute(params);`
  Future<Either<Failure, T>> call(P params) => execute(params);
}

/// Parameter kosong untuk use case yang tidak membutuhkan parameter.
///
/// Gunakan `NoParams()` sebagai parameter saat memanggil use case
/// yang tidak memerlukan input parameter.
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'NoParams()';
}

/// Base contract untuk use case yang tidak membutuhkan parameter input.
///
/// Merupakan spesialisasi dari [UseCase] dengan parameter [NoParams].
abstract class NoParamsUseCase<T> extends UseCase<T, NoParams> {
  const NoParamsUseCase();

  /// Mengeksekusi use case tanpa parameter.
  ///
  /// Implementation yang lebih bersih untuk use case tanpa parameter.
  Future<Either<Failure, T>> executeNoParams() => execute(const NoParams());

  /// Memanggil use case tanpa parameter.
  Future<Either<Failure, T>> callNoParams() => executeNoParams();
}

/// Base contract untuk use case yang melakukan operasi void/unit.
///
/// Gunakan untuk operasi yang tidak mengembalikan nilai spesifik
/// selain konfirmasi bahwa operasi berhasil dilakukan.
abstract class UnitUseCase<P> extends UseCase<Unit, P> {
  const UnitUseCase();
}

/// Base contract untuk use case yang tidak memerlukan parameter
/// dan melakukan operasi void/unit.
abstract class NoParamsUnitUseCase extends UseCase<Unit, NoParams> {
  const NoParamsUnitUseCase();

  /// Mengeksekusi use case tanpa parameter.
  Future<Either<Failure, Unit>> executeNoParams() => execute(const NoParams());

  /// Memanggil use case tanpa parameter.
  Future<Either<Failure, Unit>> callNoParams() => executeNoParams();
}
