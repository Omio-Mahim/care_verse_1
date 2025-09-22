import 'package:flutter/material.dart';
import '../../models/health_record.dart';
import '../../services/supabase_service.dart';

class EditHealthRecordDialog extends StatefulWidget {
  final HealthRecord record;

  const EditHealthRecordDialog({super.key, required this.record});

  @override
  State<EditHealthRecordDialog> createState() => _EditHealthRecordDialogState();
}

class _EditHealthRecordDialogState extends State<EditHealthRecordDialog> {
  late TextEditingController _reportTypeController;
  late TextEditingController _hospitalNameController;
  late TextEditingController _attachmentController;
  late DateTime _selectedDateOfBirth;
  late DateTime _selectedRecordDate;
  bool isLoading = false;

  final List<String> reportTypes = [
    "Lab Report",
    "X-Ray Report",
    "MRI Report",
    "CT Scan Report",
    "Blood Test Report",
    "Prescription",
    "Medical Certificate",
  ];

  @override
  void initState() {
    super.initState();
    _reportTypeController = TextEditingController(
      text: widget.record.reportType,
    );
    _hospitalNameController = TextEditingController(
      text: widget.record.hospitalName,
    );
    _attachmentController = TextEditingController(
      text: widget.record.attachment,
    );
    _selectedDateOfBirth = widget.record.dateOfBirth;
    _selectedRecordDate = widget.record.recordDate;
  }

  @override
  void dispose() {
    _reportTypeController.dispose();
    _hospitalNameController.dispose();
    _attachmentController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isDateOfBirth ? _selectedDateOfBirth : _selectedRecordDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          _selectedDateOfBirth = picked;
        } else {
          _selectedRecordDate = picked;
        }
      });
    }
  }

  Future<void> _updateRecord() async {
    if (_reportTypeController.text.isNotEmpty &&
        _hospitalNameController.text.isNotEmpty &&
        _attachmentController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      try {
        final updatedRecord = HealthRecord(
          id: widget.record.id,
          reportType: _reportTypeController.text,
          hospitalName: _hospitalNameController.text,
          dateOfBirth: _selectedDateOfBirth,
          recordDate: _selectedRecordDate,
          attachment: _attachmentController.text,
          userId: widget.record.userId,
        );

        await SupabaseService.updateHealthRecord(updatedRecord);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health record updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating record: $e')));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Health Record',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _reportTypeController.text,
                decoration: const InputDecoration(
                  labelText: 'Report Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                items: reportTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _reportTypeController.text = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _hospitalNameController,
                decoration: const InputDecoration(
                  labelText: 'Hospital Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_hospital),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date of Birth'),
                subtitle: Text(
                  "${_selectedDateOfBirth.day}/${_selectedDateOfBirth.month}/${_selectedDateOfBirth.year}",
                ),
                leading: const Icon(Icons.cake),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Record Date'),
                subtitle: Text(
                  "${_selectedRecordDate.day}/${_selectedRecordDate.month}/${_selectedRecordDate.year}",
                ),
                leading: const Icon(Icons.calendar_today),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _attachmentController,
                decoration: const InputDecoration(
                  labelText: 'Attachment',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_file),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : _updateRecord,
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
                            'Update',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
