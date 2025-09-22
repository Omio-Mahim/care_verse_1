import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Auth methods
  static Future<AuthResponse> signUp(
      String email, String password, String name) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        // Create user profile
        await _client.from('user_profiles').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'phone': '',
          'age': 0,
          'gender': '',
          'address': '',
          'date_of_joining': DateTime.now().toIso8601String(),
          'total_consultations': 0,
          'doctor_visits': 0,
          'profile_photo': '',
        });
      }

      return response;
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

// Update your existing signOut method in SupabaseService
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      // Clear any local storage or cached data if needed
      print('User signed out successfully');
    } catch (e) {
      print('Error during sign out: $e');
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

// Add this method to check auth state
  static bool get isLoggedIn {
    return _client.auth.currentUser != null;
  }

// Add this method to listen to auth changes
  static Stream<AuthState> get authStateChanges {
    return _client.auth.onAuthStateChange;
  }

  static User? get currentUser => _client.auth.currentUser;

  static Future<UserProfile?> getUserProfile(String userId) async {
    try {
      print('Getting profile for user: $userId');

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      print('Profile response: $response');

      if (response == null) {
        print('No profile found, creating new one...');

        // Get current user info
        final user = _client.auth.currentUser;
        if (user == null) {
          print('No current user found');
          return null;
        }

        // Create default profile data
        final defaultProfile = {
          'id': userId,
          'name': user.email?.split('@')[0] ?? 'User',
          'email': user.email ?? '',
          'phone': '',
          'age': 0,
          'gender': '',
          'address': '',
          'date_of_joining': DateTime.now().toIso8601String(),
          'total_consultations': 0,
          'doctor_visits': 0,
          'profile_photo': '',
        };

        print('Creating profile with data: $defaultProfile');

        try {
          // Insert the profile
          final insertResponse = await _client
              .from('user_profiles')
              .insert(defaultProfile)
              .select()
              .single();

          print('Profile created successfully: $insertResponse');
          return UserProfile.fromJson(insertResponse);
        } catch (insertError) {
          print('Failed to create profile: $insertError');

          // Return a temporary profile that's not saved to database
          return UserProfile(
            id: userId,
            name: user.email?.split('@')[0] ?? 'User',
            email: user.email ?? '',
            phone: '',
            age: 0,
            gender: '',
            address: '',
            dateOfJoining: DateTime.now(),
            totalConsultations: 0,
            doctorVisits: 0,
            profilePhoto: '',
          );
        }
      }

      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error in getUserProfile: $e');

      // Return a basic profile as fallback
      final user = _client.auth.currentUser;
      if (user != null) {
        return UserProfile(
          id: userId,
          name: user.email?.split('@')[0] ?? 'User',
          email: user.email ?? '',
          phone: '',
          age: 0,
          gender: '',
          address: '',
          dateOfJoining: DateTime.now(),
          totalConsultations: 0,
          doctorVisits: 0,
          profilePhoto: '',
        );
      }

      return null;
    }
  }

  static Future<void> updateUserProfile(UserProfile profile) async {
    try {
      await _client
          .from('user_profiles')
          .update(profile.toJson())
          .eq('id', profile.id);
    } catch (e) {
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Doctors methods
  static Future<List<Doctor>> getDoctors() async {
    try {
      final response = await _client.from('doctors').select();
      return (response as List).map((json) => Doctor.fromJson(json)).toList();
    } catch (e) {
      print('Error getting doctors: $e');
      return [];
    }
  }

  static Future<Doctor?> getDoctorById(String id) async {
    try {
      final response =
          await _client.from('doctors').select().eq('id', id).maybeSingle();

      if (response == null) return null;

      return Doctor.fromJson(response);
    } catch (e) {
      print('Error getting doctor: $e');
      return null;
    }
  }

  // Appointments methods
  static Future<List<BookedAppointment>> getUserAppointments(
      String userId) async {
    try {
      final response = await _client
          .from('appointments')
          .select('*, doctors(*)')
          .eq('user_id', userId)
          .order('booking_date', ascending: false);

      List<BookedAppointment> appointments = [];
      for (var item in response) {
        try {
          // Handle the doctor data properly
          final doctorData = item['doctors'];
          if (doctorData != null) {
            final appointment = BookedAppointment(
              id: item['id'] ?? '',
              doctor: Doctor.fromJson(doctorData),
              date: item['date'] ?? '',
              time: item['time'] ?? '',
              status: item['status'] ?? 'Upcoming',
              bookingDate: DateTime.parse(
                  item['booking_date'] ?? DateTime.now().toIso8601String()),
              userId: item['user_id'] ?? '',
            );
            appointments.add(appointment);
          }
        } catch (e) {
          print('Error parsing appointment: $e');
          continue;
        }
      }

      return appointments;
    } catch (e) {
      print('Error getting appointments: $e');
      return [];
    }
  }

  static Future<void> createAppointment(BookedAppointment appointment) async {
    try {
      await _client.from('appointments').insert({
        'id': appointment.id,
        'doctor_id': appointment.doctor.id,
        'user_id': appointment.userId,
        'date': appointment.date,
        'time': appointment.time,
        'status': appointment.status,
        'booking_date': appointment.bookingDate.toIso8601String(),
      });

      // Create notification
      await createNotification(NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: NotificationType.appointment,
        title: 'Appointment Booked',
        message:
            'Your appointment with ${appointment.doctor.name} has been scheduled for ${appointment.date} at ${appointment.time}',
        createdAt: DateTime.now(),
        userId: appointment.userId,
      ));

      // Update user consultation count
      final user = await getUserProfile(appointment.userId);
      if (user != null) {
        await updateUserProfile(user.copyWith(
          totalConsultations: user.totalConsultations + 1,
        ));
      }
    } catch (e) {
      throw Exception('Failed to create appointment: ${e.toString()}');
    }
  }

  static Future<void> updateAppointmentStatus(
      String appointmentId, String status) async {
    try {
      await _client
          .from('appointments')
          .update({'status': status}).eq('id', appointmentId);
    } catch (e) {
      throw Exception('Failed to update appointment: ${e.toString()}');
    }
  }

  // Health Records methods
  static Future<List<HealthRecord>> getUserHealthRecords(String userId) async {
    try {
      final response = await _client
          .from('health_records')
          .select()
          .eq('user_id', userId)
          .order('record_date', ascending: false);

      return (response as List)
          .map((json) => HealthRecord.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting health records: $e');
      return [];
    }
  }

  static Future<void> createHealthRecord(HealthRecord record) async {
    try {
      await _client.from('health_records').insert(record.toJson());
    } catch (e) {
      throw Exception('Failed to create health record: ${e.toString()}');
    }
  }

  static Future<void> updateHealthRecord(HealthRecord record) async {
    try {
      await _client
          .from('health_records')
          .update(record.toJson())
          .eq('id', record.id);
    } catch (e) {
      throw Exception('Failed to update health record: ${e.toString()}');
    }
  }

  static Future<void> deleteHealthRecord(String recordId) async {
    try {
      await _client.from('health_records').delete().eq('id', recordId);
    } catch (e) {
      throw Exception('Failed to delete health record: ${e.toString()}');
    }
  }

  // Notifications methods
  static Future<List<NotificationItem>> getUserNotifications(
      String userId) async {
    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  static Future<void> createNotification(NotificationItem notification) async {
    try {
      await _client.from('notifications').insert(notification.toJson());
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  static Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  static Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('user_id', userId);
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

// Update these methods in your SupabaseService class

// Chat methods
  static Future<List<ChatMessage>> getChatMessages() async {
    try {
      print('Fetching chat messages...');
      final response = await _client
          .from('chat_messages')
          .select()
          .order('timestamp', ascending: true);

      print('Raw response: $response');

      if (response == null) {
        print('No messages found');
        return [];
      }

      final messages = (response as List)
          .map((json) {
            try {
              return ChatMessage.fromJson(json);
            } catch (e) {
              print('Error parsing message: $e, JSON: $json');
              return null;
            }
          })
          .where((message) => message != null)
          .cast<ChatMessage>()
          .toList();

      print('Parsed ${messages.length} messages');
      return messages;
    } catch (e) {
      print('Error getting chat messages: $e');
      return [];
    }
  }

  static Future<void> sendChatMessage(ChatMessage message) async {
    try {
      print('Sending message: ${message.message}');

      final messageData = {
        'id': message.id,
        'sender_id': message.senderId,
        'sender_name': message.senderName,
        'message': message.message,
        'timestamp': message.timestamp.toIso8601String(),
        'is_doctor': message.isDoctor,
      };

      print('Message data: $messageData');

      final response =
          await _client.from('chat_messages').insert(messageData).select();

      print('Insert response: $response');
      print('Message sent successfully');
    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  static Stream<List<ChatMessage>> getChatMessagesStream() {
    try {
      print('Setting up chat messages stream...');

      return _client
          .from('chat_messages')
          .stream(primaryKey: ['id'])
          .order('timestamp', ascending: true)
          .map((data) {
            print('Stream data received: ${data.length} items');

            return data
                .map((json) {
                  try {
                    return ChatMessage.fromJson(json);
                  } catch (e) {
                    print('Error parsing stream message: $e, JSON: $json');
                    return null;
                  }
                })
                .where((message) => message != null)
                .cast<ChatMessage>()
                .toList();
          })
          .handleError((error) {
            print('Stream error: $error');
          });
    } catch (e) {
      print('Error setting up chat stream: $e');
      // Return empty stream if setup fails
      return Stream.value(<ChatMessage>[]);
    }
  }

  // Bookmarks methods
  static Future<List<String>> getUserBookmarkedDoctors(String userId) async {
    try {
      final response = await _client
          .from('bookmarked_doctors')
          .select('doctor_id')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['doctor_id'] as String)
          .toList();
    } catch (e) {
      print('Error getting bookmarked doctors: $e');
      return [];
    }
  }

  static Future<void> bookmarkDoctor(String userId, String doctorId) async {
    try {
      await _client.from('bookmarked_doctors').insert({
        'user_id': userId,
        'doctor_id': doctorId,
      });
    } catch (e) {
      throw Exception('Failed to bookmark doctor: ${e.toString()}');
    }
  }

  static Future<void> removeBookmark(String userId, String doctorId) async {
    try {
      await _client
          .from('bookmarked_doctors')
          .delete()
          .eq('user_id', userId)
          .eq('doctor_id', doctorId);
    } catch (e) {
      throw Exception('Failed to remove bookmark: ${e.toString()}');
    }
  }

  // Add this method to your SupabaseService class
  static Future<void> resendConfirmationEmail(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } catch (e) {
      throw Exception('Failed to resend confirmation email: ${e.toString()}');
    }
  }
}
