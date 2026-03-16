import 'package:telephony/telephony.dart';

class SMSService {
  static final Telephony telephony = Telephony.instance;

  /// Request SMS permission
  static Future<bool> requestPermission() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

    return permissionsGranted ?? false;
  }

  /// Read inbox SMS
  static Future<List<SmsMessage>> readInbox() async {
    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    return messages;
  }
}
