import 'network_error.dart';

/// Exception thrown when authentication fails or token is invalid
class UnauthorizedException extends NetworkError {
  /// Whether to attempt automatic token refresh
  final bool shouldAttemptRefresh;

  /// Creates an unauthorized exception
  UnauthorizedException({
    super.message = 'Unauthorized. Please sign in again.',
    this.shouldAttemptRefresh = true,
    super.responseData,
    super.path,
  }) : super(
          code: 'UNAUTHORIZED',
          statusCode: 401,
        );

  /// Factory method for token expired errors
  factory UnauthorizedException.tokenExpired({
    String message = 'Your session has expired. Please sign in again.',
    String? path,
  }) {
    return UnauthorizedException(
      message: message,
      shouldAttemptRefresh: true,
      path: path,
    );
  }

  /// Factory method for invalid credentials
  factory UnauthorizedException.invalidCredentials({
    String message = 'Invalid username or password.',
    String? path,
  }) {
    return UnauthorizedException(
      message: message,
      shouldAttemptRefresh: false,
      path: path,
    );
  }

  /// Factory method for insufficient permissions
  factory UnauthorizedException.insufficientPermissions({
    String message = 'You don\'t have permission to access this resource.',
    String? path,
  }) {
    return UnauthorizedException(
      message: message,
      shouldAttemptRefresh: false,
      path: path,
    );
  }
}
