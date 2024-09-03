import 'package:docter/navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'onboarding/welcome.dart';
import 'onboarding/getStarted.dart';
import 'onboarding/login.dart';
import 'onboarding/register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: FutureBuilder<User?>(
        future: _checkUserLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0064F7),
              ),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in
            // Pass user data to NavigationBarPage
            return NavigationBarPage(user: snapshot.data);
          } else {
            // User is not logged in
            return const WelcomePage();
          }
        },
      ),
      routes: {
        '/getstarted': (context) => const GetStartedPage(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        ''
        '/navigationBar': (context) => const NavigationBarPage(user: null),
      },
    );
  }

  Future<User?> _checkUserLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user; // Return the current user if logged in, or null if not
  }
}
