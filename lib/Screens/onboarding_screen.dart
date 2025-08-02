import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoga_session_app/Screens/signup_helper_screen.dart';
import 'package:yoga_session_app/Screens/home_Screen.dart';
import 'package:yoga_session_app/Screens/login_helper_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController(
    initialPage: 1,
  ); // Start with home page (middle)
  int _currentPage = 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  // Dot widget for indicator
  Widget _buildDot(int index) {
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: _currentPage == index ? Colors.black87 : Colors.grey[400],
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color.fromARGB(255, 247, 247, 247),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 247, 247, 247),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  SignupHelperScreenContent(), // Left page (index 0)
                  HomeScreenContent(), // Center page (index 1)
                  LoginHelperScreenContent(), // Right page (index 2)
                ],
              ),
            ),
            // Page indicator dots
            Container(
              color: const Color.fromARGB(255, 247, 247, 247),
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDot(0), // Signup dot
                  _buildDot(1), // Home dot
                  _buildDot(2), // Login dot
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
