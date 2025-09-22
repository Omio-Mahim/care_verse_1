class HealthRecord {
  final String id;
  final String reportType;
  final String hospitalName;
  final DateTime dateOfBirth;
  final String attachment;
  final DateTime recordDate;
  final String userId;

  HealthRecord({
    required this.id,
    required this.reportType,
    required this.hospitalName,
    required this.dateOfBirth,
    required this.attachment,
    required this.recordDate,
    required this.userId,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    try {
      return HealthRecord(
        id: json['id']?.toString() ?? '',
        reportType: json['report_type']?.toString() ?? '',
        hospitalName: json['hospital_name']?.toString() ?? '',
        dateOfBirth: _parseToDateTime(json['date_of_birth']),
        attachment: json['attachment']?.toString() ?? '',
        recordDate: _parseToDateTime(json['record_date']),
        userId: json['user_id']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing HealthRecord from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
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
      'report_type': reportType,
      'hospital_name': hospitalName,
      'date_of_birth': dateOfBirth.toIso8601String(),
      'attachment': attachment,
      'record_date': recordDate.toIso8601String(),
      'user_id': userId,
    };
  }
}
