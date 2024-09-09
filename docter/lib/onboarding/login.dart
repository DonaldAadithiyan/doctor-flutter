import 'package:docter/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        title: const Text(
          'Login',
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
                const SizedBox(height: 20),
                // Login button
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Show a loading indicator while waiting for authentication
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      // Sign in using Firebase Auth
                      UserCredential userCredential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );

                      // Wait until the FirebaseAuth is fully updated
                      User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                          // Fetch user data from Firestore
                          DocumentSnapshot<Object?> userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();

                          // Close the loading dialog before navigating
                          Navigator.pop(context);

                          if (userDoc.exists) {
                            // Navigate to the NavigationBarPage with the user document snapshot
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NavigationBarPage(
                                  user: user,
                                ),
                              ),
                            );
                          } else {
                            Navigator.pop(context); // Close loading if user data not found
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User data not found')),
                            );
                          }
                        } else {
                          Navigator.pop(context); // Close loading if authentication fails
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('User not authenticated')),
                          );
                        }
                      } catch (e) {
                        Navigator.pop(context); // Close loading in case of error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed: ${e.toString()}')),
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
                    'Login',
                    style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Registration link
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(
                    "Don't have an account? Register here",
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
