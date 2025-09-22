enum NotificationType { healthTip, videoCall, appointment, general }

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  bool isRead;
  final DateTime createdAt;
  final String userId;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    required this.createdAt,
    required this.userId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    try {
      return NotificationItem(
        id: json['id']?.toString() ?? '',
        type: _parseNotificationType(json['type']),
        title: json['title']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        isRead: json['is_read'] == true,
        createdAt: _parseToDateTime(json['created_at']),
        userId: json['user_id']?.toString() ?? '',
      );
    } catch (e) {
      print('Error parsing NotificationItem from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  static NotificationType _parseNotificationType(dynamic value) {
    if (value == null) return NotificationType.general;
    final typeString = value.toString().toLowerCase();

    switch (typeString) {
      case 'healthtip':
      case 'health_tip':
        return NotificationType.healthTip;
      case 'videocall':
      case 'video_call':
        return NotificationType.videoCall;
      case 'appointment':
        return NotificationType.appointment;
      default:
        return NotificationType.general;
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
      'type': type.toString().split('.').last,
      'title': title,
      'message': message,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'user_id': userId,
    };
  }
}
