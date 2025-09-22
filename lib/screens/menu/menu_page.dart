import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../main_navigation_page.dart';
import '../bookings/my_bookings_page.dart';
import '../health/my_health_page.dart';
import '../profile/my_profile_page.dart';
import '../doctors/my_doctors_page.dart';
import '../notifications/notifications_page.dart';
import '../settings/settings_page.dart';
import '../auth/login_page.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  Future<void> _logout(BuildContext context) async {
    // Show confirmation dialog first
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 8),
              Text("Logout"),
            ],
          ),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text("Signing out..."),
              ],
            ),
          );
        },
      );

      // Perform logout
      await SupabaseService.signOut();

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Navigate to login page and clear all previous routes
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text("Logged out successfully"),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      // Close loading dialog if it's open
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text("Logout failed: ${error.toString()}"),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu", style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: const Color(0xFF0077B6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  "assets/images/logo.png",
                  height: 50,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Color(0xFF0077B6),
                        size: 30,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  "CareVerse",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  "Welcome, ${SupabaseService.currentUser?.email ?? 'User'}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _menuItem(
                  Icons.home,
                  "Home",
                  context,
                  page: const MainNavigationPage(),
                  isHome: true,
                ),
                _menuItem(
                  Icons.book_online,
                  "My Bookings",
                  context,
                  page: const MyBookingsPage(),
                ),
                _menuItem(
                  Icons.health_and_safety,
                  "My Health",
                  context,
                  page: const MyHealthPage(),
                ),
                _menuItem(
                  Icons.person,
                  "My Profile",
                  context,
                  page: const MyProfilePage(),
                ),
                _menuItem(
                  Icons.local_hospital,
                  "My Doctors",
                  context,
                  page: const MyDoctorsPage(),
                ),
                _menuItem(
                  Icons.notifications,
                  "Notifications",
                  context,
                  page: const NotificationsPage(),
                ),
                _menuItem(
                  Icons.settings,
                  "Settings",
                  context,
                  page: const SettingsPage(),
                ),
                const Divider(),
                _menuItem(Icons.logout, "Logout", context, isLogout: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    BuildContext context, {
    Widget? page,
    bool isHome = false,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : const Color(0xFF0077B6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : Colors.black,
          fontWeight: isLogout ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        if (isLogout) {
          _logout(context);
        } else if (page != null) {
          if (isHome) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => page),
              (route) => false,
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          }
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}
