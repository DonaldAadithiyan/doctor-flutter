import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../users/doctor.dart'; // Import the DoctorPage
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class FieldPage extends StatelessWidget {
  final QueryDocumentSnapshot<Object?> field;

  const FieldPage({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    final fieldData = field.data() as Map<String, dynamic>?;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          fieldData?['name'] ?? 'Field Name',
          style: const TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display the field's icon
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  fieldData?['icon'] ??
                      'https://firebasestorage.googleapis.com/v0/b/docter-63df0.appspot.com/o/profileimages%2FProfile_avatar_placeholder_large.png?alt=media&token=69f5245e-8ca5-4a24-9e2f-2e2cbeef8584',
                ),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the field's description or "about" with "See More"/"See Less"
                AboutSection(aboutMe: fieldData?['about'] ?? 'No description available'),
                const SizedBox(height: 8.0),
                // Display the number of doctors
                const SizedBox(height: 8.0),
                Text(
                  'Specialists in ${(fieldData?['name'] ?? 'Field Name')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${(fieldData?['doctors'] as List<dynamic>?)?.length ?? 0} Doctors',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .where(FieldPath.documentId, whereIn: fieldData?['doctors'] as List<dynamic>? ?? [])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF0064F7)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No doctors available'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doctor = snapshot.data!.docs[index];
                    final doctorData = doctor.data() as Map<String, dynamic>;

                    return FutureBuilder<DocumentSnapshot>(
                      future: doctorData['default_location'].get(),
                      builder: (context, locationSnapshot) {
                        if (locationSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator(color: Color(0xFF0064F7)));
                        }

                        if (!locationSnapshot.hasData) {
                          return const Center(child: Text('Location not found'));
                        }

                        final locationData = locationSnapshot.data!.data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorPage(
                                  doctor: doctor,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.8),
                                width: 0.3,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 120,
                                  height: 125,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        doctorData['profileImageUrl'] ??
                                            'https://example.com/default-profile.png',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctorData['name'] ?? 'No name available',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        doctorData['specialization'] ??
                                            'No specialization available',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.star_fill,
                                            color: Colors.yellow,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            doctorData['star_rating'] != null
                                                ? '${doctorData['star_rating']}'
                                                : 'No rating available',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF6F7F9),
                                          borderRadius: BorderRadius.circular(8.0),
                                          border: Border.all(
                                            color: const Color(0xFFF6F7F9).withOpacity(0.9),
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(CupertinoIcons.location_solid,
                                                    color: Color(0xFF0064F7),
                                                    size: 12),
                                                const SizedBox(width: 8),
                                                Text(
                                                  locationData['name'] ?? 'No location name available',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              locationData['Address'] ?? 'No address available',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: Colors.black54,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AboutSection extends StatefulWidget {
  final String aboutMe;

  const AboutSection({super.key, required this.aboutMe});

  @override
  _AboutSectionState createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  bool isExpanded = false;
  final int textLimit = 150; // Set your desired character limit

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: isExpanded
            ? widget.aboutMe
            : widget.aboutMe.length > textLimit
                ? widget.aboutMe.substring(0, textLimit)
                : widget.aboutMe,
        style: const TextStyle(
          fontSize: 14,
          height: 1.5,
          color: Colors.black87,
        ),
        children: [
          if (widget.aboutMe.length > textLimit)
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
    );
  }
}
