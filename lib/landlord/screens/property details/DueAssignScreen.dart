// lib/landlord/screens/due_assign_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/DueAssignmentProvider.dart';
import '../../providers/DuesProvider.dart';
import 'package:intl/intl.dart';

class DueAssignScreen extends StatefulWidget {
  final String tenantId;
  final String landlordId;

  const DueAssignScreen({
    Key? key,
    required this.tenantId,
    required this.landlordId,
  }) : super(key: key);

  @override
  State<DueAssignScreen> createState() => _DueAssignScreenState();
}

class _DueAssignScreenState extends State<DueAssignScreen> {
  final Map<String, bool> _selectedDues = {};
  final Map<String, TextEditingController> _variableAmountControllers = {};
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDues();
    });
  }

  Future<void> _loadDues() async {
    final duesProvider = Provider.of<DuesProvider>(context, listen: false);
    await duesProvider.loadDues();
  }

  @override
  void dispose() {
    _variableAmountControllers.values.forEach(
          (controller) => controller.dispose(),
    );
    super.dispose();
  }

  void _toggleDueSelection(String dueId, String type) {
    setState(() {
      _selectedDues[dueId] = !(_selectedDues[dueId] ?? false);

      // Create or remove controller for variable type dues
      if (type == 'variable') {
        if (_selectedDues[dueId] == true) {
          _variableAmountControllers[dueId] = TextEditingController();
        } else {
          _variableAmountControllers[dueId]?.dispose();
          _variableAmountControllers.remove(dueId);
        }
      }
    });
  }

  Future<void> _selectDueDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _assignDues() async {
    // Validate tenant and landlord IDs
    if (widget.tenantId.isEmpty) {
      _showErrorSnackbar('Invalid tenant ID');
      return;
    }

    if (widget.landlordId.isEmpty) {
      _showErrorSnackbar('Invalid landlord ID');
      return;
    }

    // Check if at least one due is selected
    if (!_selectedDues.containsValue(true)) {
      _showErrorSnackbar('Please select at least one due');
      return;
    }

    // Validate variable amounts
    for (var entry in _variableAmountControllers.entries) {
      if (_selectedDues[entry.key] == true) {
        if (entry.value.text.isEmpty) {
          _showErrorSnackbar('Please enter amount for all variable dues');
          return;
        }

        final amount = double.tryParse(entry.value.text);
        if (amount == null || amount <= 0) {
          _showErrorSnackbar('Please enter a valid amount greater than 0');
          return;
        }
      }
    }

    try {
      // Prepare the assigned dues data
      final duesProvider = Provider.of<DuesProvider>(context, listen: false);
      final assignmentProvider = Provider.of<DueAssignmentProvider>(
        context,
        listen: false,
      );
      final assignedDues = <Map<String, dynamic>>[];

      _selectedDues.forEach((dueId, isSelected) {
        if (isSelected) {
          try {
            final due = duesProvider.dues.firstWhere(
                  (d) => d.id == dueId,
              orElse: () => throw Exception('Due not found'),
            );

            final dueData = {
              'dueId': dueId,
              'name': due.name ?? 'Unnamed Due',
              'type': due.type ?? 'fixed',
            };

            if (due.type == 'variable') {
              final controller = _variableAmountControllers[dueId];
              if (controller != null && controller.text.isNotEmpty) {
                dueData['amount'] = controller.text;
              } else {
                throw Exception('Variable amount not provided for ${due.name}');
              }
            } else {
              if (due.amount != null) {
                dueData['amount'] = due.amount.toString();
              } else {
                throw Exception('Fixed due amount is null for ${due.name}');
              }
            }

            assignedDues.add(dueData);
          } catch (e) {
            print('Error processing due $dueId: $e');
          }
        }
      });

      if (assignedDues.isEmpty) {
        _showErrorSnackbar('No valid dues to assign');
        return;
      }

      // Format due date as ISO 8601 string (yyyy-MM-dd)
      // This format is compatible with MongoDB Date casting
      final formattedDueDate = _selectedDueDate.toIso8601String();

      print('Assigning dues to tenant...');
      print('Tenant ID: ${widget.tenantId}');
      print('Landlord ID: ${widget.landlordId}');
      print('Due Date: $formattedDueDate');
      print('Assigned Dues: $assignedDues');

      // Call API to assign multiple dues
      final result = await assignmentProvider.assignMultipleDues(
        tenantId: widget.tenantId,
        landlordId: widget.landlordId,
        duesData: assignedDues,
        dueDate: formattedDueDate,
      );

      // Show result
      final successCount = result['success'] as int;
      final failureCount = result['failure'] as int;
      final errors = result['errors'] as List<String>;

      if (successCount > 0 && failureCount == 0) {
        // All successful
        _showSuccessSnackbar(
          'All dues assigned successfully! ($successCount assigned)',
        );
        Navigator.of(context).pop(true); // Return true to indicate success
        Navigator.of(context).pop(true); // Return true to indicate success
      } else if (successCount > 0 && failureCount > 0) {
        // Partial success
        _showWarningDialog(
          'Partial Success',
          'Successfully assigned $successCount due(s), but $failureCount failed.\n\nErrors:\n${errors.join('\n')}',
        );
      } else {
        // All failed
        _showErrorDialog(
          'Assignment Failed',
          'Failed to assign dues.\n\nErrors:\n${errors.join('\n')}',
        );
      }
    } catch (e) {
      _showErrorSnackbar('Error: ${e.toString()}');
    }
  }

  void _showSuccessSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showWarningDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Close screen after dialog
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Dues'), elevation: 0),
      body: Consumer2<DuesProvider, DueAssignmentProvider>(
        builder: (context, duesProvider, assignmentProvider, child) {
          if (duesProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (duesProvider.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading dues',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(duesProvider.error ?? 'Unknown error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDues,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (duesProvider.dues.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No dues available',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Create dues first to assign them to tenants'),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Due Date Selection
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: InkWell(
                  onTap: _selectDueDate,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        const Text(
                          'Due Date: ',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          DateFormat('dd MMM yyyy').format(_selectedDueDate),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.edit, size: 18, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: duesProvider.dues.length,
                  itemBuilder: (context, index) {
                    final due = duesProvider.dues[index];
                    final dueId = due.id ?? '';
                    final dueName = due.name ?? 'Unnamed Due';
                    final dueType = due.type ?? 'fixed';
                    final isSelected = _selectedDues[dueId] ?? false;
                    final isVariable = dueType == 'variable';

                    if (dueId.isEmpty) {
                      return const SizedBox.shrink(); // Skip if no ID
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                          isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _toggleDueSelection(dueId, dueType),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      _toggleDueSelection(dueId, dueType);
                                    },
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dueName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color:
                                                isVariable
                                                    ? Colors.orange.shade100
                                                    : Colors.blue.shade100,
                                                borderRadius:
                                                BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                dueType.toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                  isVariable
                                                      ? Colors
                                                      .orange
                                                      .shade900
                                                      : Colors
                                                      .blue
                                                      .shade900,
                                                ),
                                              ),
                                            ),
                                            if (!isVariable &&
                                                due.amount != null) ...[
                                              const SizedBox(width: 8),
                                              Text(
                                                '₹${due.amount!.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected && isVariable) ...[
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _variableAmountControllers[dueId],
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Enter Amount',
                                    prefixText: '₹ ',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                      assignmentProvider.isLoading ? null : _assignDues,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                      assignmentProvider.isLoading
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Text(
                        'Assign Dues',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}