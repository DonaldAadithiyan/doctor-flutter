import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppointmentPage extends StatefulWidget {
  final DocumentSnapshot? appointment;

  const AppointmentPage({super.key, this.appointment});

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  bool isReasonEditable = false;
  bool isDescriptionEditable = false;
  String reason = '';
  String description = '';
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
  }

  Future<void> fetchUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userRole = userDoc['role'];
      });
    }
  }

  Future<void> deleteAppointment() async {
    try {
      // Delete the appointment document
      await widget.appointment?.reference.delete();

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment deleted successfully')),
      );

      // Navigate back to the previous screen
      Navigator.of(context).pop();
    } catch (error) {
      // Show error message if delete fails
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
                  alignment: Alignment.centerLeft,
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
                    content: const Text(
                        'Are you sure you want to delete this appointment?'),
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
                          Navigator.of(context).pop(); // Close the dialog
                          deleteAppointment(); // Call the delete function
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
            return const Center(child: CircularProgressIndicator());
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
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Doctor Profile Image
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
                        // Doctor Details
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
                                              : 'No rating available',
                                          style: const TextStyle(
                                            fontSize: 14,
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

                  // Reason Row with Edit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reason',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(
                        CupertinoIcons.pencil,
                        color: Color(0xFF0064F7),
                        size: 24,
                      ),
                        onPressed: () {
                          if (userRole == 'user') {
                            setState(() {
                              isReasonEditable = !isReasonEditable;
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  title: Text('Permission Denied'),
                                  content: Text('Only users can edit the reason.'),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  if (isReasonEditable)
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          reason = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter reason',
                        border: OutlineInputBorder(),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(reason.isNotEmpty ? reason : 'No reason provided'),
                    ),
                  const SizedBox(height: 20),

                  // Doctor Description Row with Edit Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Doctor Description',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(
                        CupertinoIcons.pencil,
                        color: Color(0xFF0064F7),
                        size: 24,
                      ),
                        onPressed: () {
                          if (userRole == 'doctor') {
                            setState(() {
                              isDescriptionEditable = !isDescriptionEditable;
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  title: Text('Permission Denied'),
                                  content: Text(
                                      'Only doctors can edit the description.'),
                                );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  if (isDescriptionEditable)
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Enter description',
                        border: OutlineInputBorder(),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(description.isNotEmpty
                          ? description
                          : 'No description provided'),
                    ),
                  const SizedBox(height: 20),

                  // Review Section
                  const Text(
                    'Review',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      appointmentData['review'] ?? 'No review provided',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
