import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _client = Supabase.instance.client;

  static const _rememberMeKey = 'remember_me';
  static const _savedEmailKey = 'saved_email';

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  UserModel? _userModel;
  UserModel? get userModel => _userModel;
  UserModel? get user => _userModel;
  bool get isAdmin => _userModel?.isAdmin ?? false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _rememberMe = false;
  bool get rememberMe => _rememberMe;

  String _savedEmail = '';
  String get savedEmail => _savedEmail;

  AuthViewModel() {
    _loadRememberMe();
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    _rememberMe = prefs.getBool(_rememberMeKey) ?? false;
    _savedEmail = prefs.getString(_savedEmailKey) ?? '';
    notifyListeners();
  }

  void setRememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUserModel(String uid) async {
    final profile = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    if (profile != null) {
      _userModel = UserModel.fromMap(profile);
    } else if (currentUser != null) {
      _userModel = UserModel(
        id: currentUser!.id,
        email: currentUser!.email ?? '',
        role: 'student',
      );
    }
    notifyListeners();
  }

  void updateLocalUserModel(UserModel updated) {
    _userModel = updated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      _userModel = await _authService.login(email.trim(), password.trim());
      final prefs = await SharedPreferences.getInstance();
      if (_rememberMe) {
        await prefs.setBool(_rememberMeKey, true);
        await prefs.setString(_savedEmailKey, email.trim());
      } else {
        await prefs.setBool(_rememberMeKey, false);
        await prefs.remove(_savedEmailKey);
      }
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setLoading(false);
      _setError(_friendlyError(e.message));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      _userModel = await _authService.register(email.trim(), password.trim());
      _setLoading(false);
      return true;
    } on AuthException catch (e) {
      _setLoading(false);
      _setError(_friendlyError(e.message));
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Something went wrong. Please try again.');
      return false;
    }
  }

  Future<void> logout() async {
    if (!_rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_savedEmailKey);
      _savedEmail = '';
    }
    await _authService.logout();
    _userModel = null;
    notifyListeners();
  }

  String _friendlyError(String message) {
    final value = message.toLowerCase();
    if (value.contains('invalid login credentials')) {
      return 'Incorrect email or password. Please try again.';
    }
    if (value.contains('already registered') || value.contains('already exists')) {
      return 'This email is already registered.';
    }
    if (value.contains('password')) {
      return 'Password must be at least 6 characters.';
    }
    if (value.contains('email')) {
      return 'Please enter a valid email address.';
    }
    if (value.contains('rate')) {
      return 'Too many attempts. Please try again later.';
    }
    return message;
  }
}
