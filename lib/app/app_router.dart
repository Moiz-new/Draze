// auth_screens.dart
import 'package:draze/landlord/screens/add_property.dart';
import 'package:draze/landlord/screens/landlordmainscree.dart';
import 'package:draze/landlord/screens/profile_screen.dart';
import 'package:draze/landlord/screens/property%20details/add_room_screen.dart';
import 'package:draze/landlord/screens/property%20details/add_tenant.dart';
import 'package:draze/landlord/screens/property%20details/property_details_screens.dart';
import 'package:draze/presentations/screens/landlord_registration.dart';
import 'package:draze/presentations/screens/mobile_screen.dart';
import 'package:draze/presentations/screens/onboarding_screen.dart';
import 'package:draze/presentations/screens/otp_screen.dart';
import 'package:draze/presentations/screens/select_role.dart';
import 'package:draze/presentations/screens/seller_registration.dart';
import 'package:draze/presentations/screens/spalshscreen.dart';
import 'package:draze/presentations/screens/user_registration.dart';
import 'package:draze/seller/screens/add_property_screen.dart';
import 'package:draze/seller/screens/bottom_navigation.dart';
import 'package:draze/seller/screens/profile_screen.dart';
import 'package:draze/seller/screens/property_details_screen.dart';
import 'package:draze/user/screens/profile_screen.dart';
import 'package:draze/user/screens/userbottomnavigation.dart';
import 'package:flutter/material.dart';

// Updated router with authentication routes
import 'package:go_router/go_router.dart';

import '../landlord/screens/EditRoomScreen.dart';
import '../landlord/screens/add_property_images_screen.dart';
import '../landlord/screens/property_list_screen.dart';
import '../landlord/screens/visitors/AllVisitorsScreen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/',
  errorBuilder:
      (context, state) => Scaffold(
        body: Center(
          child: Text('Error: Route ${state.uri.toString()} not found'),
        ),
      ),
  routes: [
    // Authentication routes
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(
      path: '/onboard',
      builder: (context, state) => PropertyOnboardingScreen(),
    ),
    GoRoute(
      path: '/auth/phone',
      builder: (context, state) {
        final role = state.extra as String;
        return PhoneAuthScreen(role: role);
      },
    ),
    GoRoute(
      path: '/auth/otp',

      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return OTPVerificationScreen(
          phoneNumber: data['phoneNumber'],
          role: data['role'],
        );
      },
    ),
    GoRoute(
      path: '/auth/role',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/seller_registration',
      builder:
          (context, state) => const SellerRegistrationScreen(role: 'Seller'),
    ),
    GoRoute(
      path: '/landlord_registration',
      builder:
          (context, state) =>
              const LandlordRegistrationScreen(role: 'Landlord'),
    ),
    GoRoute(
      path: '/user_registration',
      builder: (context, state) => const UserRegistrationScreen(),
    ),

    //add property image
    GoRoute(
      path: '/add-property-images/:propertyId',
      builder: (context, state) {
        final propertyId = state.pathParameters['propertyId']!;
        return AddPropertyImagesScreen(propertyId: propertyId);
      },
    ),

    GoRoute(
      path: '/property_all_list',
      builder: (context, state) => const PropertyListScreen(),
    ),
    GoRoute(
      path: '/all_visitors',
      builder: (context, state) {
        final status = state.extra as String;
        return AllVisitorsScreen(status: status);
      },
    ),

    GoRoute(
      path: '/properties/property-details/:propertyId/edit-room/:roomId',
      builder: (context, state) {
        final propertyId = state.pathParameters['propertyId']!;
        final roomId = state.pathParameters['roomId']!;
        return EditRoomScreen(
          propertyId: propertyId,
          roomId: roomId,
        );
      },
    ),
    // Existing property routes
    GoRoute(
      path: '/properties',
      builder: (context, state) => const LandlordMainScreen(),
      routes: [
        GoRoute(
          path: 'add-property',
          builder: (context, state) => const AddPropertyScreen(),
        ),
        GoRoute(
          path: 'property-details/:propertyId',
          builder: (context, state) {
            final propertyId = state.pathParameters['propertyId']!;
            final propertyName = state.pathParameters['propertyId']!;
            return PropertyDetailsScreen(propertyId: propertyId, propertyName: propertyName);
          },
          routes: [
            GoRoute(
              path: '/add-room',
              builder: (context, state) {
                final propertyId = state.pathParameters['propertyId']!;
                return AddRoomScreen(propertyId: propertyId);
              },
            ),
            GoRoute(
              path: 'add-tenant',
              builder: (context, state) {
                final propertyId = state.pathParameters['propertyId']!;
                return AddTenantScreen(
                  propertyId: propertyId,
                  bedId: "",
                  roomId: "",
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const LandlordProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/User',
      builder: (context, state) => const UserMainScreen(),
      routes: [
        GoRoute(
          path: 'add-property',
          builder: (context, state) => const AddPropertyScreen(),
        ),

        GoRoute(
          path: 'profile',
          builder: (context, state) => const UserProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/seller',
      builder: (context, state) => const SellerMainScreen(),
      routes: [
        /*GoRoute(
          path: 'property-details/:propertyId',
          builder: (context, state) {
            final propertyId = state.pathParameters['propertyId']!;
            return SellerPropertyDetailsScreen(property: "",);
          },
        ),*/
        GoRoute(
          path: '/add-property',
          builder: (context, state) {
            return SellerAddPropertyScreen();
          },
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const SellerProfileScreen(),
        ),
      ],
    ),
  ],
);
