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
  String phone = "";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// LOAD PROFILE
  Future loadProfile() async {
    try {
      final data = await ApiService.getProfile();

      setState(() {
        name = data["name"] ?? "";
        email = data["email"] ?? "";
        phone = data["phone"] ?? "";
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

  /// LOGOUT
  Future<void> logout() async {
    await ApiService.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  /// DELETE ACCOUNT
  Future deleteAccount() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Account"),
          content: const Text("Are you sure you want to delete your account?"),
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

  Widget box(Widget child) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
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
                  /// PROFILE PHOTO
                  box(
                    const Center(
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: Color(0xFF4F7C82),
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// NAME
                  box(
                    Row(
                      children: [
                        const Icon(Icons.person),
                        const SizedBox(width: 10),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// EMAIL
                  box(
                    Row(
                      children: [
                        const Icon(Icons.email),
                        const SizedBox(width: 10),
                        Text(email),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// PHONE
                  box(
                    Row(
                      children: [
                        const Icon(Icons.phone),
                        const SizedBox(width: 10),
                        Text(phone.isEmpty ? "Not provided" : phone),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// DELETE ACCOUNT BUTTON
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: deleteAccount,
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete Account"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.all(14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// FOOTER
                  const Text(
                    "Built by Karan",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
    );
  }
}
