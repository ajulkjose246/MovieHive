import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moviehive/authentication/signin_screen.dart';
import 'package:moviehive/screens/dash_board.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If user is logged in
        if (snapshot.hasData) {
          return const DashBoard();
        }
        // If user is NOT logged in
        else {
          return const SigninScreen();
        }
      },
    );
  }
}
