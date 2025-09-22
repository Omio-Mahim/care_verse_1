import 'package:flutter/material.dart';
import '../../models/health_record.dart';
import '../../services/supabase_service.dart';
import 'add_health_record_dialog.dart';
import 'edit_health_record_dialog.dart';

class MyHealthPage extends StatefulWidget {
  const MyHealthPage({super.key});

  @override
  State<MyHealthPage> createState() => _MyHealthPageState();
}

class _MyHealthPageState extends State<MyHealthPage> {
  List<HealthRecord> _healthRecords = [];
  List<HealthRecord> _filteredRecords = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHealthRecords();
  }

  Future<void> _loadHealthRecords() async {
    try {
      final user = SupabaseService.currentUser;
      if (user != null) {
        final records = await SupabaseService.getUserHealthRecords(user.id);
        setState(() {
          _healthRecords = records;
          _filteredRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading health records: $e')),
      );
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredRecords = _healthRecords;
      }
    });
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _healthRecords;
      } else {
        _filteredRecords = _healthRecords.where((record) {
          return record.reportType.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
              record.hospitalName.toLowerCase().contains(query.toLowerCase()) ||
              record.attachment.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _showAddRecordForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AddHealthRecordDialog();
      },
    ).then((_) {
      _loadHealthRecords();
    });
  }

  void _showEditRecordForm(HealthRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditHealthRecordDialog(record: record);
      },
    ).then((_) {
      _loadHealthRecords();
    });
  }

  Future<void> _deleteRecord(HealthRecord record) async {
    try {
      await SupabaseService.deleteHealthRecord(record.id);
      _loadHealthRecords();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health record deleted successfully'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting record: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("My Health", style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search health records...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: _performSearch,
              )
            : const Text("My Health", style: TextStyle(color: Colors.white)),
        actions: [
          if (_healthRecords.isNotEmpty)
            IconButton(
              icon: Icon(
                _isSearching ? Icons.close : Icons.search,
                color: Colors.white,
              ),
              onPressed: _toggleSearch,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRecordForm,
        backgroundColor: const Color(0xFF0077B6),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _filteredRecords.isEmpty
          ? Center(
              child: _isSearching
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No records found for '${_searchController.text}'",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          size: 80,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No health records yet",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Tap the + button to add your first health record",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRecords.length,
              itemBuilder: (_, index) {
                final record = _filteredRecords[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _viewRecordDetails(record),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.description,
                                color: Color(0xFF0077B6),
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  record.reportType,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _showEditRecordForm(record);
                                  } else if (value == 'delete') {
                                    _showDeleteDialog(record);
                                  }
                                },
                                itemBuilder: (BuildContext context) => [
                                  const PopupMenuItem<String>(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, color: Colors.blue),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildRecordInfoRow(
                            Icons.local_hospital,
                            "Hospital",
                            record.hospitalName,
                          ),
                          _buildRecordInfoRow(
                            Icons.cake,
                            "Date of Birth",
                            "${record.dateOfBirth.day}/${record.dateOfBirth.month}/${record.dateOfBirth.year}",
                          ),
                          _buildRecordInfoRow(
                            Icons.calendar_today,
                            "Record Date",
                            "${record.recordDate.day}/${record.recordDate.month}/${record.recordDate.year}",
                          ),
                          _buildRecordInfoRow(
                            Icons.attach_file,
                            "Attachment",
                            record.attachment,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRecordInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0077B6), size: 16),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  void _viewRecordDetails(HealthRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Health Record Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),
                _buildDetailRow('Report Type', record.reportType),
                _buildDetailRow('Hospital', record.hospitalName),
                _buildDetailRow(
                  'Date of Birth',
                  "${record.dateOfBirth.day}/${record.dateOfBirth.month}/${record.dateOfBirth.year}",
                ),
                _buildDetailRow(
                  'Record Date',
                  "${record.recordDate.day}/${record.recordDate.month}/${record.recordDate.year}",
                ),
                _buildDetailRow('Attachment', record.attachment),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showEditRecordForm(record);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077B6),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDeleteDialog(record);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _showDeleteDialog(HealthRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Health Record'),
          content: const Text(
            'Are you sure you want to delete this health record?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteRecord(record);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
