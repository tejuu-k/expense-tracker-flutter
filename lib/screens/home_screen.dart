import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      id: '1',
      title: 'Lunch',
      amount: 250,
      category: 'Food',
      date: DateTime.now(),
    ),
    Expense(
      id: '2',
      title: 'Bus Ticket',
      amount: 100,
      category: 'Travel',
      date: DateTime.now(),
    ),
    Expense(
      id: '3',
      title: 'Notebook',
      amount: 180,
      category: 'Shopping',
      date: DateTime.now(),
    ),
  ];

  final double income = 20000;

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  // Save expenses to local storage
  Future<void> saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final expenseList = expenses
        .map((expense) => jsonEncode(expense.toJson()))
        .toList();

    await prefs.setStringList('expenses', expenseList);
  }

  // Load expenses from local storage
  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final savedExpenses = prefs.getStringList('expenses');

    if (savedExpenses == null) {
      return;
    }

    setState(() {
      expenses.clear();

      expenses.addAll(
        savedExpenses.map(
          (expense) => Expense.fromJson(
            jsonDecode(expense) as Map<String, dynamic>,
          ),
        ),
      );
    });
  }

  double get totalExpenses {
    return expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  double get balance {
    return income - totalExpenses;
  }

  // Delete an expense
  void deleteExpense(int index) {
    setState(() {
      expenses.removeAt(index);
    });

    saveExpenses();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense deleted'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Add a new expense
  void showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    String selectedCategory = 'Food';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                'Add Expense',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Expense name',
                        prefixIcon: Icon(
                          Icons.edit_outlined,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(
                          Icons.currency_rupee,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(
                          Icons.category_outlined,
                        ),
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
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),

                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

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

                    final newExpense = Expense(
                      id: DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                      title: title,
                      amount: amount,
                      category: selectedCategory,
                      date: DateTime.now(),
                    );

                    setState(() {
                      expenses.add(newExpense);
                    });

                    saveExpenses();

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Expense added successfully'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: const Text('Add Expense'),
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
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  0,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello! 👋',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Expense Tracker',
                              style: TextStyle(
                                fontSize: 27,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons
                                .account_balance_wallet_rounded,
                            color: Theme.of(context)
                                .colorScheme
                                .primary,
                            size: 26,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary,
                            Theme.of(context)
                                .colorScheme
                                .primaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.25),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Balance',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            '₹${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Keep track of your spending',
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: 0.85),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Income and Expenses
                    Row(
                      children: [
                        SummaryCard(
                          title: 'Income',
                          amount:
                              '₹${income.toStringAsFixed(0)}',
                          icon: Icons.arrow_downward_rounded,
                        ),
                        const SizedBox(width: 12),
                        SummaryCard(
                          title: 'Expenses',
                          amount:
                              '₹${totalExpenses.toStringAsFixed(0)}',
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Recent Expenses
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Expenses',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton.icon(
                          onPressed:
                              showAddExpenseDialog,
                          icon: const Icon(
                            Icons.add,
                            size: 19,
                          ),
                          label: const Text('Add New'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Expense List
            if (expenses.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 15),
                        Text(
                          'No expenses yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Start adding your daily expenses.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                sliver: SliverList(
                  delegate:
                      SliverChildBuilderDelegate(
                    (context, index) {
                      final expense = expenses[index];

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: ExpenseTile(
                          expense: expense,
                          onDelete: () {
                            deleteExpense(index);
                          },
                        ),
                      );
                    },
                    childCount: expenses.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Expense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}