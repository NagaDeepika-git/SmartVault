import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/router/route_names.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/widgets/responsive_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingItem> _slides = const [
    _OnboardingItem(
      icon: Icons.shield_outlined,
      accentColor: AppColors.champagne,
      title: 'Unified Records & Document Vault',
      description:
          'Keep your academic degrees, certificates, ID passports, and invoices organized in one private, intelligent vault.',
    ),
    _OnboardingItem(
      icon: Icons.hourglass_top_rounded,
      accentColor: AppColors.amber,
      title: 'Real-Time Warranty Tracking',
      description:
          'Never miss a warranty claim deadline. Automatically calculate remaining days, expiration dates, and upcoming alerts.',
    ),
    _OnboardingItem(
      icon: Icons.build_circle_outlined,
      accentColor: AppColors.info,
      title: 'Asset & Service History',
      description:
          'Track appliance repairs, battery replacements, and maintenance expenses connected directly to your products.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(RouteNames.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: const Text('Skip', style: TextStyle(color: AppColors.champagne, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContentContainer(
        maxWidth: 600,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: slide.accentColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: slide.accentColor.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: slide.accentColor.withValues(alpha: 0.15),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(slide.icon, size: 54, color: slide.accentColor),
                      ),
                      const SizedBox(height: 48),
                      Text(
                        slide.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        slide.description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  height: 6,
                  width: isActive ? 24 : 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.champagne
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    borderRadius: AppRadius.radiusFull,
                  ),
                );
              }),
            ),
            const SizedBox(height: 40),

            // Bottom Navigation Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (_currentPage < _slides.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    _completeOnboarding();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.champagne,
                  foregroundColor: const Color(0xFF1A1300),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
                ),
                child: Text(
                  _currentPage < _slides.length - 1 ? 'Continue' : 'Enter SmartVault',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;

  const _OnboardingItem({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
  });
}
