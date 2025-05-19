import 'package:boilerplate/core/domain/error/failures.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/domain/usecase/use_case.dart';
import '../../repository/user/user_repository.dart';

class IsLoggedInUseCase extends NoParamsUseCase<bool> {
  final UserRepository _userRepository;

  IsLoggedInUseCase(this._userRepository);

  @override
  Future<Either<Failure, bool>> execute(NoParams params) async {
    final result = await _userRepository.isLoggedIn;
    return result.fold(
      (failure) => Left(failure),
      (isLoggedIn) => Right(isLoggedIn),
    );
  }
}
