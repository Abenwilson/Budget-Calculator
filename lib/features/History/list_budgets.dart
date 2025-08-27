import 'package:budget_calculator/features/History/expenses.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ListBudgets extends StatefulWidget {
  const ListBudgets({super.key});

  @override
  State<ListBudgets> createState() => _ListBudgetsState();
}

class _ListBudgetsState extends State<ListBudgets> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("Look Back", style: TextStyle(fontSize: 20)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection("budgets")
                .where("userId", isEqualTo: uid)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No budgets found"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final month = data["month"] ?? "Unknown";
              final savings = (data["savings"] ?? 0).toDouble();

              return ListTile(
                title: Text(month.toString()),
                subtitle: Text(
                  "Savings: ₹${savings.toStringAsFixed(2)}",
                  style: TextStyle(
                    color:
                        savings < 0
                            ? Colors.red
                            : const Color.fromARGB(255, 1, 40, 72),
                  ),
                ),
                trailing: IconButton(
                  onPressed: () async {
                    final docId = docs[index].id; // Get document ID
                    await FirebaseFirestore.instance
                        .collection("budgets")
                        .doc(docId)
                        .delete();
                  },
                  icon: Icon(Icons.delete),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder:
                          (context) => DetailsBudgets(
                            budgetId:
                                docs[index].id, // pass docId to details page
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
