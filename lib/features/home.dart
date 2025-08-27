import 'dart:async';

import 'package:budget_calculator/features/History/list_budgets.dart';
import 'package:budget_calculator/features/about.dart';
import 'package:budget_calculator/features/budget%20store/add_Budget.dart';
import 'package:budget_calculator/features/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime currentDate = DateTime.now();
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // Check every day at midnight if the month has changed
    timer = Timer.periodic(Duration(hours: 1), (_) {
      DateTime now = DateTime.now();
      if (now.month != currentDate.month || now.year != currentDate.year) {
        setState(() {
          currentDate = now;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    // Navigate back to Login after logout
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
    );
  }

  final Map<String, Color> categoryColors = {
    'Bills': Colors.blue,
    'Shopping': Colors.purple,
    'Food': Colors.orange,
    'Sem Fees': Colors.teal,
    'Travel': Colors.green,
    'EMI': Colors.red,
    'Others': Colors.grey,
  };
  Future<Map<String, double>> getCategoryTotals(String userId) async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("budgets")
            .where("userId", isEqualTo: userId)
            .get();

    Map<String, double> totals = {
      'Bills': 0,
      'Shopping': 0,
      'Food': 0,
      'Sem Fees': 0,
      'Travel': 0,
      'EMI': 0,
      'Others': 0,
    };

    for (var doc in snapshot.docs) {
      final categories = Map<String, dynamic>.from(doc["categories"] ?? {});
      categories.forEach((name, values) {
        final actual = (values["actual"] ?? 0).toDouble();
        if (totals.containsKey(name)) {
          totals[name] = (totals[name] ?? 0) + actual; // sum across months
        } else {
          totals[name] = actual; // fallback for new categories
        }
      });
    }

    return totals;
  }

  @override
  Widget build(BuildContext context) {
    String monthName = DateFormat('yyyy').format(currentDate).toUpperCase();
    print("Firestore UID: ${FirebaseAuth.instance.currentUser?.uid}");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return About();
                },
              ),
            );
          },
          icon: Icon(Icons.menu),
        ),
        title: Text("Budget Report", style: TextStyle(fontSize: 20)),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30, child: Text("Hi..")),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.grey.shade100,
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  height: 300,
                  padding: const EdgeInsets.all(16),
                  child: FutureBuilder<Map<String, double>>(
                    future:
                        FirebaseAuth.instance.currentUser == null
                            ? null
                            : getCategoryTotals(
                              FirebaseAuth.instance.currentUser!.uid,
                            ),
                    builder: (context, snapshot) {
                      if (FirebaseAuth.instance.currentUser == null) {
                        return const Center(child: Text("Please login first"));
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                          child: Text("No category data available"),
                        );
                      }

                      final totals = snapshot.data!;
                      final sections =
                          totals.entries
                              .where(
                                (e) => e.value > 0,
                              ) // only show non-zero categories
                              .map((e) {
                                return PieChartSectionData(
                                  value: e.value,
                                  title: "${e.value.toInt()}₹",
                                  color: categoryColors[e.key] ?? Colors.grey,
                                  radius: 60,
                                  titleStyle: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                );
                              })
                              .toList();

                      return Column(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sections: sections,
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                                borderData: FlBorderData(show: false),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            alignment: WrapAlignment.center,
                            children:
                                totals.keys.map((cat) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        color:
                                            categoryColors[cat] ?? Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(cat, style: TextStyle(fontSize: 12)),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: const Color.fromARGB(255, 255, 242, 201),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 69, 171, 255),
                          const Color.fromARGB(255, 226, 253, 255),
                        ],
                        begin: Alignment.bottomRight,
                      ),
                    ),
                    width: 170,
                    height: 200,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return AddBudget();
                            },
                          ),
                        );
                        setState(() {}); // refresh UI after returning
                      },
                      icon: Icon(
                        Icons.addchart,
                        size: 50,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),

                      gradient: LinearGradient(
                        begin: Alignment.bottomRight,
                        colors: [
                          const Color.fromARGB(255, 69, 171, 255),
                          const Color.fromARGB(255, 226, 253, 255),
                        ],
                      ),
                    ),
                    width: 170,
                    height: 200,
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ListBudgets(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.assignment,
                        size: 50,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                margin: EdgeInsets.only(top: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),

                color: Theme.of(context).colorScheme.secondary,
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [
                        const Color.fromARGB(255, 255, 140, 215),
                        const Color.fromARGB(255, 246, 255, 254),
                      ],
                    ),
                  ),
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  height: 180,
                  alignment: Alignment.center,
                  child: Text(
                    monthName,
                    style: TextStyle(
                      color: Colors.black26,
                      fontSize: 90,
                      fontWeight: FontWeight.w800,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
