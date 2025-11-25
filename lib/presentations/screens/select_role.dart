import 'package:draze/core/constants/appColors.dart';
import 'package:draze/core/constants/appSizes.dart';
import 'package:draze/presentations/widgets/background_bubble.dart';
import 'package:draze/user/provider/reel_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() =>
      _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selectedRole;
  bool _isLoading = false;

  final List<RoleOption> _roles = [
    RoleOption(
      id: 'seller',
      title: 'Seller',
      description: 'Sell your properties and connect with buyers',
      icon: Icons.business,
    ),
    RoleOption(
      id: 'landlord',
      title: 'Landlord',
      description: 'Rent out your property and manage tenants',
      icon: Icons.home,
    ),
    RoleOption(
      id: 'tenant',
      title: 'User',
      description: 'Find and rent properties that suit your needs',
      icon: Icons.person,
    ),
  ];

  void _continueWithRole() async {
    if (_selectedRole == null || !mounted) return;

    setState(() => _isLoading = true);



    try {

      print('All providers reset for role: $_selectedRole');
    } catch (e) {
      print('Error resetting providers: $e');
    }

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() => _isLoading = false);

      switch (_selectedRole) {
        case 'seller':
          context.push('/auth/phone',extra: _selectedRole);
          break;
        case 'landlord':
          context.push('/auth/phone',extra: _selectedRole);
          break;
        case 'tenant':
          context.push('/auth/phone',extra: _selectedRole);
          break;
        default:
          context.push('/auth/phone',extra: _selectedRole);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          BackgroundBubbles(),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.mediumPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSizes.largePadding(context) + 20),
                  Text(
                    'Choose Your Role',
                    style: TextStyle(
                      fontSize: AppSizes.titleText(context) - 8,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: AppSizes.smallPadding(context)),
                  Text(
                    'Select your role to personalize your experience',
                    style: TextStyle(
                      fontSize: AppSizes.smallText(context),
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: AppSizes.largePadding(context) * 2),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _roles.length,
                      itemBuilder: (context, index) {
                        final role = _roles[index];
                        final isSelected = _selectedRole == role.id;

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: AppSizes.mediumPadding(context),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedRole = role.id;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(
                                AppSizes.mediumPadding(context),
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.primary.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : Colors.grey[300]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : Colors.grey[400],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      role.icon,
                                      color: Colors.white,
                                      size: AppSizes.mediumIcon(context),
                                    ),
                                  ),
                                  SizedBox(
                                    width: AppSizes.mediumPadding(context),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          role.title,
                                          style: TextStyle(
                                            fontSize:
                                                AppSizes.smallText(context) + 1,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(
                                          height:
                                              AppSizes.smallPadding(context) /
                                              2,
                                        ),
                                        Text(
                                          role.description,
                                          style: TextStyle(
                                            fontSize: AppSizes.smallText(
                                              context,
                                            ),
                                            color: AppColors.textSecondary,
                                            height: 1.4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? AppColors.primary
                                                : Colors.grey[400]!,
                                        width: 2,
                                      ),
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : Colors.transparent,
                                    ),
                                    child:
                                        isSelected
                                            ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 14,
                                            )
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight(context),
                    child: ElevatedButton(
                      onPressed:
                          _selectedRole != null && !_isLoading
                              ? _continueWithRole
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey[200],
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: AppSizes.mediumText(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                  SizedBox(height: AppSizes.mediumPadding(context)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoleOption {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  RoleOption({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
