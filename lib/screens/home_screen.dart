import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../widgets/expense_tile.dart';
import '../widgets/summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Expense> expenses = [
    Expense(
      title: 'Lunch',
      amount: 250,
      category: 'Food',
      date: DateTime.now(),
    ),
    Expense(
      title: 'Bus Ticket',
      amount: 100,
      category: 'Travel',
      date: DateTime.now(),
    ),
    Expense(
      title: 'Notebook',
      amount: 180,
      category: 'Shopping',
      date: DateTime.now(),
    ),
  ];

  final double income = 20000;

  double get totalExpenses {
    return expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  double get balance {
    return income - totalExpenses;
  }

  void deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });
  }

  void showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    String selectedCategory = 'Food';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Expense'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Expense name',
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.currency_rupee),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Food',
                          child: Text('Food'),
                        ),
                        DropdownMenuItem(
                          value: 'Travel',
                          child: Text('Travel'),
                        ),
                        DropdownMenuItem(
                          value: 'Shopping',
                          child: Text('Shopping'),
                        ),
                        DropdownMenuItem(
                          value: 'Bills',
                          child: Text('Bills'),
                        ),
                        DropdownMenuItem(
                          value: 'Other',
                          child: Text('Other'),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount =
                        double.tryParse(amountController.text.trim());

                    if (title.isEmpty ||
                        amount == null ||
                        amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid name and amount',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      expenses.add(
                        Expense(
                          title: title,
                          amount: amount,
                          category: selectedCategory,
                          date: DateTime.now(),
                        ),
                      );
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                SummaryCard(
                  title: 'Income',
                  amount: '₹${income.toStringAsFixed(2)}',
                  icon: Icons.arrow_downward,
                ),
                const SizedBox(width: 10),
                SummaryCard(
                  title: 'Expenses',
                  amount: '₹${totalExpenses.toStringAsFixed(2)}',
                  icon: Icons.arrow_upward,
                ),
              ],
            ),

            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Expenses',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: showAddExpenseDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),

            const SizedBox(height: 15),

            if (expenses.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Text(
                    'No expenses added yet.',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ...expenses.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final expense = entry.value;

                  return ExpenseTile(
                    expense: expense,
                    onDelete: () {
                      deleteExpense(index);
                    },
                  );
                },
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddExpenseDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
