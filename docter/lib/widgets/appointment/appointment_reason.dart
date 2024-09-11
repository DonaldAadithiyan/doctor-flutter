import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AppointmentReason extends StatefulWidget {
  final DocumentSnapshot? appointment;

  const AppointmentReason({Key? key, this.appointment}) : super(key: key);

  @override
  _AppointmentReasonState createState() => _AppointmentReasonState();
}

class _AppointmentReasonState extends State<AppointmentReason> {
  bool isEditable = false;
  bool showTextField = false;
  final TextEditingController reasonController = TextEditingController();
  String? userRole;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    if (widget.appointment != null) {
      final appointmentData = widget.appointment!.data() as Map<String, dynamic>;
      reasonController.text = appointmentData['reason'] ?? '';
    }
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
        isEditable = userRole == 'user'; // Only users can edit
      });
    }
  }

  Future<void> updateAppointmentField(String field, String value) async {
    try {
      await widget.appointment?.reference.update({field: value});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updated successfully')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reason',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (isEditable)
              IconButton(
                icon: const Icon(CupertinoIcons.pencil, color: Color(0xFF0064F7)),
                onPressed: () {
                  setState(() {
                    showTextField = !showTextField;
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (showTextField && isEditable)
          Column(
            children: [
              TextField(
                controller: reasonController,
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF979797).withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF0064F7),
                  side: const BorderSide(color: Color(0xFF0064F7), width: 1),
                  minimumSize: const Size(double.infinity, 40),
                ),
                onPressed: () {
                  updateAppointmentField('reason', reasonController.text);
                },
                child: const Text('Submit'),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(reasonController.text.isNotEmpty ? reasonController.text : 'No reason provided',
                style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
      ],
    );
  }
}