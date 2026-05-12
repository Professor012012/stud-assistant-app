import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_application_1/viewmodels/auth_viewmodel.dart';
import 'package:flutter_application_1/views/auth/login_screen.dart';
import 'package:flutter_application_1/widgets/skeleton_loader.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();

    return StreamBuilder<AuthState>(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        final user = auth.currentUser;

        if (user != null) {
          if (auth.userModel == null) {
            auth.loadUserModel(user.id);
            return const AppLoadingSkeleton();
          }

        }

        return const LoginScreen();
      },
    );
  }
}
