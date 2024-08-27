import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorPage extends StatelessWidget {
  final QueryDocumentSnapshot doctor;

  const DoctorPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final doctorData = doctor.data() as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: Text(doctorData['name'] ?? 'Doctor Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                doctorData['profileImageUrl'] ??
                    'https://example.com/default-profile.png',
              ),
            ),
            const SizedBox(height: 16),
            Text(
              doctorData['name'] ?? 'No name available',
              // style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 8),
            Text(
              doctorData['specialty'] ?? 'No specialty available',
              // style: Theme.of(context).textTheme.subtitle1,
            ),
            const SizedBox(height: 16),
            Text(
              'Biography: ${doctorData['bio'] ?? 'No biography available'}',
              // style: Theme.of(context).textTheme.bodyText2,
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
