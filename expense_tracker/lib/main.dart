import 'package:expense_tracker/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();

  await Hive.initFlutter();

  await Hive.openBox("expenseBox");
  await Hive.openBox("settingsBox");

  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Expense Tracker",

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B2E33),
          centerTitle: true,
        ),

        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4F7C82),
          secondary: Color(0xFF93B1B5),
        ),

        cardColor: const Color(0xFF0B2E33),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F7C82),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
          ),
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
