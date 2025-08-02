import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class LoginHelperScreen extends StatefulWidget {
  const LoginHelperScreen({super.key});

  @override
  State<LoginHelperScreen> createState() => _LoginHelperScreenState();
}

class _LoginHelperScreenState extends State<LoginHelperScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const LoginHelperScreenContent());
  }
}

class LoginHelperScreenContent extends StatelessWidget {
  const LoginHelperScreenContent({super.key});

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
            const SizedBox(height: 55),
            Expanded(
              child: Lottie.asset(
                'assets/Animation/Deep Breathing Meditation Animation.json',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const Text(
                      "Welcome Back to\n Yoga Journey",
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
                      "Login to continue your\n personalized yoga journey\n and access all your\n saved sessions.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[700],
                        fontFamily: 'Roboto',
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 45),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) =>
                            //         const LoginPage(),
                            //   ),
                            // );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            backgroundColor: Colors.black87,
                          ),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // Space from bottom
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
