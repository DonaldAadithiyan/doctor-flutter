import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'appointment_popup.dart';

class TimeList extends StatefulWidget {
  final String selectedMonth;
  dynamic selectedDate;
  final Map<String, dynamic> doctor;

  TimeList({
    super.key,
    required this.selectedMonth,
    required this.selectedDate,
    required this.doctor,
  });

  @override
  _TimeListState createState() => _TimeListState();
}

class _TimeListState extends State<TimeList> {
  String? selectedTimeSlot;
  String? location;
  bool isLoadingLocation = true;
  bool isLoadingAppointment = false;

  final List<String> timeIntervals = [
    '9:00 - 10:00',
    '10:00 - 11:00',
    '11:00 - 12:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
    '19:00 - 20:00',
    '20:00 - 21:00',
    '21:00 - 22:00',
  ];

  @override
  void initState() {
    super.initState();
    checkAndSetNextAvailableDate();
    fetchDefaultLocation(); // Fetch the default location initially
  }

  Future<void> checkAndSetNextAvailableDate() async {
    final Map<String, dynamic> unavailableHours =
        widget.doctor['unavailableHours'] as Map<String, dynamic>? ?? {};

    final monthUnavailableHours =
        unavailableHours[widget.selectedMonth] as Map<String, dynamic>?;

    final List<dynamic>? unavailableTimeSlots =
        monthUnavailableHours?[widget.selectedDate.toString()]
            as List<dynamic>?;

    if (unavailableTimeSlots != null &&
        unavailableTimeSlots.length == timeIntervals.length) {
      // If all time slots are unavailable for the selected date, find the next available date
      for (int i = widget.selectedDate + 1; i <= 31; i++) {
        final nextDayUnavailableTimeSlots =
            monthUnavailableHours?[i.toString()] as List<dynamic>?;
        if (nextDayUnavailableTimeSlots == null ||
            nextDayUnavailableTimeSlots.length != timeIntervals.length) {
          // Found a date with available slots
          setState(() {
            widget.selectedDate = i;
          });
          break;
        }
      }
    }
  }

  Future<void> fetchDefaultLocation() async {
    try {
      final defaultLocationRef =
          widget.doctor['default_location'] as DocumentReference;
      final defaultLocationSnapshot = await defaultLocationRef.get();
      final defaultLocationData =
          defaultLocationSnapshot.data() as Map<String, dynamic>?;

      setState(() {
        location = defaultLocationData?['name'] ?? 'Unknown location';
        isLoadingLocation = false;
      });
    } catch (e) {
      print('Error fetching default location: $e');
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  Future<void> fetchSpecificLocation(String index) async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      final Map<String, dynamic> locations =
          widget.doctor['location'] as Map<String, dynamic>? ?? {};
      final monthData =
          locations[widget.selectedMonth] as Map<String, dynamic>?;
      final dateData =
          monthData?[widget.selectedDate.toString()] as Map<String, dynamic>?;
      final specificLocationRef = dateData?[index];

      if (specificLocationRef != null &&
          specificLocationRef is DocumentReference) {
        final specificLocationSnapshot = await specificLocationRef.get();
        final specificLocationData =
            specificLocationSnapshot.data() as Map<String, dynamic>?;

        setState(() {
          location = specificLocationData?['name'] ?? location;
          isLoadingLocation = false;
        });
      } else {
        // If no specific location is found, revert to the default location
        fetchDefaultLocation();
      }
    } catch (e) {
      print('Error fetching specific location: $e');
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> unavailableHours =
        widget.doctor['unavailableHours'] as Map<String, dynamic>? ?? {};

    final monthUnavailableHours =
        unavailableHours[widget.selectedMonth] as Map<String, dynamic>?;

    final List<dynamic>? unavailableTimeSlots =
        monthUnavailableHours?[widget.selectedDate.toString()]
            as List<dynamic>?;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              "Select a time slot",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF979797),
              ),
            ),
            const SizedBox(height: 5),
            if (isLoadingLocation)
              const Row(
                children: [
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(color: Color(0xFF979797)),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Loading location...",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF979797),
                    ),
                  ),
                ],
              )
            else
              Text(
                "Location: $location",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF979797),
                ),
              ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              // physics: const NeverScrollableScrollPhysics(),
              itemCount: timeIntervals.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final isUnavailable =
                    unavailableTimeSlots?.contains(index.toString()) ?? false;
                final isSelected = selectedTimeSlot == timeIntervals[index];

                return GestureDetector(
                  onTap: isUnavailable
                      ? null
                      : () async {
                          if (isSelected) {
                            setState(() {
                              selectedTimeSlot = null;
                              fetchDefaultLocation(); // Revert to default location if time slot is unselected
                            });
                          } else {
                            setState(() {
                              selectedTimeSlot = timeIntervals[index];
                            });
                            await fetchSpecificLocation(index
                                .toString()); // Fetch specific location for selected time slot
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF0064F7)
                          : (isUnavailable
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0064F7)
                            : (isUnavailable
                                ? Colors.black.withOpacity(0.2)
                                : const Color(0xFF0064F7)),
                      ),
                    ),
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          timeIntervals[index],
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : (isUnavailable
                                    ? const Color(0xFF979797).withOpacity(0.3)
                                    : Colors.black),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        if (isLoadingAppointment)
          Container(
            color: Colors.white.withOpacity(0.9),
            height: 320,
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0064F7),
              ),
            ),
          )
        else if (selectedTimeSlot != null && !isLoadingLocation)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoadingAppointment = true;
                });

                try {
                  // Get the current logged-in user
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    print("No user is logged in");
                    return;
                  }

                  // Convert selected date, month, and time slot to a DateTime object
                  String timeSlot = selectedTimeSlot!;
                  List<String> timeParts = timeSlot.split(" - ");
                  int startHour = int.parse(timeParts[0].split(":")[0]);
                  int startMinute = int.parse(timeParts[0].split(":")[1]);

                  // Map month names to their respective numbers
                  final Map<String, int> monthMap = {
                    'January': 1,
                    'February': 2,
                    'March': 3,
                    'April': 4,
                    'May': 5,
                    'June': 6,
                    'July': 7,
                    'August': 8,
                    'September': 9,
                    'October': 10,
                    'November': 11,
                    'December': 12,
                  };

                  // Get the month number from the selected month name
                  int monthNumber = monthMap[widget.selectedMonth]!;

                  // Create a DateTime object for the appointment
                  DateTime appointmentDateTime = DateTime(
                    DateTime.now().year, // Assuming the current year
                    monthNumber,
                    widget.selectedDate,
                    startHour,
                    startMinute,
                  );

                  // Get the DocumentReference of the logged-in user
                  DocumentReference userRef = FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid);

                  // Get the DocumentReference of the doctor
                  String doctorId = widget.doctor[
                      'id']; // Assuming 'id' is the key for the doctor's document ID in the map
                  DocumentReference doctorRef = FirebaseFirestore.instance
                      .collection('doctors')
                      .doc(doctorId);

                  // Get the DocumentReference of the location
                  DocumentReference? locationRef;
                  if (location != null) {
                    final locationQuerySnapshot = await FirebaseFirestore
                        .instance
                        .collection('locations')
                        .where('name', isEqualTo: location)
                        .limit(1)
                        .get();

                    if (locationQuerySnapshot.docs.isNotEmpty) {
                      locationRef = locationQuerySnapshot.docs.first.reference;
                    } else {
                      print('Location not found in locations collection');
                      return;
                    }
                  }

                  // Create the appointment document
                  // Create the appointment document and get the document reference
                  DocumentReference appointmentRef = FirebaseFirestore
                      .instance
                      .collection('appointments')
                      .doc();
                  await appointmentRef.set({
                    'description': '',
                    'doctor': doctorRef,
                    'status': 'Reserved',
                    'timestamp': appointmentDateTime,
                    'user': userRef,
                    'location': locationRef,
                    'userFeedback': '',
                    'reviews': [],
                  });

                  // Add the appointment reference to the user's 'appointments' array
                  await userRef.update({
                    'appointments': FieldValue.arrayUnion([appointmentRef]),
                  });
                  print("user ku appointment added");

                  print(doctorRef);
                  // Add the appointment reference to the doctor's 'appointments' array
                  await doctorRef.update({
                    'appointments': FieldValue.arrayUnion([appointmentRef]),
                  });
                  
                  print("dcotor ku appointment added");

                  print(
                      'Appointment made for ${widget.selectedDate} ${widget.selectedMonth} at $selectedTimeSlot location: $location');
                  setState(() {
                    isLoadingAppointment = false;
                  });
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AppointmentPopup(
                        date: '${widget.selectedDate} ${widget.selectedMonth}',
                        timeSlot: selectedTimeSlot!,
                        location: location!,
                      );
                    },
                  );
                } catch (e) {
                  print('Error creating appointment: $e');
                  setState(() {
                    isLoadingAppointment = false;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: const Color(0xFF0064F7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Make an Appointment',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
