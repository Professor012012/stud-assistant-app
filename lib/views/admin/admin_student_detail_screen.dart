import 'package:flutter/material.dart';
import 'package:assistants_app/models/application_model.dart';
import 'package:assistants_app/models/user_model.dart';
import 'package:assistants_app/views/admin/admin_application_detail_screen.dart';
import 'package:assistants_app/widgets/skeleton_loader.dart';

class AdminStudentDetailScreen extends StatefulWidget {
  final UserModel student;

  const AdminStudentDetailScreen({super.key, required this.student});

  @override
  State<AdminStudentDetailScreen> createState() =>
      _AdminStudentDetailScreenState();
}

class _AdminStudentDetailScreenState extends State<AdminStudentDetailScreen> {
  List<ApplicationModel> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final initials = student.fullName.isNotEmpty
        ? student.fullName.trim().split(' ').map((e) => e[0]).take(2).join()
        : student.email[0].toUpperCase();

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    student.fullName.isNotEmpty
                        ? student.fullName
                        : 'Name not set',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.email,
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
                  student.fullName.isNotEmpty ? student.fullName : 'Not set',
                ),
                _buildDivider(),
                _buildRow(
                  'Student Number',
                  student.studentNumber?.isNotEmpty == true
                      ? student.studentNumber!
                      : 'Not set',
                ),
                _buildDivider(),
                _buildRow('Email', student.email),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Application History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                if (!_loading)
                  Text(
                    '${_history.length} record${_history.length != 1 ? 's' : ''}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            if (_loading)
              const DetailScreenSkeleton()
            else if (_history.isEmpty)
              _buildInfoCard(
                children: [
                  Text(
                    'No applications found.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              )
            else
              ..._history
                  .map((app) => _buildHistoryCard(context, app))
                  .toList(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ApplicationModel app) {
    final statusColor = app.status == 'approved'
        ? Colors.green
        : app.status == 'rejected'
        ? Colors.red
        : Colors.orange;

    // Safe: won't crash if modules list is empty
    final moduleName = app.modules.isNotEmpty
        ? app.modules.first.moduleName
        : 'No module';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminApplicationDetailScreen(application: app),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moduleName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.createdAt != null
                        ? '${app.yearOfStudy}  -  ${app.createdAt!.day}/${app.createdAt!.month}/${app.createdAt!.year}'
                        : '${app.yearOfStudy}  -  N/A',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                app.status.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  Widget _buildDivider() => Divider(height: 16, color: Colors.grey.shade200);
}
