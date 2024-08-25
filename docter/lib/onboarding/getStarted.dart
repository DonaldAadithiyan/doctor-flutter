import 'package:flutter/material.dart';

class GetStartedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color of the page
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo slightly above the center
            Padding(
              padding: const EdgeInsets.only(
                  bottom: 10.0), // Adjust spacing as needed
              child: Image.asset(
                'assets/onboarding/welcome/logo.png', // Update with your logo path
                height: 150.0,
                width: 150.0,
              ),
            ),
            // Text below the logo
            const Text(
              'Welcome to Docter!',
              style: TextStyle(
                fontFamily: 'SFProDisplay',
                fontWeight: FontWeight.w700,
                fontSize: 30, // Adjust text size as needed
                color: Color(0xFF0064F7),
              ),
            ),
            SizedBox(height: 40), // Space between text and buttons
            // Buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/login'); // Navigate to login page
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF0064F7), // Button text color
                side: BorderSide(color: Color(0xFF0064F7), width: 1),
                minimumSize: Size(370, 50), // Button size
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
            SizedBox(height: 10), // Space between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/register'); // Navigate to register page
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Color(0xFF0064F7),
                backgroundColor: Colors.white, // Button text color
                side: BorderSide(color: Color(0xFF0064F7), width: 1),
                minimumSize: Size(370, 50), // Button size
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
          ],
        ),
      ),
    );
  }
}
