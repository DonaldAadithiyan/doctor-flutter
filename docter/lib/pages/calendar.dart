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
  bool _isLoading = true;

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
                appointments =
                    List<DocumentReference>.from(userData['appointments']);
              });
            } else if (userRole == 'doctor' && userData.containsKey('docref')) {
              DocumentReference docRef = userData['docref'];
              final doctorDoc = await docRef.get();
              final doctorData = doctorDoc.data() as Map<String, dynamic>?;
              if (doctorData != null &&
                  doctorData.containsKey('appointments')) {
                setState(() {
                  appointments =
                      List<DocumentReference>.from(doctorData['appointments']);
                });
              }
            }
          }
        }
      } catch (e) {
        print("Error fetching appointments: $e");
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Reserved':
        return Colors.amber;
      case 'Finished':
        return Colors.green;
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey; // Default color if status is unknown
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Calendar',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'SFProDisplay',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Color(
                      0xFF0064F7), // Background color for the selected day
                  shape: BoxShape.circle, // Shape of the selected day indicator
                ),
                selectedTextStyle: TextStyle(
                  color: Colors.white, // Text color for the selected day
                ),
              ),
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              availableGestures: AvailableGestures.all,
              onDaySelected: _onDaySelected,
              selectedDayPredicate: (day) => _isSameDay(day),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF0064F7)))
              : Expanded(
                  child: appointments.isNotEmpty
                      ? FutureBuilder(
                          future: Future.wait(appointments
                              .map((appointmentRef) => appointmentRef.get())),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator(
                                      color: Color(0xFF0064F7)));
                            }

                            if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data == null) {
                              return const Center(
                                  child: Text('No appointments',
                                      style:
                                          TextStyle(color: Color(0xFF0064F7))));
                            }

                            List<DocumentSnapshot> appointmentSnapshots =
                                snapshot.data!;

                            // Flag to track if any appointment matches the selected date
                            bool hasAppointmentOnSelectedDate = false;

                            List<Widget> appointmentWidgets =
                                appointmentSnapshots.map((appointmentSnapshot) {
                              if (!appointmentSnapshot.exists) {
                                return const SizedBox.shrink();
                              }

                              final appointmentData = appointmentSnapshot.data()
                                  as Map<String, dynamic>;
                              final timestamp =
                                  (appointmentData['timestamp'] as Timestamp)
                                      .toDate();

                              if (_isSameDay(timestamp)) {
                                hasAppointmentOnSelectedDate =
                                    true; // Set flag if an appointment matches the date

                                final doctorRef = appointmentData['doctor'];
                                final locationRef = appointmentData['location'];
                                final status =
                                    appointmentData['status'] ?? 'unknown';

                                return FutureBuilder<DocumentSnapshot>(
                                  future: doctorRef.get(),
                                  builder: (context, doctorSnapshot) {
                                    if (!doctorSnapshot.hasData ||
                                        doctorSnapshot.data == null) {
                                      return const SizedBox.shrink();
                                    }

                                    final doctorData = doctorSnapshot.data!
                                        .data() as Map<String, dynamic>;
                                    final profileImageUrl =
                                        doctorData['profileImageUrl'];
                                    final doctorName = doctorData['name'];
                                    final specialization =
                                        doctorData['specialization'];

                                    return FutureBuilder<DocumentSnapshot>(
                                      future: locationRef.get(),
                                      builder: (context, locationSnapshot) {
                                        if (!locationSnapshot.hasData ||
                                            locationSnapshot.data == null) {
                                          return const SizedBox.shrink();
                                        }

                                        final locationData =
                                            locationSnapshot.data!.data()
                                                as Map<String, dynamic>;
                                        final locationName =
                                            locationData['name'];

                                        return GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AppointmentPage(
                                                        appointment:
                                                            appointmentSnapshot),
                                              ),
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10.0,
                                                right: 10.0,
                                                top: 8,
                                                bottom: 8),
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 2.0),
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey
                                                        .withOpacity(0.8),
                                                    width: 0.3),
                                                borderRadius:
                                                    BorderRadius.circular(12.0),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Stack(
                                                    children: [
                                                      Positioned(
                                                        right: 0,
                                                        top: 0,
                                                        child: Container(
                                                          height: 30,
                                                          width: 80,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          child: Center(
                                                            // Center the text inside the container
                                                            child: Text(
                                                              '$status',
                                                              style: TextStyle(
                                                                color: _getStatusColor(
                                                                    status), // Text color according to the status
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      ListTile(
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                        leading: CircleAvatar(
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  profileImageUrl),
                                                          radius: 35,
                                                        ),
                                                        title: Text(
                                                          doctorName,
                                                          style:
                                                              const TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          specialization,
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 8.0),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween, // Space the pairs evenly
                                                      children: [
                                                        // First Pair: Calendar icon and date text
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                CupertinoIcons
                                                                    .calendar_today,
                                                                color: Color(
                                                                    0xFF0064F7)),
                                                            const SizedBox(
                                                                width:
                                                                    4), // Slight spacing between icon and text
                                                            Text(
                                                              '${timestamp.day}/${timestamp.month}/${timestamp.year}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ],
                                                        ),
                                                        // Second Pair: Time icon and time text
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                CupertinoIcons
                                                                    .time,
                                                                color: Color(
                                                                    0xFF0064F7)),
                                                            const SizedBox(
                                                                width:
                                                                    4), // Slight spacing between icon and text
                                                            Text(
                                                              '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ],
                                                        ),
                                                        // Third Pair: Location icon and location name
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                                CupertinoIcons
                                                                    .location,
                                                                color: Color(
                                                                    0xFF0064F7)),
                                                            const SizedBox(
                                                                width:
                                                                    4), // Slight spacing between icon and text
                                                            Text(
                                                              locationName,
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          14),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            }).toList();

                            return hasAppointmentOnSelectedDate
                                ? ListView(children: appointmentWidgets)
                                : const Center(
                                    child: Text(
                                        'No appointments on selected date',
                                        style: TextStyle(
                                            color: Color(0xFF0064F7))));
                          },
                        )
                      : const Center(
                          child: Text('No appointments found',
                              style: TextStyle(color: Color(0xFF0064F7)))),
                ),
        ],
      ),
    );
  }
}
