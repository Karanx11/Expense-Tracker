import 'package:telephony/telephony.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;
  final storage = const FlutterSecureStorage();

  /// 🔥 INIT
  Future<void> init(Function(double amount, DateTime date) onDetected) async {
    bool? permissionsGranted = await telephony.requestSmsPermissions;

    if (!(permissionsGranted ?? false)) return;

    /// ✅ Get last processed time
    String? lastTimeStr = await storage.read(key: "last_sms_time");
    DateTime? lastTime = lastTimeStr != null
        ? DateTime.parse(lastTimeStr)
        : null;

    /// 🔥 READ RECENT SMS
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    for (var msg in messages.take(10)) {
      DateTime smsDate = DateTime.fromMillisecondsSinceEpoch(msg.date ?? 0);

      /// ❌ Skip old SMS
      if (lastTime != null && smsDate.isBefore(lastTime)) continue;

      _processMessage(msg.body ?? "", smsDate, onDetected);
    }

    /// 🔥 LISTEN NEW SMS
    telephony.listenIncomingSms(
      onNewMessage: (SmsMessage message) async {
        DateTime smsDate = DateTime.fromMillisecondsSinceEpoch(
          message.date ?? 0,
        );

        String? lastTimeStr = await storage.read(key: "last_sms_time");
        DateTime? lastTime = lastTimeStr != null
            ? DateTime.parse(lastTimeStr)
            : null;

        /// ❌ Ignore old/replayed SMS
        if (lastTime != null && smsDate.isBefore(lastTime)) return;

        _processMessage(message.body ?? "", smsDate, onDetected);
      },
    );
  }

  /// 🔍 PROCESS SMS
  void _processMessage(
    String body,
    DateTime smsDate,
    Function(double, DateTime) onDetected,
  ) async {
    final text = body.toLowerCase();

    if (text.contains("debited") || text.contains("upi")) {
      final amount = _extractAmount(body);

      if (amount != null) {
        /// ✅ Save latest processed time
        await storage.write(
          key: "last_sms_time",
          value: smsDate.toIso8601String(),
        );

        onDetected(amount, smsDate);
      }
    }
  }

  /// 💰 EXTRACT AMOUNT
  double? _extractAmount(String text) {
    final regex = RegExp(r'(₹|INR)\s?(\d+(\.\d+)?)');
    final match = regex.firstMatch(text);

    if (match != null) {
      return double.tryParse(match.group(2)!);
    }
    return null;
  }
}
