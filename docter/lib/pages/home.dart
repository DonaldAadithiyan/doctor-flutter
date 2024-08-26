import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatelessWidget {
  final User? user; // Nullable user

  HomePage({this.user}); // Constructor

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body:
                Center(child: CircularProgressIndicator()), // Loading indicator
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('User data not found')),
          );
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final displayName =
            userData['displayName'] ?? 'Guest'; // Get displayName
        final profileImageUrl = userData['profileImageUrl'] ??
            'https://firebasestorage.googleapis.com/v0/b/docter-63df0.appspot.com/o/profileimages%2FProfile_avatar_placeholder_large.png?alt=media&token=69f5245e-8ca5-4a24-9e2f-2e2cbeef8584'; // Get profileImageUrl

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFFFFFFF),
            leading: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: CircleAvatar(
                backgroundImage: NetworkImage(profileImageUrl),
                radius: 30, // Adjust size as needed
              ),
            ),
            title: Row(
              // mainAxisSize:
              //     MainAxisSize.min, // Ensure Row takes only necessary space
              children: [
                // Use SizedBox to add precise spacing between avatar and text
                SizedBox(width: 2), // 10 pixels of space
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hello 👋',
                      style: TextStyle(
                        fontSize: 24, // Increase text size
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      displayName,
                      style: const TextStyle(
                          fontSize: 19, // Adjust size as needed
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: Icon(
                    CupertinoIcons.bell,
                    size: 24,
                  ),
                  onPressed: () {
                    // Handle bell icon press
                  },
                ),
              ),
            ],
            toolbarHeight: 80, // Increase AppBar height
          ),
          body: Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DetailsPage()),
                );
              },
              child: const Text('Go to Details'),
            ),
          ),
        );
      },
    );
  }
}

class DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.red, // Matching AppBar color
      ),
      body: const Center(
        child: Text('Details Page'),
      ),
    );
  }
}
