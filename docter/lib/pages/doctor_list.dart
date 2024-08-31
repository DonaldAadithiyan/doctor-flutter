import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../users/doctor.dart'; // Import the DoctorPage
import 'package:flutter/cupertino.dart';

class DoctorsListPage extends StatelessWidget {
  const DoctorsListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Our Specialists',
          style: TextStyle(
            fontFamily: 'SFProDisplay',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black, // Adjust the color to match your theme
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color:Color(0xFF0064F7)));
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
                    return const Center(child: CircularProgressIndicator(color:Color(0xFF0064F7)));
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
                          builder: (context) => DoctorPage(doctor: doctor),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        // boxShadow: [
                        //   BoxShadow(
                        //     color: Colors.grey.withOpacity(0.9),
                        //     spreadRadius: 2,
                        //     blurRadius: 5,
                        //   ),
                        // ],
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
                                    color: Color(0xFFF6F7F9),
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: Color(0xFFF6F7F9).withOpacity(0.9),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(CupertinoIcons.location_solid,
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
                                          fontSize: 10, // Adjust font size as needed
                                          color: Colors.black54,
                                        ),
                                        maxLines: 1, // Ensure the text is restricted to one line
                                        overflow: TextOverflow.ellipsis, // Add ellipsis if the text overflows
                                        softWrap: false, // Prevent the text from wrapping onto a new line
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
    );
  }
}
