import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String phone = "";
  String email = "";
  String uid = "";

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  /// LOAD PROFILE FROM FIREBASE
  Future loadProfile() async {
    User? user = FirebaseAuth.instance.currentUser;

    setState(() {
      phone = user?.phoneNumber ?? "";
      email = user?.email ?? "Not provided";
      uid = user?.uid ?? "";
      loading = false;
    });
  }

  /// LOGOUT
  Future logout() async {
    await FirebaseAuth.instance.signOut();

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

                User? user = FirebaseAuth.instance.currentUser;

                await user?.delete();

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
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
                  /// PROFILE ICON
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

                  /// PHONE
                  box(
                    Row(
                      children: [
                        const Icon(Icons.phone),
                        const SizedBox(width: 10),
                        Text(phone),
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

                  /// USER ID
                  box(
                    Row(
                      children: [
                        const Icon(Icons.fingerprint),
                        const SizedBox(width: 10),
                        Expanded(child: Text(uid)),
                      ],
                    ),
                  ),

                  const Spacer(),

                  /// LOGOUT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: logout,
                      icon: const Icon(Icons.logout),
                      label: const Text("Logout"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// DELETE ACCOUNT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: deleteAccount,
                      icon: const Icon(Icons.delete),
                      label: const Text("Delete Account"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

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
