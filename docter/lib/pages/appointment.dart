import 'package:docter/widgets/appointment/appointment_description.dart';
import 'package:docter/widgets/appointment/appointment_reason.dart';
import 'package:docter/widgets/appointment/appointment_review.dart';
import 'package:docter/widgets/review_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AppointmentPage extends StatefulWidget {
  final DocumentSnapshot? appointment;

  const AppointmentPage({super.key, this.appointment});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String? userRole;

  @override
  void initState() {
    super.initState();
  }

  

  Future<void> deleteAppointment() async {
    try {
      await widget.appointment?.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted successfully')),
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete appointment: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointmentData = widget.appointment?.data() as Map<String, dynamic>;
    final timestamp = (appointmentData['timestamp'] as Timestamp).toDate();
    final doctorRef = appointmentData['doctor'];

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Appointment details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Only display the delete icon if the appointment is in the future
          if (timestamp.isAfter(DateTime.now())) 
            IconButton(
              icon: const Icon(
                CupertinoIcons.trash,
                color: Color(0xFF0064F7),
                size: 18,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Delete Appointment'),
                      content: const Text('Are you sure you want to delete this appointment?'),
                      actions: [
                        TextButton(
                          child: const Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text('Delete'),
                          onPressed: () {
                            Navigator.of(context).pop();
                            deleteAppointment();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: doctorRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 10, // Adjust the width to make it smaller
                height: 10, // Adjust the height to make it smaller
                child: CircularProgressIndicator(
                  strokeWidth: 3, // Adjust the stroke width to make it thinner
                ),
              ),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading doctor details'));
          }

          final doctorData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Info Container
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(5.0),
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
                                      color: const Color(0xFFF6F7F9)
                                          .withOpacity(0.1),
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
                                        const SizedBox(width: 2),
                                        Text(
                                          doctorData['review_count'] != null
                                              ? '(${doctorData['review_count']})'
                                              : '0',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0064F7),
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

                  // Date and Time Row
                  const Text(
                    'Date',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                        color: Color(0xFF0064F7),
                        size: 24,
                      ),
                      const SizedBox(width: 15),
                      Text(
                        '${timestamp.day}/${timestamp.month}/${timestamp.year} - ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Reason Input Field
                  AppointmentReason(appointment: widget.appointment),

                  const SizedBox(height: 20),

                  // Doctor Description Input Field
                  AppointmentDescription(appointment: widget.appointment),

                  const SizedBox(height: 20),

                  // Review Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Review',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      AppointmentReview(appointment: widget.appointment),
                    ],
                  ),
                  ReviewList(appointment: widget.appointment), // Add the review component here
                  
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}