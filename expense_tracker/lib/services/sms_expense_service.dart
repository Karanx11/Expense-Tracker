import '../services/expense_service.dart';
import '../utils/sms_parser.dart';

Future<void> processSMS(String smsBody) async {
  /// Parse SMS
  ParsedSMS? parsed = parseBankSMS(smsBody);

  /// Ignore OTP / non-transaction SMS
  if (parsed == null) {
    return;
  }

  /// Ignore if amount missing
  if (parsed.amount == null) {
    return;
  }

  /// Send expense to backend
  await ExpenseService.addExpense(parsed.amount!, parsed.category, "Auto SMS");
}
