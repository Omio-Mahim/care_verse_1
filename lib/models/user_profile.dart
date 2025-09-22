class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final int age;
  final String gender;
  final String address;
  final DateTime dateOfJoining;
  final int totalConsultations;
  final int doctorVisits;
  final String profilePhoto;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.address,
    required this.dateOfJoining,
    required this.totalConsultations,
    required this.doctorVisits,
    required this.profilePhoto,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    try {
      return UserProfile(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        age: _parseToInt(json['age']),
        gender: json['gender']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        dateOfJoining: _parseToDateTime(json['date_of_joining']),
        totalConsultations: _parseToInt(json['total_consultations']),
        doctorVisits: _parseToInt(json['doctor_visits']),
        profilePhoto: json['profile_photo']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing UserProfile from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseToDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'address': address,
      'date_of_joining': dateOfJoining.toIso8601String(),
      'total_consultations': totalConsultations,
      'doctor_visits': doctorVisits,
      'profile_photo': profilePhoto,
    };
  }

  UserProfile copyWith({
    String? name,
    String? phone,
    int? age,
    String? gender,
    String? address,
    String? profilePhoto,
    int? totalConsultations,
    int? doctorVisits,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      dateOfJoining: dateOfJoining,
      totalConsultations: totalConsultations ?? this.totalConsultations,
      doctorVisits: doctorVisits ?? this.doctorVisits,
      profilePhoto: profilePhoto ?? this.profilePhoto,
    );
  }
}
