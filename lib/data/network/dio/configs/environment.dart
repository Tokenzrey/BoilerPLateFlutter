/// Enum representing different environments the app can run in
enum EnvironmentType {
  /// Development environment for local testing
  dev,

  /// Testing/QA environment
  staging,

  /// Production environment
  production,
}

/// Class to hold environment-specific configuration values
class Environment {
  /// The base URL of the API for this environment
  final String apiBaseUrl;

  /// The type of this environment
  final EnvironmentType type;

  /// Timeout for API calls in this environment (milliseconds)
  final int apiTimeoutMs;

  /// Whether to enable detailed logging in this environment
  final bool enableLogging;

  /// Creates a new Environment instance
  const Environment({
    required this.apiBaseUrl,
    required this.type,
    this.apiTimeoutMs = 30000,
    this.enableLogging = false,
  });

  /// The current environment (initialized at app startup)
  static late final Environment current;

  /// Initialize the current environment
  static void init({required EnvironmentType environmentType}) {
    current = _getEnvironment(environmentType);
  }

  /// Get environment configuration based on environment type
  static Environment _getEnvironment(EnvironmentType type) {
    switch (type) {
      case EnvironmentType.dev:
        return const Environment(
          apiBaseUrl: 'https://api.comick.fun/',
          type: EnvironmentType.dev,
          apiTimeoutMs: 60000, // Longer timeout for development
          enableLogging: true,
        );
      case EnvironmentType.staging:
        return const Environment(
          apiBaseUrl: 'https://api.comick.fun/',
          type: EnvironmentType.staging,
          apiTimeoutMs: 45000,
          enableLogging: true,
        );
      case EnvironmentType.production:
        return const Environment(
          apiBaseUrl: 'https://api.comick.fun/',
          type: EnvironmentType.production,
          apiTimeoutMs: 30000,
          enableLogging: false, // Disable logging in production
        );
    }
  }

  /// Check if this is the development environment
  bool get isDev => type == EnvironmentType.dev;

  /// Check if this is the staging environment
  bool get isStaging => type == EnvironmentType.staging;

  /// Check if this is the production environment
  bool get isProduction => type == EnvironmentType.production;
}
