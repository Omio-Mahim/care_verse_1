class Doctor {
  final String id;
  final String name;
  final String specialty;
  final int consultations;
  final int years;
  final double rating;
  final int fee;
  final String photo;
  final List<String> details;
  final String bio;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.consultations,
    required this.years,
    required this.rating,
    required this.fee,
    required this.photo,
    required this.details,
    required this.bio,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    try {
      return Doctor(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        specialty: json['specialty']?.toString() ?? '',
        consultations: _parseToInt(json['consultations']),
        years: _parseToInt(json['years']),
        rating: _parseToDouble(json['rating']),
        fee: _parseToInt(json['fee']),
        photo: json['photo']?.toString() ?? '',
        details: _parseToStringList(json['details']),
        bio: json['bio']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing Doctor from JSON: $e');
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

  static double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static List<String> _parseToStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    if (value is String) {
      try {
        return [value];
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'consultations': consultations,
      'years': years,
      'rating': rating,
      'fee': fee,
      'photo': photo,
      'details': details,
      'bio': bio,
    };
  }
}
