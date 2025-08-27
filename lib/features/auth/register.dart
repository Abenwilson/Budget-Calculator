import 'package:budget_calculator/features/auth/component.dart';
import 'package:budget_calculator/features/auth/login.dart';
import 'package:budget_calculator/features/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController email_ctrl = TextEditingController();
  final TextEditingController pass_ctrl = TextEditingController();
  final TextEditingController cnfrmPass_ctrl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> register() async {
    if (pass_ctrl.text != cnfrmPass_ctrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Passwords do not match",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(255, 25, 152, 255),
        ),
      );
      return;
    }

    try {
      await _auth.createUserWithEmailAndPassword(
        email: email_ctrl.text.trim(),
        password: pass_ctrl.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Home()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registration Successful 🎉"),
          backgroundColor: Colors.white,
        ),
      );

      // Optionally navigate to another page
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
    } on FirebaseAuthException catch (e) {
      String message = "";
      if (e.code == 'weak-password') {
        message = "The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "This email is already registered.";
      } else if (e.code == 'invalid-email') {
        message = "Invalid email address.";
      } else {
        message = e.message ?? "Registration failed.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Hi Friend Nice to Meet You!"),
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
              MyTextField(
                controller: cnfrmPass_ctrl,
                hinttext: "confirm password",
                obscureText: false,
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: register,
                child: Text("Signup", style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Login()),
                  );
                },
                child: Text(
                  "Already a user? Move to Sign In.",
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
