import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'time_list.dart'; // Import TimeList

class HorizontalCalendar extends StatefulWidget {
  final QueryDocumentSnapshot doctor;

  const HorizontalCalendar({super.key, required this.doctor});

  @override
  _HorizontalCalendarState createState() => _HorizontalCalendarState();
}

class _HorizontalCalendarState extends State<HorizontalCalendar> {
  DateTime selectedDate = DateTime.now();
  DateTime today = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final doctorData = widget.doctor.data() as Map<String, dynamic>;
    final Map<String, List<int>> unAvailableDates =
        (doctorData['unAvailableDates'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        (value as List).map((e) {
          try {
            return int.parse(e.toString());
          } catch (e) {
            return null;
          }
        }).where((e) => e != null).cast<int>().toList(),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            DateFormat('MMMM').format(selectedDate),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF979797),
            ),
          ),
        ),
        SizedBox(
          height: 70,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 1000, // Large number to simulate infinite scrolling
            itemBuilder: (context, index) {
              // Calculate the date based on the index
              DateTime date = today.subtract(const Duration(days: 3)).add(Duration(days: index));
              bool isUnavailable = _isDateUnavailable(date, unAvailableDates);
              bool isSelected = date.day == selectedDate.day &&
                                date.month == selectedDate.month &&
                                date.year == selectedDate.year;
              bool isPastDate = date.isBefore(today);

              return GestureDetector(
                onTap: isUnavailable || isPastDate
                    ? null
                    : () {
                        setState(() {
                          selectedDate = date;
                        });
                        print(DateFormat('MMMM dd').format(selectedDate));
                      },
                child: Container(
                  width: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0064F7)
                        : isUnavailable || isPastDate
                            ? Colors.white.withOpacity(0.5)
                            : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isUnavailable || isPastDate
                          ? Colors.black.withOpacity(0.2)
                          : isSelected
                              ? Colors.transparent
                              : const Color(0xFF0064F7),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('E').format(date),
                        style: TextStyle(
                          color: isUnavailable || isPastDate
                              ? Colors.black.withOpacity(0.09)
                              : isSelected
                                  ? Colors.white
                                  : Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: TextStyle(
                          color: isUnavailable || isPastDate
                              ? Colors.black.withOpacity(0.08)
                              : isSelected
                                  ? Colors.white
                                  : Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Add the TimeList widget here, passing the necessary data
        TimeList(
          selectedMonth: DateFormat('MMMM').format(selectedDate),
          selectedDate: selectedDate.day,
          doctor: doctorData,
        ),
      ],
    );
  }

  bool _isDateUnavailable(
      DateTime date, Map<String, List<int>> unAvailableDates) {
    String month = DateFormat('MMMM').format(date);
    List<int>? unavailableDates = unAvailableDates[month];
    return unavailableDates?.contains(date.day) ?? false;
  }
}
