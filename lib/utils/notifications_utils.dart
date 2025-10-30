// -------------------------------------------------------------
// Importing modules and dependencies
// -------------------------------------------------------------

import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class NotificationsManager {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static void initialize() {
    const androidSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    const linuxSettings = LinuxInitializationSettings(defaultActionName: 'Open notification');
    const initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );

    _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (notificationResponse) {
        // Handle notification response
      },
    );
  }
  static void showLowStockNotification(String productName) async {
    const androidDetails = AndroidNotificationDetails(
      "low_stock_channel",
      "Low Stock",
      importance: Importance.high,
      ticker: "Low Stock",
    );
    
    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
      category: LinuxNotificationCategory.im,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      linux: linuxDetails,
    );
      // 
      await _flutterLocalNotificationsPlugin.show(
        0, 
        'Low Stock Alert', 
        "$productName is running low on stock!",
        notificationDetails, 
        payload: "low_stock",
      
      );
  }
}