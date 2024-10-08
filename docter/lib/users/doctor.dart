import 'package:docter/widgets/review_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/horizontal_calendar.dart'; // Import the HorizontalCalendar

class DoctorPage extends StatefulWidget {
  final QueryDocumentSnapshot doctor;

  const DoctorPage({super.key, required this.doctor});

  @override
  _DoctorPageState createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  bool isExpanded = false; // Controls whether the full text is shown
  String chatStatus = "create chat request"; // Default status
  bool isContainerClickable = true; // Controls container's clickability
  final FirebaseAuth _auth = FirebaseAuth.instance; // For the current user
  bool isLoading = false; // Controls the loading state

  @override
  void initState() {
    super.initState();
    checkChatStatus();
  }

  @override
  Widget build(BuildContext context) {
    final doctorData = widget.doctor.data() as Map<String, dynamic>;
    final socialMediaLinks =
        doctorData['socialMediaLinks'] as Map<String, dynamic>?;

    final String aboutMe = doctorData['AboutMe'] ?? 'No information available';
    const int textLimit = 140; // Character limit for the truncated text

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Doctor Details',
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black, // Adjust the color to match your theme
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Wrap the body with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey.shade300, // Adjust the color as needed
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        shape: BoxShape.rectangle,
                        image: DecorationImage(
                          image: NetworkImage(
                            doctorData['profileImageUrl'] ??
                                'https://example.com/default-profile.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  doctorData['name'] ?? 'No name available',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFF6F7F9).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFF6F7F9)
                                          .withOpacity(1),
                                      blurRadius: 17,
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.star_fill,
                                      color: Color(0xFF0064F7),
                                      size: 12,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      doctorData['star_rating'] != null
                                          ? '${doctorData['star_rating']}'
                                          : '0.0',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF0064F7),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      doctorData['review_count'] != null
                                          ? '(${doctorData['review_count']})'
                                          : '0',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                            doctorData['specialization'] ??
                                'No specialty available',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Email: ${doctorData['email'] ?? 'No email available'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Phone: ${doctorData['phoneNumber'] ?? 'Not Public'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              if (socialMediaLinks != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (socialMediaLinks.containsKey('Instagram') &&
                        socialMediaLinks['Instagram'] != "")
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/instagram.svg',
                            width: 24.0,
                            height: 24.0,
                            semanticsLabel: 'Instagram logo',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            socialMediaLinks['Instagram'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0064F7),
                            ),
                          ),
                        ],
                      ),
                    if (socialMediaLinks.containsKey('Facebook') &&
                        socialMediaLinks['Instagram'] != "")
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/facebook.svg',
                            width: 24.0,
                            height: 24.0,
                            semanticsLabel: 'Facebook logo',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            socialMediaLinks['Facebook'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0064F7),
                            ),
                          ),
                        ],
                      ),
                    if (socialMediaLinks.containsKey('Twitter') &&
                        socialMediaLinks['Instagram'] != "")
                      Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icon/twitter.svg',
                            width: 24.0,
                            height: 24.0,
                            semanticsLabel: 'Twitter logo',
                          ),
                          const SizedBox(width: 8),
                          Text(
                            socialMediaLinks['Twitter'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0064F7),
                            ),
                          ),
                        ],
                      ),
                    if (socialMediaLinks.containsKey('Website') &&
                        socialMediaLinks['Instagram'] != "")
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundImage:
                                AssetImage('assets/icon/internet.png'),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            socialMediaLinks['Website'],
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0064F7),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              GestureDetector(
                onTap: isContainerClickable
                    ? () {
                        if (chatStatus == "create chat request") {
                          createChatRequest(); // Create a new chat request
                        } else if (chatStatus == "Go to chat") {
                          // Handle navigation to chat page
                        }
                      }
                    : null,
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
                          color: const Color(0xFF0064F7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          CupertinoIcons.chat_bubble,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Text(
                        chatStatus == 'chat request sent'
                            ? 'Chat request sent'
                            : chatStatus == 'Go to chat'
                                ? 'Go to chat'
                                : 'Create chat request', // Default to 'Create chat request'
                        style: const TextStyle(
                          color: Color(0xFF0064F7),
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'About Me',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 10),
              // Display the truncated or full text with "See More" or "See Less" appended at the end
              RichText(
                text: TextSpan(
                  text: isExpanded
                      ? aboutMe
                      : aboutMe.length > textLimit
                          ? aboutMe.substring(0, textLimit)
                          : aboutMe,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                  children: [
                    if (aboutMe.length > textLimit)
                      TextSpan(
                        text: isExpanded ? '  See Less' : ' ... See More',
                        style: const TextStyle(
                          color: Color(0xFF0064F7),
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                      ),
                  ],
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 18),
              Text(
                'Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
              ReviewList(
                  doctor: widget.doctor), // Add the ReviewList widget here
              const SizedBox(height: 20), // Add some space before the calendar
              HorizontalCalendar(
                  doctor:
                      widget.doctor), // Add the HorizontalCalendar widget here
            ],
          ),
        ),
      ),
    );
  }

  Future<void> checkChatStatus() async {
  try {
    final doctorData = widget.doctor.data() as Map<String, dynamic>;
    final DocumentReference doctorUserRef = doctorData['user'];

    // Get the user document for the doctor
    final DocumentSnapshot doctorUserDoc = await doctorUserRef.get();

    if (doctorUserDoc.data() == null) {
      print('Doctor user document is null.');
      return;
    }

    final Map<String, dynamic> doctorUserData = doctorUserDoc.data() as Map<String, dynamic>;

    if (!doctorUserData.containsKey('chats')) {
      await doctorUserRef.update({'chats': []});
    }

    final List chats = doctorUserData['chats'];

    final User? loggedInUser = _auth.currentUser;
    if (loggedInUser == null) return;

    // Fetch all valid chat documents and ignore null ones
    final validChats = await Future.wait(chats.map((chatRef) async {
      final chatDoc = await chatRef.get();
      return chatDoc.exists && chatDoc.data() != null ? chatDoc : null;
    }));

    // Filter out null documents
    final nonNullChats = validChats.where((chatDoc) => chatDoc != null).toList();

    for (var chatDoc in nonNullChats) {
      final chatData = chatDoc!.data() as Map<String, dynamic>;

      final DocumentReference chatUserRef = chatData['user'];

      if (chatUserRef.id == loggedInUser.uid) {
        if (chatData['permission'] == 'waiting') {
          setState(() {
            chatStatus = "chat request sent";
            isContainerClickable = false;
          });
          return;
        } else if (chatData['permission'] == 'accepted') {
          setState(() {
            chatStatus = "Go to chat";
            isContainerClickable = true;
          });
          return;
        } else if (chatData['permission'] == 'denied') {
          setState(() {
            chatStatus = "create chat request";
            isContainerClickable = true;
          });
          return;
        }
      }
    }

    // If no matching chat found
    setState(() {
      chatStatus = "create chat request";
      isContainerClickable = true;
    });
  } catch (e) {
    print('Error in checking chat status: $e');
  }
}

  Future<void> createChatRequest() async {
    try {
      final doctorData = widget.doctor.data() as Map<String, dynamic>;
      final User? loggedInUser = _auth.currentUser;
      if (loggedInUser == null) return;

      // Get the reference to the doctor’s user object
      final DocumentReference doctorUserRef = doctorData['user'];

      // Create a reference to the 'chats' collection
      final CollectionReference chatsRef =
          FirebaseFirestore.instance.collection('chats');

      // Create the new chat document
      final DocumentReference newChatDocRef = await chatsRef.add({
        'user': FirebaseFirestore.instance
            .collection('users')
            .doc(loggedInUser.uid),
        'doctor': doctorUserRef,
        'permission': 'waiting',
      });

      // Add the new chat reference to the logged-in user's 'chats' field
      final DocumentReference loggedInUserRef =
          FirebaseFirestore.instance.collection('users').doc(loggedInUser.uid);
      await loggedInUserRef.update({
        'chats': FieldValue.arrayUnion([newChatDocRef])
      });

      // Add the new chat reference to the doctor's user document 'chats' field
      await doctorUserRef.update({
        'chats': FieldValue.arrayUnion([newChatDocRef])
      });

      // Update UI after creating the chat request
      setState(() {
        chatStatus = "chat request sent";
        isContainerClickable = false;
      });
    } catch (e) {
      print('Error creating chat request: $e');
    }
  }
}
