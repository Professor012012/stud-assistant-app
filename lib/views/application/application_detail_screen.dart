import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:assistants_app/models/application_model.dart';
import 'package:assistants_app/viewmodels/application_viewmodel.dart';
import 'package:assistants_app/viewmodels/auth_viewmodel.dart';
import 'package:assistants_app/views/application/edit_application_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final ApplicationModel application;

  const ApplicationDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final isPending = application.status == 'pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Application Details'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(application.status),
            const SizedBox(height: 20),
            _buildDetailsCard(),
            const SizedBox(height: 20),
            ...application.modules.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildModuleCard('Module ${entry.key + 1}', entry.value),
                  ),
                ),
            const SizedBox(height: 8),
            _buildEligibilityCard(),
            const SizedBox(height: 20),
            _buildDocumentsCard(context),
            const SizedBox(height: 28),
            if (isPending) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Application'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditApplicationScreen(application: application),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete Application'),
                  onPressed: () => _confirmDelete(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
            if (!isPending)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  'This application has been ${application.status}. It can no longer be edited or deleted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
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
    final message = status == 'approved'
        ? 'Your application has been approved.'
        : status == 'rejected'
            ? 'Your application was not successful.'
            : 'Your application is under review.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.toUpperCase(),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(message, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return _buildCard(
      title: 'Application Info',
      child: Column(
        children: [
          _buildRow('Year of Study', application.yearOfStudy),
          _buildDivider(),
          _buildRow(
            'Submitted',
            application.createdAt != null
                ? '${application.createdAt!.day}/${application.createdAt!.month}/${application.createdAt!.year}'
                : 'N/A',
          ),
          _buildDivider(),
          _buildRow('Status', application.status.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildModuleCard(String title, ApplicationModule module) {
    return _buildCard(
      title: title,
      child: Column(
        children: [
          _buildRow('Academic Level', module.academicLevel),
          _buildDivider(),
          _buildRow('Module', module.moduleName),
        ],
      ),
    );
  }

  Widget _buildEligibilityCard() {
    return _buildCard(
      title: 'Eligibility',
      child: _buildRow('Confirmed', application.confirmedEligibility ? 'Yes' : 'No'),
    );
  }

  Widget _buildDocumentsCard(BuildContext context) {
    return _buildCard(
      title: 'Supporting Documents',
      child: Column(
        children: [
          _buildDocumentTile(context, 'Academic Transcript', application.transcriptUrl),
          _buildDivider(),
          _buildDocumentTile(context, 'ID Document', application.idDocumentUrl),
          _buildDivider(),
          _buildDocumentTile(context, 'Proof of Registration', application.proofOfRegistrationUrl),
        ],
      ),
    );
  }

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
              child: Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
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
  }

  Widget _buildDivider() => Divider(height: 16, color: Colors.grey.shade200);

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open document.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Application'),
        content: const Text('Are you sure you want to delete your application? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    final appVm = context.read<ApplicationViewModel>();
    final auth = context.read<AuthViewModel>();
    final success = await appVm.deleteApplication(application.id!, auth.currentUser!.id);

    if (!context.mounted) return;

    if (success) {
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appVm.errorMessage ?? 'Delete failed.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }
}
