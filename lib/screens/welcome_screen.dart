import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // App Logo/Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D8A),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: const Icon(
                  Icons.medication,
                  size: 60,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // App Title
              Text(
                'PillTime',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                'Never miss your medication again',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.normal,
                      color: const Color(0xFF666666),
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              // Description
              Text(
                'Take control of your health with timely reminders and easy prescription management',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text('Get Started'),
                ),
              ),

              const SizedBox(height: 16),

              // Sign In Link
              TextButton(
                onPressed: () {
                  // TODO: Navigate to sign in screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Sign in feature coming soon!')),
                  );
                },
                child: const Text(
                  'Already have an account? Sign In',
                  style: TextStyle(
                    color: Color(0xFF2E7D8A),
                    fontSize: 16,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
