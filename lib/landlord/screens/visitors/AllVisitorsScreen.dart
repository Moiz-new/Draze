import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/VisitorModel.dart';
import '../../providers/AllVisitorsProvider.dart';
import 'VisitorDetailsScreen.dart';

class AllVisitorsScreen extends StatefulWidget {
  final String? status;

  const AllVisitorsScreen({Key? key, this.status}) : super(key: key);

  @override
  State<AllVisitorsScreen> createState() => _AllVisitorsScreenState();
}

class _AllVisitorsScreenState extends State<AllVisitorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    final status = widget.status ?? 'all';
    debugPrint('Status: $status');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AllVisitorsProvider>().fetchAllVisitors(status);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Consumer<AllVisitorsProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            slivers: [
              _buildModernAppBar(provider),
              _buildFilterSection(provider),
              _buildVisitorsList(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildModernAppBar(AllVisitorsProvider provider) {
    return SliverAppBar(
      expandedHeight: 160.h,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          if (mounted) {
            Navigator.pop(context);
          }
        },
        icon: Icon(Icons.arrow_back, size: 18.w, color: Colors.white),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Visitors',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Manage your property visits',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSection(AllVisitorsProvider provider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search visitors...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 14.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey.shade500,
                    size: 20.w,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
                onChanged: (value) {
                  // Implement search logic
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _NoData() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 100.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 80, color: Colors.grey.shade400),
            SizedBox(height: 16.h),
            Text(
              "No Data Found for ${widget.status ?? 'all'}",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitorsList(AllVisitorsProvider provider) {
    if (provider.error != null) {
      return SliverToBoxAdapter(child: _buildErrorState(provider));
    }

    if (provider.isLoading && provider.visitors.isEmpty) {
      return SliverToBoxAdapter(child: _buildLoadingState());
    }

    if (provider.visitors.isEmpty) {
      return SliverToBoxAdapter(child: _NoData());
    }

    final filteredVisitors = provider.filteredVisitors;
    if (filteredVisitors.isEmpty) {
      return SliverToBoxAdapter(child: _NoData());
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index >= filteredVisitors.length) {
            return const SizedBox.shrink();
          }

          final visitor = filteredVisitors[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: ModernVisitorCard(
              visitor: visitor,
              onTap: () {
                if (mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => VisitorDetailsScreen(visitor: visitor),
                    ),
                  );
                }
              },
            ),
          );
        }, childCount: filteredVisitors.length),
      ),
    );
  }

  Widget _buildErrorState(AllVisitorsProvider provider) {
    return Container(
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 40.w,
              color: Colors.red.shade400,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade900,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            provider.error ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                provider.clearError();
                provider.fetchAllVisitors(widget.status ?? 'all');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Try Again',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: 120.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF6366F1),
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernVisitorCard extends StatelessWidget {
  final VisitorModel visitor;
  final VoidCallback onTap;

  const ModernVisitorCard({
    Key? key,
    required this.visitor,
    required this.onTap,
  }) : super(key: key);

  String _getLandlordName() {
    return visitor.landlordId?.name ?? 'Unknown Landlord';
  }

  String _getLandlordMobile() {
    return visitor.landlordId?.mobile ?? 'No contact';
  }

  String _getPropertyName() {
    return visitor.propertyId?.name ?? 'Unknown Property';
  }

  String _getPropertyAddress() {
    return visitor.propertyId?.address ?? 'Address not available';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getStatusColor().withOpacity(0.8),
                              _getStatusColor(),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 24.w,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getLandlordName(),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              _getLandlordMobile(),
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          visitor.statusText.isNotEmpty
                              ? visitor.statusText
                              : visitor.status,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16.w,
                              color: const Color(0xFF6366F1),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                _getPropertyName(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade900,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16.w,
                              color: const Color(0xFF6366F1),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              _formatVisitDate(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      context,
                      'View',
                      Icons.visibility_rounded,
                      const Color(0xFF6366F1),
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    VisitorDetailsScreen(visitor: visitor),
                          ),
                        );
                      },
                    ),
                  ),
                  // Only show action buttons if visit date hasn't passed
                  if (!_isVisitDatePassed()) ...[
                    if (_isPending()) ...[
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          'Confirm',
                          Icons.check_rounded,
                          const Color(0xFF10B981),
                          () {
                            _showConfirmDialog(context);
                          },
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          'Cancel',
                          Icons.cancel_outlined,
                          const Color(0xFFDC2020),
                          () {
                            _showCancelDialog(context);
                          },
                        ),
                      ),
                    ],
                    if (_isConfirmed()) ...[
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildQuickAction(
                          context,
                          'Complete',
                          Icons.done_all_rounded,
                          const Color(0xFF10B981),
                          () {
                            _showCompleteDialog(context);
                          },
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isPending() {
    final status = visitor.status.toLowerCase().trim();
    return status == 'pending';
  }

  bool _isVisitDatePassed() {
    try {
      final now = DateTime.now();
      final visitDate = visitor.visitDate;

      // Check if visit date is in the past
      return visitDate.isBefore(now);
    } catch (e) {
      debugPrint('Error checking visit date: $e');
      return false;
    }
  }

  bool _isConfirmed() {
    final status = visitor.status.toLowerCase().trim();
    return status == 'confirmed';
  }

  String _formatVisitDate() {
    try {
      return DateFormat('MMM dd, yyyy • hh:mm a').format(visitor.visitDate);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Date not available';
    }
  }

  void _showCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final completionNotesController = TextEditingController();
        final feedbackCommentController = TextEditingController();
        bool isCompleting = false;

        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return PopScope(
              canPop: !isCompleting,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.done_all_rounded,
                        color: const Color(0xFF10B981),
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Complete Visit',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mark this visit as completed and provide feedback',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Completion Notes',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: completionNotesController,
                        maxLines: 3,
                        enabled: !isCompleting,
                        decoration: InputDecoration(
                          hintText: 'e.g., Visit completed successfully',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF10B981),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Feedback Comment',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: feedbackCommentController,
                        maxLines: 3,
                        enabled: !isCompleting,
                        decoration: InputDecoration(
                          hintText: 'e.g., User was interested in the property',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF10B981),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Both fields are optional',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isCompleting
                            ? null
                            : () {
                              completionNotesController.dispose();
                              feedbackCommentController.dispose();
                              Navigator.of(dialogContext).pop();
                            },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                  ),
                  ElevatedButton(
                    onPressed:
                        isCompleting
                            ? null
                            : () async {
                              setDialogState(() {
                                isCompleting = true;
                              });

                              final completionNotes =
                                  completionNotesController.text.trim();
                              final feedbackComment =
                                  feedbackCommentController.text.trim();

                              try {
                                final visitorProvider =
                                    Provider.of<AllVisitorsProvider>(
                                      context,
                                      listen: false,
                                    );

                                final success = await visitorProvider
                                    .completeVisit(
                                      visitorId: visitor.id ?? '',
                                      completionNotes:
                                          completionNotes.isEmpty
                                              ? null
                                              : completionNotes,
                                      feedbackComment:
                                          feedbackComment.isEmpty
                                              ? null
                                              : feedbackComment,
                                    );

                                completionNotesController.dispose();
                                feedbackCommentController.dispose();

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }

                                if (context.mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12.w),
                                            const Text(
                                              'Visit completed successfully!',
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(
                                          0xFF10B981,
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(16.w),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Text(
                                                visitorProvider.error ??
                                                    'Failed to complete visit',
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(
                                          0xFFEF4444,
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(16.w),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                completionNotesController.dispose();
                                feedbackCommentController.dispose();

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child:
                        isCompleting
                            ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Complete Visit',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final confirmationNotesController = TextEditingController();
        final meetingPointController = TextEditingController();
        bool isConfirming = false;

        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return PopScope(
              canPop: !isConfirming,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.check_circle_outline,
                        color: const Color(0xFF10B981),
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Confirm Visit',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add details for the visit confirmation',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Confirmation Notes',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: confirmationNotesController,
                        maxLines: 3,
                        enabled: !isConfirming,
                        decoration: InputDecoration(
                          hintText:
                              'e.g., Looking forward to showing you the property',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF10B981),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Meeting Point',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: meetingPointController,
                        enabled: !isConfirming,
                        decoration: InputDecoration(
                          hintText: 'e.g., Main entrance lobby',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF10B981),
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Both fields are optional',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isConfirming
                            ? null
                            : () {
                              confirmationNotesController.dispose();
                              meetingPointController.dispose();
                              Navigator.of(dialogContext).pop();
                            },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                  ),
                  ElevatedButton(
                    onPressed:
                        isConfirming
                            ? null
                            : () async {
                              setDialogState(() {
                                isConfirming = true;
                              });

                              final confirmationNotes =
                                  confirmationNotesController.text.trim();
                              final meetingPoint =
                                  meetingPointController.text.trim();

                              try {
                                final visitorProvider =
                                    Provider.of<AllVisitorsProvider>(
                                      context,
                                      listen: false,
                                    );

                                final success = await visitorProvider
                                    .confirmVisit(
                                      visitorId: visitor.id ?? '',
                                      confirmationNotes:
                                          confirmationNotes.isEmpty
                                              ? null
                                              : confirmationNotes,
                                      meetingPoint:
                                          meetingPoint.isEmpty
                                              ? null
                                              : meetingPoint,
                                    );

                                confirmationNotesController.dispose();
                                meetingPointController.dispose();

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }

                                if (context.mounted) {
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12.w),
                                            const Text(
                                              'Visit confirmed successfully!',
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(
                                          0xFF10B981,
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(16.w),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12.w),
                                            Expanded(
                                              child: Text(
                                                visitorProvider.error ??
                                                    'Failed to confirm visit',
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: const Color(
                                          0xFFEF4444,
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(16.w),
                                      ),
                                    );
                                  }
                                }
                              } catch (e) {
                                confirmationNotesController.dispose();
                                meetingPointController.dispose();

                                if (dialogContext.mounted) {
                                  Navigator.of(dialogContext).pop();
                                }

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: ${e.toString()}'),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child:
                        isConfirming
                            ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Confirm',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final cancellationReasonController = TextEditingController();
        bool isCancelling = false;

        return StatefulBuilder(
          builder: (stateContext, setDialogState) {
            return PopScope(
              canPop: !isCancelling,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2020).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(
                        Icons.cancel_outlined,
                        color: const Color(0xFFDC2020),
                        size: 24.w,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Cancel Visit',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to cancel this visit? Please provide a reason.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Cancellation Reason',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: cancellationReasonController,
                        maxLines: 3,
                        enabled: !isCancelling,
                        decoration: InputDecoration(
                          hintText:
                              'e.g., Schedule conflict, Property no longer available',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFFDC2020),
                            ),
                          ),
                          contentPadding: EdgeInsets.all(12.w),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Optional - Defaults to "No reason provided"',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed:
                        isCancelling
                            ? null
                            : () {
                              cancellationReasonController.dispose();
                              Navigator.pop(dialogContext);
                            },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: Text(
                      'No, Keep It',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  ElevatedButton(
                    onPressed:
                        isCancelling
                            ? null
                            : () async {
                              setDialogState(() {
                                isCancelling = true;
                              });

                              final cancellationReason =
                                  cancellationReasonController.text.trim();

                              final visitorProvider =
                                  Provider.of<AllVisitorsProvider>(
                                    context,
                                    listen: false,
                                  );

                              final success = await visitorProvider.cancelVisit(
                                visitorId: visitor.id ?? '',
                                cancellationReason:
                                    cancellationReason.isEmpty
                                        ? null
                                        : cancellationReason,
                              );

                              cancellationReasonController.dispose();

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                              }

                              if (context.mounted) {
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 12.w),
                                          const Text(
                                            'Visit cancelled successfully!',
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFFDC2020),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      margin: EdgeInsets.all(16.w),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 12.w),
                                          Expanded(
                                            child: Text(
                                              visitorProvider.error ??
                                                  'Failed to cancel visit',
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      margin: EdgeInsets.all(16.w),
                                    ),
                                  );
                                }
                              }
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2020),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child:
                        isCancelling
                            ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Yes, Cancel',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickAction(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.w, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    final status = visitor.status.toLowerCase().trim();
    switch (status) {
      case 'pending':
        return const Color(0xFFEAB308);
      case 'confirmed':
        return const Color(0xFF6366F1);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey.shade600;
    }
  }
}
