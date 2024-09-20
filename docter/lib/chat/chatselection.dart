import 'package:docter/pages/doctor_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSelectionPage extends StatefulWidget {
  final User? user;

  const ChatSelectionPage({super.key, required this.user});

  @override
  _ChatSelectionPageState createState() => _ChatSelectionPageState();
}

class _ChatSelectionPageState extends State<ChatSelectionPage> {
  String? userRole;

  @override
  void initState() {
    super.initState();
    checkAndCreateChatsField();
    fetchUserRole();
  }

  Future<void> checkAndCreateChatsField() async {
    if (widget.user != null) {
      // Fetch the user document from Firestore
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);
      final userDoc = await userDocRef.get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      // If the chats field doesn't exist, create it with an empty array
      if (userData != null && userData['chats'] == null) {
        await userDocRef.update({
          'chats': [],
        });
      }
    }
  }

  Future<void> fetchUserRole() async {
    if (widget.user != null) {
      // Fetch the user's role from Firestore
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).get();
      setState(() {
        userRole = userDoc.data()?['role'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SFProDisplay',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            
            // Cupertino Search Bar
            const CupertinoSearchTextField(
              placeholder: 'Search...',
            ),
            
            const SizedBox(height: 15),
        
            // Role-based container
            if (userRole != null)
              GestureDetector(
                onTap: () {
                  if (userRole == 'doctor') {
                   
                  } else if (userRole == 'user') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorsListPage(),
                      ),
                    );
                   
                  }
                },
                child: Container(
                  // margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.only(top:8, bottom:8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Color(0xFF0064F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          userRole == 'doctor'
                              ? CupertinoIcons.check_mark_circled
                              : CupertinoIcons.plus_circled,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        userRole == 'doctor'
                            ? 'View my Chat requests'
                            : 'Create chat request',
                        style: const TextStyle(
                          color: Color(0xFF0064F7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
            const SizedBox(height: 20),
        
            // Text saying "Chats"
            // const Padding(
            //   padding: EdgeInsets.only(left: 16.0),
            //   child: Text(
            //     'Chats',
            //     style: TextStyle(
            //       fontSize: 16,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),

        
            // Other chats or chat list can go here
          ],
        ),
      ),
    );
  }
}