import 'package:assistants_app/models/user_model.dart';
import 'package:assistants_app/viewmodels/admin_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminStudentDetailScreen extends StatefulWidget {
  final UserModel student;

  const AdminStudentDetailScreen({super.key, required this.student});

  @override
  State<AdminStudentDetailScreen> createState() =>
      _AdminStudentDetailScreenState();
}

class _AdminStudentDetailScreenState extends State<AdminStudentDetailScreen> {
  late UserModel _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  Future<void> _disableAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disable account?'),
        content: Text(
          'This will block ${_student.fullName.isNotEmpty ? _student.fullName : _student.email} from signing in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Disable account'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final adminVm = context.read<AdminViewModel>();
    final success = await adminVm.disableStudentAccount(_student.id);

    if (!mounted) return;

    if (success) {
      setState(() {
        _student = _student.copyWith(isDisabled: true);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account disabled.'),
          backgroundColor: Colors.green,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(adminVm.errorMessage ?? 'Failed to disable account.'),
        backgroundColor: Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adminVm = context.watch<AdminViewModel>();
    final initials = _student.fullName.isNotEmpty
        ? _student.fullName.trim().split(' ').map((e) => e[0]).take(2).join()
        : _student.email[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Student Detail'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A237E),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _student.fullName.isNotEmpty
                        ? _student.fullName
                        : 'Name not set',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _student.email,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Student Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoCard(
              children: [
                _buildRow(
                  'Full Name',
                  _student.fullName.isNotEmpty ? _student.fullName : 'Not set',
                ),
                _buildDivider(),
                _buildRow(
                  'Student Number',
                  _student.studentNumber?.isNotEmpty == true
                      ? _student.studentNumber!
                      : 'Not set',
                ),
                _buildDivider(),
                _buildRow('Email', _student.email),
                _buildDivider(),
                _buildRow(
                  'Year of Study',
                  _student.yearOfStudy?.isNotEmpty == true
                      ? _student.yearOfStudy!
                      : 'Not set',
                ),
                _buildDivider(),
                _buildRow(
                  'Phone',
                  _student.phone?.isNotEmpty == true
                      ? _student.phone!
                      : 'Not set',
                ),
                _buildDivider(),
                _buildRow(
                  'Account Status',
                  _student.isDisabled ? 'Disabled' : 'Active',
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _student.isDisabled || adminVm.isLoading
                    ? null
                    : _disableAccount,
                icon: adminVm.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.block),
                label: Text(
                  _student.isDisabled
                      ? 'Account disabled'
                      : 'Disable account',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade400,
                  disabledForegroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      );

  Widget _buildRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildDivider() => Divider(height: 16, color: Colors.grey.shade200);
}
