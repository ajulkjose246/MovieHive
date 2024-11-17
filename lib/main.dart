import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:moviehive/authentication/signin_screen.dart';
import 'package:moviehive/authentication/signup_screen.dart';
import 'package:moviehive/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:moviehive/providers/dashboard_provider.dart';
import 'package:moviehive/screens/details_screen.dart';
import 'package:moviehive/authentication/auth_page.dart';
import 'package:moviehive/providers/auth_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        routes: ({
          '/': (context) => const AuthPage(),
          '/movie_details': (context) => const DetailsScreen(),
          '/signin': (context) => const SigninScreen(),
          '/signup': (context) => const SignupScreen(),
        }),
        initialRoute: '/',
      ),
    );
  }
}
