import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:go_router/go_router.dart';

class AppColors {
  static const Color primary = Color(0xFF5c4eff);
  static const Color secondary = Color(0xFF5c4eff);
  static const Color accent = Color(0xFF5c4eff);
  static const Color background = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
}

class PropertyOnboardingScreen extends StatefulWidget {
  const PropertyOnboardingScreen({super.key});

  @override
  State<PropertyOnboardingScreen> createState() =>
      _PropertyOnboardingScreenState();
}

class _PropertyOnboardingScreenState extends State<PropertyOnboardingScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _bubbleController;
  late AnimationController _slideController;
  int _currentPage = 0;

  final List<OnboardingData> _onboardingItems = [
    OnboardingData(
      title: "Smart Property\nManagement",
      subtitle:
      "Manage all your properties efficiently with our advanced digital platform",
      imagePath: "assets/onboard/1.jpg",
      primaryColor: AppColors.primary,
      icon: Icons.home_work,
    ),
    OnboardingData(
      title: "Real-time\nMonitoring",
      subtitle:
      "Track maintenance, rent collection, and tenant communications in real-time",
      imagePath: "assets/onboard/2.jpg",
      primaryColor: AppColors.secondary,
      icon: Icons.analytics,
    ),
    OnboardingData(
      title: "Seamless\nExperience",
      subtitle:
      "Enjoy a smooth, intuitive interface designed for property professionals",
      imagePath: "assets/onboard/3.jpg",
      primaryColor: AppColors.accent,
      icon: Icons.speed,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _bubbleController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Preload images and trigger initial animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (var item in _onboardingItems) {
        precacheImage(AssetImage(item.imagePath), context);
      }
      // Trigger the initial slide animation so the first page shows immediately
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bubbleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Animated Bubbles Background
          // _buildAnimatedBubbles(),

          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Skip Button
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _navigateToHome(),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingItems.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                      _slideController.forward(from: 0);
                    },
                    itemBuilder: (context, index) {
                      return _buildOnboardingPage(_onboardingItems[index]);
                    },
                  ),
                ),

                // Bottom Navigation
                _buildBottomNavigation(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBubbles() {
    return AnimatedBuilder(
      animation: _bubbleController,
      builder: (context, child) {
        return Stack(
          children: List.generate(15, (index) {
            final double animationValue =
                (_bubbleController.value + index * 0.1) % 1.0;
            final double size = 20 + (index % 3) * 15;
            final double opacity = 0.1 + (index % 4) * 0.05;
            final IconData icon = _getPropertyIcon(index);

            return Positioned(
              left: (index * 67) % MediaQuery.of(context).size.width - size,
              top: MediaQuery.of(context).size.height * animationValue - size,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(opacity),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: size * 0.5,
                  color: AppColors.primary.withOpacity(opacity * 2),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  IconData _getPropertyIcon(int index) {
    final icons = [
      Icons.home,
      Icons.apartment,
      Icons.business,
      Icons.villa,
      Icons.house,
      Icons.domain,
      Icons.roofing,
      Icons.foundation,
      Icons.garage,
      Icons.balcony,
      Icons.stairs,
      Icons.elevator,
      Icons.security,
      Icons.key,
      Icons.door_front_door,
    ];
    return icons[index % icons.length];
  }

  Widget _buildOnboardingPage(OnboardingData data) {
    return AnimatedBuilder(
      animation: _slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _slideController.value)),
          child: Opacity(
            opacity: _slideController.value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image Card
                  Container(
                    width: double.infinity,
                    height: 280,
                    margin: const EdgeInsets.only(bottom: 50),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Stack(
                        children: [
                          // Asset Image with error handling
                          SizedBox(
                            width: double.infinity,
                            height: double.infinity,
                            child: Image.asset(
                              data.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback in case image doesn't load
                                return Container(
                                  color: data.primaryColor.withOpacity(0.1),
                                  child: Icon(
                                    data.icon,
                                    size: 80,
                                    color: data.primaryColor,
                                  ),
                                );
                              },
                            ),
                          ),

                          // Icon Overlay
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                data.icon,
                                color: data.primaryColor,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Subtitle
                  Text(
                    data.subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingItems.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                width: _currentPage == index ? 30 : 10,
                height: 10,
                decoration: BoxDecoration(
                  color:
                  _currentPage == index
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Previous Button
              if (_currentPage > 0)
                GestureDetector(
                  onTap:
                      () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                  ),
                )
              else
                const SizedBox(width: 60),

              // Main Action Button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage == _onboardingItems.length - 1) {
                        _navigateToHome();
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.primary.withOpacity(0.4),
                    ),
                    child: Text(
                      _currentPage == _onboardingItems.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              // Next Button
              if (_currentPage < _onboardingItems.length - 1)
                GestureDetector(
                  onTap:
                      () => _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                )
              else
                const SizedBox(width: 60),
            ],
          ),
        ],
      ),
    );
  }

  void _navigateToHome() {
    context.go('/auth/role');
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color primaryColor;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.primaryColor,
    required this.icon,
  });
}

// Usage Example
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Property Management',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF2E86AB, <int, Color>{
          50: Color(0xFFE6F3F8),
          100: Color(0xFFC1E1ED),
          200: Color(0xFF98CEE1),
          300: Color(0xFF6EBAD5),
          400: Color(0xFF4FABCC),
          500: Color(0xFF2E86AB),
          600: Color(0xFF297EA4),
          700: Color(0xFF23739A),
          800: Color(0xFF1D6991),
          900: Color(0xFF125680),
        }),
        fontFamily: 'SF Pro Display',
      ),
      home: const PropertyOnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}