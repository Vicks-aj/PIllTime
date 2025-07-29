import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pilltime/screens/splash_screen.dart';
import 'package:pilltime/screens/onboarding_screen.dart';
import 'package:pilltime/screens/home_screen.dart';
import 'package:pilltime/screens/signup_screens.dart';
import 'package:pilltime/screens/login_screen.dart';
import 'package:pilltime/screens/welcome_screen.dart';
import 'package:pilltime/screens/add_medication_screen.dart';
import 'package:pilltime/screens/medications_screen.dart';
import 'package:pilltime/screens/medication_detail_screen.dart';
import 'package:pilltime/screens/forgot_password_screen.dart';
import 'package:pilltime/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service (will handle web vs mobile automatically)
  try {
    await NotificationService().initialize();
  } catch (e) {
    print('Error initializing notifications: $e');
  }

  runApp(PillTimeApp());
}

class PillTimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillTime',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF1E3A8A),
        fontFamily: 'Roboto',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFF1E3A8A),
            side: BorderSide(color: Color(0xFF1E3A8A)),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF1E3A8A),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF1E3A8A), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
        '/add-medication': (context) => AddMedicationScreen(),
        '/medications': (context) => MedicationsScreen(),
        '/medication-detail': (context) => MedicationDetailScreen(),
        '/forgot-password': (context) => ForgotPasswordScreen(),
      },
    );
  }
}
