import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../services/supabase_service.dart';
import '../../data/doctors_data.dart';
import '../../widgets/doctor_card_widget.dart';
import '../menu/menu_page.dart';
import '../notifications/notifications_page.dart';
import 'doctor_detail_page.dart';

class TelemedicineHomePage extends StatefulWidget {
  const TelemedicineHomePage({super.key});

  @override
  State<TelemedicineHomePage> createState() => _TelemedicineHomePageState();
}

class _TelemedicineHomePageState extends State<TelemedicineHomePage> {
  List<Doctor> displayedDoctors = [];
  List<Doctor> allDoctors = [];
  List<NotificationItem> notifications = [];
  List<String> bookmarkedDoctorIds = [];
  String selectedCategory = "All";
  String searchQuery = "";
  bool isLoading = true;
  String? errorMessage;

  final List<String> categories = [
    "All",
    "Gynae & Obs",
    "Child Care",
    "Cardiology",
    "Dermatology",
    "Orthopedics",
    "ENT",
    "Medicine",
    "Neurology",
    "Psychiatry",
    "Dentistry",
    "Eye Specialist",
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      allDoctors = getDoctorsData();

      try {
        final supabaseDoctors = await SupabaseService.getDoctors();
        if (supabaseDoctors.isNotEmpty) {
          allDoctors = supabaseDoctors;
        }
      } catch (e) {
        print('Failed to load doctors from Supabase, using local data: $e');
      }

      final user = SupabaseService.currentUser;
      if (user != null) {
        try {
          final notificationsData =
              await SupabaseService.getUserNotifications(user.id);
          final bookmarkedData =
              await SupabaseService.getUserBookmarkedDoctors(user.id);

          setState(() {
            notifications = notificationsData;
            bookmarkedDoctorIds = bookmarkedData;
          });
        } catch (e) {
          print('Failed to load user data: $e');

          setState(() {
            notifications = [];
            bookmarkedDoctorIds = [];
          });
        }
      }

      _applyFilters();
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterDoctors(String category) {
    setState(() {
      selectedCategory = category;
      _applyFilters();
    });
  }

  void _applyFilters() {
    displayedDoctors = allDoctors.where((doc) {
      final matchesCategory =
          selectedCategory == "All" || doc.specialty == selectedCategory;
      final matchesSearch = doc.name.toLowerCase().contains(
            searchQuery.toLowerCase(),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  void _refreshNotificationCount() {
    setState(() {});
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("CareVerse", style: TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshData,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    int unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              "assets/images/logo.png",
              height: 40,
              width: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.local_hospital,
                    color: Color(0xFF0077B6),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              "CareVerse",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MenuPage()),
              );
            },
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsPage(),
                    ),
                  );
                  _refreshNotificationCount();
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search by Doctor name",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                      _applyFilters();
                    });
                  },
                ),
              ),
              SizedBox(
                height: 60,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (_, index) {
                    final cat = categories[index];
                    final isSelected = cat == selectedCategory;
                    return GestureDetector(
                      onTap: () => filterDoctors(cat),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0077B6)
                              : const Color(0xFF90E0EF),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: displayedDoctors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              searchQuery.isNotEmpty
                                  ? "No doctors found for '$searchQuery'"
                                  : "No doctors available in $selectedCategory",
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: displayedDoctors.length,
                        itemBuilder: (_, index) => DoctorCardWidget(
                          doctor: displayedDoctors[index],
                          isBookmarked: bookmarkedDoctorIds
                              .contains(displayedDoctors[index].id),
                          onBookmarkToggle: (isBookmarked) async {
                            final user = SupabaseService.currentUser;
                            if (user != null) {
                              try {
                                if (isBookmarked) {
                                  await SupabaseService.bookmarkDoctor(
                                      user.id, displayedDoctors[index].id);
                                  setState(() {
                                    bookmarkedDoctorIds
                                        .add(displayedDoctors[index].id);
                                  });
                                } else {
                                  await SupabaseService.removeBookmark(
                                      user.id, displayedDoctors[index].id);
                                  setState(() {
                                    bookmarkedDoctorIds
                                        .remove(displayedDoctors[index].id);
                                  });
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Error: ${e.toString()}')),
                                );
                              }
                            }
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorDetailPage(
                                    doctor: displayedDoctors[index]),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
