import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'appointment.dart';

class CalendarPage extends StatefulWidget {
  final User? user;

  const CalendarPage({super.key, this.user});

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDay = DateTime.now();
  List<DocumentReference> appointments = [];

  @override
  void initState() {
    super.initState();
    _fetchUserAppointments();
  }

  Future<void> _fetchUserAppointments() async {
    if (widget.user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(widget.user!.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data();
          if (userData != null && userData.containsKey('role')) {
            String userRole = userData['role'];

            if (userRole == 'user' && userData.containsKey('appointments')) {
              setState(() {
                appointments = List<DocumentReference>.from(userData['appointments']);
              });
            } else if (userRole == 'doctor' && userData.containsKey('docref')) {
              DocumentReference docRef = userData['docref'];
              final doctorDoc = await docRef.get();
              final doctorData = doctorDoc.data() as Map<String, dynamic>?;
              if (doctorData != null && doctorData.containsKey('appointments')) {
                setState(() {
                  appointments = List<DocumentReference>.from(doctorData['appointments']);
                });
              }
            }
          }
        }
      } catch (e) {
        print("Error fetching appointments: $e");
      }
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
    });
  }

  bool _isSameDay(DateTime date) {
    return date.year == _selectedDay.year &&
        date.month == _selectedDay.month &&
        date.day == _selectedDay.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar(
              locale: 'en-US',
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronIcon: Icon(
                  CupertinoIcons.left_chevron,
                  color: Color(0xFF0064F7),
                  size: 15,
                ),
                rightChevronIcon: Icon(
                  CupertinoIcons.right_chevron,
                  color: Color(0xFF0064F7),
                  size: 15,
                ),
              ),
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              availableGestures: AvailableGestures.all,
              onDaySelected: _onDaySelected,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
            ),
          ),
          Expanded(
            child: appointments.isNotEmpty
                ? ListView.builder(
                    itemCount: appointments.length,
                    itemBuilder: (context, index) {
                      final appointmentRef = appointments[index];

                      return FutureBuilder<DocumentSnapshot>(
                        future: appointmentRef.get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return const Text('Error loading appointment');
                          }

                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Text('No appointment data found');
                          }

                          final appointmentData =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final timestamp =
                              (appointmentData['timestamp'] as Timestamp).toDate();

                          if (_isSameDay(timestamp)) {
                            final doctorRef = appointmentData['doctor'];
                            final locationRef = appointmentData['location'];

                            return FutureBuilder<DocumentSnapshot>(
                              future: doctorRef.get(),
                              builder: (context, doctorSnapshot) {
                                if (doctorSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }

                                if (!doctorSnapshot.hasData ||
                                    doctorSnapshot.data == null) {
                                  return const Text('No doctor data found');
                                }

                                final doctorData = doctorSnapshot.data!.data()
                                    as Map<String, dynamic>;
                                final profileImageUrl =
                                    doctorData['profileImageUrl'];
                                final doctorName = doctorData['name'];
                                final specialization =
                                    doctorData['specialization'];

                                return FutureBuilder<DocumentSnapshot>(
                                  future: locationRef.get(),
                                  builder: (context, locationSnapshot) {
                                    if (locationSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }

                                    if (!locationSnapshot.hasData ||
                                        locationSnapshot.data == null) {
                                      return const Text('No location data found');
                                    }

                                    final locationData =
                                        locationSnapshot.data!.data()
                                            as Map<String, dynamic>;
                                    final locationName = locationData['name'];

                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AppointmentPage(
                                                    appointment:
                                                        snapshot.data),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: CircleAvatar(
                                                backgroundImage:
                                                    NetworkImage(profileImageUrl),
                                              ),
                                              title: Text(doctorName),
                                              subtitle: Text(specialization),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                                ),
                                                const Icon(Icons.access_time),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${timestamp.hour}:${timestamp.minute}',
                                                ),
                                                const Icon(Icons.location_on),
                                                const SizedBox(width: 4),
                                                Text(locationName),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else {
                            return Container(); // No appointment for this day
                          }
                        },
                      );
                    },
                  )
                : const Center(child: Text('No appointments')),
          ),
        ],
      ),
    );
  }
}
