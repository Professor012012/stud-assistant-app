import 'package:file_picker/file_picker.dart';
import 'package:assistants_app/data/modules_data.dart';
import 'package:assistants_app/models/application_model.dart';
import 'package:assistants_app/viewmodels/application_viewmodel.dart';
import 'package:assistants_app/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ApplicationFormScreen extends StatefulWidget {
  const ApplicationFormScreen({super.key});

  @override
  State<ApplicationFormScreen> createState() => _ApplicationFormScreenState();
}

class _ApplicationFormScreenState extends State<ApplicationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedYear;
  String? _selectedModule1Level;
  String? _selectedModule1;
  bool _addSecondModule = false;
  String? _selectedModule2Level;
  String? _selectedModule2;
  bool _eligibilityConfirmed = false;

  // Using bytes + filename instead of File (dart:io File doesn't work on web)
  Uint8List? _transcriptBytes;
  String? _transcriptName;
  Uint8List? _idDocumentBytes;
  String? _idDocumentName;
  Uint8List? _proofBytes;
  String? _proofName;

  void _onYearChanged(String? value) {
    setState(() {
      _selectedYear = value;
      _selectedModule1Level = value;
      _selectedModule1 = null;
      _selectedModule2Level = value;
      _selectedModule2 = null;
    });
  }

  void _onSecondModuleToggled(bool value) {
    setState(() {
      _addSecondModule = value;
      if (!value) {
        _selectedModule2Level = null;
        _selectedModule2 = null;
      }
    });
  }

  Future<void> _pickFile(
    Function(Uint8List bytes, String name) onPicked,
  ) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true, // required on web to get bytes
    );
    if (result != null && result.files.single.bytes != null) {
      onPicked(
        result.files.single.bytes!,
        result.files.single.name,
      );
      setState(() {});
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_eligibilityConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must confirm your eligibility before submitting.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_transcriptBytes == null ||
        _idDocumentBytes == null ||
        _proofBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all three required documents.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final auth = context.read<AuthViewModel>();
    final appVm = context.read<ApplicationViewModel>();

    final modules = <ApplicationModule>[
      ApplicationModule(
        academicLevel: _selectedModule1Level!,
        semester: '',
        moduleCode: _selectedModule1!.split(' ').first,
        moduleName: _selectedModule1!,
      ),
      if (_addSecondModule && _selectedModule2 != null)
        ApplicationModule(
          academicLevel: _selectedModule2Level!,
          semester: '',
          moduleCode: _selectedModule2!.split(' ').first,
          moduleName: _selectedModule2!,
        ),
    ];

    final application = ApplicationModel(
      studentId: auth.currentUser!.id,
      yearOfStudy: _selectedYear!,
      modules: modules,
      confirmedEligibility: _eligibilityConfirmed,
      createdAt: DateTime.now(),
    );

    final success = await appVm.submitApplication(
      application: application,
      transcriptBytes: _transcriptBytes!,
      transcriptName: _transcriptName!,
      idDocumentBytes: _idDocumentBytes!,
      idDocumentName: _idDocumentName!,
      proofBytes: _proofBytes!,
      proofName: _proofName!,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appVm.errorMessage ?? 'Submission failed.'),
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
        title: const Text('SA Application Form'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader('Personal Information'),
              const SizedBox(height: 12),
              _buildCard(
                child: _buildDropdown(
                  label: 'Year of Study',
                  value: _selectedYear,
                  items: ModulesData.years,
                  onChanged: _onYearChanged,
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
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Switch(
                      value: _addSecondModule,
                      onChanged: _selectedYear != null
                          ? _onSecondModuleToggled
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
                      fileName: _transcriptName,
                      onTap: () => _pickFile((bytes, name) {
                        _transcriptBytes = bytes;
                        _transcriptName = name;
                      }),
                    ),
                    const SizedBox(height: 12),
                    _buildFileTile(
                      label: 'ID Document',
                      fileName: _idDocumentName,
                      onTap: () => _pickFile((bytes, name) {
                        _idDocumentBytes = bytes;
                        _idDocumentName = name;
                      }),
                    ),
                    const SizedBox(height: 12),
                    _buildFileTile(
                      label: 'Proof of Registration',
                      fileName: _proofName,
                      onTap: () => _pickFile((bytes, name) {
                        _proofBytes = bytes;
                        _proofName = name;
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _buildSectionHeader('Eligibility'),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimum requirements for Student Assistants:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRequirementItem(
                        'Passed the module you are applying to assist with'),
                    _buildRequirementItem(
                        'Currently enrolled at CUT, Free State'),
                    _buildRequirementItem('In good academic standing'),
                    const SizedBox(height: 12),
                    Row(
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
                  ],
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: appVm.isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: appVm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Submit Application',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A237E),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // No more dart:io File — just uses fileName string for display
  Widget _buildFileTile({
    required String label,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    final hasFile = fileName != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: hasFile
              ? Colors.green.withOpacity(0.08)
              : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: hasFile ? Colors.green : Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              hasFile
                  ? Icons.check_circle_outline
                  : Icons.upload_file_outlined,
              color: hasFile ? Colors.green : const Color(0xFF1A237E),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? fileName : 'PDF, JPG, or PNG',
                    style:
                        TextStyle(fontSize: 12, color: Colors.grey.shade600),
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
  }) {
    return DropdownButtonFormField<String>(
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
}