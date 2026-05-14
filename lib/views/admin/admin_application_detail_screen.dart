import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assistants_app/models/application_model.dart';
import 'package:assistants_app/models/user_model.dart';
import 'package:assistants_app/services/admin_service.dart';
import 'package:assistants_app/viewmodels/admin_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminApplicationDetailScreen extends StatefulWidget {
  final ApplicationModel application;

  const AdminApplicationDetailScreen({super.key, required this.application});

  @override
  State<AdminApplicationDetailScreen> createState() => _AdminApplicationDetailScreenState();
}

class _AdminApplicationDetailScreenState extends State<AdminApplicationDetailScreen> {
  UserModel? _student;
  List<ApplicationModel> _history = [];
  bool _loadingStudent = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final service = AdminService();
    final student = await service.getUser(widget.application.studentId);
    final history = await service.getApplicationsByStudent(widget.application.studentId);
    setState(() {
      _student = student;
      _history = history;
      _loadingStudent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.application;
    final adminVm = context.read<AdminViewModel>();
    final isPending = app.status == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Application Detail'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(app.status),
            const SizedBox(height: 20),
            _buildSectionHeader('Application Info'),
            const SizedBox(height: 10),
            _buildInfoCard(children: [
              _buildRow('Year of Study', app.yearOfStudy),
              _buildDivider(),
              ...app.modules.asMap().entries.expand(
                    (entry) => [
                      _buildRow('Module ${entry.key + 1}', entry.value.moduleName),
                      _buildRow('Level ${entry.key + 1}', entry.value.academicLevel),
                      if (entry.key != app.modules.length - 1) _buildDivider(),
                    ],
                  ),
              _buildDivider(),
              _buildRow('Eligibility Confirmed', app.confirmedEligibility ? 'Yes' : 'No'),
              _buildRow(
                'Submitted',
                app.createdAt != null ? '${app.createdAt!.day}/${app.createdAt!.month}/${app.createdAt!.year}' : 'N/A',
              ),
            ]),
            const SizedBox(height: 20),
            _buildSectionHeader('Supporting Documents'),
            const SizedBox(height: 10),
            _buildInfoCard(children: [
              _buildDocumentTile(context, 'Academic Transcript', app.transcriptUrl),
              _buildDivider(),
              _buildDocumentTile(context, 'ID Document', app.idDocumentUrl),
              _buildDivider(),
              _buildDocumentTile(context, 'Proof of Registration', app.proofOfRegistrationUrl),
            ]),
            const SizedBox(height: 20),
            _buildSectionHeader('Student Info'),
            const SizedBox(height: 10),
            _loadingStudent
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _student == null
                    ? _buildInfoCard(children: const [
                        Text('Student details not found.', style: TextStyle(color: Colors.grey)),
                      ])
                    : _buildInfoCard(children: [
                        _buildRow('Full Name', _student!.fullName.isNotEmpty ? _student!.fullName : 'Not set'),
                        _buildDivider(),
                        _buildRow('Student Number', _student!.studentNumber?.isNotEmpty == true ? _student!.studentNumber! : 'Not set'),
                        _buildDivider(),
                        _buildRow('Email', _student!.email),
                      ]),
            const SizedBox(height: 20),
            _buildSectionHeader('Application History'),
            const SizedBox(height: 10),
            _loadingStudent
                ? const SizedBox()
                : _history.isEmpty
                    ? _buildInfoCard(children: [
                        Text('No history found.', style: TextStyle(color: Colors.grey.shade500)),
                      ])
                    : Column(children: _history.map((item) => _buildHistoryCard(item)).toList()),
            const SizedBox(height: 24),
            if (isPending) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                      onPressed: () => _updateStatus(context, app.id!, 'approved', adminVm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      onPressed: () => _updateStatus(context, app.id!, 'rejected', adminVm),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove Application'),
                onPressed: () => _confirmDelete(context, app.id!, adminVm),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(String status) {
    final color = status == 'approved'
        ? Colors.green
        : status == 'rejected'
            ? Colors.red
            : Colors.orange;
    final icon = status == 'approved'
        ? Icons.check_circle_outline
        : status == 'rejected'
            ? Icons.cancel_outlined
            : Icons.hourglass_empty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 10),
          Text(
            status.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ApplicationModel app) {
    final statusColor = app.status == 'approved'
        ? Colors.green
        : app.status == 'rejected'
            ? Colors.red
            : Colors.orange;
    final isCurrent = app.id == widget.application.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0xFF1A237E).withOpacity(0.04) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? const Color(0xFF1A237E).withOpacity(0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.modules.isNotEmpty ? app.modules.first.moduleName : 'No modules',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  app.createdAt != null ? '${app.createdAt!.day}/${app.createdAt!.month}/${app.createdAt!.year}' : 'N/A',
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
              style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1A237E),
        ),
      );

  Widget _buildInfoCard({required List<Widget> children}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _buildRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            ),
            Expanded(
              child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      );

  Widget _buildDocumentTile(BuildContext context, String label, String? url) {
    final hasUrl = url != null && url.isNotEmpty;

    return InkWell(
      onTap: hasUrl ? () => _openUrl(context, url) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(
              hasUrl ? Icons.insert_drive_file_outlined : Icons.error_outline,
              color: hasUrl ? const Color(0xFF1A237E) : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            Text(
              hasUrl ? 'Open' : 'Missing',
              style: TextStyle(
                color: hasUrl ? const Color(0xFF1A237E) : Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => Divider(height: 16, color: Colors.grey.shade200);

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open document.'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    String applicationId,
    String status,
    AdminViewModel adminVm,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${status[0].toUpperCase()}${status.substring(1)} Application'),
        content: Text('Are you sure you want to $status this application?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              status[0].toUpperCase() + status.substring(1),
              style: TextStyle(color: status == 'approved' ? Colors.green : Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await adminVm.updateStatus(applicationId, status);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Application $status.' : adminVm.errorMessage ?? 'Action failed.'),
        backgroundColor: success ? Colors.green : Colors.red.shade700,
      ),
    );

    if (success) Navigator.pop(context);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String applicationId,
    AdminViewModel adminVm,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Application'),
        content: const Text('Are you sure you want to permanently remove this application?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final success = await adminVm.deleteApplication(applicationId);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Application removed.' : adminVm.errorMessage ?? 'Delete failed.'),
        backgroundColor: success ? Colors.green : Colors.red.shade700,
      ),
    );

    if (success) Navigator.pop(context);
  }
}
