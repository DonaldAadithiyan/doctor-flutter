import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentPage extends StatelessWidget {
  final DocumentSnapshot? appointment;

  const AppointmentPage({super.key, this.appointment});

  @override
  Widget build(BuildContext context) {
    final appointmentData = appointment?.data() as Map<String, dynamic>;
    final timestamp = (appointmentData['timestamp'] as Timestamp).toDate();
    final doctorRef = appointmentData['doctor'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: doctorRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Text('Error loading doctor details');
          }

          final doctorData = snapshot.data!.data() as Map<String, dynamic>;
          final doctorName = doctorData['name'];
          final specialization = doctorData['specialization'];
          final profileImageUrl = doctorData['profileImageUrl'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(profileImageUrl),
                ),
                const SizedBox(height: 16),
                Text(
                  doctorName,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(specialization),
                const SizedBox(height: 16),
                Text(
                  'Appointment Date: ${timestamp.day}/${timestamp.month}/${timestamp.year}',
                ),
                Text(
                  'Appointment Time: ${timestamp.hour}:${timestamp.minute}',
                ),
                // Add more fields as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
