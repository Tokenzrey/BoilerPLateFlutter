import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:device_info_plus/device_info_plus.dart';

/// Callback types for notification interactions
typedef NotificationActionCallback = void Function(String? payload);
typedef PermissionStatusCallback = void Function(bool isGranted);
typedef NotificationResponseCallback = void Function(
    NotificationResponse response);

/// Enum representing different notification channels
enum NotificationChannelType {
  general,
  alerts,
  messages,
  updates,
  silent,
  download,
  // New channel types can be added here
}

/// Types of notification attachments
enum NotificationAttachmentType {
  image,
  video,
  audio,
  file,
}

/// Class to represent attachment data
class NotificationAttachment {
  final String identifier;
  final String path;
  final NotificationAttachmentType type;
  final bool isUrl;

  /// Create an attachment from a file path
  const NotificationAttachment.file({
    required this.identifier,
    required this.path,
    this.type = NotificationAttachmentType.file,
  }) : isUrl = false;

  /// Create an attachment from a URL
  const NotificationAttachment.url({
    required this.identifier,
    required this.path,
    this.type = NotificationAttachmentType.image,
  }) : isUrl = true;

  /// Create an image attachment from a file path
  factory NotificationAttachment.imageFile(String path, {String? identifier}) {
    return NotificationAttachment.file(
      identifier:
          identifier ?? 'image_${DateTime.now().millisecondsSinceEpoch}',
      path: path,
      type: NotificationAttachmentType.image,
    );
  }

  /// Create an image attachment from a URL
  factory NotificationAttachment.imageUrl(String url, {String? identifier}) {
    return NotificationAttachment.url(
      identifier:
          identifier ?? 'image_${DateTime.now().millisecondsSinceEpoch}',
      path: url,
      type: NotificationAttachmentType.image,
    );
  }

  /// Create an audio attachment
  factory NotificationAttachment.audio(String path,
      {String? identifier, bool isUrl = false}) {
    return isUrl
        ? NotificationAttachment.url(
            identifier:
                identifier ?? 'audio_${DateTime.now().millisecondsSinceEpoch}',
            path: path,
            type: NotificationAttachmentType.audio,
          )
        : NotificationAttachment.file(
            identifier:
                identifier ?? 'audio_${DateTime.now().millisecondsSinceEpoch}',
            path: path,
            type: NotificationAttachmentType.audio,
          );
  }

  /// Create a video attachment
  factory NotificationAttachment.video(String path,
      {String? identifier, bool isUrl = false}) {
    return isUrl
        ? NotificationAttachment.url(
            identifier:
                identifier ?? 'video_${DateTime.now().millisecondsSinceEpoch}',
            path: path,
            type: NotificationAttachmentType.video,
          )
        : NotificationAttachment.file(
            identifier:
                identifier ?? 'video_${DateTime.now().millisecondsSinceEpoch}',
            path: path,
            type: NotificationAttachmentType.video,
          );
  }
}

/// Class to represent a notification action
class NotificationAction {
  final String id;
  final String title;
  final bool foreground;
  final bool dismissOnAction;
  final bool destructive;
  final bool authRequired;
  final String? icon;
  final NotificationInputOption? input;
  final Color? color;

  const NotificationAction({
    required this.id,
    required this.title,
    this.foreground = true,
    this.dismissOnAction = true,
    this.destructive = false,
    this.authRequired = false,
    this.icon,
    this.input,
    this.color,
  });
}

/// Input option for notification actions
class NotificationInputOption {
  final String placeholder;
  final List<String>? choices;
  final bool allowFreeText;
  final bool allowEmptyText;
  final int? maxLength;

  const NotificationInputOption({
    required this.placeholder,
    this.choices,
    this.allowFreeText = true,
    this.allowEmptyText = false,
    this.maxLength,
  });
}

/// Class to represent an item in a grouped notification
class GroupedNotificationItem {
  final int id;
  final String title;
  final String body;
  final String? payload;
  final NotificationAttachment? attachment;
  final String? icon;
  final NotificationChannelType channelType;
  final bool playSound;
  final String? customSound;
  final List<NotificationAction>? actions;

  const GroupedNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.attachment,
    this.icon,
    this.channelType = NotificationChannelType.general,
    this.playSound = true,
    this.customSound,
    this.actions,
  });
}

/// Config for a notification channel (Android)
class AndroidNotificationChannelDetails {
  final String id;
  final String name;
  final String? description;
  final Importance importance;
  final Priority priority;
  final bool enableVibration;
  final Int64List? vibrationPattern;
  final bool playSound;
  final AndroidNotificationSound? sound;
  final Color? lightColor;
  final bool enableLights;
  final bool showBadge;
  final bool enableBubbles;

  AndroidNotificationChannelDetails(
    this.id,
    this.name, {
    this.description,
    this.importance = Importance.defaultImportance,
    this.priority = Priority.defaultPriority,
    this.enableVibration = true,
    this.vibrationPattern,
    this.playSound = true,
    this.sound,
    this.lightColor,
    this.enableLights = true,
    this.showBadge = true,
    this.enableBubbles = false,
  });
}

/// Log level for the notification service
enum NotificationLogLevel {
  none,
  error,
  warn,
  info,
  verbose,
}

/// Result of a notification operation
class NotificationResult {
  final bool success;
  final String? error;
  final int? notificationId;

  const NotificationResult({
    required this.success,
    this.error,
    this.notificationId,
  });

  factory NotificationResult.success(int notificationId) => NotificationResult(
        success: true,
        notificationId: notificationId,
      );

  factory NotificationResult.error(String error) => NotificationResult(
        success: false,
        error: error,
      );
}

/// Advanced notification service with support for scheduled, repeating, and rich notifications
class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  /// Factory constructor to return the singleton instance
  factory NotificationService() => _instance;

  /// The plugin instance used for local notifications
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Device info plugin for platform-specific features
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Current badge count
  int _badgeCount = 0;

  /// State tracking
  bool _isRequestingPermission = false;
  bool _isInitialized = false;
  NotificationLogLevel _logLevel = NotificationLogLevel.warn;

  /// Callback for notification responses
  NotificationResponseCallback? _onNotificationResponse;

  /// Map of Android notification channels
  final Map<NotificationChannelType, AndroidNotificationChannelDetails>
      _channels = {
    NotificationChannelType.general: AndroidNotificationChannelDetails(
      'general_channel',
      'General',
      description: 'For general notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    NotificationChannelType.alerts: AndroidNotificationChannelDetails(
      'alerts_channel',
      'Alerts',
      description: 'For important alerts and notices',
      importance: Importance.max,
      priority: Priority.high,
      showBadge: true,
    ),
    NotificationChannelType.messages: AndroidNotificationChannelDetails(
      'messages_channel',
      'Messages',
      description: 'For chat and message notifications',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound('message_sound'),
      enableBubbles: true,
    ),
    NotificationChannelType.updates: AndroidNotificationChannelDetails(
      'updates_channel',
      'Updates',
      description: 'For app updates and content changes',
      importance: Importance.low,
      priority: Priority.low,
    ),
    NotificationChannelType.silent: AndroidNotificationChannelDetails(
      'silent_channel',
      'Silent',
      description: 'For background and silent notifications',
      importance: Importance.min,
      priority: Priority.min,
      playSound: false,
      enableVibration: false,
      showBadge: false,
    ),
    NotificationChannelType.download: AndroidNotificationChannelDetails(
      'download_channel',
      'Downloads',
      description: 'For file download progress',
      importance: Importance.low,
      priority: Priority.low,
      enableVibration: false,
      showBadge: true,
    ),
  };

  /// Configure the log level
  void setLogLevel(NotificationLogLevel level) {
    _logLevel = level;
  }

  /// Log a message at the given level
  void _log(String message,
      {NotificationLogLevel level = NotificationLogLevel.info}) {
    if (_logLevel.index >= level.index) {
      final logPrefix = '[NotificationService] ${level.name.toUpperCase()}: ';
      debugPrint('$logPrefix$message');
    }
  }

  /// Initialize the notification service
  ///
  /// This must be called before using any other methods.
  ///
  /// Parameters:
  /// - [onDidReceiveNotificationResponse]: Called when a notification is tapped
  /// - [onDidReceiveBackgroundNotificationResponse]: Called when a notification action is tapped in the background
  /// - [requestPermissions]: Whether to request notification permissions automatically
  /// - [permissionStatusCallback]: Called with the permission status after initialization
  /// - [defaultIcon]: Default notification icon (Android resource name)
  Future<bool> init({
    NotificationResponseCallback? onDidReceiveNotificationResponse,
    void Function(NotificationResponse?)?
        onDidReceiveBackgroundNotificationResponse,
    bool requestPermissions = true,
    PermissionStatusCallback? permissionStatusCallback,
    String defaultIcon = 'ic_appicon',
    NotificationLogLevel logLevel = NotificationLogLevel.warn,
  }) async {
    if (_isInitialized) {
      _log('NotificationService already initialized',
          level: NotificationLogLevel.warn);
      return true;
    }

    _logLevel = logLevel;
    _onNotificationResponse = onDidReceiveNotificationResponse;

    try {
      _log('Initializing notification service',
          level: NotificationLogLevel.info);

      // Initialize timezone data
      tz.initializeTimeZones();

      // Get local timezone
      final String timeZoneName = tz.local.name;
      _log('Local timezone: $timeZoneName', level: NotificationLogLevel.info);

      // Configure platform-specific settings
      final AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings(defaultIcon);

      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        requestCriticalPermission: false,
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
        macOS: iosSettings,
      );

      // Initialize the plugin
      final bool? initResult =
          await _flutterLocalNotificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _log('Received notification response: ${response.payload}',
              level: NotificationLogLevel.info);
          _onNotificationResponse?.call(response);
          onDidReceiveNotificationResponse?.call(response);
        },
        onDidReceiveBackgroundNotificationResponse:
            onDidReceiveBackgroundNotificationResponse,
      );

      if (initResult != true) {
        _log('Failed to initialize notification plugin',
            level: NotificationLogLevel.error);
        return false;
      }

      // Create notification channels on Android
      if (Platform.isAndroid) {
        await _createNotificationChannels();
      }

      // Request permissions if needed
      if (requestPermissions) {
        final bool granted =
            await requestPermission(callback: permissionStatusCallback);
        if (!granted) {
          _log('Notification permissions not granted',
              level: NotificationLogLevel.warn);
          // Continue initialization even if permissions not granted
        }
      }

      _isInitialized = true;
      _log('Notification service initialized successfully',
          level: NotificationLogLevel.info);
      return true;
    } catch (e, stackTrace) {
      _log('Error initializing notification service: $e',
          level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return false;
    }
  }

  /// Update notification settings (channel configuration, icon, etc.)
  Future<bool> updateSettings({
    Map<NotificationChannelType, AndroidNotificationChannelDetails>? channels,
    String? defaultIcon,
    NotificationResponseCallback? onNotificationResponse,
  }) async {
    if (!_isInitialized) {
      _log('NotificationService not initialized',
          level: NotificationLogLevel.error);
      return false;
    }

    try {
      // Update channels if provided
      if (channels != null) {
        _channels.addAll(channels);
        if (Platform.isAndroid) {
          await _updateNotificationChannels(channels.values.toList());
        }
      }

      // Update notification callback if provided
      if (onNotificationResponse != null) {
        _onNotificationResponse = onNotificationResponse;
      }

      return true;
    } catch (e, stackTrace) {
      _log('Error updating notification settings: $e',
          level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return false;
    }
  }

  /// Create notification channels on Android
  Future<void> _createNotificationChannels() async {
    try {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin == null) {
        _log('AndroidFlutterLocalNotificationsPlugin not available',
            level: NotificationLogLevel.error);
        return;
      }

      for (final channelDetails in _channels.values) {
        await androidPlugin.createNotificationChannel(
          AndroidNotificationChannel(
            channelDetails.id,
            channelDetails.name,
            description: channelDetails.description,
            importance: channelDetails.importance,
            playSound: channelDetails.playSound,
            sound: channelDetails.sound,
            enableVibration: channelDetails.enableVibration,
            vibrationPattern: channelDetails.vibrationPattern,
            enableLights: channelDetails.enableLights,
            ledColor: channelDetails.lightColor,
            showBadge: channelDetails.showBadge,
          ),
        );
      }
      _log('Created ${_channels.length} notification channels',
          level: NotificationLogLevel.info);
    } catch (e, stackTrace) {
      _log('Error creating notification channels: $e',
          level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
    }
  }

  /// Update existing notification channels
  Future<void> _updateNotificationChannels(
      List<AndroidNotificationChannelDetails> channels) async {
    try {
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin == null) {
        _log('AndroidFlutterLocalNotificationsPlugin not available',
            level: NotificationLogLevel.error);
        return;
      }

      // On Android, we delete and recreate channels to update them
      for (final channelDetails in channels) {
        // Delete existing channel if it exists
        await androidPlugin.deleteNotificationChannel(channelDetails.id);

        // Create new channel with updated settings
        await androidPlugin.createNotificationChannel(
          AndroidNotificationChannel(
            channelDetails.id,
            channelDetails.name,
            description: channelDetails.description,
            importance: channelDetails.importance,
            playSound: channelDetails.playSound,
            sound: channelDetails.sound,
            enableVibration: channelDetails.enableVibration,
            vibrationPattern: channelDetails.vibrationPattern,
            enableLights: channelDetails.enableLights,
            ledColor: channelDetails.lightColor,
            showBadge: channelDetails.showBadge,
          ),
        );
      }
      _log('Updated ${channels.length} notification channels',
          level: NotificationLogLevel.info);
    } catch (e, stackTrace) {
      _log('Error updating notification channels: $e',
          level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
    }
  }

  /// Request notification permission with the appropriate approach based on platform and version
  Future<bool> requestPermission({
    PermissionStatusCallback? callback,
  }) async {
    if (_isRequestingPermission) {
      _log('Already requesting permission', level: NotificationLogLevel.warn);
      return false;
    }

    _isRequestingPermission = true;
    bool isGranted = false;

    try {
      if (Platform.isAndroid) {
        // Check Android version for appropriate permission request strategy
        final androidInfo = await _deviceInfo.androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 33) {
          // Android 13 (API level 33) and above
          // Use post-notifications permission for Android 13+
          final status = await Permission.notification.request();
          isGranted = status.isGranted;
          _log('Android 13+ notification permission status: $status',
              level: NotificationLogLevel.info);
        } else {
          // For older Android versions, permission is granted during app install
          final status = await Permission.notification.status;
          isGranted = status.isGranted;
          _log('Android notification permission status: $status',
              level: NotificationLogLevel.info);
        }
      } else if (Platform.isIOS) {
        // Request iOS permissions
        final iosPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        if (iosPlugin != null) {
          isGranted = await iosPlugin.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
                critical: false,
              ) ??
              false;
          _log('iOS notification permission status: $isGranted',
              level: NotificationLogLevel.info);
        }
      }

      // Call the callback with result
      callback?.call(isGranted);
      return isGranted;
    } catch (e, stackTrace) {
      _log('Error requesting notification permissions: $e',
          level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      callback?.call(false);
      return false;
    } finally {
      _isRequestingPermission = false;
    }
  }

  /// Check the current notification permission status
  Future<bool> checkPermission() async {
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final status = await Permission.notification.status;
        return status.isGranted;
      }
      return false;
    } catch (e) {
      _log('Error checking notification permissions: $e',
          level: NotificationLogLevel.error);
      return false;
    }
  }

  /// Convert a file URI to a file path
  String _normalizeFilePath(String path) {
    if (path.startsWith('file://')) {
      return path.replaceFirst('file://', '');
    }
    return path;
  }

  /// Process an attachment (download if it's a URL)
  Future<String?> _processAttachment(NotificationAttachment attachment) async {
    try {
      if (!attachment.isUrl) {
        return _normalizeFilePath(attachment.path);
      }

      // Download from URL
      final response = await http.get(Uri.parse(attachment.path));
      if (response.statusCode != 200) {
        _log('Failed to download attachment: ${response.statusCode}',
            level: NotificationLogLevel.error);
        return null;
      }

      // Get temporary directory to save downloaded file
      final directory = await getTemporaryDirectory();

      // Generate a unique filename
      final extension = attachment.path.split('.').last;
      final filename =
          '${attachment.identifier}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '${directory.path}/$filename';

      // Save file
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      _log('Downloaded attachment to $filePath',
          level: NotificationLogLevel.info);
      return filePath;
    } catch (e, stackTrace) {
      _log('Error processing attachment: $e',
          level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return null;
    }
  }

  /// Load an image asset as a bitmap
  Future<Uint8List> _getImageBitmapFromAsset(String assetPath) async {
    try {
      final ByteData data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e, stackTrace) {
      _log('Error loading asset: $e', level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return Uint8List(0);
    }
  }

  /// Get the big picture style information for notifications
  Future<BigPictureStyleInformation?> _getBigPictureStyleInformation(
      NotificationAttachment attachment) async {
    try {
      AndroidBitmap<Object>? largeIcon;
      AndroidBitmap<Object>? bigPicture;

      // Process attachment based on its source
      final String? processedPath = await _processAttachment(attachment);

      if (processedPath == null) {
        _log('Failed to process image attachment',
            level: NotificationLogLevel.error);
        return null;
      }

      if (attachment.isUrl) {
        // For downloaded URLs, we now have a file path
        final imageBytes = await File(processedPath).readAsBytes();
        largeIcon = ByteArrayAndroidBitmap(imageBytes);
        bigPicture = ByteArrayAndroidBitmap(imageBytes);
      } else if (processedPath.startsWith('asset')) {
        // Asset path
        final imageBytes = await _getImageBitmapFromAsset(
            processedPath.replaceFirst('asset://', ''));
        largeIcon = ByteArrayAndroidBitmap(imageBytes);
        bigPicture = ByteArrayAndroidBitmap(imageBytes);
      } else {
        // File path
        final imageBytes = await File(processedPath).readAsBytes();
        largeIcon = ByteArrayAndroidBitmap(imageBytes);
        bigPicture = ByteArrayAndroidBitmap(imageBytes);
      }

      return BigPictureStyleInformation(
        bigPicture,
        largeIcon: largeIcon,
        contentTitle: 'Expanded title',
        htmlFormatContentTitle: true,
        summaryText: 'Expanded body',
        htmlFormatSummaryText: true,
      );
    } catch (e, stackTrace) {
      _log('Error creating big picture style: $e',
          level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return null;
    }
  }

  /// Process attachments for iOS
  Future<List<DarwinNotificationAttachment>?> _processIOSAttachments(
      NotificationAttachment attachment) async {
    try {
      final String? processedPath = await _processAttachment(attachment);

      if (processedPath == null) {
        _log('Failed to process iOS attachment',
            level: NotificationLogLevel.error);
        return null;
      }

      final List<DarwinNotificationAttachment> attachments = [];

      // Create appropriate identifier based on attachment type
      String identifier;
      switch (attachment.type) {
        case NotificationAttachmentType.image:
          identifier = 'image';
          break;
        case NotificationAttachmentType.video:
          identifier = 'video';
          break;
        case NotificationAttachmentType.audio:
          identifier = 'audio';
          break;
        case NotificationAttachmentType.file:
          identifier = 'file';
          break;
      }

      attachments.add(DarwinNotificationAttachment(
        processedPath,
        identifier: identifier,
      ));

      return attachments;
    } catch (e, stackTrace) {
      _log('Error processing iOS attachments: $e',
          level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return null;
    }
  }

  /// Convert icon string to AndroidBitmap if needed
  AndroidBitmap<Object>? _createAndroidBitmap(String? iconPath) {
    if (iconPath == null) return null;
    return DrawableResourceAndroidBitmap(iconPath);
  }

  /// Show a basic notification
  Future<NotificationResult> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    NotificationAttachment? attachment,
    bool useCustomSound = false,
    String? customSound,
    String? icon,
    bool autoDismiss = true,
    Color? color,
    bool? showWhen,
    List<NotificationAction>? actions,
    int? badgeNumber,
    bool? playSound,
  }) async {
    if (!_isInitialized) {
      return NotificationResult.error('NotificationService not initialized');
    }

    try {
      final AndroidNotificationChannelDetails channelDetails =
          _channels[channelType] ?? _channels[NotificationChannelType.general]!;

      // Process Android notification details
      AndroidNotificationDetails? androidDetails;
      if (Platform.isAndroid) {
        BigPictureStyleInformation? bigPictureStyle;

        // Process big picture style if attachment is provided
        if (attachment != null &&
            attachment.type == NotificationAttachmentType.image) {
          bigPictureStyle = await _getBigPictureStyleInformation(attachment);
        }

        // Build Android notification details
        androidDetails = AndroidNotificationDetails(
          channelDetails.id,
          channelDetails.name,
          channelDescription: channelDetails.description,
          importance: channelDetails.importance,
          priority: channelDetails.priority,
          enableVibration: channelDetails.enableVibration,
          vibrationPattern: channelDetails.vibrationPattern,
          playSound: playSound ?? channelDetails.playSound,
          sound: useCustomSound && customSound != null
              ? RawResourceAndroidNotificationSound(customSound)
              : channelDetails.sound,
          icon: icon ?? 'ic_appicon',
          largeIcon: icon != null ? _createAndroidBitmap(icon) : null,
          styleInformation: bigPictureStyle,
          autoCancel: autoDismiss,
          color: color,
          showWhen: showWhen ?? true,
          usesChronometer: false,
        );

        // Add actions if provided
        if (actions != null && actions.isNotEmpty) {
          final androidActions = <AndroidNotificationAction>[];
          for (final action in actions) {
            List<AndroidNotificationActionInput> inputs = [];
            if (action.input != null) {
              inputs = <AndroidNotificationActionInput>[
                AndroidNotificationActionInput(
                  choices: action.input!.choices ?? [],
                  allowFreeFormInput: action.input!.allowFreeText,
                  label: action.input!.placeholder,
                )
              ];
            }

            androidActions.add(
              AndroidNotificationAction(
                action.id,
                action.title,
                icon: action.icon != null
                    ? DrawableResourceAndroidBitmap(action.icon!)
                    : null,
                showsUserInterface: action.foreground,
                cancelNotification: action.dismissOnAction,
                contextual: false,
                allowGeneratedReplies: false,
                inputs: inputs,
              ),
            );
          }

          // If the version supports it, set the actions
          if (androidActions.isNotEmpty) {
            androidDetails = androidDetails.copyWith(
              actions: androidActions,
            );
          }
        }
      }

      // Process iOS/macOS notification details
      DarwinNotificationDetails? darwinDetails;
      if (Platform.isIOS || Platform.isMacOS) {
        List<DarwinNotificationAttachment>? iosAttachments;

        // Process attachments for iOS
        if (attachment != null) {
          iosAttachments = await _processIOSAttachments(attachment);
        }

        // Build iOS notification details
        darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: playSound ?? channelDetails.playSound,
          sound: useCustomSound && customSound != null ? customSound : null,
          attachments: iosAttachments,
          badgeNumber: badgeNumber,
          categoryIdentifier: actions != null ? 'actionable' : null,
          interruptionLevel: channelDetails.importance == Importance.high ||
                  channelDetails.importance == Importance.max
              ? InterruptionLevel.timeSensitive
              : InterruptionLevel.active,
        );
      }

      // Create platform-specific notification details
      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      // Show the notification
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );

      // Update badge count if provided
      if (badgeNumber != null) {
        await updateBadgeCount(badgeNumber);
      }

      return NotificationResult.success(id);
    } catch (e, stackTrace) {
      final error = 'Error showing notification: $e';
      _log(error, level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return NotificationResult.error(error);
    }
  }

  /// Show a notification with actions
  Future<NotificationResult> showNotificationWithActions({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    required List<NotificationAction> actions,
    NotificationAttachment? attachment,
    String? icon,
    bool autoDismiss = true,
    Color? color,
    int? badgeNumber,
  }) async {
    return showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channelType: channelType,
      attachment: attachment,
      icon: icon,
      autoDismiss: autoDismiss,
      color: color,
      actions: actions,
      badgeNumber: badgeNumber,
    );
  }

  /// Schedule a notification
  Future<NotificationResult> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    bool allowWhileIdle = false,
    NotificationAttachment? attachment,
    String? customSound,
    bool useCustomSound = false,
    String? icon,
    int? badgeNumber,
    bool precise = false,
    List<NotificationAction>? actions,
    bool useTz = true,
  }) async {
    if (!_isInitialized) {
      return NotificationResult.error('NotificationService not initialized');
    }

    try {
      final AndroidNotificationChannelDetails channelDetails =
          _channels[channelType] ?? _channels[NotificationChannelType.general]!;

      // Process Android notification details
      AndroidNotificationDetails? androidDetails;
      if (Platform.isAndroid) {
        BigPictureStyleInformation? bigPictureStyle;

        // Process big picture style if attachment is provided
        if (attachment != null &&
            attachment.type == NotificationAttachmentType.image) {
          bigPictureStyle = await _getBigPictureStyleInformation(attachment);
        }

        // Build Android notification details
        androidDetails = AndroidNotificationDetails(
          channelDetails.id,
          channelDetails.name,
          channelDescription: channelDetails.description,
          importance: channelDetails.importance,
          priority: channelDetails.priority,
          enableVibration: channelDetails.enableVibration,
          vibrationPattern: channelDetails.vibrationPattern,
          playSound: channelDetails.playSound,
          sound: useCustomSound && customSound != null
              ? RawResourceAndroidNotificationSound(customSound)
              : channelDetails.sound,
          icon: icon ?? 'ic_appicon',
          largeIcon: icon != null ? _createAndroidBitmap(icon) : null,
          styleInformation: bigPictureStyle,
        );

        // Add actions if provided
        if (actions != null && actions.isNotEmpty) {
          final androidActions = <AndroidNotificationAction>[];
          for (final action in actions) {
            List<AndroidNotificationActionInput>? inputs;
            if (action.input != null) {
              inputs = <AndroidNotificationActionInput>[
                AndroidNotificationActionInput(
                  choices: action.input!.choices ?? [],
                  allowFreeFormInput: action.input!.allowFreeText,
                  label: action.input!.placeholder,
                )
              ];
            }

            androidActions.add(
              AndroidNotificationAction(
                action.id,
                action.title,
                icon: action.icon != null
                    ? DrawableResourceAndroidBitmap(action.icon!)
                    : null,
                showsUserInterface: action.foreground,
                cancelNotification: action.dismissOnAction,
                contextual: false,
                allowGeneratedReplies: false,
                inputs: inputs ?? <AndroidNotificationActionInput>[],
              ),
            );
          }

          // If the version supports it, set the actions
          if (androidActions.isNotEmpty) {
            androidDetails = androidDetails.copyWith(
              actions: androidActions,
            );
          }
        }
      }

      // Process iOS/macOS notification details
      DarwinNotificationDetails? darwinDetails;
      if (Platform.isIOS || Platform.isMacOS) {
        List<DarwinNotificationAttachment>? iosAttachments;

        // Process attachments for iOS
        if (attachment != null) {
          iosAttachments = await _processIOSAttachments(attachment);
        }

        // Build iOS notification details
        darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: channelDetails.playSound,
          sound: useCustomSound && customSound != null ? customSound : null,
          attachments: iosAttachments,
          badgeNumber: badgeNumber,
          categoryIdentifier: actions != null ? 'actionable' : null,
        );
      }

      // Create platform-specific notification details
      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      // Use timezone-aware scheduling
      final tz.TZDateTime scheduledTzDate = useTz
          ? tz.TZDateTime.from(scheduledDate, tz.local)
          : tz.TZDateTime.from(scheduledDate, tz.UTC);

      // Schedule the notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzDate,
        platformDetails,
        androidScheduleMode: precise
            ? (allowWhileIdle
                ? AndroidScheduleMode.exactAllowWhileIdle
                : AndroidScheduleMode.exact)
            : AndroidScheduleMode.inexactAllowWhileIdle,
        payload: payload,
        matchDateTimeComponents: null, // For one-off schedule
      );

      // Update badge count if provided
      if (badgeNumber != null) {
        await updateBadgeCount(badgeNumber);
      }

      return NotificationResult.success(id);
    } catch (e, stackTrace) {
      final error = 'Error scheduling notification: $e';
      _log(error, level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return NotificationResult.error(error);
    }
  }

  /// Show a recurring notification
  Future<NotificationResult> showPeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval interval,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.general,
    String? customSound,
    bool useCustomSound = false,
    String? icon,
    NotificationAttachment? attachment,
    int? badgeNumber,
    bool allowWhileIdle = false,
    List<NotificationAction>? actions,
  }) async {
    if (!_isInitialized) {
      return NotificationResult.error('NotificationService not initialized');
    }

    try {
      final AndroidNotificationChannelDetails channelDetails =
          _channels[channelType] ?? _channels[NotificationChannelType.general]!;

      // Process Android notification details
      AndroidNotificationDetails? androidDetails;
      if (Platform.isAndroid) {
        BigPictureStyleInformation? bigPictureStyle;

        // Process big picture style if attachment is provided
        if (attachment != null &&
            attachment.type == NotificationAttachmentType.image) {
          bigPictureStyle = await _getBigPictureStyleInformation(attachment);
        }

        // Build Android notification details
        androidDetails = AndroidNotificationDetails(
          channelDetails.id,
          channelDetails.name,
          channelDescription: channelDetails.description,
          importance: channelDetails.importance,
          priority: channelDetails.priority,
          enableVibration: channelDetails.enableVibration,
          vibrationPattern: channelDetails.vibrationPattern,
          playSound: channelDetails.playSound,
          sound: useCustomSound && customSound != null
              ? RawResourceAndroidNotificationSound(customSound)
              : channelDetails.sound,
          icon: icon ?? 'ic_appicon',
          largeIcon: icon != null ? _createAndroidBitmap(icon) : null,
          styleInformation: bigPictureStyle,
        );

        // Add actions if provided
        if (actions != null && actions.isNotEmpty) {
          final androidActions = <AndroidNotificationAction>[];
          for (final action in actions) {
            List<AndroidNotificationActionInput>? inputs;
            if (action.input != null) {
              inputs = <AndroidNotificationActionInput>[
                AndroidNotificationActionInput(
                  choices: action.input!.choices ?? [],
                  allowFreeFormInput: action.input!.allowFreeText,
                  label: action.input!.placeholder,
                )
              ];
            }

            androidActions.add(
              AndroidNotificationAction(
                action.id,
                action.title,
                icon: action.icon != null
                    ? DrawableResourceAndroidBitmap(action.icon!)
                    : null,
                showsUserInterface: action.foreground,
                cancelNotification: action.dismissOnAction,
                contextual: false,
                allowGeneratedReplies: false,
                inputs: inputs ?? <AndroidNotificationActionInput>[],
              ),
            );
          }

          // If the version supports it, set the actions
          if (androidActions.isNotEmpty) {
            androidDetails = androidDetails.copyWith(
              actions: androidActions,
            );
          }
        }
      }

      // Process iOS/macOS notification details
      DarwinNotificationDetails? darwinDetails;
      if (Platform.isIOS || Platform.isMacOS) {
        List<DarwinNotificationAttachment>? iosAttachments;

        // Process attachments for iOS
        if (attachment != null) {
          iosAttachments = await _processIOSAttachments(attachment);
        }

        // Build iOS notification details
        darwinDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: channelDetails.playSound,
          sound: useCustomSound && customSound != null ? customSound : null,
          attachments: iosAttachments,
          badgeNumber: badgeNumber,
          categoryIdentifier: actions != null ? 'actionable' : null,
        );
      }

      // Create platform-specific notification details
      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      // Show periodic notification
      await _flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        interval,
        platformDetails,
        androidScheduleMode: allowWhileIdle
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexact,
        payload: payload,
      );

      // Update badge count if provided
      if (badgeNumber != null) {
        await updateBadgeCount(badgeNumber);
      }

      return NotificationResult.success(id);
    } catch (e, stackTrace) {
      final error = 'Error showing periodic notification: $e';
      _log(error, level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return NotificationResult.error(error);
    }
  }

  /// Show a progress notification (for downloads, etc.)
  Future<NotificationResult> showProgressNotification({
    required int id,
    required String title,
    required String body,
    required int progress,
    required int maxProgress,
    bool indeterminate = false,
    String? payload,
    NotificationChannelType channelType = NotificationChannelType.download,
    String? icon,
    bool onlyAlertOnce = true,
    bool autoDismiss = false,
  }) async {
    if (!_isInitialized) {
      return NotificationResult.error('NotificationService not initialized');
    }

    try {
      final AndroidNotificationChannelDetails channelDetails =
          _channels[channelType] ??
              _channels[NotificationChannelType.download]!;

      // Android-only feature
      if (Platform.isAndroid) {
        final androidDetails = AndroidNotificationDetails(
          channelDetails.id,
          channelDetails.name,
          channelDescription: channelDetails.description,
          importance: channelDetails.importance,
          priority: channelDetails.priority,
          enableVibration: channelDetails.enableVibration,
          icon: icon ?? 'ic_appicon',
          showProgress: true,
          maxProgress: maxProgress,
          progress: progress,
          indeterminate: indeterminate,
          onlyAlertOnce: onlyAlertOnce,
          autoCancel: autoDismiss,
          channelShowBadge: channelDetails.showBadge,
          playSound: false, // Usually no sound for progress updates
        );

        final NotificationDetails platformDetails = NotificationDetails(
          android: androidDetails,
        );

        await _flutterLocalNotificationsPlugin.show(
          id,
          title,
          body,
          platformDetails,
          payload: payload,
        );

        return NotificationResult.success(id);
      } else {
        // For iOS, we can't show progress directly, so just show a regular notification
        return showNotification(
          id: id,
          title: title,
          body: '$body - ${(progress / maxProgress * 100).round()}%',
          payload: payload,
          channelType: channelType,
          icon: icon,
        );
      }
    } catch (e, stackTrace) {
      final error = 'Error showing progress notification: $e';
      _log(error, level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return NotificationResult.error(error);
    }
  }

  /// Show grouped notifications
  Future<NotificationResult> showGroupedNotifications({
    required String groupKey,
    required List<GroupedNotificationItem> notifications,
    required String summaryTitle,
    required String summaryBody,
    NotificationChannelType channelType = NotificationChannelType.general,
    int? badgeNumber,
  }) async {
    if (!_isInitialized) {
      return NotificationResult.error('NotificationService not initialized');
    }

    try {
      final AndroidNotificationChannelDetails channelDetails =
          _channels[channelType] ?? _channels[NotificationChannelType.general]!;

      // Show individual notifications
      for (int i = 0; i < notifications.length; i++) {
        final item = notifications[i];

        // Process Android notification details
        AndroidNotificationDetails? androidDetails;
        if (Platform.isAndroid) {
          BigPictureStyleInformation? bigPictureStyle;

          // Process big picture style if attachment is provided
          if (item.attachment != null &&
              item.attachment!.type == NotificationAttachmentType.image) {
            bigPictureStyle =
                await _getBigPictureStyleInformation(item.attachment!);
          }

          // Build Android notification details for individual item
          androidDetails = AndroidNotificationDetails(
            channelDetails.id,
            channelDetails.name,
            channelDescription: channelDetails.description,
            importance: channelDetails.importance,
            priority: channelDetails.priority,
            groupKey: groupKey,
            setAsGroupSummary: false,
            icon: item.icon ?? 'ic_appicon',
            styleInformation: bigPictureStyle,
            playSound: item.playSound,
            sound: item.customSound != null
                ? RawResourceAndroidNotificationSound(item.customSound!)
                : channelDetails.sound,
          );

          // Add actions if provided
          if (item.actions != null && item.actions!.isNotEmpty) {
            final androidActions = <AndroidNotificationAction>[];
            for (final action in item.actions!) {
              List<AndroidNotificationActionInput>? inputs;
              if (action.input != null) {
                inputs = <AndroidNotificationActionInput>[
                  AndroidNotificationActionInput(
                    choices: action.input!.choices ?? [],
                    allowFreeFormInput: action.input!.allowFreeText,
                    label: action.input!.placeholder,
                  )
                ];
              }

              androidActions.add(
                AndroidNotificationAction(
                  action.id,
                  action.title,
                  icon: action.icon != null
                      ? DrawableResourceAndroidBitmap(action.icon!)
                      : null,
                  showsUserInterface: action.foreground,
                  cancelNotification: action.dismissOnAction,
                  contextual: false,
                  allowGeneratedReplies: false,
                  inputs: inputs ?? <AndroidNotificationActionInput>[],
                ),
              );
            }

            // If the version supports it, set the actions
            if (androidActions.isNotEmpty) {
              androidDetails = androidDetails.copyWith(
                actions: androidActions,
              );
            }
          }
        }

        // Process iOS/macOS notification details
        DarwinNotificationDetails? darwinDetails;
        if (Platform.isIOS || Platform.isMacOS) {
          List<DarwinNotificationAttachment>? iosAttachments;

          // Process attachments for iOS
          if (item.attachment != null) {
            iosAttachments = await _processIOSAttachments(item.attachment!);
          }

          // Build iOS notification details for individual item
          darwinDetails = DarwinNotificationDetails(
            threadIdentifier: groupKey,
            presentAlert: true,
            presentBadge: true,
            presentSound: item.playSound,
            sound: item.customSound,
            attachments: iosAttachments,
            categoryIdentifier: item.actions != null ? 'actionable' : null,
          );
        }

        // Create platform-specific notification details for individual item
        final NotificationDetails details = NotificationDetails(
          android: androidDetails,
          iOS: darwinDetails,
          macOS: darwinDetails,
        );

        // Show individual notification
        await _flutterLocalNotificationsPlugin.show(
          item.id,
          item.title,
          item.body,
          details,
          payload: item.payload,
        );
      }

      // Create and show summary notification (Android-specific)
      if (Platform.isAndroid) {
        final androidSummaryDetails = AndroidNotificationDetails(
          channelDetails.id,
          channelDetails.name,
          channelDescription: channelDetails.description,
          importance: channelDetails.importance,
          priority: channelDetails.priority,
          groupKey: groupKey,
          setAsGroupSummary: true,
          icon: 'ic_appicon',
        );

        final NotificationDetails summaryDetails = NotificationDetails(
          android: androidSummaryDetails,
        );

        await _flutterLocalNotificationsPlugin.show(
          0, // Summary ID is typically 0
          summaryTitle,
          summaryBody,
          summaryDetails,
        );
      }

      // Update badge count if provided
      if (badgeNumber != null) {
        await updateBadgeCount(badgeNumber);
      } else if (badgeNumber == null && notifications.isNotEmpty) {
        // If no badge number is provided, use the count of notifications
        await updateBadgeCount(notifications.length);
      }

      return NotificationResult.success(0);
    } catch (e, stackTrace) {
      final error = 'Error showing grouped notifications: $e';
      _log(error, level: NotificationLogLevel.error);
      _log('Stack trace: $stackTrace', level: NotificationLogLevel.verbose);
      return NotificationResult.error(error);
    }
  }

  /// Show a silent notification that doesn't appear in the notification tray
  Future<NotificationResult> showSilentNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    return showNotification(
      id: id,
      title: title,
      body: body,
      payload: payload,
      channelType: NotificationChannelType.silent,
      playSound: false,
    );
  }

  /// Update the badge count
  Future<bool> updateBadgeCount(int count) async {
    try {
      _badgeCount = count;

      if (Platform.isIOS || Platform.isMacOS) {
        final darwinPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        if (darwinPlugin != null) {
          // For newer versions of the plugin, we can use setBadgeCount
          // Check if the method exists via reflection
          try {
            await darwinPlugin.setBadgeCount(count);
            _log('Updated iOS badge count to $count using setBadgeCount',
                level: NotificationLogLevel.info);
            return true;
          } catch (e) {
            _log(
                'setBadgeCount method not available, badge count may not be updated on iOS',
                level: NotificationLogLevel.warn);
            // Continue to use alternative methods or just track locally
          }
        }
      }

      // On Android, badge count is typically shown via ShortcutBadger or similar,
      // which is handled internally by the plugin

      return true;
    } catch (e) {
      _log('Error updating badge count: $e', level: NotificationLogLevel.error);
      return false;
    }
  }

  /// Get the current badge count
  int getBadgeCount() => _badgeCount;

  /// Reset the badge count to zero
  Future<bool> resetBadgeCount() => updateBadgeCount(0);

  /// Cancel a specific notification by ID
  Future<bool> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      _log('Cancelled notification with ID $id',
          level: NotificationLogLevel.info);
      return true;
    } catch (e) {
      _log('Error cancelling notification: $e',
          level: NotificationLogLevel.error);
      return false;
    }
  }

  /// Cancel all notifications from a specific channel
  Future<bool> cancelNotificationsByChannel(
      NotificationChannelType channelType) async {
    try {
      if (Platform.isAndroid) {
        final androidPlugin = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidPlugin != null) {
          final channelDetails = _channels[channelType];
          if (channelDetails != null) {
            try {
              // Instead of using a direct method, we need to use the available API
              // Check for notification channels and delete notifications by channel ID
              await _flutterLocalNotificationsPlugin.cancelAll();
              _log(
                  'Cancelled all notifications (including those from channel ${channelDetails.name})',
                  level: NotificationLogLevel.info);
              return true;
            } catch (e) {
              _log('Error cancelling notifications by channel: $e',
                  level: NotificationLogLevel.error);
              return false;
            }
          }
        }
      }

      // iOS doesn't support cancelling by channel, so we would need to track notification IDs
      // by channel to implement this feature properly

      _log(
          'Cancelling notifications by channel not fully supported on this platform',
          level: NotificationLogLevel.warn);
      return false;
    } catch (e) {
      _log('Error cancelling notifications by channel: $e',
          level: NotificationLogLevel.error);
      return false;
    }
  }

  /// Cancel all notifications
  Future<bool> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      _log('Cancelled all notifications', level: NotificationLogLevel.info);

      // Reset badge count
      await resetBadgeCount();

      return true;
    } catch (e) {
      _log('Error cancelling all notifications: $e',
          level: NotificationLogLevel.error);
      return false;
    }
  }

  /// Get all pending notification requests
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      _log('Error getting pending notifications: $e',
          level: NotificationLogLevel.error);
      return [];
    }
  }

  /// Get the app launch details (was the app opened from a notification?)
  Future<NotificationAppLaunchDetails?> getAppLaunchDetails() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .getNotificationAppLaunchDetails();
    } catch (e) {
      _log('Error getting app launch details: $e',
          level: NotificationLogLevel.error);
      return null;
    }
  }

  /// Get the current notification settings (permission status) on iOS
  Future<bool> requestIOSPermissions({
    bool alert = true,
    bool badge = true,
    bool sound = true,
    bool critical = false,
    bool provisional = false,
  }) async {
    if (!Platform.isIOS) return false;

    try {
      final iosPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      if (iosPlugin != null) {
        final result = await iosPlugin.requestPermissions(
          alert: alert,
          badge: badge,
          sound: sound,
          critical: critical,
          provisional: provisional,
        );

        _log('iOS notification permissions result: $result',
            level: NotificationLogLevel.info);
        return result ?? false;
      }

      return false;
    } catch (e) {
      _log('Error requesting iOS permissions: $e',
          level: NotificationLogLevel.error);
      return false;
    }
  }
}

/// Extension for IOSFlutterLocalNotificationsPlugin to add badge count functionality
extension IOSFlutterLocalNotificationsPluginExtension
    on IOSFlutterLocalNotificationsPlugin {
  /// Sets the application badge number on iOS devices
  ///
  /// This method allows setting the badge count that appears on the app icon
  /// Returns true if successful, false otherwise
  Future<bool> setBadgeCount(int count) async {
    try {
      // Use the platform channel to communicate with iOS native code
      final Map<String, dynamic> arguments = <String, dynamic>{'count': count};
      await const MethodChannel('dexterous.com/flutter/local_notifications')
          .invokeMethod<void>('setBadgeCount', arguments);
      return true;
    } catch (e) {
      debugPrint('Error setting badge count: $e');
      return false;
    }
  }
}

/// Extension for AndroidNotificationDetails to add copyWith functionality for actions
extension AndroidNotificationDetailsExtension on AndroidNotificationDetails {
  /// Creates a copy of this AndroidNotificationDetails instance with the given fields replaced with new values
  ///
  /// [actions] The notification actions to be included in the notification
  AndroidNotificationDetails copyWith({
    required List<AndroidNotificationAction> actions,
    String? icon,
    Int64List? vibrationPattern,
    AndroidNotificationChannelAction? channelAction,
    bool? showProgress,
    int? maxProgress,
    int? progress,
    bool? indeterminate,
    bool? channelShowBadge,
    bool? autoCancel,
    bool? ongoing,
    bool? onlyAlertOnce,
    Color? color,
    AndroidBitmap<Object>? largeIcon,
    String? largeIconBitmapSource,
    AndroidNotificationStyle? style,
    StyleInformation? styleInformation,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      icon: icon ?? this.icon,
      importance: importance,
      priority: priority,
      styleInformation: styleInformation ?? this.styleInformation,
      playSound: playSound,
      sound: sound,
      enableVibration: enableVibration,
      vibrationPattern: vibrationPattern ?? this.vibrationPattern,
      groupKey: groupKey,
      setAsGroupSummary: setAsGroupSummary,
      autoCancel: autoCancel ?? this.autoCancel,
      ongoing: ongoing ?? this.ongoing,
      color: color ?? this.color,
      largeIcon: largeIcon ?? this.largeIcon,
      onlyAlertOnce: onlyAlertOnce ?? this.onlyAlertOnce,
      showProgress: showProgress ?? this.showProgress,
      maxProgress: maxProgress ?? this.maxProgress,
      progress: progress ?? this.progress,
      indeterminate: indeterminate ?? this.indeterminate,
      channelShowBadge: channelShowBadge ?? this.channelShowBadge,
      showWhen: showWhen,
      usesChronometer: usesChronometer,
      chronometerCountDown: chronometerCountDown,
      channelAction:
          channelAction ?? AndroidNotificationChannelAction.createIfNotExists,
      enableLights: enableLights,
      ledColor: ledColor,
      ledOnMs: ledOnMs,
      ledOffMs: ledOffMs,
      ticker: ticker,
      visibility: visibility,
      timeoutAfter: timeoutAfter,
      category: category,
      fullScreenIntent: fullScreenIntent,
      shortcutId: shortcutId,
      subText: subText,
      tag: tag,
      colorized: colorized,
      number: number,
      audioAttributesUsage: audioAttributesUsage,
      actions: actions,
    );
  }
}
