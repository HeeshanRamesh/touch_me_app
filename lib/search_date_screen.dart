import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class SearchDateScreen extends StatefulWidget {
  const SearchDateScreen({super.key});

  @override
  _SearchDateScreenState createState() => _SearchDateScreenState();
}

class _SearchDateScreenState extends State<SearchDateScreen> {
  DateTime _focusedDay = DateTime(2025, 1, 1); // Start with January 2025
  DateTime? _selectedDay = DateTime(2025, 1, 9); // Selected date from screenshot

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B9A), // Purple color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Perfect Time',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Clear the selected date
              setState(() {
                _selectedDay = null;
              });
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TableCalendar(
              firstDay: DateTime(2020), // Arbitrary past date
              lastDay: DateTime(2030), // Arbitrary future date
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: true,
                outsideTextStyle: const TextStyle(color: Colors.grey),
                defaultTextStyle: const TextStyle(color: Colors.black),
                weekendTextStyle: const TextStyle(color: Colors.black),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xFF6A1B9A), // Purple background for selected date
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white),
                todayDecoration: BoxDecoration(
                  color: Colors.grey[300], // Light grey for today's date
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(color: Colors.black),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false, // Hide format button (week/month)
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: const Icon(Icons.arrow_left, color: Colors.black),
                rightChevronIcon: const Icon(Icons.arrow_right, color: Colors.black),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black),
                weekendStyle: TextStyle(color: Colors.black),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _selectedDay == null
                  ? null // Disable button if no date is selected
                  : () {
                      // Handle schedule action
                      // For example, navigate to the next screen or save the selected date
                      print('Scheduled on: $_selectedDay');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A), // Purple color
                minimumSize: const Size(double.infinity, 50), // Full-width button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Schedule',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}// TODO Implement this library.