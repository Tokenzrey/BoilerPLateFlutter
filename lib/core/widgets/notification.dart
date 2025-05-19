import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationHelper {
  static Future<void> showNotification({
    required String title,
    required String body,
    String? summary,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: title,
        body: body,
        summary: summary,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}
