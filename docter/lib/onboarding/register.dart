import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'Register',
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFFFFFFF),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: 'Back',
          iconSize: 22,
        ),
      ),
      body: SafeArea(
        child: Container(
          color: const Color(0xFFFFFFFF),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name text field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    filled: true,
                    fillColor: const Color(0xFFF6F7F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 19),
                      child:
                          Icon(CupertinoIcons.person, color: Color(0xFF0064F7)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Email text field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFFF6F7F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 19),
                      child: Icon(CupertinoIcons.envelope,
                          color: Color(0xFF0064F7)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password text field
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFFF6F7F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 19),
                      child:
                          Icon(CupertinoIcons.lock, color: Color(0xFF0064F7)),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                // Confirm Password text field
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    filled: true,
                    fillColor: const Color(0xFFF6F7F9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 15.0, right: 19),
                      child:
                          Icon(CupertinoIcons.lock, color: Color(0xFF0064F7)),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                // Register button
                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text ==
                        confirmPasswordController.text) {
                      try {
                        // Create user with email and password in Firebase Auth
                        UserCredential userCredential = await FirebaseAuth
                            .instance
                            .createUserWithEmailAndPassword(
                          email: emailController.text,
                          password: passwordController.text,
                        );

                        // Define default values for the user document
                        Map<String, dynamic> defaultUserValues = {
                          'displayName': nameController.text,
                          'email': emailController.text,
                          'role': 'user', // Default value
                          'address': null, // Default value for 'address'
                          'createdAt':
                              FieldValue.serverTimestamp(), // Timestamp
                          'dateOfBirth':
                              null, // Default value for 'dateOfBirth'
                          'gender': null, // Default value for 'gender'
                          'phoneNumber':
                              null, // Default value for 'phoneNumber'
                          'profileImageUrl':
                              "https://firebasestorage.googleapis.com/v0/b/docter-63df0.appspot.com/o/profileimages%2FProfile_avatar_placeholder_large.png?alt=media&token=69f5245e-8ca5-4a24-9e2f-2e2cbeef8584"
                        };

                        // Save user data to Firestore
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userCredential.user!.uid)
                            .set(defaultUserValues);

                        // Navigate to a different page or show a success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Registration successful!')),
                        );

                        // Navigate to a different page if needed
                        // Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        // Handle errors
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    } else {
                      // Show error if passwords do not match
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Passwords do not match')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF0064F7),
                    side: const BorderSide(color: Color(0xFF0064F7), width: 1),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Login link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Already have an account? Login here",
                    style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0064F7),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
