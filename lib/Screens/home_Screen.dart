import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:yoga_session_app/Screens/SessionPreviewScreen.dart';
import 'package:yoga_session_app/Screens/session_library_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: HomeScreenContent());
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  bool _isNavigating = false;

  void _navigateToSessionLibrary() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SessionLibraryScreen()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  void _navigateToSessionPreview() async {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
    });

    try {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SessionPreviewScreen()),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        color: const Color.fromARGB(255, 247, 247, 247),
        child: Column(
          children: [
            SizedBox(height: 14),
            Expanded(
              child: Lottie.asset(
                'assets/Animation/Girl yoga.json',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: const Color(0xFFF5F9F5),
                    child: const Center(
                      child: Icon(
                        Icons.self_improvement,
                        size: 100,
                        color: Color(0xFF7C9885),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Enjoy your Yoga\nanytime.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      "Access your Personalized yoga\ncourses anytime,\nanywhere.\n\nStart your yoga journey with us.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontFamily: 'Roboto',
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: _isNavigating
                              ? null
                              : _navigateToSessionLibrary,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor: _isNavigating
                                ? Colors.grey
                                : Colors.black87,
                          ),
                          child: _isNavigating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "Session Library",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
