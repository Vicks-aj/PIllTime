import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Simulate user registration
  Future<bool> signUp(UserModel user, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));

      // In a real app, you would make an API call to your backend
      // For now, we'll simulate a successful registration

      // Generate a mock user ID
      final userWithId = user.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user data locally
      await _saveUserData(userWithId);
      await _setLoggedInStatus(true);

      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  // Simulate user sign in
  Future<bool> signIn(String email, String password) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // In a real app, you would validate credentials with your backend
      // For now, we'll simulate a successful sign in

      return true;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Check login status error: $e');
      return false;
    }
  }

  // Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson);
        return UserModel.fromJson(userMap);
      }

      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }

  // Update user profile
  Future<bool> updateProfile(UserModel user) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update user data locally
      final updatedUser = user.copyWith(updatedAt: DateTime.now());
      await _saveUserData(updatedUser);

      return true;
    } catch (e) {
      print('Update profile error: $e');
      return false;
    }
  }

  // Private helper methods
  Future<void> _saveUserData(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }

  Future<void> _setLoggedInStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, status);
  }

  // Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate password strength
  bool isValidPassword(String password) {
    // At least 8 characters
    if (password.length < 8) return false;

    // Contains at least one letter and one number
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasLetter && hasNumber;
  }
}
