import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    super.initState();
    // Navigate to GetStartedPage after a 3-second delay
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacementNamed('/getstarted');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0064F7), // Background color of the page
      body: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensure the column takes up minimum space
          children: [
            Image.asset(
              'assets/onboarding/welcome/logo.png',
              height: 150.0,
              width: 150.0,
            ), // Your image asset
            const Text(
              'Docter',
              style: TextStyle(
                fontFamily: 'SFProDisplay',
                fontWeight: FontWeight.w400,
                fontSize: 30, // Text size
                color: Colors.white, // Text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
