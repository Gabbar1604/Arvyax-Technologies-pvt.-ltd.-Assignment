import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

class SignupHelperScreen extends StatefulWidget {
  const SignupHelperScreen({super.key});

  @override
  State<SignupHelperScreen> createState() => _SignupHelperScreenState();
}

class _SignupHelperScreenState extends State<SignupHelperScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: const SignupHelperScreenContent());
  }
}

class SignupHelperScreenContent extends StatelessWidget {
  const SignupHelperScreenContent({super.key});

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
                'assets/Animation/Yoga.json',
                width: MediaQuery.of(context).size.width * 0.8,
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
                      "Sign Up for\n Yoga Journey",
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
                      "Create your account and\n access personalized yoga\n courses anytime,\n anywhere.",
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
                            //         const SignupPage(),
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
                            "Sign Up",
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
