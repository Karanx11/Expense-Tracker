import 'dart:ui';
import 'package:flutter/material.dart';
import '../widgets/glass_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(20),

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F1115), Color(0xFF1A1C22)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// PROFILE AVATAR
              const CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),

              const SizedBox(height: 20),

              const Text(
                "Karan Sharma",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              /// USER INFO CARD
              GlassCard(
                height: 160,

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Row(
                      children: [
                        Icon(Icons.email),
                        SizedBox(width: 10),
                        Text("karan@email.com"),
                      ],
                    ),

                    SizedBox(height: 20),

                    Row(
                      children: [
                        Icon(Icons.phone),
                        SizedBox(width: 10),
                        Text("+91 9876543210"),
                      ],
                    ),

                    SizedBox(height: 20),

                    Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 10),
                        Text("User ID: 10234"),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// LOGOUT BUTTON
              GlassCard(
                height: 70,
                child: InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text("Logged out")));
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: Colors.orange),
                      SizedBox(width: 10),
                      Text("Logout", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// DELETE ACCOUNT
              GlassCard(
                height: 70,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete Account"),
                          content: const Text(
                            "Are you sure you want to delete your account?",
                          ),

                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },

                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 10),
                      Text("Delete Account", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
