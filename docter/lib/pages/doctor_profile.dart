import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorProfilePage extends StatelessWidget {
  final User? user; // Nullable user parameter

  DoctorProfilePage({this.user}); // Constructor with nullable user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Profile'),
      ),
      body: Center(
        child: user != null
            ? Text(
                'Welcome ${user!.email} to the Doctor Profile Page') // Use the user object
            : Text('Welcome to the Doctor Profile Page'), // Default message
      ),
    );
  }
}
