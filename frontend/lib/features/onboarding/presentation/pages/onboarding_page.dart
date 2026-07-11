import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/onboarding_item.dart';
import '../widgets/onboarding_background_orb.dart';
import '../widgets/onboarding_content_card.dart';
import '../widgets/onboarding_indicator.dart';
import '../../../auth/presentation/pages/sign_in_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _orbController;
  late Animation<double> _orbPulse;

  final List<OnboardingItem> _items = const [
    OnboardingItem(
      title: 'Pindai Makanan Anda',
      subtitle: 'Cukup arahkan kamera ke makanan Anda untuk mendapatkan rincian nutrisi instan secara otomatis.',
      imagePath: 'assets/image3.png',
      buttonText: 'Lanjut',
      showSkip: true,
    ),
    OnboardingItem(
      title: 'Analisis Nutrisi Akurat',
      subtitle: 'Pahami apa yang masuk ke tubuh Anda dengan data makro dan mikro nutrisi yang mendalam.',
      imagePath: 'assets/image2.png',
      buttonText: 'Lanjut',
      showSkip: true,
    ),
    OnboardingItem(
      title: 'Rekomendasi Pintar',
      subtitle: 'Dapatkan saran makanan yang dipersonalisasi sesuai dengan target kesehatan dan preferensi diet Anda.',
      imagePath: 'assets/image1.png',
      buttonText: 'Mulai Sekarang',
      showSkip: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _orbPulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _orbController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _onNextPressed() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SignInPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final double bottomSheetHeight = screenSize.height * 0.39;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F6F1),
              Color(0xFFF5FBF9),
              Colors.white,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: AnimatedBuilder(
          animation: _orbPulse,
          builder: (context, child) {
            return Stack(
              children: [
                 OnboardingBackgroundOrb(
                   top: -screenSize.width * 0.2,
                   right: -screenSize.width * 0.1,
                   size: screenSize.width * 0.6,
                   opacity: 0.05,
                   scale: _orbPulse.value,
                 ),
                 OnboardingBackgroundOrb(
                   bottom: -screenSize.width * 0.3,
                   left: -screenSize.width * 0.2,
                   size: screenSize.width * 0.8,
                   opacity: 0.03,
                   scale: _orbPulse.value,
                 ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: bottomSheetHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(36),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.04),
                          blurRadius: 32,
                          offset: const Offset(0, -12),
                        ),
                      ],
                    ),
                  ),
                ),
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    return OnboardingContentCard(
                      item: _items[index],
                      screenSize: screenSize,
                      currentPage: _currentPage,
                    );
                  },
                ),
                SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(),
                      const Spacer(),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 32,
                  left: 24,
                  right: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OnboardingIndicator(
                        itemCount: _items.length,
                        currentPage: _currentPage,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _onNextPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.9, end: 1.0)
                                      .animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Row(
                              key: ValueKey<int>(_currentPage),
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _items[_currentPage].buttonText,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                if (_currentPage < _items.length - 1) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final showSkip = _items[_currentPage].showSkip;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerRight,
      child: AnimatedOpacity(
        opacity: showSkip ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: showSkip
            ? TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                child: const Text('Lewati'),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
