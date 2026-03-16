import '../models/expense.dart';

class ExpenseService {
  static List<Expense> expenses = [];

  static List<Expense> getExpenses() {
    return expenses;
  }

  static void addExpense(Expense expense) {
    expenses.add(expense);
  }

  /// DELETE EXPENSE
  static void deleteExpense(Expense expense) {
    expenses.remove(expense);
  }
}
