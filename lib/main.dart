import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:assistants_app/viewmodels/admin_viewmodel.dart';
import 'package:assistants_app/viewmodels/application_viewmodel.dart';
import 'package:assistants_app/viewmodels/auth_viewmodel.dart';
import 'package:assistants_app/widgets/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://irlettzyrnetrqgxmyiw.supabase.co',
    anonKey: 'sb_publishable_gGHRaNAsjODubkTnI_gVsQ_BaIE3zfo',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => ApplicationViewModel()),
        ChangeNotifierProvider(create: (_) => AdminViewModel()),
      ],
      child: MaterialApp(
        title: 'Student Assistant',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A237E)),
          useMaterial3: true,
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}
