import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _backgroundController;
  late AnimationController _pulseController;
  late AnimationController _fadeController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String isLoggedIn = ""; // Initialize with default value
  String role = ""; // Initialize with default value

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    _initializeAnimations();
    _startAnimationsAndNavigation(); // Combined method
  }

  Future<void> getLoginSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        isLoggedIn = prefs.getString('auth_token') ?? "";
        role = prefs.getString('user_role') ?? "";
      });
    } catch (e) {
      // Handle error gracefully
      debugPrint('Error getting login session: $e');
      setState(() {
        isLoggedIn = "";
      });
    }
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Background animation controller
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Logo scale animation with bounce effect
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Logo rotation animation
    _logoRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
      ),
    );

    // Logo opacity animation
    _logoOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Background gradient animation
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );

    // Pulse animation for glow effect
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Slide animation for logo entrance
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutCubic),
    );

    // Fade animation for smooth transitions
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
  }

  void _startAnimationsAndNavigation() async {
    // Start getting login session immediately
    final loginFuture = getLoginSession();

    // Start animations
    _backgroundController.forward();

    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _pulseController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 500));
    _fadeController.forward();

    await loginFuture;

    await Future.delayed(const Duration(milliseconds: 2500));

    print(role);
    if (mounted) {
      if (isLoggedIn.isNotEmpty) {
        if (role == "user") {
          context.go('/User');
        } else if (role == "landlord") {
          context.go('/properties');
        } else if (role == "seller") {
          context.go('/seller');
        }
      } else {
        context.go('/onboard');
      }
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _backgroundController.dispose();
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _logoController,
          _backgroundController,
          _pulseController,
          _fadeController,
        ]),
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50.withOpacity(
                    0.3 * _backgroundAnimation.value,
                  ),
                  Colors.grey.shade100.withOpacity(
                    0.2 * _backgroundAnimation.value,
                  ),
                  Colors.white,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated background circles
                ...List.generate(6, (index) => _buildBackgroundCircle(index)),

                // Main logo content
                Center(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo container with animations
                          _buildAnimatedLogo(),

                          const SizedBox(height: 40),

                          // Loading indicator
                          _buildLoadingIndicator(),

                          // Uncomment if you want app name
                          // const SizedBox(height: 20),
                          // _buildAppName(),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom brand text or version
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: _buildBottomText(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Transform.scale(
      scale: _logoScaleAnimation.value * _pulseAnimation.value,
      child: Transform.rotate(
        angle: _logoRotationAnimation.value * 0.1,
        child: FadeTransition(
          opacity: _logoOpacityAnimation,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300.withOpacity(
                    0.5 * _logoOpacityAnimation.value,
                  ),
                  blurRadius: 20 * _pulseAnimation.value,
                  spreadRadius: 5 * _pulseAnimation.value,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Image(
                    image: AssetImage('assets/images/draze_logo.png'),
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => Icon(
                          Icons.image_not_supported,
                          size: 80,
                          color: Colors.grey,
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: 40,
        height: 4,
        child: LinearProgressIndicator(
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildAppName() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'Your App Name',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crafted with Excellence',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomText() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Text(
        'Version 1.0.0',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade400,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildBackgroundCircle(int index) {
    final sizes = [150.0, 200.0, 120.0, 180.0, 100.0, 220.0];
    final positions = [
      const Alignment(-1.2, -1.0),
      const Alignment(1.2, -0.8),
      const Alignment(-1.0, 1.2),
      const Alignment(1.0, 1.0),
      const Alignment(0.0, -1.5),
      const Alignment(0.0, 1.5),
    ];

    return Positioned.fill(
      child: Align(
        alignment: positions[index],
        child: Transform.scale(
          scale: _backgroundAnimation.value,
          child: Container(
            width: sizes[index],
            height: sizes[index],
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.grey.shade100.withOpacity(
                    0.1 * _backgroundAnimation.value,
                  ),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
