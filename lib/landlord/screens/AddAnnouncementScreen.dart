import 'dart:convert';
import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import '../providers/AnnouncementProvider.dart';

class AddAnnouncementScreen extends StatefulWidget {
  const AddAnnouncementScreen({Key? key}) : super(key: key);

  @override
  State<AddAnnouncementScreen> createState() => _AddAnnouncementScreenState();
}

class _AddAnnouncementScreenState extends State<AddAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool _sendToAll = true;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isLoadingTenants = false;

  String? _selectedPropertyId;
  String? _selectedTenantId;
  List<Property> _properties = [];
  List<Tenant> _tenants = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('$base_url/api/landlord/properties'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['properties'] != null) {
          setState(() {
            _properties =
                (data['properties'] as List)
                    .map((json) => Property.fromJson(json))
                    .toList();
          });
        } else {
          throw Exception('Failed to load properties');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      if (mounted) {
        _showErrorSnackBar('Error loading properties: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTenants(String propertyId) async {
    setState(() {
      _isLoadingTenants = true;
      _tenants = [];
      _selectedTenantId = null;
    });

    try {
      final property = _properties.firstWhere((p) => p.id == propertyId);

      // Use a Map to deduplicate tenants by tenantId
      Map<String, Tenant> uniqueTenants = {};

      // Extract tenants from all rooms and beds
      for (var room in property.rooms) {
        // Add room-level tenants
        for (var tenant in room.tenants) {
          if (tenant.tenantId.isNotEmpty) {
            uniqueTenants[tenant.tenantId] = tenant;
          }
        }

        // Add bed-level tenants
        for (var bed in room.beds) {
          for (var tenant in bed.tenants) {
            if (tenant.tenantId.isNotEmpty) {
              uniqueTenants[tenant.tenantId] = tenant;
            }
          }
        }
      }

      setState(() {
        _tenants = uniqueTenants.values.toList();
      });
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error loading tenants: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoadingTenants = false;
      });
    }
  }

  Future<void> _createAnnouncement() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_sendToAll && (_selectedPropertyId == null || _selectedTenantId == null)) {
      _showErrorSnackBar('Please select a property and tenant');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found');
      }

      final body = {
        'propertyId': _selectedPropertyId,
        'title': _titleController.text.trim(),
        'message': _messageController.text.trim(),
        'sendToAll': _sendToAll.toString(),
        'isActive': _isActive.toString(),
        if (!_sendToAll && _selectedTenantId != null)
          'tenantId': _selectedTenantId,
      };

      final response = await http.post(
        Uri.parse('$base_url/api/announcement/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print(body);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        if (data['success'] == true || data['announcement'] != null) {
          // Refresh announcements list
          if (mounted) {
            context.read<AnnouncementProvider>().loadAnnouncements();
            _showSuccessSnackBar('Announcement created successfully!');
            Navigator.of(context).pop(true);
          }
        } else {
          throw Exception(data['message'] ?? 'Failed to create announcement');
        }
      } else {
        final data = json.decode(response.body);
        throw Exception(
          data['message'] ?? 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Create Announcement',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body:
      _isLoading && _properties.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Create announcements to notify your tenants about important updates',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Property Dropdown
                _buildSectionTitle('Select Property'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedPropertyId,
                  decoration: _buildInputDecoration(
                    hint: 'Choose a property',
                    icon: Icons.home_work,
                  ),
                  items:
                  _properties.map((property) {
                    return DropdownMenuItem(
                      value: property.id,
                      child: Text(
                        property.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPropertyId = value;
                      _selectedTenantId = null;
                      _tenants = [];
                    });
                    if (value != null && value.isNotEmpty) {
                      _loadTenants(value);
                    }
                  },
                  validator: (value) {
                    if (!_sendToAll && (value == null || value.isEmpty)) {
                      return 'Please select a property';
                    }
                    return null;
                  },
                ),
                // Title Field
                const SizedBox(height: 8),

                _buildSectionTitle('Announcement Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  decoration: _buildInputDecoration(
                    hint: 'Enter announcement title',
                    icon: Icons.title,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    if (value.trim().length < 3) {
                      return 'Title must be at least 3 characters';
                    }
                    return null;
                  },
                  maxLength: 100,
                ),

                const SizedBox(height: 20),

                // Message Field
                _buildSectionTitle('Message'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _messageController,
                  decoration: _buildInputDecoration(
                    hint: 'Enter your message',
                    icon: Icons.message,
                  ),
                  maxLines: 5,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a message';
                    }
                    if (value.trim().length < 10) {
                      return 'Message must be at least 10 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // Send To Section
                _buildSectionTitle('Send To'),
                const SizedBox(height: 12),

                // Send to All Switch
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.public,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Send to All Tenants',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Notify all tenants in your properties',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _sendToAll,
                        onChanged: (value) {
                          setState(() {
                            _sendToAll = value;
                            if (value) {
                              _selectedPropertyId = null;
                              _selectedTenantId = null;
                              _tenants = [];
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ),

                // Specific Tenant Selection
                if (!_sendToAll) ...[
                  const SizedBox(height: 16),

                  const SizedBox(height: 16),

                  // Tenant Dropdown
                  _buildSectionTitle('Select Tenant'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTenantId,
                    decoration: _buildInputDecoration(
                      hint:
                      _isLoadingTenants
                          ? 'Loading tenants...'
                          : _tenants.isEmpty
                          ? 'No tenants available'
                          : 'Choose a tenant',
                      icon: Icons.person,
                    ),
                    items:
                    _tenants.map((tenant) {
                      return DropdownMenuItem(
                        value: tenant.tenantId,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            Text(
                              tenant.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged:
                    _isLoadingTenants
                        ? null
                        : (value) {
                      setState(() {
                        _selectedTenantId = value;
                      });
                    },
                    validator: (value) {
                      if (!_sendToAll && (value == null || value.isEmpty)) {
                        return 'Please select a tenant';
                      }
                      return null;
                    },
                  ),

                  if (_tenants.isEmpty &&
                      _selectedPropertyId != null &&
                      !_isLoadingTenants)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'No tenants found in this property',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.warning,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 24),

                // Active Status Switch
                _buildSectionTitle('Status'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                          _isActive
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isActive ? Icons.check_circle : Icons.cancel,
                          color:
                          _isActive
                              ? AppColors.success
                              : AppColors.error,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isActive ? 'Active' : 'Inactive',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isActive
                                  ? 'Announcement is visible to tenants'
                                  : 'Announcement is hidden from tenants',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createAnnouncement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child:
                    _isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign, size: 20),
                        SizedBox(width: 12),
                        Text(
                          'Create Announcement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.7),
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }
}

// Property Model (simplified for dropdown)
class Property {
  final String id;
  final String name;
  final List<Room> rooms;

  Property({required this.id, required this.name, required this.rooms});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      rooms:
      (json['rooms'] as List?)
          ?.map((room) => Room.fromJson(room))
          .toList() ??
          [],
    );
  }
}

class Room {
  final String roomId;
  final String name;
  final List<Bed> beds;
  final List<Tenant> tenants;

  Room({
    required this.roomId,
    required this.name,
    required this.beds,
    required this.tenants,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      roomId: json['roomId'] ?? '',
      name: json['name'] ?? '',
      beds:
      (json['beds'] as List?)?.map((bed) => Bed.fromJson(bed)).toList() ??
          [],
      tenants:
      (json['tenants'] as List?)
          ?.map((tenant) => Tenant.fromJson(tenant))
          .toList() ??
          [],
    );
  }
}

class Bed {
  final String bedId;
  final String name;
  final List<Tenant> tenants;

  Bed({required this.bedId, required this.name, required this.tenants});

  factory Bed.fromJson(Map<String, dynamic> json) {
    return Bed(
      bedId: json['bedId'] ?? '',
      name: json['name'] ?? '',
      tenants:
      (json['tenants'] as List?)
          ?.map((tenant) => Tenant.fromJson(tenant))
          .toList() ??
          [],
    );
  }
}

class Tenant {
  final String tenantId;
  final String name;
  final String email;
  final String mobile;

  Tenant({
    required this.tenantId,
    required this.name,
    required this.email,
    required this.mobile,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      tenantId: json['tenantId'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
    );
  }
}