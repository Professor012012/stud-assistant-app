import 'package:flutter/material.dart';
import '../models/application_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminViewModel extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<UserModel> _students = [];
  List<UserModel> get students => _filteredStudents();

  List<ApplicationModel> _applications = [];
  List<ApplicationModel> get applications => _filteredApplications();

  String _filterStatus = 'all';
  String get filterStatus => _filterStatus;

  String _studentSearchQuery = '';
  String get studentSearchQuery => _studentSearchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Stream<List<ApplicationModel>> get applicationsStream => Stream.fromFuture(_service.getAllApplications());
  Stream<List<UserModel>> get studentsStream => Stream.fromFuture(_service.getAllStudents());

  void setApplications(List<ApplicationModel> applications) {
    _applications = applications;
    notifyListeners();
  }

  void setStudents(List<UserModel> students) {
    _students = students;
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void setStudentSearch(String query) {
    _studentSearchQuery = query;
    notifyListeners();
  }

  List<ApplicationModel> _filteredApplications() {
    if (_filterStatus == 'all') return _applications;
    return _applications.where((a) => a.status == _filterStatus).toList();
  }

  List<UserModel> _filteredStudents() {
    if (_studentSearchQuery.trim().isEmpty) return _students;
    final query = _studentSearchQuery.trim().toLowerCase();
    return _students.where((student) {
      return (student.studentNumber ?? '').toLowerCase().contains(query) ||
          student.fullName.toLowerCase().contains(query) ||
          student.email.toLowerCase().contains(query);
    }).toList();
  }

  Future<List<ApplicationModel>> getStudentHistory(String studentId) async {
    return await _service.getApplicationsByStudent(studentId);
  }

  Future<bool> updateStatus(String applicationId, String status) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.updateApplicationStatus(applicationId, status);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update status.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> disableStudentAccount(String studentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.disableStudentAccount(studentId);
      _students = _students
          .map((student) => student.id == studentId
              ? student.copyWith(isDisabled: true)
              : student)
          .toList();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to disable account.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteApplication(String applicationId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.deleteApplication(applicationId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete application.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
