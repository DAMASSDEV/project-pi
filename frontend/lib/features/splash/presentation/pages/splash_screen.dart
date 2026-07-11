import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../onboarding/presentation/pages/onboarding_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../personalization/presentation/pages/personalization_page.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;

  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _logoSlide;
  late Animation<double> _leafRotation;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _taglineFade;
  late Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);


    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _logoSlide = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _leafRotation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.05, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.65, 0.9, curve: Curves.easeOut),
      ),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _entryController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 800), () async {
          if (mounted) {
            final prefs = await SharedPreferences.getInstance();
            final email = prefs.getString('logged_in_email');
            final goal = prefs.getString('user_goal');
            Widget nextPage = const OnboardingPage();
            if (email != null) {
              final hasCompleted = prefs.getBool('has_completed_personalization') ?? false;
              if (hasCompleted) {
                nextPage = DashboardPage(goal: goal);
              } else {
                nextPage = PersonalizationPage(email: email);
              }
            }
            if (mounted) {
              Navigator.of(context).pushReplacement(
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => nextPage,
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            }
          }
        });
      }
    });

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFAFEFC),
              Colors.white,
              Color(0xFFF5FBF8),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildOrb(
              top: -screenSize.width * 0.3,
              right: -screenSize.width * 0.2,
              size: screenSize.width * 0.7,
              opacity: 0.035,
            ),
            _buildOrb(
              bottom: -screenSize.width * 0.35,
              left: -screenSize.width * 0.25,
              size: screenSize.width * 0.85,
              opacity: 0.025,
            ),
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 4),
                    _buildLogo(),
                    const SizedBox(height: 28),
                    _buildTitle(),
                    const Spacer(flex: 5),
                    _buildFooter(),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required double opacity,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppTheme.primaryColor.withOpacity(opacity),
              AppTheme.primaryColor.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _pulseController]),
      builder: (context, child) {
        return SlideTransition(
          position: _logoSlide,
          child: FadeTransition(
            opacity: _logoFade,
            child: Transform.scale(
              scale: _logoScale.value * _pulseScale.value,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.06),
                      AppTheme.primaryColor.withOpacity(0.0),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
                padding: const EdgeInsets.all(12),
                child: Transform.rotate(
                  angle: _leafRotation.value,
                  child: Image.asset(
                    'assets/hero-bot.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle() {
    return SlideTransition(
      position: _titleSlide,
      child: FadeTransition(
        opacity: _titleFade,
        child: const Text(
          'Nutrify',
          style: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w900,
            color: AppTheme.primaryColor,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _taglineFade,
      child: const Text(
        'Smarter Nutrition for a Better You',
        style: TextStyle(
          fontSize: 13,
          color: Color(0xFFADB5BD),
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
