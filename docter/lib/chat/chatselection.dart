import 'package:docter/chat/chatlist.dart';
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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkAndCreateChatsField();
    fetchUserRole();
  }

  Future<void> checkAndCreateChatsField() async {
    if (widget.user != null) {
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.user!.uid);
      final userDoc = await userDocRef.get();
      final userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData['chats'] == null) {
        await userDocRef.update({
          'chats': [],
        });
      }
    }
  }

  Future<void> fetchUserRole() async {
    if (widget.user != null) {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).get();
      setState(() {
        userRole = userDoc.data()?['role'];
        isLoading = false; // Set loading to false after fetching
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
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          const CupertinoSearchTextField(
            placeholder: 'Search...',
          ),
          const SizedBox(height: 15),
          isLoading
              ? Center(child: CircularProgressIndicator()) // Loading indicator
              : userRole != null
                  ? GestureDetector(
                      onTap: () {
                        if (userRole == 'doctor') {
                          // Handle doctor action here
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
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
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
                    )
                  : const SizedBox.shrink(),
          const SizedBox(height: 20),
          ChatList(user: widget.user), // Directly add ChatList here
        ],
      ),
    ),
  );
}
}