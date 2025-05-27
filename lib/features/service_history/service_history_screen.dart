import 'package:flutter/material.dart';
import '../../core/database/service_history_repository.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';

class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final _historyRepository = ServiceHistoryRepository();
  final _logger = Logger();
  List<Map<String, dynamic>> _historyItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await _historyRepository.getServiceHistory();
      if (!mounted) return;

      setState(() {
        _historyItems = data;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      _logger.e('Error loading service history: ${e.toString()}\n$stackTrace');
      if (!mounted) return;

      setState(() {
        _error = 'Failed to load service history: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _showAddEditDialog([
    Map<String, dynamic>? existingRecord,
  ]) async {
    final isEditing = existingRecord != null;
    final serviceTypeController = TextEditingController(
      text: isEditing ? existingRecord['service_type'] : '',
    );
    final notesController = TextEditingController(
      text: isEditing ? existingRecord['notes'] : '',
    );
    DateTime selectedDate =
        isEditing
            ? DateTime.parse(existingRecord['completed_at'])
            : DateTime.now();
    String status = isEditing ? existingRecord['status'] : 'Completed';

    if (!mounted) return;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              isEditing ? 'Edit Service Record' : 'Add Service Record',
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: serviceTypeController,
                    decoration: const InputDecoration(
                      labelText: 'Service Type',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(selectedDate)}',
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        selectedDate = pickedDate;
                        // Force rebuild of dialog
                        Navigator.pop(context);
                        _showAddEditDialog(existingRecord);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items:
                        ['Pending', 'In Progress', 'Completed', 'Cancelled']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        status = value;
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (isEditing) {
                      await _historyRepository.updateServiceRecord(
                        recordId: existingRecord['id'],
                        serviceType: serviceTypeController.text,
                        completedAt: selectedDate,
                        status: status,
                        notes: notesController.text,
                      );
                    } else {
                      await _historyRepository.addServiceRecord(
                        serviceType: serviceTypeController.text,
                        completedAt: selectedDate,
                        status: status,
                        notes: notesController.text,
                      );
                    }
                    if (!mounted) return;
                    Navigator.pop(context);
                    _loadHistory(); // Refresh the list
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: Text(isEditing ? 'Update' : 'Add'),
              ),
            ],
          ),
    );
  }

  Future<void> _confirmDelete(Map<String, dynamic> record) async {
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this service record?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      try {
        await _historyRepository.deleteServiceRecord(record['id']);
        if (!mounted) return;
        _loadHistory(); // Refresh the list
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEditDialog(),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!),
                    ElevatedButton(
                      onPressed: _loadHistory,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : _historyItems.isEmpty
              ? const Center(child: Text('No service history records found'))
              : RefreshIndicator(
                onRefresh: _loadHistory,
                child: ListView.builder(
                  itemCount: _historyItems.length,
                  itemBuilder: (context, index) {
                    final item = _historyItems[index];
                    final completedAt = DateTime.parse(item['completed_at']);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(item['service_type']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('MMM dd, yyyy').format(completedAt),
                            ),
                            if (item['notes'] != null)
                              Text(
                                item['notes'],
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text(item['status']),
                              backgroundColor: _getStatusColor(item['status']),
                            ),
                            PopupMenuButton(
                              itemBuilder:
                                  (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    _showAddEditDialog(item);
                                    break;
                                  case 'delete':
                                    _confirmDelete(item);
                                    break;
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green[100]!;
      case 'In Progress':
        return Colors.blue[100]!;
      case 'Pending':
        return Colors.orange[100]!;
      case 'Cancelled':
        return Colors.red[100]!;
      default:
        return Colors.grey[100]!;
    }
  }
}
