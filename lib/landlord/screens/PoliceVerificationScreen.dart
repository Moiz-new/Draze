import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/appColors.dart';

import 'AssignRegionTab.dart';
import 'AssignedTenantsListTab.dart';
import 'AssignedTenantsTab.dart';

class PoliceVerificationScreen extends StatefulWidget {
  const PoliceVerificationScreen({Key? key}) : super(key: key);

  @override
  State<PoliceVerificationScreen> createState() =>
      _PoliceVerificationScreenState();
}

class _PoliceVerificationScreenState extends State<PoliceVerificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Text(
          'Tenant Police Verification',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.6),
          labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.assignment_turned_in), text: 'Assign Region'),
            Tab(icon: Icon(Icons.people), text: 'Assigned Tenants'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AssignRegionTab(),
          //AssignedTenantsTab(),
          AssignedTenantsListTab(),
        ],
      ),
    );
  }
}
