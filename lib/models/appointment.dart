import 'doctor.dart';

class BookedAppointment {
  final String id;
  final Doctor doctor;
  final String date;
  final String time;
  final String status;
  final DateTime bookingDate;
  final String userId;

  BookedAppointment({
    required this.id,
    required this.doctor,
    required this.date,
    required this.time,
    required this.status,
    required this.bookingDate,
    required this.userId,
  });

  factory BookedAppointment.fromJson(Map<String, dynamic> json) {
    return BookedAppointment(
      id: json['id'] ?? '',
      doctor: Doctor.fromJson(json['doctor'] ?? {}),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? '',
      bookingDate: DateTime.parse(
        json['booking_date'] ?? DateTime.now().toIso8601String(),
      ),
      userId: json['user_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor': doctor.toJson(),
      'date': date,
      'time': time,
      'status': status,
      'booking_date': bookingDate.toIso8601String(),
      'user_id': userId,
    };
  }
}
