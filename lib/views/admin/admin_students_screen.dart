import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assistants_app/models/user_model.dart';
import 'package:assistants_app/viewmodels/admin_viewmodel.dart';
import 'package:assistants_app/views/admin/admin_student_detail_screen.dart';
import 'package:assistants_app/widgets/skeleton_loader.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() =>
      _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminVm = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Students'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: adminVm.studentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const StudentsListSkeleton();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading students.'));
          }

          final students = snapshot.data ?? [];
          adminVm.setStudents(students);
          final filtered = adminVm.students;

          return Column(
            children: [
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  onChanged: adminVm.setStudentSearch,
                  decoration: InputDecoration(
                    hintText:
                        'Search by name, student number or email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              adminVm.setStudentSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          BorderSide(color: Colors.grey.shade300),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${filtered.length} student${filtered.length != 1 ? 's' : ''} found',
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                ),
              ),

              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildStudentCard(
                                context, filtered[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, UserModel student) {
    final initials = student.fullName.isNotEmpty
        ? student.fullName
            .trim()
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join()
        : student.email[0].toUpperCase();

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminStudentDetailScreen(student: student),
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
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF1A237E),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName.isNotEmpty
                        ? student.fullName
                        : 'Name not set',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.studentNumber?.isNotEmpty == true
                        ? student.studentNumber!
                        : 'No student number',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    student.email,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'No students found.',
              style: TextStyle(
                  fontSize: 15, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
}
