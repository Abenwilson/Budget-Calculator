import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
  const About({super.key});
  final String githuburl = "https://github.com/Abenwilson";
  final String linkedinurl =
      "https://www.linkedin.com/in/aben-wilson-11601a348/";

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url); // ✅ Convert String -> Uri
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: Text("about", style: TextStyle(fontSize: 20)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Text(
              "This application is designed to help individuals and families manage  and  calculate their yearly budget ",
              textAlign: TextAlign.center, // 👈 centers the text
            ),
            Text("effectively"),
            SizedBox(height: 50),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // GitHub Logo
                GestureDetector(
                  onTap: () => _launchUrl(githuburl),
                  child: Image.asset("assets/github.png", height: 40),
                ),
                SizedBox(width: 30),
                // GitHub Logo
                GestureDetector(
                  onTap: () => _launchUrl(linkedinurl),
                  child: Image.asset("assets/linkedin.png", height: 40),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text(
              "ensure connected with internet",
              textAlign: TextAlign.center, // 👈 centers the text
            ),
            SizedBox(height: 5),
            Text(
              "© 2025 YourAppName. All rights reserved.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
