import 'package:draze/app/app_router.dart';
import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/landlord/providers/MySubscriptionProvider.dart';
import 'package:draze/landlord/providers/OverviewPropertyProvider.dart';
import 'package:draze/landlord/providers/VisitorsDashboardProvider.dart';
import 'package:draze/presentations/providers/OTPVerificationProvider.dart';
import 'package:draze/presentations/providers/PhoneAuthProvider.dart';
import 'package:draze/presentations/providers/SellerRegistrationProvider.dart';
import 'package:draze/presentations/providers/UserRegistrationProvider.dart';
import 'package:draze/seller/providers/EditSellerProfileProvider.dart';
import 'package:draze/seller/providers/MySubscriptionProvider.dart';
import 'package:draze/seller/providers/SellerAddPropertyProvider.dart';
import 'package:draze/seller/providers/SellerAddReelProvider.dart';
import 'package:draze/seller/providers/SellerAllVisitorsProvider.dart';
import 'package:draze/seller/providers/SellerProfileProvider.dart';
import 'package:draze/seller/providers/SellerPropertyProvider.dart';
import 'package:draze/seller/providers/SellerReelsProvider.dart';
import 'package:draze/seller/providers/SellerSubscriptionProvider.dart';
import 'package:draze/seller/providers/SellerVisitorsDashboardProvider.dart';
import 'package:draze/seller/screens/profile_screen.dart';
import 'package:draze/user/provider/EnquiriesProvider.dart';
import 'package:draze/user/provider/MyVisitsProvider.dart';
import 'package:draze/user/provider/PropertyDetailsProvider.dart';
import 'package:draze/user/provider/RentPropertyProvider.dart';
import 'package:draze/user/provider/SellerListProvider.dart';
import 'package:draze/user/provider/UserProfileProvider.dart';
import 'package:draze/user/provider/UserReelsProvider.dart';
import 'package:draze/user/provider/reel_provider.dart';
import 'package:draze/user/screens/UserReelsScreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    hide ChangeNotifierProvider;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'landlord/providers/AddExpensesProvider.dart';
import 'landlord/providers/AddRoomImagesProvider.dart';
import 'landlord/providers/AddSubOwnerProvider.dart';
import 'landlord/providers/AllPropertyListProvider.dart';
import 'landlord/providers/AllTenantDuesListProvider.dart';
import 'landlord/providers/AllTenantListProvider.dart';
import 'landlord/providers/AllVisitorsProvider.dart';
import 'landlord/providers/AnnouncementProvider.dart';
import 'landlord/providers/BedProvider.dart';
import 'landlord/providers/CollectionForecastProvider.dart';
import 'landlord/providers/DueAssignmentProvider.dart';
import 'landlord/providers/DuesProvider.dart';
import 'landlord/providers/AddTenantProvider.dart';
import 'landlord/providers/ExpensesAnalyticsProvider.dart';
import 'landlord/providers/ExpensesListProvider.dart';
import 'landlord/providers/LandlordProfileEditProvider.dart';
import 'landlord/providers/LandlordReelsProvider.dart';
import 'landlord/providers/SubscriptionProvider.dart';
import 'landlord/providers/TenantDocumentProvider.dart';
import 'landlord/providers/TenantDuesAgainstPropertyProvider.dart';
import 'landlord/providers/VerificationProvider.dart';
import 'landlord/providers/landlord_registration_provider.dart';
import 'landlord/providers/reel_provider.dart';
import 'landlord/providers/room_provider.dart';
import 'landlord/providers/tenant_provider.dart';
import 'landlord/screens/LandlordProfileEditScreen.dart';
import 'landlord/screens/property details/ExpenseAgainstPropertyScreen.dart';
import 'landlord/screens/property details/PropertyReviewScreen.dart';
import 'landlord/screens/property details/ComplaintAgainstPropertyScreen.dart';
import 'landlord/screens/property_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LandlordRegistrationProvider()),
          ChangeNotifierProvider(create: (_) => PhoneAuthProvider()),
          ChangeNotifierProvider(create: (_) => OTPVerificationProvider()),
          ChangeNotifierProvider(create: (_) => AllPropertyListProvider()),
          ChangeNotifierProvider(create: (_) => VisitorsDashboardProvider()),
          ChangeNotifierProvider(create: (_) => AllVisitorsProvider()),
          ChangeNotifierProvider(create: (_) => UserRegistrationProvider()),
          ChangeNotifierProvider(create: (_) => UserProfileProvider()),
          ChangeNotifierProvider(create: (_) => RentPropertyProvider()),
          ChangeNotifierProvider(create: (_) => PropertyDetailsProvider()),
          ChangeNotifierProvider(create: (_) => VisitsProvider()),
          ChangeNotifierProvider(create: (_) => SellerListProvider()),
          ChangeNotifierProvider(create: (_) => ReelsProvider()),
          ChangeNotifierProvider(create: (_) => VideoControllersProvider()),
          ChangeNotifierProvider(create: (_) => UserReelsProvider()),
          ChangeNotifierProvider(create: (_) => RoomProvider()),
          ChangeNotifierProvider(create: (_) => AddRoomImageProvider()),
          ChangeNotifierProvider(create: (_) => BedProvider()),
          ChangeNotifierProvider(create: (_) => DuesProvider()),
          ChangeNotifierProvider(create: (_) => AddTenantProvider()),
          ChangeNotifierProvider(create: (_) => DueAssignmentProvider()),
          ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
          ChangeNotifierProvider(create: (_) => AllTenantDuesListProvider()),
          ChangeNotifierProvider(create: (_) => AddExpensesProvider()),
          ChangeNotifierProvider(create: (_) => ExpensesAnalyticsProvider()),
          ChangeNotifierProvider(create: (_) => ExpensesListProvider()),
          ChangeNotifierProvider(create: (_) => CollectionForecastProvider()),
          ChangeNotifierProvider(create: (_) => ReelProvider()),
          ChangeNotifierProvider(create: (_) => LandlordReelsProvider()),
          ChangeNotifierProvider(
            create: (_) => TenantDuesAgainstPropertyProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ComplaintAgainstPropertyProvider(),
          ),
          ChangeNotifierProvider(
            create: (_) => ExpenseAgainstPropertyProvider(),
          ),
          ChangeNotifierProvider(create: (_) => PropertyReviewProvider()),
          ChangeNotifierProvider(create: (_) => AllTenantListProvider()),
          ChangeNotifierProvider(create: (_) => SubOwnerProvider()),
          ChangeNotifierProvider(create: (_) => SellerRegistrationProvider()),
          ChangeNotifierProvider(create: (_) => SellerProfileProvider()),
          ChangeNotifierProvider(create: (_) => SellerAddPropertyProvider()),
          ChangeNotifierProvider(create: (_) => SellerPropertyProvider()),
          ChangeNotifierProvider(create: (_) => LandlordProfileEditProvider()),
          ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
          ChangeNotifierProvider(create: (_) => MySubscriptionProvider()),
          ChangeNotifierProvider(create: (_) => EditSellerProfileProvider()),
          ChangeNotifierProvider(create: (_) => SellerAllVisitorsProvider()),
          ChangeNotifierProvider(create: (_) => VerificationProvider()),
          ChangeNotifierProvider(create: (_) => EnquiriesProvider()),
          ChangeNotifierProvider(create: (_) => SellerMySubscriptionProvider()),
          ChangeNotifierProvider(
            create: (_) => SellerVisitorsDashboardProvider(),
          ),
          ChangeNotifierProvider(create: (_) => SellerSubscriptionProvider()),
          ChangeNotifierProvider(create: (_) => SellerReelProvider()),
          ChangeNotifierProvider(create: (_) => SellerReelsProvider()),
          ChangeNotifierProvider(create: (_) => TenantDocumentProvider()),
          ChangeNotifierProvider(
            create: (_) => TenantProvider(TenantService()),
          ),
          ChangeNotifierProvider(
            create: (_) => OverviewPropertyProvider(OverviewPropertyService()),
          ),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Draze',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              surface: AppColors.surface,
            ),
            useMaterial3: true,
            fontFamily: 'Poppins',
            scaffoldBackgroundColor: AppColors.background,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: AppColors.textPrimary,
                fontSize: AppSizes.titleText(context),
                fontWeight: FontWeight.w600,
                fontFamily: 'Poppins',
              ),
              iconTheme: const IconThemeData(color: AppColors.textPrimary),
            ),
          ),
          routerConfig: router,
        );
      },
    );
  }
}
