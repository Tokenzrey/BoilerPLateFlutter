import 'package:boilerplate/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/notification.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';

class NotificationSandbox extends StatefulWidget {
  const NotificationSandbox({super.key});

  @override
  State<NotificationSandbox> createState() => _NotificationSandboxState();
}

class _NotificationSandboxState extends State<NotificationSandbox> {
  final NotificationService _notificationService = getIt<NotificationService>();

  bool _hasPermission = false;
  String _lastAction = "None";
  int _notificationCount = 0;
  int _lastNotificationId = 0;

  // Form controllers
  final TextEditingController _titleController =
      TextEditingController(text: "Test Notification");
  final TextEditingController _bodyController =
      TextEditingController(text: "This is a notification body");
  final TextEditingController _imageUrlController =
      TextEditingController(text: "https://picsum.photos/200");

  // Selected options
  NotificationChannelType _selectedChannel = NotificationChannelType.general;
  bool _useAttachment = false;
  DateTime _scheduledDate = DateTime.now().add(const Duration(minutes: 1));
  int _progressValue = 50;

  @override
  void initState() {
    super.initState();
    _initializeNotification(); // Pastikan init service dilakukan DI (sekali di awal App)
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _initializeNotification() async {
    // Tidak perlu init lagi jika sudah di service_locator (cukup cek permission saja)
    final granted = await _notificationService.checkPermission();
    setState(() {
      _hasPermission = granted;
    });
  }

  Future<void> _showBasicNotification() async {
    final id = _getNextNotificationId();
    final result = await _notificationService.showNotification(
      id: id,
      title: _titleController.text,
      body: _bodyController.text,
      payload: "basic_notification_$id",
      channelType: _selectedChannel,
      attachment: _useAttachment
          ? NotificationAttachment.imageUrl(_imageUrlController.text)
          : null,
    );
    _handleNotificationResult(result);
  }

  Future<void> _showNotificationWithActions() async {
    final id = _getNextNotificationId();
    final result = await _notificationService.showNotificationWithActions(
      id: id,
      title: _titleController.text,
      body: _bodyController.text,
      payload: "action_notification_$id",
      channelType: _selectedChannel,
      attachment: _useAttachment
          ? NotificationAttachment.imageUrl(_imageUrlController.text)
          : null,
      actions: [
        NotificationAction(
          id: 'accept',
          title: 'Accept',
          icon: 'ic_done',
        ),
        NotificationAction(
          id: 'decline',
          title: 'Decline',
          icon: 'ic_close',
          destructive: true,
        ),
        NotificationAction(
          id: 'reply',
          title: 'Reply',
          input: NotificationInputOption(
            placeholder: 'Type your response...',
            allowFreeText: true,
          ),
        ),
      ],
    );
    _handleNotificationResult(result);
  }

  Future<void> _scheduleNotification() async {
    final id = _getNextNotificationId();
    if (_scheduledDate
        .isBefore(DateTime.now().add(const Duration(seconds: 1)))) {
      setState(() {
        _lastAction = "Schedule date must be in the future!";
      });
      return;
    }
    final result = await _notificationService.scheduleNotification(
      id: id,
      title: _titleController.text,
      body: _bodyController.text,
      scheduledDate: _scheduledDate,
      payload: "scheduled_notification_$id",
      channelType: _selectedChannel,
      attachment: _useAttachment
          ? NotificationAttachment.imageUrl(_imageUrlController.text)
          : null,
    );
    _handleNotificationResult(result);
  }


  Future<void> _showProgressNotification() async {
    final id = _getNextNotificationId();
    final result = await _notificationService.showProgressNotification(
      id: id,
      title: _titleController.text,
      body: _bodyController.text,
      progress: _progressValue,
      maxProgress: 100,
      payload: "progress_notification_$id",
      channelType: NotificationChannelType.download,
      autoDismiss: false,
    );
    _handleNotificationResult(result);
  }

  Future<void> _showGroupedNotifications() async {
    final result = await _notificationService.showGroupedNotifications(
      groupKey: "group_test",
      summaryTitle: "New Messages",
      summaryBody: "You have 3 new messages",
      channelType: _selectedChannel,
      notifications: [
        GroupedNotificationItem(
          id: _getNextNotificationId(),
          title: "John",
          body: "Hi there!",
          payload: "message_john",
        ),
        GroupedNotificationItem(
          id: _getNextNotificationId(),
          title: "Sarah",
          body: "How are you doing?",
          payload: "message_sarah",
        ),
        GroupedNotificationItem(
          id: _getNextNotificationId(),
          title: "Mike",
          body: "Meeting at 5pm",
          payload: "message_mike",
        ),
      ],
    );
    _handleNotificationResult(result);
  }

  Future<void> _cancelAllNotifications() async {
    final result = await _notificationService.cancelAllNotifications();
    setState(() {
      _lastAction = result
          ? "All notifications canceled"
          : "Failed to cancel notifications";
    });
  }

  int _getNextNotificationId() {
    setState(() {
      _lastNotificationId = _notificationCount++;
    });
    return _lastNotificationId;
  }

  void _handleNotificationResult(NotificationResult result) {
    setState(() {
      if (result.success) {
        _lastAction = "Notification sent with ID: ${result.notificationId}";
      } else {
        _lastAction = "Failed: ${result.error}";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Sandbox"),
      ),
      body: _buildNotificationSandbox(),
    );
  }

  Widget _buildNotificationSandbox() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildNotificationConfig(),
          const SizedBox(height: 24),
          AppText(
            "Notification Types",
            variant: TextVariant.headlineSmall,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          _buildNotificationButtons(),
          const SizedBox(height: 24),
          _buildAdvancedOptions(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _cancelAllNotifications,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.destructive,
              foregroundColor: AppColors.destructiveForeground,
              padding: const EdgeInsets.all(16),
            ),
            child: const Text("Cancel All Notifications"),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              "Notification Status",
              variant: TextVariant.titleLarge,
              color: AppColors.primary,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _hasPermission ? Icons.check_circle : Icons.error,
                  color: _hasPermission
                      ? AppColors.success
                      : AppColors.destructive,
                ),
                const SizedBox(width: 8),
                AppText(
                  "Permissions: ${_hasPermission ? 'Granted' : 'Not Granted'}",
                  variant: TextVariant.bodyMedium,
                  color: AppColors.foreground,
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppText(
              "Last Action: $_lastAction",
              variant: TextVariant.bodyMedium,
              color: AppColors.foreground,
            ),
            const SizedBox(height: 8),
            AppText(
              "Total Notifications: $_notificationCount",
              variant: TextVariant.bodyMedium,
              color: AppColors.foreground,
            ),
            if (!_hasPermission) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final granted =
                      await _notificationService.requestPermission();
                  setState(() {
                    _hasPermission = granted;
                    _lastAction =
                        granted ? "Permission granted" : "Permission denied";
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                ),
                child: const Text("Request Permissions"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationConfig() {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              "Notification Configuration",
              variant: TextVariant.titleLarge,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: "Title",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.input,
              ),
              style: TextStyle(color: AppColors.inputForeground),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: "Body",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.input,
              ),
              style: TextStyle(color: AppColors.inputForeground),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<NotificationChannelType>(
              value: _selectedChannel,
              decoration: InputDecoration(
                labelText: "Channel Type",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: AppColors.input,
              ),
              style: TextStyle(color: AppColors.inputForeground),
              dropdownColor: AppColors.card,
              items: NotificationChannelType.values.map((channel) {
                return DropdownMenuItem<NotificationChannelType>(
                  value: channel,
                  child: Text(channel.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedChannel = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: AppText(
                "Include Image Attachment",
                variant: TextVariant.bodyMedium,
                color: AppColors.foreground,
              ),
              value: _useAttachment,
              onChanged: (value) {
                setState(() {
                  _useAttachment = value;
                });
              },
              activeColor: AppColors.primary,
            ),
            if (_useAttachment) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: "Image URL",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: AppColors.input,
                ),
                style: TextStyle(color: AppColors.inputForeground),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton(
          onPressed: _showBasicNotification,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text("Basic Notification"),
        ),
        ElevatedButton(
          onPressed: _showNotificationWithActions,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.secondaryForeground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text("With Actions"),
        ),
        ElevatedButton(
          onPressed: _scheduleNotification,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.accentForeground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text("Scheduled"),
        ),
        ElevatedButton(
          onPressed: _showProgressNotification,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.muted,
            foregroundColor: AppColors.mutedForeground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text("Progress"),
        ),
        ElevatedButton(
          onPressed: _showGroupedNotifications,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.successForeground,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text("Grouped"),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions() {
    return Card(
      color: AppColors.card,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              "Advanced Options",
              variant: TextVariant.titleLarge,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            AppText(
              "Schedule Time (for scheduled notifications)",
              variant: TextVariant.bodyMedium,
              color: AppColors.foreground,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Schedule: ${_scheduledDate.toString().substring(0, 16)}",
                    style: TextStyle(color: AppColors.foreground),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _scheduledDate,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 365)),
                    );

                    if (!mounted) return; // CEK MOUNTED untuk context

                    if (pickedDate != null) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_scheduledDate),
                      );

                      if (!mounted) return;

                      if (pickedTime != null) {
                        setState(() {
                          _scheduledDate = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );
                        });
                      }
                    }
                  },
                  child: const Text("Change"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppText(
              "Progress Value (for progress notifications)",
              variant: TextVariant.bodyMedium,
              color: AppColors.foreground,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _progressValue.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primary,
                    inactiveColor: AppColors.border,
                    label: _progressValue.toString(),
                    onChanged: (value) {
                      setState(() {
                        _progressValue = value.toInt();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    "$_progressValue%",
                    style: TextStyle(color: AppColors.foreground),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
