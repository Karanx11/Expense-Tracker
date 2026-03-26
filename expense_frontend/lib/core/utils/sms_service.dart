import 'package:telephony/telephony.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/utils/category_detector.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;
  final storage = const FlutterSecureStorage();

  /// 🔥 INIT
  Future<void> init(
    Function(double amount, DateTime date, String category) onDetected,
  ) async {
    bool? granted = await telephony.requestSmsPermissions;

    print("SMS PERMISSION: $granted");

    if (!(granted ?? false)) return;

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

      await _processMessage(msg.body ?? "", smsDate, onDetected);
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

        await _processMessage(message.body ?? "", smsDate, onDetected);
      },
      listenInBackground: false,
    );
  }

  /// 🔍 PROCESS SMS
  Future<void> _processMessage(
    String body,
    DateTime smsDate,
    Function(double amount, DateTime date, String category) onDetected,
  ) async {
    final text = body.toLowerCase();

    print("📩 SMS RECEIVED: $body");

    /// ✅ STRICT FILTER (ONLY EXPENSE SMS)
    if (text.contains("debited") && text.contains("upi")) {
      final amount = _extractAmount(body);

      if (amount != null) {
        print("💸 EXPENSE DETECTED: ₹$amount");

        /// ✅ Save latest processed time
        await storage.write(
          key: "last_sms_time",
          value: smsDate.toIso8601String(),
        );

        /// 🤖 Smart Category Detection
        String category = CategoryDetector.detect(body);

        onDetected(amount, smsDate, category);
      }
    }
  }

  /// EXTRACT AMOUNT (FOR ₹, INR, Rs)
  double? _extractAmount(String text) {
    final regex = RegExp(r'(₹|INR|Rs\.?)\s?(\d+(\.\d+)?)');
    final match = regex.firstMatch(text);

    if (match != null) {
      return double.tryParse(match.group(2)!);
    }
    return null;
  }
}
