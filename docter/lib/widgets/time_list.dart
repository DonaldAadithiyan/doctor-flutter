import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeList extends StatefulWidget {
  final String selectedMonth;
  final int selectedDate;
  final Map<String, dynamic> doctor;

  const TimeList({
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

  @override
  void initState() {
    super.initState();
    fetchDefaultLocation(); // Fetch the default location initially
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
                    child: CircularProgressIndicator(color: Color(0xFF979797)),
                    width: 10,
                    height: 10,
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
              physics: const NeverScrollableScrollPhysics(),
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
                            await fetchSpecificLocation(
                                index.toString()); // Fetch specific location for selected time slot
                          }
                        },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Color(0xFF0064F7)
                          : (isUnavailable
                              ? Colors.white.withOpacity(0.2)
                              : Colors.white),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF0064F7)
                            : (isUnavailable
                                ? Colors.black.withOpacity(0.2)
                                : Colors.blue),
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
                                    ? Color(0xFF979797).withOpacity(0.3)
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
        if (selectedTimeSlot != null && !isLoadingLocation)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                print(
                    'Appointment made for ${widget.selectedDate} ${widget.selectedMonth} at $selectedTimeSlot location: $location');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                backgroundColor: Color(0xFF0064F7),
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
