// lib/core/services/admin_auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hardcoded admin email
  static const String ADMIN_EMAIL = 'Admin12345@gmail.com';

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if current user is admin
  Future<bool> isAdmin() async {
    final user = currentUser;
    if (user == null) return false;

    // Check if email matches admin email
    return user.email?.toLowerCase() == ADMIN_EMAIL.toLowerCase();
  }

  // Admin login - WEB COMPATIBLE
  Future<Map<String, dynamic>> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      // Validate email is admin email
      if (email.toLowerCase() != ADMIN_EMAIL.toLowerCase()) {
        return {
          'success': false,
          'message': 'Access denied. Admin credentials required.',
        };
      }

      // Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Double check admin email
      if (userCredential.user?.email?.toLowerCase() != ADMIN_EMAIL.toLowerCase()) {
        await _auth.signOut();
        return {
          'success': false,
          'message': 'Access denied. Admin credentials required.',
        };
      }

      // Update last login timestamp (optional)
      try {
        await _updateLastLogin(userCredential.user!.uid);
      } catch (e) {
        print('Warning: Could not update last login: $e');
        // Don't fail login if this fails
      }

      return {
        'success': true,
        'message': 'Login successful',
        'user': userCredential.user,
      };

    } catch (e) {
      // Handle all errors uniformly for web compatibility
      String message = 'Login failed';

      // Try to extract error code from the error
      final errorString = e.toString().toLowerCase();

      if (errorString.contains('user-not-found') || errorString.contains('user not found')) {
        message = 'Admin account not found';
      } else if (errorString.contains('wrong-password') || errorString.contains('wrong password')) {
        message = 'Incorrect password';
      } else if (errorString.contains('invalid-email') || errorString.contains('invalid email')) {
        message = 'Invalid email format';
      } else if (errorString.contains('user-disabled') || errorString.contains('disabled')) {
        message = 'Admin account has been disabled';
      } else if (errorString.contains('too-many-requests') || errorString.contains('too many')) {
        message = 'Too many login attempts. Please try again later';
      } else if (errorString.contains('network')) {
        message = 'Network error. Please check your internet connection';
      } else if (errorString.contains('invalid-credential')) {
        message = 'Invalid credentials. Please check your email and password';
      } else {
        message = 'Login failed. Please check your credentials';
      }

      print('Login error: $e');

      return {
        'success': false,
        'message': message,
      };
    }
  }

  // Admin logout
  Future<void> adminLogout() async {
    await _auth.signOut();
  }

  // Update last login timestamp
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _firestore.collection('admin_metadata').doc('admin_user').set({
        'last_login': FieldValue.serverTimestamp(),
        'user_id': userId,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // Get admin user stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Verify admin on app start
  Future<bool> verifyAdminAccess() async {
    final user = currentUser;
    if (user == null) return false;

    // Check email
    if (user.email?.toLowerCase() != ADMIN_EMAIL.toLowerCase()) {
      await _auth.signOut();
      return false;
    }

    return true;
  }

  // Send password reset email - WEB COMPATIBLE
  Future<Map<String, dynamic>> sendPasswordResetEmail(String email) async {
    try {
      if (email.toLowerCase() != ADMIN_EMAIL.toLowerCase()) {
        return {
          'success': false,
          'message': 'Access denied. Admin email required.',
        };
      }

      await _auth.sendPasswordResetEmail(email: email);

      return {
        'success': true,
        'message': 'Password reset email sent. Please check your inbox.',
      };
    } catch (e) {
      print('Password reset error: $e');
      return {
        'success': false,
        'message': 'Failed to send reset email. Please try again.',
      };
    }
  }

  // Change admin password - WEB COMPATIBLE
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No user logged in',
        };
      }

      // Verify current password by re-authenticating
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);

      return {
        'success': true,
        'message': 'Password updated successfully',
      };
    } catch (e) {
      print('Change password error: $e');

      final errorString = e.toString().toLowerCase();
      String message;

      if (errorString.contains('wrong-password') || errorString.contains('wrong password')) {
        message = 'Current password is incorrect';
      } else if (errorString.contains('weak-password') || errorString.contains('weak')) {
        message = 'New password is too weak';
      } else if (errorString.contains('requires-recent-login') || errorString.contains('recent login')) {
        message = 'Please log out and log in again to change password';
      } else {
        message = 'Failed to change password. Please try again.';
      }

      return {
        'success': false,
        'message': message,
      };
    }
  }
}