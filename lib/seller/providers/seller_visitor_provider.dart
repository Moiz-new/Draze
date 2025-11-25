import 'package:draze/seller/models/seller_visitor_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VisitsState {
  final List<Visit> visits;
  final List<VisitQuery> queries;
  final bool isLoading;
  final String? error;

  VisitsState({
    this.visits = const [],
    this.queries = const [],
    this.isLoading = false,
    this.error,
  });

  VisitsState copyWith({
    List<Visit>? visits,
    List<VisitQuery>? queries,
    bool? isLoading,
    String? error,
  }) {
    return VisitsState(
      visits: visits ?? this.visits,
      queries: queries ?? this.queries,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class VisitsNotifier extends StateNotifier<VisitsState> {
  VisitsNotifier() : super(VisitsState());

  // Filtered visits by status
  List<Visit> get pendingVisits =>
      state.visits.where((v) => v.status == VisitStatus.pending).toList();

  List<Visit> get confirmedVisits =>
      state.visits.where((v) => v.status == VisitStatus.confirmed).toList();

  List<Visit> get completedVisits =>
      state.visits.where((v) => v.status == VisitStatus.completed).toList();

  List<Visit> get todaysVisits {
    final today = DateTime.now();
    return state.visits
        .where(
          (v) =>
              v.scheduledDate.day == today.day &&
              v.scheduledDate.month == today.month &&
              v.scheduledDate.year == today.year,
        )
        .toList();
  }

  List<Visit> get upcomingVisits {
    final today = DateTime.now();
    return state.visits
        .where(
          (v) =>
              v.scheduledDate.isAfter(today) &&
              (v.status == VisitStatus.confirmed ||
                  v.status == VisitStatus.pending),
        )
        .toList();
  }

  // Filtered queries
  List<VisitQuery> get pendingQueries =>
      state.queries.where((q) => q.status == QueryStatus.pending).toList();

  // Initialize with static data (remove when API is integrated)
  void _initializeStaticData() {
    state = state.copyWith(
      visits: [
        Visit(
          id: '1',
          propertyId: 'prop_001',
          propertyTitle: 'Modern 3BHK Apartment',
          propertyAddress: '123 Green Valley, Sector 15, Indore',
          visitorName: 'Rahul Sharma',
          visitorEmail: 'rahul.sharma@email.com',
          visitorPhone: '+91 9876543210',
          scheduledDate: DateTime.now().add(Duration(days: 1)),
          timeSlot: '10:00 AM - 11:00 AM',
          status: VisitStatus.pending,
          notes: 'Interested in the apartment',
          specialRequests: 'Would like to see the balcony view',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          propertyImage: 'https://example.com/property1.jpg',
        ),
        Visit(
          id: '2',
          propertyId: 'prop_002',
          propertyTitle: 'Luxury Villa with Garden',
          propertyAddress: '456 Palm Heights, AB Road, Indore',
          visitorName: 'Priya Patel',
          visitorEmail: 'priya.patel@email.com',
          visitorPhone: '+91 8765432109',
          scheduledDate: DateTime.now().add(Duration(hours: 3)),
          timeSlot: '2:00 PM - 3:00 PM',
          status: VisitStatus.confirmed,
          notes: 'Looking for family home',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          propertyImage: 'https://example.com/property2.jpg',
        ),
        Visit(
          id: '3',
          propertyId: 'prop_003',
          propertyTitle: '2BHK Near IT Park',
          propertyAddress: '789 Tech City, Vijay Nagar, Indore',
          visitorName: 'Amit Kumar',
          visitorEmail: 'amit.kumar@email.com',
          visitorPhone: '+91 7654321098',
          scheduledDate: DateTime.now().subtract(Duration(days: 1)),
          timeSlot: '11:00 AM - 12:00 PM',
          status: VisitStatus.completed,
          notes: 'Completed visit, very satisfied',
          createdAt: DateTime.now().subtract(Duration(days: 3)),
          propertyImage: 'https://example.com/property3.jpg',
        ),
        Visit(
          id: '4',
          propertyId: 'prop_004',
          propertyTitle: 'Spacious 4BHK Penthouse',
          propertyAddress: '321 Sky Tower, MG Road, Indore',
          visitorName: 'Neha Singh',
          visitorEmail: 'neha.singh@email.com',
          visitorPhone: '+91 6543210987',
          scheduledDate: DateTime.now().add(Duration(days: 3)),
          timeSlot: '4:00 PM - 5:00 PM',
          status: VisitStatus.confirmed,
          notes: 'Looking for premium property',
          specialRequests: 'Wants to see all amenities',
          createdAt: DateTime.now().subtract(Duration(hours: 12)),
          propertyImage: 'https://example.com/property4.jpg',
        ),
        Visit(
          id: '5',
          propertyId: 'prop_005',
          propertyTitle: 'Affordable 1BHK Studio',
          propertyAddress: '654 Budget Homes, Rau, Indore',
          visitorName: 'Vikash Jain',
          visitorEmail: 'vikash.jain@email.com',
          visitorPhone: '+91 5432109876',
          scheduledDate: DateTime.now().add(Duration(days: 2)),
          timeSlot: '9:00 AM - 10:00 AM',
          status: VisitStatus.rescheduled,
          notes: 'Rescheduled due to personal reasons',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          propertyImage: 'https://example.com/property5.jpg',
        ),
      ],
      queries: [
        VisitQuery(
          id: 'q1',
          visitId: '1',
          visitorName: 'Rahul Sharma',
          message:
              'Is parking available for this property? Also, what are the maintenance charges?',
          createdAt: DateTime.now().subtract(Duration(hours: 5)),
          status: QueryStatus.pending,
        ),
        VisitQuery(
          id: 'q2',
          visitId: '2',
          visitorName: 'Priya Patel',
          message:
              'Can I bring my family during the visit? Are pets allowed in the villa?',
          createdAt: DateTime.now().subtract(Duration(hours: 8)),
          status: QueryStatus.responded,
          response:
              'Yes, you can bring your family. Pets are allowed with proper documentation.',
          respondedAt: DateTime.now().subtract(Duration(hours: 6)),
        ),
        VisitQuery(
          id: 'q3',
          visitId: '4',
          visitorName: 'Neha Singh',
          message:
              'What are the nearby facilities like hospitals, schools, and shopping centers?',
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          status: QueryStatus.pending,
        ),
      ],
    );
  }

  Future<void> loadVisits() async {
    state = state.copyWith(isLoading: true);
    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 1));
      _initializeStaticData();
      state = state.copyWith(error: null);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateVisitStatus(String visitId, VisitStatus newStatus) async {
    try {
      final updatedVisits =
          state.visits.map((v) {
            if (v.id == visitId) {
              return v.copyWith(status: newStatus);
            }
            return v;
          }).toList();
      state = state.copyWith(visits: updatedVisits);
      // In real implementation, make API call here
      // await api.updateVisitStatus(visitId, newStatus);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> respondToQuery(String queryId, String response) async {
    try {
      final updatedQueries =
          state.queries.map((q) {
            if (q.id == queryId) {
              return VisitQuery(
                id: q.id,
                visitId: q.visitId,
                visitorName: q.visitorName,
                message: q.message,
                createdAt: q.createdAt,
                status: QueryStatus.responded,
                response: response,
                respondedAt: DateTime.now(),
              );
            }
            return q;
          }).toList();
      state = state.copyWith(queries: updatedQueries);
      // In real implementation, make API call here
      // await api.respondToQuery(queryId, response);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> rescheduleVisit(
    String visitId,
    DateTime newDate,
    String newTimeSlot,
  ) async {
    try {
      final updatedVisits =
          state.visits.map((v) {
            if (v.id == visitId) {
              return v.copyWith(
                scheduledDate: newDate,
                timeSlot: newTimeSlot,
                status: VisitStatus.rescheduled,
              );
            }
            return v;
          }).toList();
      state = state.copyWith(visits: updatedVisits);
      // In real implementation, make API call here
      // await api.rescheduleVisit(visitId, newDate, newTimeSlot);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final visitsProvider = StateNotifierProvider<VisitsNotifier, VisitsState>((
  ref,
) {
  return VisitsNotifier();
});
