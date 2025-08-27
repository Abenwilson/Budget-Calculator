import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PlaningPage extends StatefulWidget {
  final String title;
  final double totalAmount;
  PlaningPage({super.key, required this.title, required this.totalAmount});

  @override
  State<PlaningPage> createState() => _PlaningPageState();
}

class _PlaningPageState extends State<PlaningPage> {
  Future<void> saveBudgetToFirebase() async {
    Map<String, dynamic> budgetData = {
      "month": widget.title,
      "totalAmount": widget.totalAmount,
      "createdAt": FieldValue.serverTimestamp(),
      "plannedTotal": totalPlanned,
      "actualTotal": totalActual,
      "savings": savings,
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "categories": {},
    };

    // store each category with actual & planned
    for (int i = 0; i < myPlans.length; i++) {
      budgetData["categories"][myPlans[i]] = {
        "actual": double.tryParse(controllers[i][0].text) ?? 0,
        "planned": double.tryParse(controllers[i][1].text) ?? 0,
      };
    }

    await FirebaseFirestore.instance.collection("budgets").add(budgetData);
  }

  double get totalPlanned {
    double sum = 0;
    for (var pair in controllers) {
      sum += double.tryParse(pair[1].text) ?? 0;
    }
    return sum;
  }

  double get totalActual {
    double sum = 0;
    for (var pair in controllers) {
      sum += double.tryParse(pair[0].text) ?? 0;
    }
    return sum;
  }

  double get savings => widget.totalAmount - totalActual;

  final List<String> myPlans = [
    'Bills',
    'Shopping',
    'Food',
    'Sem Fees',
    'Travel',
    'EMI',
    'Others',
  ];

  // 2 controllers per plan → one for each TextField
  late List<List<TextEditingController>> controllers;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      myPlans.length,
      (_) => [TextEditingController(), TextEditingController()],
    );
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks
    for (var pair in controllers) {
      for (var c in pair) {
        c.dispose();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title.toUpperCase(), style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade200,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: myPlans.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            child: RotatedBox(
                              quarterTurns: -1, // -90 degrees
                              child: Text(
                                myPlans[index],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: controllers[index][0],
                            decoration: InputDecoration(
                              hintText: "Actual",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (_) {
                              setState(() {}); // 🔥 Recalculate and refresh UI
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: controllers[index][1],
                            decoration: InputDecoration(
                              hintText: "planned",
                              hintStyle: TextStyle(color: Colors.grey.shade500),
                              filled: true,
                              fillColor: Colors.white,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.tertiary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (_) {
                              setState(() {}); // 🔥 Recalculate and refresh UI
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              Text("Total Planned: "),
                              Text(
                                "₹${totalPlanned.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color:
                                      totalPlanned > widget.totalAmount
                                          ? Colors.red
                                          : Color.fromARGB(255, 1, 31, 45),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Text("Savings: "),
                              Text(
                                "₹${savings.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color:
                                      savings < 0 ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 70),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    bool hasEmptyPlanned = controllers.any(
                                      (pair) => pair[1].text.trim().isEmpty,
                                    ); // pair[1] = planned field

                                    if (hasEmptyPlanned) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Please enter all planned values before submitting.",
                                          ),
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            1,
                                            31,
                                            45,
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    await saveBudgetToFirebase();
                                    for (var pair in controllers) {
                                      for (var c in pair) {
                                        c.clear();
                                      }
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Budget saved !"),
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          1,
                                          31,
                                          45,
                                        ),
                                      ),
                                    );

                                    setState(() {}); // refresh UI
                                    Navigator.pop(context);
                                  },
                                  child: Text("Submit"),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
