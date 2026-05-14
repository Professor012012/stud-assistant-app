import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assistants_app/models/application_model.dart';
import 'package:assistants_app/viewmodels/admin_viewmodel.dart';
import 'package:assistants_app/views/admin/admin_application_detail_screen.dart';
import 'package:assistants_app/widgets/skeleton_loader.dart';

class AdminApplicationsScreen extends StatelessWidget {
  const AdminApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVm = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Applications'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<List<ApplicationModel>>(
        stream: adminVm.applicationsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ApplicationsListSkeleton();
          }
          if (snapshot.hasError) {
            return const Center(
                child: Text('Error loading applications.'));
          }

          final apps = snapshot.data ?? [];
          adminVm.setApplications(apps);
          final filtered = adminVm.applications;

          return Column(
            children: [
              _buildFilterBar(context, adminVm),

              Expanded(
                child: filtered.isEmpty
                    ? _buildEmptyState(adminVm.filterStatus)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _buildApplicationCard(
                                context, filtered[index], adminVm),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar(
      BuildContext context, AdminViewModel adminVm) {
    final filters = ['all', 'pending', 'approved', 'rejected'];
    return Container(
      color: Colors.white,
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: filters.map((filter) {
          final isSelected = adminVm.filterStatus == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                  filter[0].toUpperCase() + filter.substring(1)),
              selected: isSelected,
              onSelected: (_) => adminVm.setFilter(filter),
              selectedColor:
                  const Color(0xFF1A237E).withOpacity(0.15),
              checkmarkColor: const Color(0xFF1A237E),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF1A237E)
                    : Colors.grey.shade700,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildApplicationCard(BuildContext context,
      ApplicationModel app, AdminViewModel adminVm) {
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    app.status.toUpperCase(),
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12),
                  ),
                  Text(
                    app.createdAt != null
                        ? '${app.createdAt!.day}/${app.createdAt!.month}/${app.createdAt!.year}'
                        : 'N/A',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRow('Year', app.yearOfStudy),
                        _buildRow(
                            'Module 1', app.module1.moduleName),
                        if (app.module2 != null)
                          _buildRow(
                              'Module 2', app.module2!.moduleName),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined,
              size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            filter == 'all'
                ? 'No applications yet.'
                : 'No $filter applications.',
            style: TextStyle(
                fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
