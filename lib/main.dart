import 'package:flutter/material.dart';
import 'package:pilltime/screens/home_screen.dart';
import 'package:pilltime/screens/signup_screens.dart';
import 'package:pilltime/screens/welcome_screen.dart';

void main() {
  runApp(PillTimeApp());
}

class PillTimeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillTime',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF2E7D8A),
        // accentColor: const Color(0xFF4CAF50),
        fontFamily: 'Roboto',

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // primary: Color(0xFF2E7D8A),
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFFDDDDDD)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Color(0xFF2E7D8A), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/signup': (context) => SignUpScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
