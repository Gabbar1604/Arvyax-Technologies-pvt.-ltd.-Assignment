import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yoga_session_app/Screens/onboarding_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color.fromARGB(255, 247, 247, 247),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const YogaApp());
}

class YogaApp extends StatelessWidget {
  const YogaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Modular Yoga Session',
      theme: ThemeData(
        primarySwatch: createMaterialColor(const Color(0xFF7C9885)),
        primaryColor: const Color(0xFF7C9885),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF7C9885),
          secondary: const Color(0xFFB8CDB8),
          surface: const Color(0xFFF5F7F5),
          onPrimary: Colors.white,
          onSecondary: const Color(0xFF2C3E2C),
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        ),
      ),
      home: const OnboardingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }

  MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
