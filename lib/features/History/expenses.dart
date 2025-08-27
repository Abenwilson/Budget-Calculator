import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsBudgets extends StatefulWidget {
  final String budgetId;

  const DetailsBudgets({super.key, required this.budgetId});

  @override
  State<DetailsBudgets> createState() => _DetailsBudgetsState();
}

class _DetailsBudgetsState extends State<DetailsBudgets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.grey.shade200,
        title: const Text("Detailed budget", style: TextStyle(fontSize: 20)),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance
                .collection("budgets")
                .doc(widget.budgetId)
                .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final categories = data["categories"] as Map<String, dynamic>? ?? {};

          if (categories.isEmpty) {
            return const Center(child: Text("No category data available"));
          }

          final categoryNames = categories.keys.toList();

          return Padding(
            padding: const EdgeInsets.all(15),
            child: GridView.builder(
              itemCount: categoryNames.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 cards per row
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final name = categoryNames[index];
                final value = categories[name];

                final actualValue = value is Map ? value["actual"] : value;

                return Card(
                  elevation: 2,
                  color: const Color.fromARGB(255, 164, 198, 255),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(7),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "₹${actualValue.toString()}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
