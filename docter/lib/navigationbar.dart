import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'pages/home.dart';
import 'pages/chat.dart';
import 'pages/calendar.dart';
import 'pages/doctor_profile.dart';
import 'pages/user_profile.dart';

class NavigationBarPage extends StatefulWidget {
  final User? user; // Add user as a parameter

  NavigationBarPage({required this.user}); // Update constructor

  @override
  _NavigationBarPageState createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _selectedIndex = 0;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(user: widget.user),
      ChatPage(user: widget.user),
      CalendarPage(user: widget.user),
      Container(), // Placeholder for dynamic profile page
    ];

    _initializeProfilePage();
  }

  Future<void> _initializeProfilePage() async {
    if (widget.user != null) {
      try {
        // Fetch user role from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('user_profiles')
            .doc(widget.user!.uid)
            .get();

        final userRole =
            userDoc.data()?['role'] ?? 'user'; // Default to 'user' if not found

        final profilePage = userRole == 'doctor'
            ? DoctorProfilePage(user: widget.user)
            : UserProfilePage(user: widget.user);

        setState(() {
          _pages[3] = profilePage;
        });
      } catch (e) {
        print('Error fetching user role: $e');
      }
    } else {
      print('User data not available');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        height: 70,
        elevation: 10,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: [
          _buildNavigationDestination(
              CupertinoIcons.home, CupertinoIcons.house_fill, 0),
          _buildNavigationDestination(
              CupertinoIcons.chat_bubble, CupertinoIcons.chat_bubble_fill, 1),
          _buildNavigationDestination(
              CupertinoIcons.calendar, CupertinoIcons.calendar_today, 2),
          _buildNavigationDestination(
              CupertinoIcons.person, CupertinoIcons.person_fill, 3),
        ],
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        indicatorColor: Colors.transparent,
      ),
    );
  }

  NavigationDestination _buildNavigationDestination(
      IconData icon, IconData iconClicked, int index) {
    return NavigationDestination(
      icon: Icon(
        _selectedIndex == index ? iconClicked : icon,
        size: 28,
        color: _selectedIndex == index ? Color(0xFF0064F7) : Colors.grey,
      ),
      label: '',
      selectedIcon: Icon(
        iconClicked,
        size: 28,
        color: Color(0xFF0064F7),
      ),
    );
  }
}
