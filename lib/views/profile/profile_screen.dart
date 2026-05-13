import 'package:assistants_app/viewmodels/auth_viewmodel.dart';
import 'package:assistants_app/viewmodels/profile_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _studentNumberController;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthViewModel>().userModel;
    _fullNameController =
        TextEditingController(text: user?.fullName ?? '');
    _studentNumberController =
        TextEditingController(text: user?.studentNumber ?? '');
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _studentNumberController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleProfileUpdate() async {
    if (!_profileFormKey.currentState!.validate()) return;

    final auth = context.read<AuthViewModel>();
    final profileVm = context.read<ProfileViewModel>();

    final success = await profileVm.updateProfile(
      auth.currentUser!.id,
      _fullNameController.text.trim(),
      _studentNumberController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      final updated = auth.userModel!.copyWith(
        fullName: _fullNameController.text.trim(),
        studentNumber: _studentNumberController.text.trim(),
      );
      auth.updateLocalUserModel(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(profileVm.errorMessage ?? 'Update failed.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Future<void> _handlePasswordUpdate() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final profileVm = context.read<ProfileViewModel>();

    final success = await profileVm.updatePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(profileVm.errorMessage ?? 'Password update failed.'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final profileVm = context.watch<ProfileViewModel>();
    final user = auth.userModel;
    final isAdmin = auth.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(user?.fullName ?? '', user?.email ?? '',
                isAdmin),
            const SizedBox(height: 24),
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 12),
            _buildCard(
              child: Form(
                key: _profileFormKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: user?.email ?? '',
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon:
                            const Icon(Icons.email_outlined),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Full name is required'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    if (!isAdmin)
                      TextFormField(
                        controller: _studentNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Student Number',
                          prefixIcon:
                              Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Student number is required'
                                : null,
                      ),
                    if (isAdmin) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFF1A237E)
                                  .withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.admin_panel_settings,
                                color: Color(0xFF1A237E),
                                size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Administrator Account',
                              style: TextStyle(
                                color: Color(0xFF1A237E),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: profileVm.isLoading
                            ? null
                            : _handleProfileUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                        child: profileVm.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionHeader('Change Password'),
            const SizedBox(height: 12),

            _buildCard(
              child: Form(
                key: _passwordFormKey,
                child: Column(
                  children: [
                    _buildPasswordField(
                      controller: _currentPasswordController,
                      label: 'Current Password',
                      obscure: _obscureCurrent,
                      onToggle: () => setState(
                          () => _obscureCurrent = !_obscureCurrent),
                      validator: (value) =>
                          value == null || value.isEmpty
                              ? 'Current password is required'
                              : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _newPasswordController,
                      label: 'New Password',
                      obscure: _obscureNew,
                      onToggle: () => setState(
                          () => _obscureNew = !_obscureNew),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'New password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordField(
                      controller: _confirmPasswordController,
                      label: 'Confirm New Password',
                      obscure: _obscureConfirm,
                      onToggle: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: profileVm.isLoading
                            ? null
                            : _handlePasswordUpdate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                        ),
                        child: profileVm.isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('Update Password'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () async {
                  final confirm =
                      await _showLogoutDialog(context);
                  if (confirm == true && context.mounted) {
                    auth.logout();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(
      String name, String email, bool isAdmin) {
    final initials = name.isNotEmpty
        ? name.trim().split(' ').map((e) => e[0]).take(2).join()
        : email.isNotEmpty
            ? email[0].toUpperCase()
            : '?';

    return Center(
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFF1A237E),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF1A237E).withOpacity(0.3),
                  width: 3),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name.isNotEmpty ? name : 'No name set',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(email,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin
                  ? const Color(0xFF1A237E).withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAdmin ? 'Admin' : 'Student',
              style: TextStyle(
                fontSize: 12,
                color:
                    isAdmin ? const Color(0xFF1A237E) : Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: IconButton(
          icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: onToggle,
        ),
      ),
      validator: validator,
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

  Future<bool?> _showLogoutDialog(BuildContext context) =>
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Logout'),
          content:
              const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Logout',
                  style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
}
