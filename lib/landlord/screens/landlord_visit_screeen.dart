import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/models/landlord_visit_model.dart';
import 'package:draze/landlord/providers/landlord_visitor_providers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({Key? key}) : super(key: key);

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ProviderScope.containerOf(
        context,
      ).read(visitsProvider.notifier).loadVisits();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Property Visits',
          style: TextStyle(
            fontSize: AppSizes.largeText(context),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: TextStyle(
            fontSize: AppSizes.smallText(context) + 2,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'All Visits'),
            Tab(text: 'Schedule'),
            Tab(text: 'Queries'),
          ],
        ),
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final visitsState = ref.watch(visitsProvider);

          if (visitsState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (visitsState.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: AppSizes.largeIcon(context) * 2,
                    color: AppColors.error,
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),
                  Text(
                    'Error: ${visitsState.error}',
                    style: TextStyle(
                      fontSize: AppSizes.mediumText(context),
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),
                  ElevatedButton(
                    onPressed:
                        () => ref.read(visitsProvider.notifier).loadVisits(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAllVisitsTab(context, ref),
              _buildScheduleTab(context, ref),
              _buildQueriesTab(context, ref),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAllVisitsTab(BuildContext context, WidgetRef ref) {
    final visits = ref.watch(visitsProvider).visits;

    return RefreshIndicator(
      onRefresh: () => ref.read(visitsProvider.notifier).loadVisits(),
      color: AppColors.primary,
      child:
          visits.isEmpty
              ? _buildEmptyState('No visits found', Icons.calendar_today)
              : ListView.builder(
                padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                itemCount: visits.length,
                itemBuilder: (context, index) {
                  final visit = visits[index];
                  return _buildVisitCard(visit, ref);
                },
              ),
    );
  }

  Widget _buildScheduleTab(BuildContext context, WidgetRef ref) {
    final visitsNotifier = ref.watch(visitsProvider.notifier);
    final todaysVisits = visitsNotifier.todaysVisits;
    final upcomingVisits = visitsNotifier.upcomingVisits;

    return RefreshIndicator(
      onRefresh: () => ref.read(visitsProvider.notifier).loadVisits(),
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Today\'s Visits', todaysVisits.length),
            SizedBox(height: AppSizes.smallPadding(context)),
            if (todaysVisits.isEmpty)
              _buildEmptyScheduleSection('No visits scheduled for today')
            else
              ...todaysVisits.map((visit) => _buildVisitCard(visit, ref)),

            SizedBox(height: AppSizes.largePadding(context)),

            _buildSectionHeader('Upcoming Visits', upcomingVisits.length),
            SizedBox(height: AppSizes.smallPadding(context)),
            if (upcomingVisits.isEmpty)
              _buildEmptyScheduleSection('No upcoming visits')
            else
              ...upcomingVisits.map((visit) => _buildVisitCard(visit, ref)),
          ],
        ),
      ),
    );
  }

  Widget _buildQueriesTab(BuildContext context, WidgetRef ref) {
    final queries = ref.watch(visitsProvider).queries;

    return RefreshIndicator(
      onRefresh: () => ref.read(visitsProvider.notifier).loadVisits(),
      color: AppColors.primary,
      child:
          queries.isEmpty
              ? _buildEmptyState('No queries found', Icons.help_outline)
              : ListView.builder(
                padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                itemCount: queries.length,
                itemBuilder: (context, index) {
                  final query = queries[index];
                  return _buildQueryCard(query, ref);
                },
              ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.mediumPadding(context),
        vertical: AppSizes.smallPadding(context),
      ),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: AppSizes.largeText(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSizes.smallPadding(context),
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: AppSizes.smallText(context),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScheduleSection(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.largePadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.schedule,
            size: AppSizes.largeIcon(context),
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSizes.smallPadding(context)),
          Text(
            message,
            style: TextStyle(
              fontSize: AppSizes.mediumText(context),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisitCard(Visit visit, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.home,
                        color: AppColors.primary,
                        size: AppSizes.mediumIcon(context),
                      ),
                    ),
                    SizedBox(width: AppSizes.mediumPadding(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit.propertyTitle,
                            style: TextStyle(
                              fontSize: AppSizes.mediumText(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            visit.propertyAddress,
                            style: TextStyle(
                              fontSize: AppSizes.smallText(context),
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(visit.status),
                  ],
                ),

                SizedBox(height: AppSizes.mediumPadding(context)),

                Container(
                  padding: EdgeInsets.all(AppSizes.smallPadding(context)),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.person, 'Visitor', visit.visitorName),
                      SizedBox(height: AppSizes.smallPadding(context)),
                      _buildInfoRow(Icons.phone, 'Phone', visit.visitorPhone),
                      SizedBox(height: AppSizes.smallPadding(context)),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Date',
                        '${visit.scheduledDate.day}/${visit.scheduledDate.month}/${visit.scheduledDate.year}',
                      ),
                      SizedBox(height: AppSizes.smallPadding(context)),
                      _buildInfoRow(Icons.access_time, 'Time', visit.timeSlot),
                    ],
                  ),
                ),

                if (visit.notes != null) ...[
                  SizedBox(height: AppSizes.mediumPadding(context)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizes.smallPadding(context)),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Notes: ${visit.notes}',
                      style: TextStyle(
                        fontSize: AppSizes.smallText(context),
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // Minimize row width to fit content
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed:
                        visit.status == VisitStatus.pending
                            ? () => ref
                                .read(visitsProvider.notifier)
                                .updateVisitStatus(
                                  visit.id,
                                  VisitStatus.confirmed,
                                )
                            : null,
                    icon: Icon(Icons.check, size: AppSizes.smallIcon(context)),
                    label: Text(
                      'Confirm',
                      style: TextStyle(fontSize: AppSizes.smallText(context)),
                      overflow: TextOverflow.ellipsis, // Prevent text overflow
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor:
                          visit.status == VisitStatus.pending
                              ? AppColors.success
                              : AppColors.disabled,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.smallPadding(
                          context,
                        ), // Consistent padding
                      ),
                      minimumSize: Size(
                        0,
                        40,
                      ), // Ensure buttons fit in one line
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showRescheduleDialog(visit, ref),
                    icon: Icon(
                      Icons.schedule,
                      size: AppSizes.smallIcon(context),
                    ),
                    label: Text(
                      'Reschedule',
                      style: TextStyle(fontSize: AppSizes.smallText(context)),
                      overflow: TextOverflow.ellipsis, // Prevent text overflow
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.warning,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.smallPadding(context),
                      ),
                      minimumSize: Size(
                        0,
                        40,
                      ), // Ensure buttons fit in one line
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
                Container(width: 1, height: 40, color: AppColors.divider),
                Expanded(
                  child: TextButton.icon(
                    onPressed:
                        () => ref
                            .read(visitsProvider.notifier)
                            .updateVisitStatus(visit.id, VisitStatus.cancelled),
                    icon: Icon(Icons.cancel, size: AppSizes.smallIcon(context)),
                    label: Text(
                      'Cancel',
                      style: TextStyle(fontSize: AppSizes.smallText(context)),
                      overflow: TextOverflow.ellipsis, // Prevent text overflow
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.smallPadding(context),
                      ),
                      minimumSize: Size(
                        0,
                        40,
                      ), // Ensure buttons fit in one line
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQueryCard(VisitQuery query, WidgetRef ref) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSizes.mediumPadding(context)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      radius: 20,
                      child: Text(
                        query.visitorName[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.mediumText(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSizes.mediumPadding(context)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            query.visitorName,
                            style: TextStyle(
                              fontSize: AppSizes.largeText(context),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            _formatDateTime(query.createdAt),
                            style: TextStyle(
                              fontSize: AppSizes.smallText(context),
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.smallPadding(context),
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color:
                            query.status == QueryStatus.pending
                                ? AppColors.warning.withOpacity(0.2)
                                : AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        query.status.displayName,
                        style: TextStyle(
                          fontSize: AppSizes.smallText(context),
                          color:
                              query.status == QueryStatus.pending
                                  ? AppColors.warning
                                  : AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: AppSizes.mediumPadding(context)),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Query:',
                        style: TextStyle(
                          fontSize: AppSizes.smallText(context),
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        query.message,
                        style: TextStyle(
                          fontSize: AppSizes.mediumText(context),
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),

                if (query.response != null) ...[
                  SizedBox(height: AppSizes.mediumPadding(context)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Response:',
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          query.response!,
                          style: TextStyle(
                            fontSize: AppSizes.mediumText(context),
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Responded on: ${_formatDateTime(query.respondedAt!)}',
                          style: TextStyle(
                            fontSize: AppSizes.smallText(context),
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (query.status == QueryStatus.pending)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showResponseDialog(query, ref),
                      icon: Icon(
                        Icons.reply,
                        size: AppSizes.smallIcon(context),
                      ),
                      label: Text(
                        'Respond',
                        style: TextStyle(fontSize: AppSizes.smallText(context)),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(VisitStatus status) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case VisitStatus.pending:
        backgroundColor = AppColors.warning.withOpacity(0.2);
        textColor = AppColors.warning;
        break;
      case VisitStatus.confirmed:
        backgroundColor = AppColors.success.withOpacity(0.2);
        textColor = AppColors.success;
        break;
      case VisitStatus.completed:
        backgroundColor = AppColors.primary.withOpacity(0.2);
        textColor = AppColors.primary;
        break;
      case VisitStatus.cancelled:
        backgroundColor = AppColors.error.withOpacity(0.2);
        textColor = AppColors.error;
        break;
      case VisitStatus.rescheduled:
        backgroundColor = AppColors.secondary;
        textColor = AppColors.primary;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.smallPadding(context),
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: AppSizes.smallText(context),
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: AppSizes.smallIcon(context), color: AppColors.primary),
        SizedBox(width: AppSizes.smallPadding(context)),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: AppSizes.smallText(context),
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: AppSizes.smallText(context),
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: AppSizes.largeIcon(context) * 2,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: AppSizes.mediumPadding(context)),
          Text(
            message,
            style: TextStyle(
              fontSize: AppSizes.largeText(context),
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(Visit visit, WidgetRef ref) {
    DateTime selectedDate = visit.scheduledDate;
    String selectedTimeSlot = visit.timeSlot;

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(
                    'Reschedule Visit',
                    style: TextStyle(
                      fontSize: AppSizes.largeText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(
                          Icons.calendar_today,
                          color: AppColors.primary,
                        ),
                        title: Text('Date'),
                        subtitle: Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              selectedDate = date;
                            });
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.access_time,
                          color: AppColors.primary,
                        ),
                        title: Text('Time Slot'),
                        subtitle: Text(selectedTimeSlot),
                        onTap: () {
                          _showTimeSlotPicker(context, (timeSlot) {
                            setState(() {
                              selectedTimeSlot = timeSlot;
                            });
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(visitsProvider.notifier)
                            .rescheduleVisit(
                              visit.id,
                              selectedDate,
                              selectedTimeSlot,
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Visit rescheduled successfully'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(
                        'Reschedule',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showTimeSlotPicker(
    BuildContext context,
    Function(String) onTimeSlotSelected,
  ) {
    final timeSlots = [
      '9:00 AM - 10:00 AM',
      '10:00 AM - 11:00 AM',
      '11:00 AM - 12:00 PM',
      '2:00 PM - 3:00 PM',
      '3:00 PM - 4:00 PM',
      '4:00 PM - 5:00 PM',
      '5:00 PM - 6:00 PM',
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Select Time Slot'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  timeSlots
                      .map(
                        (timeSlot) => ListTile(
                          title: Text(timeSlot),
                          onTap: () {
                            onTimeSlotSelected(timeSlot);
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }

  void _showResponseDialog(VisitQuery query, WidgetRef ref) {
    final responseController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Respond to Query',
              style: TextStyle(
                fontSize: AppSizes.largeText(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Query from ${query.visitorName}:',
                  style: TextStyle(
                    fontSize: AppSizes.smallText(context),
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.all(AppSizes.smallPadding(context)),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    query.message,
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                SizedBox(height: AppSizes.mediumPadding(context)),
                TextField(
                  controller: responseController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'Your Response',
                    border: OutlineInputBorder(),
                    hintText: 'Type your response here...',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (responseController.text.trim().isNotEmpty) {
                    ref
                        .read(visitsProvider.notifier)
                        .respondToQuery(
                          query.id,
                          responseController.text.trim(),
                        );
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Response sent successfully'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(
                  'Send Response',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
