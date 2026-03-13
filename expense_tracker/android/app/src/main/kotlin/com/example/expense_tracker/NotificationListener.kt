package com.example.expense_tracker

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log

class NotificationListener : NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {

        val packageName = sbn.packageName
        val extras = sbn.notification.extras

        val title = extras.getString("android.title")
        val text = extras.getCharSequence("android.text")?.toString()

        Log.d("PAYMENT_NOTIFICATION", "$packageName : $text")

        if (text != null) {

            if (text.contains("paid") ||
                text.contains("debited") ||
                text.contains("UPI")) {

                Log.d("PAYMENT_DETECTED", text)
            }
        }
    }
}