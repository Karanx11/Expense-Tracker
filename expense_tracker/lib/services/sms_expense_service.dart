import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/sms_parser.dart';

void processSMS(String smsBody) {
  // Parse SMS
  ParsedSMS? parsed = parseBankSMS(smsBody);

  // If SMS is OTP or not a transaction, ignore
  if (parsed == null) {
    return;
  }

  // If no amount detected, ignore
  if (parsed.amount == null) {
    return;
  }

  Expense expense = Expense(
    id: DateTime.now().toString(),
    amount: parsed.amount!,
    category: parsed.category,
    note: "Auto SMS",
    date: parsed.dateTime ?? DateTime.now(),
  );

  ExpenseService.addExpense(expense);
}
