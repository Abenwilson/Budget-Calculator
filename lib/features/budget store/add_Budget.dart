import 'package:budget_calculator/features/budget%20store/planing_Page.dart';
import 'package:flutter/material.dart';

class AddBudget extends StatefulWidget {
  const AddBudget({super.key});

  @override
  State<AddBudget> createState() => _AddBudgetState();
}

class _AddBudgetState extends State<AddBudget> {
  final TextEditingController month_controller1 = TextEditingController();
  final TextEditingController salary_controller = TextEditingController();

  @override
  void dispose() {
    month_controller1.dispose;
    salary_controller.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analyis your Budget", style: TextStyle(fontSize: 20)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Padding(padding: const EdgeInsets.all(15), child: Text("Month")),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: month_controller1,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
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
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Text("Total amount you have"),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              maxLength: 10,
              controller: salary_controller,
              decoration: InputDecoration(
                hintText: "INR",
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade200,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ElevatedButton(
              onPressed: () {
                final month = month_controller1.text.trim();
                final salary =
                    double.tryParse(salary_controller.text.trim()) ?? 0;

                if (month.isEmpty || salary == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Please enter both month and salary."),
                      backgroundColor: const Color.fromARGB(255, 1, 31, 45),
                    ),
                  );
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (cxt) => PlaningPage(title: month, totalAmount: salary),
                  ),
                );
                month_controller1.clear();
                salary_controller.clear();
              },
              child: Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
