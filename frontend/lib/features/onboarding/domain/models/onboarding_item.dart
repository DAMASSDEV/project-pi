class OnboardingItem {
  final String title;
  final String subtitle;
  final String imagePath;
  final String buttonText;
  final bool showSkip;

  const OnboardingItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.buttonText,
    required this.showSkip,
  });
}
