// import 'package:draze/landlord/models/property_model.dart';
// import 'package:draze/landlord/providers/property_provider.dart';
// import 'package:draze/landlord/services/property_services.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// // Property Details State
// class PropertyDetailsState {
//   final AsyncValue<Property> property;
//   final int selectedTabIndex;
//   final int selectedBottomNavIndex;

//   PropertyDetailsState({
//     required this.property,
//     required this.selectedTabIndex,
//     required this.selectedBottomNavIndex,
//   });

//   PropertyDetailsState copyWith({
//     AsyncValue<Property>? property,
//     int? selectedTabIndex,
//     int? selectedBottomNavIndex,
//   }) {
//     return PropertyDetailsState(
//       property: property ?? this.property,
//       selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
//       selectedBottomNavIndex:
//           selectedBottomNavIndex ?? this.selectedBottomNavIndex,
//     );
//   }
// }

// // Property Details Notifier
// class PropertyDetailsNotifier extends StateNotifier<PropertyDetailsState> {
//   final PropertyService propertyService;
//   final TabController tabController;

//   PropertyDetailsNotifier({
//     required this.propertyService,
//     required String propertyId,
//     required this.tabController,
//   }) : super(
//          PropertyDetailsState(
//            property: const AsyncValue.loading(),
//            selectedTabIndex: 0,
//            selectedBottomNavIndex: 0,
//          ),
//        ) {
//     _loadProperty(propertyId);
//     tabController.addListener(_handleTabChange);
//   }

//   Future<void> _loadProperty(String propertyId) async {
//     state = state.copyWith(property: const AsyncValue.loading());
//     try {
//       final property = await propertyService.getProperty(propertyId);
//       if (property != null) {
//         state = state.copyWith(property: AsyncValue.data(property));
//       } else {
//         state = state.copyWith(
//           property: AsyncValue.data(
//             Property(
//               id: '',
//               name: 'Unknown Property',
//               type: PropertyType.apartment,
//               address: '',
//               city: '',
//               state: '',
//               pincode: '',
//               description: '',
//               totalArea: 0,
//               totalRooms: 0,
//               landlordId: '',
//             ),
//           ),
//         );
//       }
//     } catch (error, stackTrace) {
//       state = state.copyWith(property: AsyncValue.error(error, stackTrace));
//     }
//   }

//   void _handleTabChange() {
//     final newIndex = tabController.index;
//     final newBottomNavIndex = _getBottomNavIndex(newIndex);
//     state = state.copyWith(
//       selectedTabIndex: newIndex,
//       selectedBottomNavIndex: newBottomNavIndex,
//     );
//   }

//   void onBottomNavTap(int index) {
//     final newTabIndex = _getTabIndexForBottomNav(index);
//     tabController.animateTo(newTabIndex);
//     state = state.copyWith(
//       selectedBottomNavIndex: index,
//       selectedTabIndex: newTabIndex,
//     );
//   }

//   int _getTabIndexForBottomNav(int bottomNavIndex) {
//     switch (bottomNavIndex) {
//       case 0: // Overview
//         return 0;
//       case 1: // Finance
//         return 3; // Collections tab
//       case 2: // Tenants
//         return 2;
//       case 3: // Profile
//         return 0; // Placeholder, as Profile is not implemented
//       default:
//         return 0;
//     }
//   }

//   int _getBottomNavIndex(int tabIndex) {
//     if (tabIndex <= 1) return 0; // Overview, Rooms
//     if (tabIndex >= 3 && tabIndex <= 5) return 1; // Collections, Dues, Expenses
//     return 2; // Tenants, Announcements
//   }

//   @override
//   void dispose() {
//     tabController.removeListener(_handleTabChange);
//     super.dispose();
//   }
// }

// // Property Details Provider
// final propertyDetailsProvider = StateNotifierProvider.family<
//   PropertyDetailsNotifier,
//   PropertyDetailsState,
//   ({String propertyId, TabController tabController})
// >((ref, params) {
//   final propertyService = ref.watch(propertyServiceProvider);
//   return PropertyDetailsNotifier(
//     propertyService: propertyService,
//     propertyId: params.propertyId,
//     tabController: params.tabController,
//   );
// });

import 'package:draze/landlord/models/property_model.dart';
import 'package:draze/landlord/providers/property_provider.dart';
import 'package:draze/landlord/services/property_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PropertyDetailsState {
  final AsyncValue<Property> property;
  final int selectedTabIndex;
  final int selectedBottomNavIndex;

  PropertyDetailsState({
    required this.property,
    required this.selectedTabIndex,
    required this.selectedBottomNavIndex,
  });

  PropertyDetailsState copyWith({
    AsyncValue<Property>? property,
    int? selectedTabIndex,
    int? selectedBottomNavIndex,
  }) {
    return PropertyDetailsState(
      property: property ?? this.property,
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      selectedBottomNavIndex:
          selectedBottomNavIndex ?? this.selectedBottomNavIndex,
    );
  }
}

class PropertyDetailsNotifier extends StateNotifier<PropertyDetailsState> {
  final PropertyService propertyService;
  final TabController tabController;

  PropertyDetailsNotifier({
    required this.propertyService,
    required String propertyId,
    required this.tabController,
  }) : super(
         PropertyDetailsState(
           property: const AsyncValue.loading(),
           selectedTabIndex: 0,
           selectedBottomNavIndex: 0,
         ),
       ) {
    _loadProperty(propertyId);
    tabController.addListener(_handleTabChange);
  }

  Future<void> _loadProperty(String propertyId) async {
    try {
      final property = await propertyService.getProperty(propertyId);
      state = state.copyWith(
        property: AsyncValue.data(
          property ??
              Property(
                id: '',
                name: 'Unknown Property',
                type: PropertyType.studioApartment,
                address: '',
                city: '',
                state: '',
                pincode: '',
                description: '',
                totalArea: 0,
                totalRooms: 0,
                landlordId: '',
                status: PropertyStatus.active,
                amenities: [],
                contactNumber: null,
                email: null,
              ),
        ),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(property: AsyncValue.error(error, stackTrace));
    }
  }

  void _handleTabChange() {
    final newIndex = tabController.index;
    final newBottomNavIndex = _getBottomNavIndex(newIndex);
    state = state.copyWith(
      selectedTabIndex: newIndex,
      selectedBottomNavIndex: newBottomNavIndex,
    );
  }

  void onBottomNavTap(int index) {
    final newTabIndex = _getTabIndexForBottomNav(index);
    tabController.animateTo(newTabIndex);
    state = state.copyWith(
      selectedBottomNavIndex: index,
      selectedTabIndex: newTabIndex,
    );
  }

  int _getTabIndexForBottomNav(int bottomNavIndex) {
    switch (bottomNavIndex) {
      case 0:
        return 0;
      case 1:
        return 3;
      case 2:
        return 2;
      case 3:
        return 3;
      default:
        return 0;
    }
  }

  int _getBottomNavIndex(int tabIndex) {
    if (tabIndex <= 1) return 0;
    if (tabIndex >= 3 && tabIndex <= 5) return 1;
    return 2;
  }

  @override
  void dispose() {
    tabController.removeListener(_handleTabChange);
    super.dispose();
  }
}

final propertyDetailsProvider = StateNotifierProvider.family<
  PropertyDetailsNotifier,
  PropertyDetailsState,
  ({String propertyId, TabController tabController})
>((ref, params) {
  final propertyService = ref.watch(propertyServiceProvider);
  return PropertyDetailsNotifier(
    propertyService: propertyService,
    propertyId: params.propertyId,
    tabController: params.tabController,
  );
});
