import 'package:budget_calculator/features/auth/register.dart';
import 'package:budget_calculator/features/home.dart';
import 'package:budget_calculator/theme/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const BudgetApp());
}

class BudgetApp extends StatelessWidget {
  const BudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Calculator',
      theme: lightmode,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(), // use wrapper to decide start page
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream:
          FirebaseAuth.instance.authStateChanges(), // listens to login/logout
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          ); // loading state
        }
        if (snapshot.hasData) {
          return const Home(); //  user already logged in
        } else {
          return const Register(); //  no user, go to register/login
        }
      },
    );
  }
}
