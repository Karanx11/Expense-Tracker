import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notifications
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(settings);
  }

  /// Show notification when limit exceeded
  static Future<void> showLimitWarning() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'limit_channel',
          'Limit Alerts',
          channelDescription: 'Alerts when spending limit is exceeded',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      0,
      "⚠ Budget Limit Exceeded",
      "You have crossed your monthly spending limit!",
      details,
    );
  }

  /// Show notification for each expense
  static Future<void> showExpenseNotification(
    double amount,
    double remaining,
  ) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'expense_channel',
          'Expense Notifications',
          channelDescription: 'Shows spending updates',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      1,
      "Expense Detected",
      "₹$amount spent. Remaining budget ₹${remaining.toStringAsFixed(0)}",
      details,
    );
  }
}
