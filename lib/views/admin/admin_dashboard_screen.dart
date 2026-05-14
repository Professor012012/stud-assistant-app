import 'package:assistants_app/models/application_model.dart';
import 'package:assistants_app/viewmodels/admin_viewmodel.dart';
import 'package:assistants_app/viewmodels/auth_viewmodel.dart';
import 'package:assistants_app/views/admin/admin_application_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assistants_app/widgets/skeleton_loader.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final adminVm = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Dashboard'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: adminVm.applicationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const DashboardSkeleton();
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading data.'));
          }

          final apps = snapshot.data ?? [];
          adminVm.setApplications(apps);

          final pending =
              apps.where((a) => a.status == 'pending').length;
          final approved =
              apps.where((a) => a.status == 'approved').length;
          final rejected =
              apps.where((a) => a.status == 'rejected').length;
          final recent = apps.take(5).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${auth.userModel?.fullName.isNotEmpty == true ? auth.userModel!.fullName : 'Admin'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Here\'s an overview of all applications.',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    _buildStatCard(
                        'Total', apps.length, Colors.blueGrey, Icons.list_alt),
                    _buildStatCard(
                        'Pending', pending, Colors.orange, Icons.hourglass_empty),
                    _buildStatCard(
                        'Approved', approved, Colors.green, Icons.check_circle_outline),
                    _buildStatCard(
                        'Rejected', rejected, Colors.red, Icons.cancel_outlined),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Recent Applications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A237E),
                  ),
                ),
                const SizedBox(height: 12),

                if (recent.isEmpty)
                  _buildEmptyState()
                else
                  ...recent.map((app) =>
                      _buildRecentCard(context, app)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(label,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentCard(
      BuildContext context, ApplicationModel app) {
    final statusColor = app.status == 'approved'
        ? Colors.green
        : app.status == 'rejected'
            ? Colors.red
            : Colors.orange;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminApplicationDetailScreen(application: app),
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
                    app.module1.moduleName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    app.yearOfStudy,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
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
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.inbox_outlined,
              size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text('No applications yet.',
              style: TextStyle(
                  fontSize: 15, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}