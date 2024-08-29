import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../users/doctor.dart';

class CarouselDoctors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF0064F7)),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No doctors available'),
          );
        }

        final doctors = snapshot.data!.docs;

        return SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index].data() as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoctorPage(doctor: doctors[index]),
                    ),
                  );
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: doctor['profileImageUrl'] != null
                            ? NetworkImage(doctor['profileImageUrl'])
                            : const AssetImage('assets/profile_placeholder.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        doctor['name'] ?? 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 1),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Text(
                                doctor['specialization'] ?? 'Specialization',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Icon(
                              CupertinoIcons.star,
                              color: Colors.amber,
                              size: 15,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              doctor['star_rating']?.toStringAsFixed(1) ??
                                  '0.0',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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
          ),
        );
      },
    );
  }
}
