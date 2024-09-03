import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  final User? user; // Nullable user parameter

  const ChatPage({super.key, this.user}); // Constructor with nullable user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Center(
        child: user != null
            ? Text(
                'Welcome ${user!.email} to the Chat Page') // Use the user object
            : const Text('Welcome to the Chat Page'), // Default message
      ),
    );
  }
}
