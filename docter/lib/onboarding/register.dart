import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text(
          'Register',
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: Color(0xFFFFFFFF), // AppBar background color
        leading: IconButton(
          icon: Icon(CupertinoIcons.back,
              color: Colors.black), // Back button icon
          onPressed: () {
            Navigator.pop(context); // Navigate back
          },
          tooltip: 'Back', // Optional tooltip text
          iconSize: 22, // Adjust icon size as needed
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Color(0xFFFFFFFF), // Page background color
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0)
                .copyWith(top: 30), // Padding for the content
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Full-width layout for children
              children: [
                // Email text field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Color(0xFFF6F7F9), // Background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0), // Oval shape
                      borderSide: BorderSide.none, // Remove border
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 19),
                      child: Icon(CupertinoIcons.envelope,
                          color: Color(0xFF0064F7)), // Envelope icon
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Password text field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Color(0xFFF6F7F9), // Background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0), // Oval shape
                      borderSide: BorderSide.none, // Remove border
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 19),
                      child: Icon(CupertinoIcons.lock,
                          color: Color(0xFF0064F7)), // Lock icon
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 16),
                // Confirm Password text field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    filled: true,
                    fillColor: Color(0xFFF6F7F9), // Background color
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0), // Oval shape
                      borderSide: BorderSide.none, // Remove border
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 15.0, right: 19),
                      child: Icon(CupertinoIcons.padlock_solid,
                          color: Color(0xFF0064F7)), // Lock icon
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                // Register button
                ElevatedButton(
                  onPressed: () {
                    // Implement registration functionality
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor:
                        Color(0xFF0064F7), // Button background color
                    side: BorderSide(
                        color: Color(0xFF0064F7),
                        width: 1), // Button border color
                    minimumSize: Size(double.infinity, 50), // Full-width button
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      fontSize: 19,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                // Login link
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Navigate back to login page
                  },
                  child: Text(
                    "Already have an account? Login here",
                    style: TextStyle(
                      fontFamily: 'SFProDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0064F7), // Link color
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
