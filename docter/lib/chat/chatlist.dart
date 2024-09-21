import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatList extends StatefulWidget {
  final User? user; // Pass the user object to the constructor
  const ChatList({Key? key, required this.user}) : super(key: key);

  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  String? currentUserRole;
  List<Map<String, dynamic>> chatDetails = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserRoleAndChats();
  }

  Future<void> getUserRoleAndChats() async {
    try {
      // Fetch user document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user!.uid)
          .get();

      if (userDoc.exists) {
        // Get the role and assign to currentUserRole
        setState(() {
          currentUserRole = userDoc['role'];
        });

        // Get the chats array from user document
        if (userDoc['chats'] != null) {
          List<DocumentReference> chatReferences =
              List<DocumentReference>.from(userDoc['chats']);

          // Fetch each chat object
          List<DocumentSnapshot> chatDocs =
              await Future.wait(chatReferences.map((ref) => ref.get()));

          // Fetch user/doctor details for each chat
          List<Map<String, dynamic>> loadedChatDetails = [];
          for (var chatDoc in chatDocs) {
            if (chatDoc.exists && chatDoc['permission'] == 'accepted') {
              // Fetch user or doctor document
              DocumentReference userOrDoctorRef = currentUserRole == 'doctor'
                  ? chatDoc['user'] // Reference to the user document
                  : chatDoc['doctor']; // Reference to the doctor document

              DocumentSnapshot userOrDoctorDoc = await userOrDoctorRef.get();
              
              // Add the chat and associated user/doctor to the list
              loadedChatDetails.add({
                'chat': chatDoc,
                'userOrDoctor': userOrDoctorDoc,
              });
            }
          }

          setState(() {
            chatDetails = loadedChatDetails; // Set the fetched chat details
          });
        } else {
          // If chats array is not present, create an empty array
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.user!.uid)
              .update({
            'chats': [],
          });
        }
      }
    } catch (e) {
      print('Error fetching chats: $e');
    } finally {
      if (mounted){
        setState(() {
        isLoading = false; // Stop loading indicator after fetching data
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const Center(child: Text('No user available.'));
    }

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return currentUserRole == null
        ? Center(child: CircularProgressIndicator(color: Color(0xFF0064F7),))
        : chatDetails.isEmpty
            ? Center(child: Text('No chats available.'))
            : Column(
                children: chatDetails.map((chatMap) {
                  // Extract chat and user/doctor details
                  final chat = chatMap['chat'] as DocumentSnapshot;
                  final userOrDoctor = chatMap['userOrDoctor'] as DocumentSnapshot;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(
                          userOrDoctor['profileImageUrl'] ?? ''),
                    ),
                    title: Text(userOrDoctor['displayName'] ?? 'Unknown'),
                    onTap: () {
                      // Handle chat item tap
                      // Navigator.push(...);
                    },
                  );
                }).toList(),
              );
  }
}