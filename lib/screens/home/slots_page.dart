import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';

class SlotsPage extends StatelessWidget {
  final Doctor doctor;
  final String? selectedDate;
  final int? selectedDateIndex;

  const SlotsPage({
    required this.doctor,
    this.selectedDate,
    this.selectedDateIndex,
    super.key,
  });

  String _getFormattedDate() {
    if (selectedDate != null && selectedDateIndex != null) {
      final DateTime now = DateTime.now();
      final DateTime targetDate = now.add(Duration(days: selectedDateIndex!));

      if (selectedDateIndex == 0) {
        return "Today (${targetDate.day}/${targetDate.month}/${targetDate.year})";
      } else if (selectedDateIndex == 1) {
        return "Tomorrow (${targetDate.day}/${targetDate.month}/${targetDate.year})";
      } else {
        return "${selectedDate!} (${targetDate.day}/${targetDate.month}/${targetDate.year})";
      }
    }

    final DateTime today = DateTime.now();
    return "Today (${today.day}/${today.month}/${today.year})";
  }

  String _getActualDate() {
    if (selectedDateIndex != null) {
      final DateTime now = DateTime.now();
      final DateTime targetDate = now.add(Duration(days: selectedDateIndex!));
      return "${targetDate.day}/${targetDate.month}/${targetDate.year}";
    }

    final DateTime today = DateTime.now();
    return "${today.day}/${today.month}/${today.year}";
  }

  @override
  Widget build(BuildContext context) {
    final List<String> slots = [
      "9:00 AM",
      "9:30 AM",
      "10:00 AM",
      "10:30 AM",
      "11:00 AM",
      "11:30 AM",
      "2:00 PM",
      "2:30 PM",
      "3:00 PM",
      "3:30 PM",
      "4:00 PM",
      "4:30 PM",
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${doctor.name} - Available Slots",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF90E0EF),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        doctor.photo,
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            width: 50,
                            color: Colors.white,
                            child: const Icon(
                              Icons.person,
                              size: 30,
                              color: Color(0xFF0077B6),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(doctor.specialty),
                          Text("Fee: ৳${doctor.fee}"),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0077B6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Selected Date: ${_getFormattedDate()}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: slots.length,
              itemBuilder: (_, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(
                      slots[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text("Available"),
                    trailing: const Icon(
                      Icons.book_online,
                      color: Color(0xFF0077B6),
                    ),
                    onTap: () {
                      _showBookingDialog(context, slots[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(BuildContext context, String timeSlot) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Booking"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Doctor: ${doctor.name}"),
              Text("Specialty: ${doctor.specialty}"),
              Text("Date: ${_getFormattedDate()}"),
              Text("Time: $timeSlot"),
              Text("Fee: ৳${doctor.fee}"),
              const SizedBox(height: 16),
              const Text(
                "Do you want to confirm this appointment?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _bookAppointment(context, timeSlot);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
              ),
              child: const Text(
                "Confirm Booking",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _bookAppointment(BuildContext context, String timeSlot) async {
    try {
      final user = SupabaseService.currentUser;
      if (user == null) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please login to book appointment")),
        );
        return;
      }

      final appointment = BookedAppointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        doctor: doctor,
        date: _getActualDate(),
        time: timeSlot,
        status: "Upcoming",
        bookingDate: DateTime.now(),
        userId: user.id,
      );

      await SupabaseService.createAppointment(appointment);

      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pop(); // Go back to previous screen

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Appointment booked successfully with ${doctor.name} on ${_getFormattedDate()} at $timeSlot",
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error booking appointment: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
