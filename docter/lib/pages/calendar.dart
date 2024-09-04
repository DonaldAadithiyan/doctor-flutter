import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';

class CalendarPage extends StatelessWidget {
  final User? user; // Nullable user parameter

  const CalendarPage({super.key, this.user}); // Constructor with nullable user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: <Widget>[
          // The Calendar widget from the package
          Expanded(
            child: Calendar(
              startOnMonday: true,
              weekDays: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
              eventsList: const [], // You should replace with your event list
              isExpandable: true,
              eventDoneColor: Colors.green,
              selectedColor: Color(0xFF0064F7),
              selectedTodayColor: Colors.red,
              todayColor: Color(0xFF0064F7),
              eventColor: null,
              locale: 'de_DE',
              todayButtonText: '',
              allDayEventText: 'Ganztägig',
              multiDayEndText: 'Ende',
              isExpanded: true,
              expandableDateFormat: 'dd MMMM yyyy',
              showEventListViewIcon: false,
              
              datePickerType: DatePickerType.hidden,
              dayOfWeekStyle: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
          // Add any additional widgets if needed, such as a ListView
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Define your action here, e.g., navigate to a new event page
      //   },
      //   child: const Icon(Icons.add),
      //   backgroundColor: Colors.green,
      // ),
    );
  }
}
