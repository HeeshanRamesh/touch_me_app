import 'package:flutter/material.dart';

class SaloonOpeningHoursScreen extends StatefulWidget {
  const SaloonOpeningHoursScreen({super.key});

  @override
  State<SaloonOpeningHoursScreen> createState() => _SaloonOpeningHoursScreenState();
}

class _SaloonOpeningHoursScreenState extends State<SaloonOpeningHoursScreen> {
  // Map to store opening hours for each day
  final Map<String, Map<String, dynamic>> _openingHours = {
    'Monday': {'open': const TimeOfDay(hour: 9, minute: 0), 'close': const TimeOfDay(hour: 17, minute: 0), 'isClosed': false},
    'Tuesday': {'open': const TimeOfDay(hour: 9, minute: 0), 'close': const TimeOfDay(hour: 17, minute: 0), 'isClosed': false},
    'Wednesday': {'open': const TimeOfDay(hour: 9, minute: 0), 'close': const TimeOfDay(hour: 17, minute: 0), 'isClosed': false},
    'Thursday': {'open': const TimeOfDay(hour: 9, minute: 0), 'close': const TimeOfDay(hour: 17, minute: 0), 'isClosed': false},
    'Friday': {'open': const TimeOfDay(hour: 9, minute: 0), 'close': const TimeOfDay(hour: 17, minute: 0), 'isClosed': false},
    'Saturday': {'open': const TimeOfDay(hour: 9, minute: 0), 'close': const TimeOfDay(hour: 17, minute: 0), 'isClosed': false},
    'Sunday': {'open': const TimeOfDay(hour: 9, minute: 0), 'close': const TimeOfDay(hour: 17, minute: 0), 'isClosed': true},
  };

  bool _isSubmitting = false;

  // Format TimeOfDay to "HH:mm" string
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Show time picker and update the selected time
  Future<void> _selectTime(BuildContext context, String day, bool isOpenTime) async {
    if (_openingHours[day]!['isClosed']) {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: isOpenTime ? _openingHours[day]!['open'] : _openingHours[day]!['close'],
      );
      if (picked != null && mounted) {
        setState(() {
          if (isOpenTime) {
            _openingHours[day]!['open'] = picked;
          } else {
            _openingHours[day]!['close'] = picked;
          }
        });
      }
    }
  }

  // Handle form submission
  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Convert opening hours to the format expected by signupMerchant
      final Map<String, Map<String, String>> formattedHours = {};
      _openingHours.forEach((day, times) {
        if (times['isClosed']) {
          formattedHours[day] = {'open': 'closed', 'close': 'closed'};
        } else {
          formattedHours[day] = {
            'open': _formatTimeOfDay(times['open']),
            'close': _formatTimeOfDay(times['close']),
          };
        }
      });

      // For now, print the formatted hours; integrate with MerchantAuthService in actual use
      print('Formatted Opening Hours: $formattedHours');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Opening hours saved successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or to the next step (e.g., Owner Information)
      Navigator.pop(context, formattedHours);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error saving opening hours: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Saloon Opening Hours - Step 2 of 4",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              "Set Opening Hours",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            const SizedBox(height: 16),
            ..._openingHours.keys.map((day) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            day,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A),
                            ),
                          ),
                          Switch(
                            value: _openingHours[day]!['isClosed'],
                            onChanged: (value) {
                              setState(() {
                                _openingHours[day]!['isClosed'] = value;
                              });
                            },
                            activeColor: Colors.red,
                            inactiveThumbColor: Colors.green,
                          ),
                        ],
                      ),
                      if (!_openingHours[day]!['isClosed']) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Open",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _selectTime(context, day, true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF6A1B9A)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _formatTimeOfDay(_openingHours[day]!['open']),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Close",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () => _selectTime(context, day, false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF6A1B9A)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _formatTimeOfDay(_openingHours[day]!['close']),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            "Closed",
                            style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 60,
                    vertical: 14,
                  ),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Save Opening Hours",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}