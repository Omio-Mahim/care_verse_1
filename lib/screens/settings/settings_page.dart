import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsItem(
            context,
            Icons.lock,
            "Change Password",
            "Update your account password",
            () => _showChangePasswordDialog(context),
          ),
          _buildSettingsItem(
            context,
            Icons.description,
            "Terms and Conditions",
            "Read our terms and conditions",
            () => _showTermsAndConditions(context),
          ),
          _buildSettingsItem(
            context,
            Icons.privacy_tip,
            "Privacy Policy",
            "Read our privacy policy",
            () => _showPrivacyPolicy(context),
          ),
          _buildSettingsItem(
            context,
            Icons.info,
            "About Us",
            "Learn more about CareVerse",
            () => _showAboutUs(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0077B6), size: 24),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF0077B6),
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change Password"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Current Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "New Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Confirm New Password",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (newPasswordController.text ==
                              confirmPasswordController.text) {
                            setState(() {
                              isLoading = true;
                            });

                            try {
                              // In a real app, you would implement password change with Supabase
                              await Future.delayed(const Duration(seconds: 1));
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Password change feature coming soon!",
                                  ),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Passwords do not match!"),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Change Password",
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Terms and Conditions"),
          content: const SingleChildScrollView(
            child: Text(
              "Welcome to CareVerse!\n\n"
              "By using our telemedicine platform, you agree to the following terms:\n\n"
              "1. Service Usage: CareVerse provides online medical consultation services.\n\n"
              "2. User Responsibilities: Users must provide accurate medical information.\n\n"
              "3. Privacy: We protect your medical data according to healthcare privacy laws.\n\n"
              "4. Consultation Fees: All consultation fees are clearly displayed before booking.\n\n"
              "5. Emergency Services: For medical emergencies, contact local emergency services immediately.\n\n"
              "6. Platform Availability: We strive for 24/7 availability but cannot guarantee uninterrupted service.\n\n"
              "7. Medical Advice: Consultations are for informational purposes and do not replace in-person medical care when necessary.\n\n"
              "For complete terms and conditions, please visit our website.",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Privacy Policy"),
          content: const SingleChildScrollView(
            child: Text(
              "CareVerse Privacy Policy\n\n"
              "Your privacy is important to us. This policy explains how we collect, use, and protect your information:\n\n"
              "Information We Collect:\n"
              "• Personal information (name, email, phone)\n"
              "• Medical information for consultations\n"
              "• Usage data to improve our services\n\n"
              "How We Use Your Information:\n"
              "• Provide medical consultation services\n"
              "• Communicate with you about appointments\n"
              "• Improve our platform and services\n\n"
              "Data Protection:\n"
              "• All data is encrypted and stored securely\n"
              "• We comply with healthcare privacy regulations\n"
              "• Your medical information is only shared with your chosen doctors\n\n"
              "Your Rights:\n"
              "• Access your personal data\n"
              "• Request data correction or deletion\n"
              "• Control how your data is used\n\n"
              "Contact us for any privacy concerns at privacy@careverse.com",
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showAboutUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("About CareVerse"),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(
                    Icons.local_hospital,
                    size: 60,
                    color: Color(0xFF0077B6),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  "CareVerse",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0077B6),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Version 1.0.0\n\n"
                  "CareVerse is a comprehensive telemedicine platform connecting patients with qualified healthcare professionals in Bangladesh.\n\n"
                  "Our Mission:\n"
                  "To make quality healthcare accessible to everyone through innovative technology and compassionate care.\n\n"
                  "Features:\n"
                  "• Video consultations with certified doctors\n"
                  "• Appointment booking and management\n"
                  "• Health record management\n"
                  "• Public chat with healthcare professionals\n"
                  "• Real-time notifications\n\n"
                  "Contact Information:\n"
                  "Email: support@careverse.com\n"
                  "Phone: +880 1234567890\n"
                  "Website: www.careverse.com\n\n"
                  "Developed with ❤️ for better healthcare access in Bangladesh.",
                  style: TextStyle(fontSize: 14, height: 1.5),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
