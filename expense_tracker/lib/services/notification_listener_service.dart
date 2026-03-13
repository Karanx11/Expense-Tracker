import 'package:flutter/services.dart';

class NotificationListenerService {
  static const platform = MethodChannel("expense_tracker/notifications");

  static void startListening(Function(String) onPayment) {
    platform.setMethodCallHandler((call) async {
      if (call.method == "paymentNotification") {
        String text = call.arguments;

        onPayment(text);
      }
    });
  }
}
