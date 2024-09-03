import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  final User? user; // Nullable user parameter

  const CalendarPage({super.key, this.user}); // Constructor with nullable user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Center(
        child: user != null
            ? Text(
                'Welcome ${user!.email} to the Calendar Page') // Use the user object
            : const Text('Welcome to the Calendar Page'), // Default message
      ),
    );
  }
}
