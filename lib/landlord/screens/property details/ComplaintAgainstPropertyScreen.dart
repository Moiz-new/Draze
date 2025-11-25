// complaint_against_property_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../app/api_constants.dart';
import '../../../core/constants/appColors.dart';

class ComplaintAgainstPropertyProvider extends ChangeNotifier {
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  String? _error;

  List<Complaint> get complaints => _complaints;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchComplaints(String propertyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        _error = 'Authentication token not found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await http.get(
        Uri.parse('$base_url/api/landlord/tenant/property/$propertyId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _complaints = [];

        for (var tenant in data) {
          final tenantName = tenant['name'] ?? 'N/A';
          final tenantId = tenant['tenantId'] ?? 'N/A';
          final complaintsData = tenant['complaints'] as List?;

          if (complaintsData != null && complaintsData.isNotEmpty) {
            for (var complaint in complaintsData) {
              _complaints.add(Complaint.fromJson(complaint, tenantName, tenantId));
            }
          }
        }
      } else {
        _error = 'Failed to load complaints: ${response.statusCode}';
      }
    } catch (e) {
      _error = 'Error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> resolveComplaint(String tenantId, String complaintId, String landlordResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.patch(
        Uri.parse('$base_url/api/landlord/tenant/$tenantId/complaint/$complaintId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'status': 'Resolved',
          'landlordResponse': landlordResponse,
        }),
      );

      if (response.statusCode == 200) {
        // Update the complaint in the local list
        final index = _complaints.indexWhere((c) => c.complaintId == complaintId);
        if (index != -1) {
          final updatedComplaintData = json.decode(response.body)['complaint'];
          _complaints[index] = Complaint.fromJson(
            updatedComplaintData,
            _complaints[index].tenantName,
            _complaints[index].tenantId,
          );
          notifyListeners();
        }
        return true;
      } else {
        throw Exception('Failed to resolve complaint: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error resolving complaint: $e');
    }
  }
}

class Complaint {
  final String complaintId;
  final String tenantName;
  final String tenantId;
  final String roomId;
  final String? bedId;
  final String subject;
  final String description;
  final String status;
  final String priority;
  final String createdAt;
  final String? landlordResponse;
  final String? resolvedAt;

  Complaint({
    required this.complaintId,
    required this.tenantName,
    required this.tenantId,
    required this.roomId,
    this.bedId,
    required this.subject,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
    this.landlordResponse,
    this.resolvedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json, String tenantName, String tenantId) {
    return Complaint(
      complaintId: json['complaintId'] ?? 'N/A',
      tenantName: tenantName,
      tenantId: tenantId,
      roomId: json['roomId'] ?? 'N/A',
      bedId: json['bedId'],
      subject: json['subject'] ?? 'N/A',
      description: json['description'] ?? 'N/A',
      status: json['status'] ?? 'Pending',
      priority: json['priority'] ?? 'Medium',
      createdAt: json['createdAt'] ?? '',
      landlordResponse: json['landlordResponse'],
      resolvedAt: json['resolvedAt'],
    );
  }

  String get formattedDate {
    if (createdAt.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(createdAt);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String get formattedResolvedDate {
    if (resolvedAt == null || resolvedAt!.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(resolvedAt!);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}



class ComplaintAgainstPropertyScreen extends StatefulWidget {
  final String propertyId;

  const ComplaintAgainstPropertyScreen({Key? key, required this.propertyId}) : super(key: key);

  @override
  State<ComplaintAgainstPropertyScreen> createState() => _ComplaintAgainstPropertyScreenState();
}

class _ComplaintAgainstPropertyScreenState extends State<ComplaintAgainstPropertyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintAgainstPropertyProvider>().fetchComplaints(widget.propertyId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<ComplaintAgainstPropertyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () => provider.fetchComplaints(widget.propertyId),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: Text('Retry', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (provider.complaints.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 80.sp, color: AppColors.success),
                  SizedBox(height: 16.h),
                  Text(
                    'No complaints found',
                    style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.fetchComplaints(widget.propertyId),
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: provider.complaints.length,
              itemBuilder: (context, index) {
                final complaint = provider.complaints[index];
                return ComplaintCard(
                  complaint: complaint,
                  propertyId: widget.propertyId,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final String propertyId;

  const ComplaintCard({
    Key? key,
    required this.complaint,
    required this.propertyId,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (complaint.status.toLowerCase()) {
      case 'resolved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'in progress':
        return AppColors.primary;
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPriorityColor() {
    switch (complaint.priority.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showResolveDialog(BuildContext context) {
    final TextEditingController responseController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Resolve Complaint',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subject: ${complaint.subject}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              TextFormField(
                controller: responseController,
                maxLines: 4,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Landlord Response',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  hintText: 'Enter your response to resolve this complaint...',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a response';
                  }
                  if (value.trim().length < 10) {
                    return 'Response must be at least 10 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop();
                _resolveComplaint(context, responseController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Resolve',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _resolveComplaint(BuildContext context, String response) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          color: AppColors.surface,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16.h),
                Text(
                  'Resolving complaint...',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final provider = context.read<ComplaintAgainstPropertyProvider>();
      final success = await provider.resolveComplaint(
        complaint.tenantId,
        complaint.complaintId,
        response,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Complaint resolved successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resolve complaint: ${e.toString()}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isResolved = complaint.status.toLowerCase() == 'resolved';

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    complaint.subject,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    complaint.priority,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _getPriorityColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              complaint.description,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Divider(height: 20.h, color: AppColors.divider),
            _buildInfoRow(Icons.person, complaint.tenantName),
            SizedBox(height: 6.h),
            _buildInfoRow(Icons.badge, complaint.tenantId),
            SizedBox(height: 6.h),
            _buildInfoRow(
              Icons.home,
              '${complaint.roomId}${complaint.bedId != null && complaint.bedId!.isNotEmpty ? ' - ${complaint.bedId}' : ''}',
            ),
            SizedBox(height: 6.h),
            _buildInfoRow(Icons.calendar_today, complaint.formattedDate),

            // Show landlord response if resolved
            if (isResolved && complaint.landlordResponse != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Landlord Response:',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      complaint.landlordResponse!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (complaint.resolvedAt != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'Resolved on: ${complaint.formattedResolvedDate}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${complaint.complaintId}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: _getStatusColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: _getStatusColor().withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        complaint.status,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _getStatusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (!isResolved) ...[
                      SizedBox(width: 8.w),
                      SizedBox(
                        height: 32.h,
                        child: ElevatedButton(
                          onPressed: () => _showResolveDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                          child: Text(
                            'Resolve',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14.sp, color: AppColors.textSecondary),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}