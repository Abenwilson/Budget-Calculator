import 'package:budget_calculator/features/auth/component.dart';
import 'package:budget_calculator/features/auth/register.dart';
import 'package:budget_calculator/features/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController email_ctrl = TextEditingController();
  final TextEditingController pass_ctrl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email_ctrl.text.trim(),
        password: pass_ctrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login Successful 🎉"),
          backgroundColor: Colors.white,
        ),
      );

      // ✅ Navigate to Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        message = "Incorrect password.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email format.";
      } else {
        message = e.message ?? "Login failed.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // important for keyboard handling
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hey, Welcome Back"),
              SizedBox(height: 20),
              MyTextField(
                controller: email_ctrl,
                hinttext: "Email",
                obscureText: false,
              ),
              SizedBox(height: 20),
              MyTextField(
                controller: pass_ctrl,
                hinttext: "Password",
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: login, child: Text("SignIn")),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Register()),
                  );
                },
                child: Text(
                  "New here? Create an account.",
                  style: TextStyle(color: Colors.blueAccent.shade400),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
