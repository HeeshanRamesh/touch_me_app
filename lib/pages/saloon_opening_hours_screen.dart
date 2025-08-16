
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SaloonOpeningHoursScreen extends StatefulWidget {
  final Map<String, Map<String, String>> openingHours;

  const SaloonOpeningHoursScreen({super.key, required this.openingHours});

  @override
  State<SaloonOpeningHoursScreen> createState() => _SaloonOpeningHoursScreenState();
}

class _SaloonOpeningHoursScreenState extends State<SaloonOpeningHoursScreen> {
  late Map<String, Map<String, String>> _openingHours;

  @override
  void initState() {
    super.initState();
    // Initialize with provided hours or default
    _openingHours = Map.from(widget.openingHours.isNotEmpty
        ? widget.openingHours
        : {
            "monday": {"open": "08:00", "close": "18:00"},
            "tuesday": {"open": "08:00", "close": "18:00"},
            "wednesday": {"open": "08:00", "close": "18:00"},
            "thursday": {"open": "08:00", "close": "18:00"},
            "friday": {"open": "08:00", "close": "18:00"},
            "saturday": {"open": "09:00", "close": "15:00"},
            "sunday": {"open": "", "close": ""},
          });
  }

  Future<void> _selectTime(BuildContext context, String day, String type) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: _parseHour(_openingHours[day]![type] ?? "08:00"),
        minute: _parseMinute(_openingHours[day]![type] ?? "08:00"),
      ),
    );
    if (picked != null) {
      setState(() {
        final formattedTime = DateFormat('HH:mm').format(
          DateTime(2025, 1, 1, picked.hour, picked.minute),
        );
        _openingHours[day]![type] = formattedTime;
      });
    }
  }

  int _parseHour(String time) {
    if (time.isEmpty) return 8;
    return int.parse(time.split(':')[0]);
  }

  int _parseMinute(String time) {
    if (time.isEmpty) return 0;
    return int.parse(time.split(':')[1]);
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF6A1B9A),
        ),
      ),
    );
  }

  BoxDecoration _fieldDecoration() {
    return BoxDecoration(
      border: Border.all(color: const Color(0xFF6A1B9A), width: 1.2),
      borderRadius: BorderRadius.circular(25),
      color: const Color(0xFFF3E5F5),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime currentDateTime = DateTime.now();
    final String formattedDateTime = DateFormat(
      'hh:mm a Z \'on\' EEEE, MMMM d, yyyy',
    ).format(currentDateTime.toUtc().add(const Duration(hours: 5, minutes: 30)));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Opening Hours"),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Set Opening Hours",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB71C9B),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  formattedDateTime,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF6A1B9A)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ..._openingHours.keys.map((day) {
                final isClosed = _openingHours[day]!['open']!.isEmpty &&
                    _openingHours[day]!['close']!.isEmpty;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFieldLabel(day.capitalize()),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: isClosed ? null : () => _selectTime(context, day, 'open'),
                            child: Container(
                              decoration: _fieldDecoration(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Text(
                                isClosed ? 'Closed' : (_openingHours[day]!['open'] ?? 'Select time'),
                                style: TextStyle(
                                  color: isClosed ? Colors.grey : const Color(0xFF6A1B9A),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: isClosed ? null : () => _selectTime(context, day, 'close'),
                            child: Container(
                              decoration: _fieldDecoration(),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Text(
                                isClosed ? 'Closed' : (_openingHours[day]!['close'] ?? 'Select time'),
                                style: TextStyle(
                                  color: isClosed ? Colors.grey : const Color(0xFF6A1B9A),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Checkbox(
                          value: isClosed,
                          onChanged: (value) {
                            setState(() {
                              if (value!) {
                                _openingHours[day]!['open'] = '';
                                _openingHours[day]!['close'] = '';
                              } else {
                                _openingHours[day]!['open'] = '08:00';
                                _openingHours[day]!['close'] = '18:00';
                              }
                            });
                          },
                          activeColor: const Color(0xFF6A1B9A),
                        ),
                        const Text('Closed'),
                      ],
                    ),
                  ],
                );
              }).toList(),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _openingHours);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 5,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 60,
                      vertical: 14,
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
