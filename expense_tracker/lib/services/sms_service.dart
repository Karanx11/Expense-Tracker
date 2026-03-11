import 'package:telephony_fix/telephony.dart';

class SmsService {
  final Telephony telephony = Telephony.instance;

  Future<List<SmsMessage>> getMessages() async {
    bool? permissionsGranted = await telephony.requestPhoneAndSmsPermissions;

    if (permissionsGranted != true) {
      return [];
    }

    List<SmsMessage> messages = await telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    return messages;
  }
}
