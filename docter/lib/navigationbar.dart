import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class NavigationBarPage extends StatefulWidget {
  @override
  _NavigationBarPageState createState() => _NavigationBarPageState();
}

class _NavigationBarPageState extends State<NavigationBarPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Container(
        child: Text("Home"),
      );
    }
    if (index == 1) {
      Container(
        child: Text("Home"),
      );
    }
    if (index == 2) {
      Container(
        child: Text("Home"),
      );
    }

    // Navigate to the respective page based on the icon clicked
    if (index == 3) {
      final Map<String, dynamic>? user =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (user != null) {
        if (user['role'] == 'doctor') {
          Container(
            child: Text("Home"),
          );
        } else if (user['role'] == 'user') {
          Container(
            child: Text("Home"),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the user data from arguments
    final Map<String, dynamic>? user =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Define the destinations
    List<Widget> destinations = [
      _buildNavigationDestination(CupertinoIcons.home, 0),
      _buildNavigationDestination(CupertinoIcons.chat_bubble, 1),
      _buildNavigationDestination(CupertinoIcons.calendar, 2),
      _buildNavigationDestination(CupertinoIcons.person, 3),
    ];

    return Scaffold(
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(bottom: 8.0), // Lifted a few pixels
        child: NavigationBar(
          backgroundColor: Colors.white,
          height: 70,
          elevation: 10, // Lifted effect
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: destinations,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          indicatorColor: Colors.transparent,
        ),
      ),
    );
  }

  NavigationDestination _buildNavigationDestination(IconData icon, int index) {
    return NavigationDestination(
      icon: Icon(
        icon,
        size: 28,
        color: _selectedIndex == index
            ? Color(0xFF0064F7)
            : Colors.grey, // Change color when selected
      ),
      label: '',
      selectedIcon: Icon(
        icon,
        size: 28,
        color: Color(0xFF0064F7), // Fill color when selected
      ),
    );
  }
}
