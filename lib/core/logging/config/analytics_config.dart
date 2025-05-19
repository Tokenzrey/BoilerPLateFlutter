import '../log_level.dart';

class AnalyticsConfig {
  final bool enabled;
  final LogLevel minLevel;
  final Future<void> Function(
          LogLevel level, String message, Map<String, dynamic> metadata)?
      sendToAnalytics;

  const AnalyticsConfig({
    this.enabled = false,
    this.minLevel = LogLevel.error,
    this.sendToAnalytics,
  });
  
  AnalyticsConfig copyWith({
    bool? enabled,
    LogLevel? minLevel,
    Future<void> Function(
            LogLevel level, String message, Map<String, dynamic> metadata)?
        sendToAnalytics,
  }) {
    return AnalyticsConfig(
      enabled: enabled ?? this.enabled,
      minLevel: minLevel ?? this.minLevel,
      sendToAnalytics: sendToAnalytics ?? this.sendToAnalytics,
    );
  }
}
