import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Future<UserModel> register(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    final user = response.user!;
    await _client.from('profiles').insert({
      'id': user.id,
      'email': email,
      'role': 'student',
    });

    return UserModel(id: user.id, email: email, role: 'student');
  }

  Future<UserModel> login(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user!;
    final profile = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (profile == null) {
      return UserModel(id: user.id, email: email, role: 'student');
    }

    return UserModel.fromMap(profile);
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}
