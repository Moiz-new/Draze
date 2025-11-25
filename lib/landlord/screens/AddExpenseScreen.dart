import 'dart:convert';
import 'dart:io';
import 'package:draze/app/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../providers/AddExpensesProvider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _paidToController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingProperties = false;

  String? _selectedPropertyId;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _selectedPaymentMode = 'Cash';
  File? _selectedBillImage;

  List<Property> _properties = [];

  final List<PaymentMode> _paymentModes = [
    PaymentMode('Cash', Icons.money),
    PaymentMode('GPay', Icons.payment),
    PaymentMode('PhonePe', Icons.phone_android),
    PaymentMode('Paytm', Icons.account_balance_wallet),
    PaymentMode('UPI', Icons.qr_code_scanner),
  ];

  final String _paidBy = 'Landlord';

  @override
  void initState() {
    super.initState();
    _loadProperties();
    // Load categories using provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AddExpensesProvider>().fetchCategories();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paidToController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoadingProperties = true;
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
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error loading properties: ${e.toString()}');
      }
    } finally {
      setState(() {
        _isLoadingProperties = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Upload Bill',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Camera'),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text('Gallery'),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedBillImage = File(image.path);
        });
      }
    }
  }

  Future<void> _createExpense() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      _showErrorSnackBar('Please select a category');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? landlordId = prefs.getString('landlord_id');

      if (landlordId == null || landlordId.isEmpty) {
        throw Exception('Landlord ID not found');
      }

      final provider = context.read<AddExpensesProvider>();

      final result = await provider.createExpense(
        categoryId: _selectedCategoryId!,
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
        paidBy: _paidBy,
        paidTo: _paidToController.text.trim(),
        description: _descriptionController.text.trim(),
        collectionMode: _selectedPaymentMode,
        landlordId: landlordId,
        propertyId: _selectedPropertyId,
        billImage: _selectedBillImage,
      );

      if (mounted) {
        if (result != null && result['success'] == true) {
          _showSuccessSnackBar(
            result['message'] ?? 'Expense added successfully!',
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception(provider.error ?? 'Failed to create expense');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: ${e.toString()}');
        print(e.toString());
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
        margin: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add New Expense',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildSectionTitle('Property', isRequired: false),
                    const SizedBox(height: 8),
                    _buildPropertyDropdown(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Category', isRequired: true),
                    const SizedBox(height: 8),
                    _buildCategoryRow(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Amount', isRequired: true),
                    const SizedBox(height: 8),
                    _buildAmountField(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Date', isRequired: true),
                    const SizedBox(height: 8),
                    _buildDatePicker(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Paid By', isRequired: false),
                    const SizedBox(height: 8),
                    _buildPaidByField(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Paid To', isRequired: true),
                    const SizedBox(height: 8),
                    _buildPaidToField(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Description', isRequired: false),
                    const SizedBox(height: 8),
                    _buildDescriptionField(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Payment Mode', isRequired: true),
                    const SizedBox(height: 12),
                    _buildPaymentModeGrid(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Upload Bill', isRequired: false),
                    const SizedBox(height: 12),
                    _buildBillUploadSection(),
                  ],
                ),
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
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _createExpense,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.primary.withOpacity(
                        0.6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Add Expense',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required bool isRequired}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPropertyDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedPropertyId,
      decoration: _buildInputDecoration(
        hint: 'Select Property (Optional)',
        prefixIcon: Icons.home_work,
      ),
      items:
          _properties.map((property) {
            return DropdownMenuItem(
              value: property.id,
              child: Text(property.name, style: const TextStyle(fontSize: 15)),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedPropertyId = value;
        });
      },
    );
  }

  Widget _buildCategoryRow() {
    return Consumer<AddExpensesProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.isLoading && categoryProvider.categories.isEmpty) {
          return Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: _buildInputDecoration(
                  hint: 'Select Category',
                  prefixIcon: Icons.category,
                ),
                items:
                    categoryProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(
                          category.name,
                          style: const TextStyle(fontSize: 15),
                        ),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Category is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Container(
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white, size: 26),
                onPressed: () => _showAddCategoryDialog(categoryProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: _buildInputDecoration(
        hint: 'Enter amount',
        prefixIcon: Icons.currency_rupee,
      ),
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Amount is required';
        }
        if (double.tryParse(value) == null) {
          return 'Enter valid amount';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('dd MMM yyyy').format(_selectedDate),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildPaidByField() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.account_circle, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _paidBy,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidToField() {
    return TextFormField(
      controller: _paidToController,
      decoration: _buildInputDecoration(
        hint: 'Recipient name',
        prefixIcon: Icons.person_outline,
      ),
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Recipient name is required';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: _buildInputDecoration(
        hint: 'Describe the expense (optional)',
        prefixIcon: Icons.description_outlined,
      ),
      maxLines: 4,
      maxLength: 300,
      style: const TextStyle(fontSize: 15),
    );
  }

  Widget _buildPaymentModeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _paymentModes.length,
      itemBuilder: (context, index) {
        final mode = _paymentModes[index];
        final isSelected = _selectedPaymentMode == mode.name;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            setState(() {
              _selectedPaymentMode = mode.name;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      isSelected
                          ? AppColors.primary.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  mode.icon,
                  color: isSelected ? Colors.white : AppColors.primary,
                  size: 30,
                ),
                Text(
                  mode.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillUploadSection() {
    return InkWell(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            _selectedBillImage == null
                ? Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.upload_file,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Upload Bill',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap to choose file',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
                : Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedBillImage!,
                        width: double.infinity,
                        height: 180,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedBillImage = null;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: AppColors.textSecondary.withOpacity(0.7),
        fontSize: 15,
      ),
      prefixIcon: Icon(prefixIcon, color: AppColors.primary, size: 22),
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

  void _showAddCategoryDialog(AddExpensesProvider categoryProvider) {
    final TextEditingController categoryController = TextEditingController();
    bool isAdding = false;

    showDialog(
      context: context,
      builder:
          (dialogContext) => StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Text(
                  'Add New Category',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                content: TextField(
                  controller: categoryController,
                  decoration: InputDecoration(
                    hintText: 'Enter category name',
                    prefixIcon: const Icon(
                      Icons.category,
                      color: AppColors.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  autofocus: true,
                  enabled: !isAdding,
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isAdding ? null : () => Navigator.pop(dialogContext),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        isAdding
                            ? null
                            : () async {
                              if (categoryController.text.trim().isNotEmpty) {
                                setDialogState(() {
                                  isAdding = true;
                                });

                                final success = await categoryProvider
                                    .addCategory(
                                      categoryController.text.trim(),
                                    );

                                if (success) {
                                  if (mounted) {
                                    Navigator.pop(dialogContext);
                                    _showSuccessSnackBar(
                                      'Category added successfully',
                                    );
                                    // Set the newly added category as selected
                                    setState(() {
                                      _selectedCategoryId =
                                          categoryProvider.categories.last.id;
                                    });
                                  }
                                } else {
                                  if (mounted) {
                                    setDialogState(() {
                                      isAdding = false;
                                    });
                                    _showErrorSnackBar(
                                      categoryProvider.error ??
                                          'Failed to add category',
                                    );
                                  }
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child:
                        isAdding
                            ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : const Text(
                              'Add',
                              style: TextStyle(fontWeight: FontWeight.w600,color: Colors.white),
                            ),
                  ),
                ],
              );
            },
          ),
    );
  }
}

// Payment Mode Model
class PaymentMode {
  final String name;
  final IconData icon;

  PaymentMode(this.name, this.icon);
}

// Property Model
class Property {
  final String id;
  final String name;

  Property({required this.id, required this.name});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(id: json['_id'] ?? '', name: json['name'] ?? '');
  }
}
