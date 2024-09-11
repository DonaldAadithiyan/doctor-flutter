import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorProfilePage extends StatelessWidget {
  final User? user; // Nullable user parameter

  const DoctorProfilePage({super.key, this.user}); // Constructor with nullable user

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/getstarted'); // Navigate to login page after signing out
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sign out')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Doctor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Center(
        child: user != null
            ? Text(
                'Welcome ${user!.email} to the Doctor Profile Page') // Use the user object
            : const Text(
                'Welcome to the Doctor Profile Page'), // Default message
      ),
    );
  }
}
