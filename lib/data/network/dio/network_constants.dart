/// Constants for network configuration
class NetworkConstants {
  /// Header name constants
  static const headers = _Headers();

  /// Content type constants
  static const contentType = _ContentTypes();

  /// Retry configuration constants
  static const retry = _RetryConstants();

  /// Default timeout constants
  static const timeout = _TimeoutConstants();

  /// HTTP status code constants
  static const statusCode = _StatusCodes();

  /// Error message constants
  static const errorMessages = _ErrorMessages();

  /// Private constructor to prevent instantiation
  const NetworkConstants._();
}

/// Header name constants
class _Headers {
  /// Content-Type header
  final String contentType = 'Content-Type';

  /// Accept header
  final String accept = 'Accept';

  /// Authorization header
  final String authorization = 'Authorization';

  /// User-Agent header
  final String userAgent = 'User-Agent';

  /// Cache-Control header
  final String cacheControl = 'Cache-Control';

  /// API Key header
  final String apiKey = 'X-API-Key';

  /// App Version header
  final String appVersion = 'X-App-Version';

  /// Device ID header
  final String deviceId = 'X-Device-ID';

  /// Platform header
  final String platform = 'X-Platform';

  const _Headers();
}

/// Content type constants
class _ContentTypes {
  /// JSON content type
  final String json = 'application/json; charset=utf-8';

  /// Form URL-encoded content type
  final String formUrlEncoded = 'application/x-www-form-urlencoded';

  /// Multipart form data content type
  final String multipartFormData = 'multipart/form-data';

  /// Plain text content type
  final String plainText = 'text/plain; charset=utf-8';

  /// XML content type
  final String xml = 'application/xml';

  const _ContentTypes();
}

/// Retry configuration constants
class _RetryConstants {
  /// Default number of retry attempts
  final int defaultRetries = 3;

  /// Default interval between retries in milliseconds
  final int defaultIntervalMs = 1000;

  /// Maximum number of retries
  final int maxRetries = 5;

  /// Maximum interval between retries in milliseconds
  final int maxIntervalMs = 32000;

  const _RetryConstants();
}

/// Timeout constants
class _TimeoutConstants {
  /// Default connection timeout in milliseconds
  final int connectionMs = 30000;

  /// Default receive timeout in milliseconds
  final int receiveMs = 30000;

  /// Default send timeout in milliseconds
  final int sendMs = 30000;

  /// Short timeout for quick operations in milliseconds
  final int shortMs = 5000;

  /// Long timeout for lengthy operations in milliseconds
  final int longMs = 60000;

  const _TimeoutConstants();
}

/// HTTP status code constants
class _StatusCodes {
  /// 200 OK
  final int ok = 200;

  /// 201 Created
  final int created = 201;

  /// 204 No Content
  final int noContent = 204;

  /// 400 Bad Request
  final int badRequest = 400;

  /// 401 Unauthorized
  final int unauthorized = 401;

  /// 403 Forbidden
  final int forbidden = 403;

  /// 404 Not Found
  final int notFound = 404;

  /// 408 Request Timeout
  final int requestTimeout = 408;

  /// 409 Conflict
  final int conflict = 409;

  /// 422 Unprocessable Entity
  final int unprocessableEntity = 422;

  /// 429 Too Many Requests
  final int tooManyRequests = 429;

  /// 500 Internal Server Error
  final int internalServerError = 500;

  /// 502 Bad Gateway
  final int badGateway = 502;

  /// 503 Service Unavailable
  final int serviceUnavailable = 503;

  /// 504 Gateway Timeout
  final int gatewayTimeout = 504;

  const _StatusCodes();
}

/// Error message templates
class _ErrorMessages {
  /// Generic error message
  final String generic = 'An unexpected error occurred. Please try again.';

  /// No connection error message
  final String noConnection =
      'No internet connection available. Please check your network.';

  /// Timeout error message
  final String timeout = 'The request timed out. Please try again later.';

  /// Server error message
  final String serverError = 'A server error occurred. Please try again later.';

  /// Unauthorized error message
  final String unauthorized =
      'You are not authorized to access this resource. Please sign in.';

  /// Not found error message
  final String notFound = 'The requested resource was not found.';

  /// Validation error message
  final String validation =
      'There are validation errors. Please check your input.';

  /// Rate limit error message
  final String rateLimit = 'Too many requests. Please try again later.';

  /// Request cancelled error message
  final String cancelled = 'Request was cancelled.';

  const _ErrorMessages();
}
