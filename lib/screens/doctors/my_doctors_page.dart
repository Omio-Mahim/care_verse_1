import 'package:flutter/material.dart';
import '../../models/doctor.dart';
import '../../services/supabase_service.dart';
import '../../data/doctors_data.dart';
import '../home/doctor_detail_page.dart';

class MyDoctorsPage extends StatefulWidget {
  const MyDoctorsPage({super.key});

  @override
  State<MyDoctorsPage> createState() => _MyDoctorsPageState();
}

class _MyDoctorsPageState extends State<MyDoctorsPage> {
  List<Doctor> bookmarkedDoctors = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookmarkedDoctors();
  }

  Future<void> _loadBookmarkedDoctors() async {
    try {
      final user = SupabaseService.currentUser;
      if (user != null) {
        final bookmarkedIds = await SupabaseService.getUserBookmarkedDoctors(
          user.id,
        );
        final allDoctors = getDoctorsData();

        setState(() {
          bookmarkedDoctors = allDoctors
              .where((doctor) => bookmarkedIds.contains(doctor.id))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading bookmarked doctors: $e')),
      );
    }
  }

  Future<void> _removeBookmark(Doctor doctor) async {
    try {
      final user = SupabaseService.currentUser;
      if (user != null) {
        await SupabaseService.removeBookmark(user.id, doctor.id);
        setState(() {
          bookmarkedDoctors.remove(doctor);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${doctor.name} removed from bookmarks")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error removing bookmark: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title:
              const Text("My Doctors", style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Doctors", style: TextStyle(color: Colors.white)),
      ),
      body: bookmarkedDoctors.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No doctors bookmarked yet",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Bookmark your favorite doctors to see them here",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookmarkedDoctors.length,
              itemBuilder: (_, index) {
                final doctor = bookmarkedDoctors[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            doctor.photo,
                            height: 70,
                            width: 70,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 70,
                                width: 70,
                                color: const Color(0xFF90E0EF),
                                child: const Icon(
                                  Icons.person,
                                  size: 40,
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
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                doctor.specialty,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text("${doctor.rating} Rating"),
                                  const SizedBox(width: 16),
                                  Text("৳${doctor.fee}"),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.bookmark,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                _removeBookmark(doctor);
                              },
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DoctorDetailPage(doctor: doctor),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0077B6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                              child: const Text(
                                "View",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
