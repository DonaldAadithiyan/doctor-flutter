import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final User? user; // Nullable user parameter

  const UserProfilePage({super.key, this.user}); // Constructor with nullable user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            user != null
                ? Text(
                    'Welcome ${user!.email} to the User Profile Page') // Use the user object
                : const Text('Welcome to the User Profile Page'), // Default message
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/'); // Redirect to main.dart
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
