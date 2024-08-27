import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../users/doctor.dart';

class HomePage extends StatefulWidget {
  final User? user;

  HomePage({this.user});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  String? _profileImageURL;
  String? _profileUsername;
  bool _isListVisible = false; // Control the visibility of the ListView

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() {
          _isListVisible = false;
        });
      }
    });

    if (widget.user != null) {
      _loadUserProfileImage();
    }
  }

  Future<void> _loadUserProfileImage() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.user!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _profileImageURL = userDoc['profileImageUrl'] ??
            'https://firebasestorage.googleapis.com/v0/b/docter-63df0.appspot.com/o/profileimages%2FProfile_avatar_placeholder_large.png?alt=media&token=69f5245e-8ca5-4a24-9e2f-2e2cbeef8584';
        _profileUsername = userDoc['displayName'] ?? 'Anonymous';
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _searchDoctors(String query) {
    if (query.isEmpty) {
      return const Stream.empty();
    }
    return FirebaseFirestore.instance
        .collection('doctors')
        .where('name', isGreaterThanOrEqualTo: query)
        .limit(5)
        .snapshots();
  }

  void _handleTapOutside(BuildContext context) {
    FocusScope.of(context).unfocus(); // Hide keyboard
    setState(() {
      _isListVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.user == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    return GestureDetector(
      onTap: () => _handleTapOutside(context),
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: CircleAvatar(
              backgroundImage: _profileImageURL != null
                  ? NetworkImage(_profileImageURL!)
                  : const NetworkImage(
                          'https://firebasestorage.googleapis.com/v0/b/docter-63df0.appspot.com/o/profileimages%2FProfile_avatar_placeholder_large.png?alt=media&token=69f5245e-8ca5-4a24-9e2f-2e2cbeef8584')
                      as ImageProvider,
              radius: 30,
            ),
          ),
          title: Row(
            children: [
              const SizedBox(width: 2),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hello 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _profileUsername ?? '',
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 6.0),
              child: IconButton(
                icon: const Icon(
                  CupertinoIcons.bell,
                  size: 26,
                ),
                onPressed: () {
                  // Handle bell icon press
                },
              ),
            ),
          ],
          toolbarHeight: 80,
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                placeholder: 'Search for Doctors, Fields',
                placeholderStyle: const TextStyle(
                  fontFamily: 'SFProDisplay',
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF979797),
                ),
                prefixIcon: const Icon(
                  CupertinoIcons.search,
                  color: Color(0xFF979797),
                ),
                backgroundColor: Colors.white,
                borderRadius: BorderRadius.circular(30),
                onTap: () {
                  setState(() {
                    _isListVisible =
                        true; // Show the list when the search field is tapped
                  });
                },
              ),
            ),
            Visibility(
              visible: _isListVisible,
              child: StreamBuilder<QuerySnapshot>(
                stream: _searchDoctors(_searchQuery),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0064F7),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final results = snapshot.data!.docs;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final doctor = results[index];
                          final doctorData =
                              doctor.data() as Map<String, dynamic>;
                          return ListTile(
                            minVerticalPadding: 3,
                            leading: CircleAvatar(
                              backgroundImage: doctorData['profileImageUrl'] !=
                                      null
                                  ? NetworkImage(doctorData['profileImageUrl'])
                                  : const AssetImage(
                                          'assets/profile_placeholder.png')
                                      as ImageProvider,
                              radius: 20,
                            ),
                            title: Text(
                              doctorData['name'],
                              style: const TextStyle(fontSize: 16),
                            ),
                            subtitle: Text(
                              doctorData['specialization'],
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DoctorPage(doctor: doctor),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Center(
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
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text('Details Page'),
      ),
    );
  }
}
