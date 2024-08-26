import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final User? user; // Nullable user parameter

  UserProfilePage({this.user}); // Constructor with nullable user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Center(
        child: user != null
            ? Text(
                'Welcome ${user!.email} to the User Profile Page') // Use the user object
            : Text('Welcome to the User Profile Page'), // Default message
      ),
    );
  }
}
