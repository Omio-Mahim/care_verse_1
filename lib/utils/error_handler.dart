import 'package:flutter/material.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static String getReadableError(dynamic error) {
    String errorString = error.toString().toLowerCase();

    if (errorString.contains('over_email_send_rate_limit')) {
      return 'Please wait 45 seconds before trying again. This is for security purposes.';
    }
    if (errorString.contains('invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (errorString.contains('email not confirmed')) {
      return 'Please check your email and confirm your account before logging in.';
    }
    if (errorString.contains('user already registered')) {
      return 'An account with this email already exists. Please try logging in instead.';
    }
    if (errorString.contains('signup disabled')) {
      return 'New registrations are currently disabled. Please contact support.';
    }
    if (errorString.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    if (errorString.contains('password')) {
      return 'Password must be at least 6 characters long.';
    }
    if (errorString.contains('network')) {
      return 'Network error. Please check your internet connection and try again.';
    }
    if (errorString.contains('timeout')) {
      return 'Request timed out. Please check your connection and try again.';
    }

    // Remove common prefixes to make error more readable
    return error
        .toString()
        .replaceAll('Exception: ', '')
        .replaceAll('AuthApiException: ', '')
        .replaceAll('Registration failed: ', '');
  }
}
