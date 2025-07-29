import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';
  static const String _passwordResetKey = 'password_reset_tokens';

  Future<bool> signUp(UserModel user, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);

      // Check if user already exists
      final existingUser = usersList.firstWhere(
        (u) => u['email'] == user.email,
        orElse: () => null,
      );

      if (existingUser != null) {
        return false; // User already exists
      }

      // Add new user
      final userData = user.toJson();
      userData['password'] = password; // In a real app, hash this!
      usersList.add(userData);

      // Save users
      await prefs.setString(_usersKey, jsonEncode(usersList));

      // Set as current user
      await prefs.setString(_currentUserKey, jsonEncode(userData));

      return true;
    } catch (e) {
      print('Error signing up: $e');
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);

      // Find user
      final userData = usersList.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => null,
      );

      if (userData != null) {
        // Set as current user
        await prefs.setString(_currentUserKey, jsonEncode(userData));
        return true;
      }

      return false;
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing users
      final usersJson = prefs.getString(_usersKey) ?? '[]';
      final List<dynamic> usersList = jsonDecode(usersJson);

      // Check if user exists
      final userExists = usersList.any((u) => u['email'] == email);

      if (userExists) {
        // Generate a reset token (in a real app, this would be sent via email)
        final resetToken = DateTime.now().millisecondsSinceEpoch.toString();

        // Store reset token
        final resetTokensJson = prefs.getString(_passwordResetKey) ?? '{}';
        final Map<String, dynamic> resetTokens = jsonDecode(resetTokensJson);
        resetTokens[email] = {
          'token': resetToken,
          'expires': DateTime.now().add(Duration(hours: 1)).toIso8601String(),
        };

        await prefs.setString(_passwordResetKey, jsonEncode(resetTokens));

        // In a real app, you would send an email here
        print('Password reset token for $email: $resetToken');

        return true;
      }

      return false; // User not found
    } catch (e) {
      print('Error sending password reset email: $e');
      return false;
    }
  }

  Future<bool> resetPassword(
      String email, String token, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Check reset token
      final resetTokensJson = prefs.getString(_passwordResetKey) ?? '{}';
      final Map<String, dynamic> resetTokens = jsonDecode(resetTokensJson);

      if (resetTokens.containsKey(email)) {
        final tokenData = resetTokens[email];
        final tokenExpires = DateTime.parse(tokenData['expires']);

        if (tokenData['token'] == token &&
            DateTime.now().isBefore(tokenExpires)) {
          // Token is valid, update password
          final usersJson = prefs.getString(_usersKey) ?? '[]';
          final List<dynamic> usersList = jsonDecode(usersJson);

          // Find and update user
          for (int i = 0; i < usersList.length; i++) {
            if (usersList[i]['email'] == email) {
              usersList[i]['password'] = newPassword;
              break;
            }
          }

          // Save updated users
          await prefs.setString(_usersKey, jsonEncode(usersList));

          // Remove used token
          resetTokens.remove(email);
          await prefs.setString(_passwordResetKey, jsonEncode(resetTokens));

          return true;
        }
      }

      return false; // Invalid or expired token
    } catch (e) {
      print('Error resetting password: $e');
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      return true;
    } catch (e) {
      print('Error signing out: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_currentUserKey);
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);

      if (userJson != null) {
        final userData = jsonDecode(userJson);
        return UserModel.fromJson(userData);
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }
}
