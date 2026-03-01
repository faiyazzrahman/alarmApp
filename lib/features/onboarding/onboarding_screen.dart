import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onboarding_project/common_widgets/video_player.dart';
import 'package:onboarding_project/constants/app_colors.dart';
import 'package:onboarding_project/constants/gradient_wrapper.dart';
import 'package:onboarding_project/core/router/app_router.dart';
import 'package:onboarding_project/core/di/injection_container.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../constants/app_style.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;
  static const String _kOnboardingKey = 'onboarding_completed';
  bool _isLoading = true;
  bool _shouldNavigate = false;

  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    try {
      final prefs = sl<SharedPreferences>();
      final onboardingCompleted = prefs.getBool(_kOnboardingKey) ?? false;

      if (onboardingCompleted && mounted) {
        setState(() {
          _shouldNavigate = true;
        });
      }
    } catch (e) {
      debugPrint('Error checking onboarding status: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shouldNavigate && !_isLoading) {
      _shouldNavigate = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && context.mounted) {
          context.go(AppRoutes.location);
        }
      });
    }
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = sl<SharedPreferences>();
      await prefs.setBool(_kOnboardingKey, true);
    } catch (e) {
      debugPrint('Error saving onboarding status: $e');
    }
  }

  void nextPage() {
    if (currentIndex < onboardingPages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
      context.go(AppRoutes.location);
    }
  }

  void skip() {
    _completeOnboarding();
    context.go(AppRoutes.location);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return GradientScaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryAccent),
        ),
      );
    }

    return GradientScaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemCount: onboardingPages.length,
              itemBuilder: (context, index) {
                final page = onboardingPages[index];

                return Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: screenHeight * 0.53625,
                            child: OnboardingVideo(videoPath: page.mediaPath),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            page.title,
                            style: AppStyles.headlineLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            page.description,
                            style: AppStyles.bodyLarge,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: SmoothPageIndicator(
                              controller: _controller,
                              count: onboardingPages.length,
                              effect: const SlideEffect(
                                dotHeight: 8,
                                dotWidth: 8,
                                activeDotColor: Colors.blue,
                                dotColor: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 70,
                      right: 16,
                      child: TextButton(
                        onPressed: skip,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.buttonText,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          minimumSize: const Size(0, 20),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: Text("Skip", style: AppStyles.buttonText),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: AppStyles.primaryButtonStyle,
                onPressed: nextPage,
                child: Text("Next", style: AppStyles.buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
