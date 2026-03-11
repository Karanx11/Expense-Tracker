import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = "";
  String email = "";
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future loadProfile() async {
    try {
      final data = await ApiService.getProfile();

      setState(() {
        name = data["name"] ?? "";
        email = data["email"] ?? "";
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to load profile")));
    }
  }

  Future<void> logout() async {
    await ApiService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text(
            "Are you sure you want to delete your account? This action cannot be undone.",
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                Navigator.pop(context);

                await ApiService.deleteAccount();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  const SizedBox(height: 20),

                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFF4F7C82),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(email, style: const TextStyle(color: Colors.grey)),

                  const SizedBox(height: 40),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text("Logout"),
                      onTap: logout,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.delete, color: Colors.red),
                      title: const Text("Delete Account"),
                      onTap: deleteAccount,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
