import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    // v20.0.0 API: initialize(settings: ...) likely?
    // Wait, the error message said 'settings' is required.
    // Let's assume the parameter name is 'settings' based on the previous error.
    // Or maybe it is still 'initializationSettings' but required as named?
    // "The named parameter 'settings' is required" -> So it is 'settings'.
    
    // Actually, looking at docs for older/newer versions, it varies.
    // Error log: "The named parameter 'settings' is required"
    // So I will use 'settings'.
    
    await _notificationsPlugin.initialize(settings: initializationSettings);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'sync_channel', // channel Id
      'Data Sync', // channel Name
      channelDescription: 'Notifications for data synchronization status',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    // v20.0.0 API: show(id: ..., title: ..., body: ..., notificationDetails: ...)
    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformChannelSpecifics,
    );
  }
}
