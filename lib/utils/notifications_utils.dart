// -------------------------------------------------------------
// Importing modules and dependencies
// -------------------------------------------------------------

import 'package:flutter_local_notifications/flutter_local_notifications.dart';



class NotificationsManager {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static void initialize(){
    const AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("@mipmap/ic_launcher");
    const InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings);

    //

    _flutterLocalNotificationsPlugin.initialize(initializationSettings, onDidReceiveNotificationResponse: (notificationResponse){
      //
    },
    );
  }
  static void showLowStockNotification(String productName) async {
    const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
      "low_stock_channel",
      "low Stock",
      importance: Importance.high,
      ticker: "Low Stock",
      
      );
      const NotificationDetails notificationDetails = NotificationDetails(android: androidNotificationDetails);
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