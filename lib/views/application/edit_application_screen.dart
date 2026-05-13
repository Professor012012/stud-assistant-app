import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:assistants_app/data/modules_data.dart';
import 'package:assistants_app/models/application_model.dart';
import 'package:assistants_app/viewmodels/application_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditApplicationScreen extends StatefulWidget {
  final ApplicationModel application;

  const EditApplicationScreen({super.key, required this.application});

  @override
  State<EditApplicationScreen> createState() => _EditApplicationScreenState();
}

class _EditApplicationScreenState extends State<EditApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  late String? _selectedYear;
  late String? _selectedModule1Level;
  late String? _selectedModule1;
  late bool _addSecondModule;
  late String? _selectedModule2Level;
  late String? _selectedModule2;
  late bool _eligibilityConfirmed;
  File? _transcript;
  File? _idDocument;
  File? _proofOfRegistration;

  @override
  void initState() {
    super.initState();
    final app = widget.application;
    _selectedYear = app.yearOfStudy;
    _selectedModule1Level = app.module1.academicLevel;
    _selectedModule1 = app.module1.moduleName;
    _addSecondModule = app.module2 != null;
    _selectedModule2Level = app.module2?.academicLevel;
    _selectedModule2 = app.module2?.moduleName;
    _eligibilityConfirmed = app.eligibilityConfirmed;
  }

  Future<void> _pickFile(Function(File) onPicked) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      onPicked(File(result.files.single.path!));
      setState(() {});
    }
  }

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_eligibilityConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must confirm your eligibility.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final appVm = context.read<ApplicationViewModel>();

    final modules = <ApplicationModule>[
      ApplicationModule(
        academicLevel: _selectedModule1Level!,
        moduleCode: _selectedModule1!.split(' ').first,
        moduleName: _selectedModule1!,
      ),
      if (_addSecondModule && _selectedModule2 != null)
        ApplicationModule(
          academicLevel: _selectedModule2Level!,
          moduleCode: _selectedModule2!.split(' ').first,
          moduleName: _selectedModule2!,
        ),
    ];

    final application = ApplicationModel(
      studentId: widget.application.studentId,
      yearOfStudy: _selectedYear!,
      modules: modules,
      confirmedEligibility: _eligibilityConfirmed,
    );

    final success = await appVm.updateApplication(
      applicationId: widget.application.id!,
      application: application,
      // transcript: _transcript,
      // idDocument: _idDocument,
      // proofOfRegistration: _proofOfRegistration,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appVm.errorMessage ?? 'Update failed.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appVm = context.watch<ApplicationViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('Edit Application'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Year of Study'),
              const SizedBox(height: 12),
              _buildCard(
                child: _buildDropdown(
                  label: 'Year of Study',
                  value: _selectedYear,
                  items: ModulesData.years,
                  onChanged: (value) => setState(() {
                    _selectedYear = value;
                    _selectedModule1Level = value;
                    _selectedModule1 = null;
                    _selectedModule2Level = value;
                    _selectedModule2 = null;
                  }),
                  validator: (value) =>
                      value == null ? 'Please select your year of study' : null,
                ),
              ),
              const SizedBox(height: 20),

              _buildSectionHeader('Module 1'),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildDropdown(
                      label: 'Academic Level',
                      value: _selectedModule1Level,
                      items: _selectedYear != null ? [_selectedYear!] : [],
                      onChanged: (value) =>
                          setState(() => _selectedModule1Level = value),
                      validator: (value) =>
                          value == null ? 'Academic level is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown(
                      label: 'Module',
                      value: _selectedModule1,
                      items: _selectedYear != null
                          ? ModulesData.modulesForYear(_selectedYear!)
                          : [],
                      onChanged: (value) =>
                          setState(() => _selectedModule1 = value),
                      validator: (value) =>
                          value == null ? 'Please select a module' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _buildCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Apply for a second module?',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Switch(
                      value: _addSecondModule,
                      onChanged: _selectedYear != null
                          ? (value) => setState(() {
                                _addSecondModule = value;
                                if (!value) {
                                  _selectedModule2Level = null;
                                  _selectedModule2 = null;
                                }
                              })
                          : null,
                      activeColor: const Color(0xFF1A237E),
                    ),
                  ],
                ),
              ),

              if (_addSecondModule) ...[
                const SizedBox(height: 20),
                _buildSectionHeader('Module 2'),
                const SizedBox(height: 12),
                _buildCard(
                  child: Column(
                    children: [
                      _buildDropdown(
                        label: 'Academic Level',
                        value: _selectedModule2Level,
                        items: _selectedYear != null ? [_selectedYear!] : [],
                        onChanged: (value) =>
                            setState(() => _selectedModule2Level = value),
                        validator: (value) =>
                            _addSecondModule && value == null
                                ? 'Academic level is required'
                                : null,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Module',
                        value: _selectedModule2,
                        items: _selectedYear != null
                            ? ModulesData.modulesForYear(_selectedYear!)
                                .where((m) => m != _selectedModule1)
                                .toList()
                            : [],
                        onChanged: (value) =>
                            setState(() => _selectedModule2 = value),
                        validator: (value) =>
                            _addSecondModule && value == null
                                ? 'Please select a module'
                                : null,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              _buildSectionHeader('Supporting Documents'),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  children: [
                    _buildFileTile(
                      label: 'Academic Transcript',
                      file: _transcript,
                      existingUrl: widget.application.transcriptUrl,
                      onTap: () => _pickFile((file) => _transcript = file),
                    ),
                    const SizedBox(height: 12),
                    _buildFileTile(
                      label: 'ID Document',
                      file: _idDocument,
                      existingUrl: widget.application.idDocumentUrl,
                      onTap: () => _pickFile((file) => _idDocument = file),
                    ),
                    const SizedBox(height: 12),
                    _buildFileTile(
                      label: 'Proof of Registration',
                      file: _proofOfRegistration,
                      existingUrl: widget.application.proofOfRegistrationUrl,
                      onTap: () => _pickFile((file) => _proofOfRegistration = file),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Eligibility'),
              const SizedBox(height: 12),
              _buildCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _eligibilityConfirmed,
                      activeColor: const Color(0xFF1A237E),
                      onChanged: (value) => setState(
                          () => _eligibilityConfirmed = value ?? false),
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'I confirm that I meet the minimum requirements for this position.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: appVm.isLoading ? null : _handleUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: appVm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Changes',
                          style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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

  Widget _buildCard({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: child,
      );

  Widget _buildFileTile({
    required String label,
    required File? file,
    required VoidCallback onTap,
    String? existingUrl,
  }) {
    final hasFile = file != null;
    final hasExisting = existingUrl != null && existingUrl.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasFile ? Colors.green.withOpacity(0.08) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hasFile ? Colors.green : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              hasFile ? Icons.check_circle_outline : Icons.upload_file_outlined,
              color: hasFile ? Colors.green : const Color(0xFF1A237E),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile
                        ? file.path.split(Platform.pathSeparator).last
                        : hasExisting
                            ? 'Already uploaded - tap to replace'
                            : 'PDF, JPG, or PNG',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) =>
      DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
        ),
        items: items
            .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: items.isEmpty ? null : onChanged,
        validator: validator,
      );
}
