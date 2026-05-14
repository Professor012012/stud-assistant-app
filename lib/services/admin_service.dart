import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/application_model.dart';
import '../models/user_model.dart';

class AdminService {
  final _client = Supabase.instance.client;

  Future<Map<String, int>> getDashboardStats() async {
    final apps = await getAllApplications();
    return {
      'total': apps.length,
      'pending': apps.where((a) => a.status == 'pending').length,
      'approved': apps.where((a) => a.status == 'approved').length,
      'rejected': apps.where((a) => a.status == 'rejected').length,
    };
  }

  Future<List<UserModel>> getAllStudents() async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('role', 'student')
        .order('first_name');

    return (data as List)
        .map((item) => UserModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<UserModel?> getUser(String studentId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', studentId)
        .maybeSingle();

    return data == null ? null : UserModel.fromMap(data);
  }

  Future<List<ApplicationModel>> getAllApplications() async {
    final data = await _client
        .from('applications')
        .select('*, profiles(*), application_modules(*)')
        .order('created_at', ascending: false);

    return (data as List)
        .map((item) => ApplicationModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<ApplicationModel>> getApplicationsByStudent(String studentId) async {
    final data = await _client
        .from('applications')
        .select('*, profiles(*), application_modules(*)')
        .eq('student_id', studentId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((item) => ApplicationModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<void> updateApplicationStatus(String applicationId, String status) async {
    await _client.from('applications').update({'status': status}).eq('id', applicationId);
  }

  Future<void> deleteApplication(String applicationId) async {
    await _client.from('applications').delete().eq('id', applicationId);
  }
}
