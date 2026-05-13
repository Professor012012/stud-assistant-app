import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/profile_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileService _service = ProfileService();
  final _client = Supabase.instance.client;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  Future<bool> updateProfile(String uid, String fullName, String studentNumber) async {
    _setLoading(true);
    try {
      final parts = fullName.trim().split(RegExp(r'\s+'));
      await _service.updateProfile(
        firstName: fullName.trim().isEmpty ? '' : parts.first,
        lastName: parts.length > 1 ? parts.skip(1).join(' ') : '',
        studentNumber: studentNumber,
        yearOfStudy: '',
        phone: '',
      );
      _successMessage = 'Profile updated successfully.';
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update profile.';
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updatePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    try {
      final user = _client.auth.currentUser!;
      await _client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      _successMessage = 'Password updated successfully.';
      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update password.';
      _setLoading(false);
      return false;
    }
  }
}
