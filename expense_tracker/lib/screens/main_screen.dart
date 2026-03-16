import 'dart:ui';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: screens[currentIndex],

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),

          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),

            child: Container(
              height: 70,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),

              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,

                currentIndex: currentIndex,

                onTap: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },

                type: BottomNavigationBarType.fixed,

                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white54,

                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard),
                    label: "Dashboard",
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.pie_chart),
                    label: "Analytics",
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: "History",
                  ),

                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
