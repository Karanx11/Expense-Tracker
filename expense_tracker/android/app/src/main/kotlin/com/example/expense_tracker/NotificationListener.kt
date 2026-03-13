package com.example.expense_tracker

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.MethodChannel

class NotificationListener : NotificationListenerService() {

    companion object {
        var channel: MethodChannel? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {

        val packageName = sbn.packageName
        val extras = sbn.notification.extras

        val title = extras.getString("android.title")
        val text = extras.getCharSequence("android.text")?.toString()

        Log.d("NOTIFICATION", "$packageName -> $text")

        if(text == null) return

        if(packageName.contains("paisa") ||
           packageName.contains("phonepe") ||
           packageName.contains("paytm")) {

            channel?.invokeMethod("paymentNotification", text)
        }
    }
}