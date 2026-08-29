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
  static const String _storageKey = 'expenses';

  final double income = 20000;

  List<Expense> expenses = [];

  String selectedCategory = 'All';

  final List<String> categories = [
    'All',
    'Food',
    'Travel',
    'Shopping',
    'Bills',
    'Entertainment',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    loadExpenses();
  }

  // ------------------------------------------------------------
  // LOCAL STORAGE
  // ------------------------------------------------------------

  Future<void> loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final savedData = prefs.getString(_storageKey);

    if (savedData == null) {
      setState(() {
        expenses = [
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
      });

      await saveExpenses();
      return;
    }

    try {
      final List<dynamic> decodedData = jsonDecode(savedData);

      setState(() {
        expenses = decodedData
            .map(
              (item) => Expense.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      });
    } catch (e) {
      setState(() {
        expenses = [];
      });
    }
  }

  Future<void> saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();

    final data = expenses.map((expense) => expense.toJson()).toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  // ------------------------------------------------------------
  // CALCULATIONS
  // ------------------------------------------------------------

  double get totalExpenses {
    return expenses.fold(
      0,
      (sum, expense) => sum + expense.amount,
    );
  }

  double get balance {
    return income - totalExpenses;
  }

  double get expensePercentage {
    if (income == 0) return 0;

    return (totalExpenses / income).clamp(0, 1).toDouble();
  }

  List<Expense> get filteredExpenses {
    if (selectedCategory == 'All') {
      return expenses;
    }

    return expenses
        .where(
          (expense) => expense.category == selectedCategory,
        )
        .toList();
  }

  // ------------------------------------------------------------
  // ADD EXPENSE
  // ------------------------------------------------------------

  Future<void> showAddExpenseDialog() async {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    String category = 'Food';
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: Colors.indigo,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Add Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          labelText: 'Expense name',
                          hintText: 'e.g. Lunch',
                          prefixIcon: const Icon(
                            Icons.edit_rounded,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: amountController,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          hintText: '0.00',
                          prefixIcon: const Icon(
                            Icons.currency_rupee_rounded,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: const Icon(
                            Icons.category_rounded,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: categories
                            .where((item) => item != 'All')
                            .map(
                              (item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              category = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );

                          if (pickedDate != null) {
                            setDialogState(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 17,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month_rounded,
                                color: Colors.indigo,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Date',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${selectedDate.day}/'
                                    '${selectedDate.month}/'
                                    '${selectedDate.year}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 15,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                20,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    final title =
                        titleController.text.trim();

                    final amount = double.tryParse(
                      amountController.text.trim(),
                    );

                    if (title.isEmpty ||
                        amount == null ||
                        amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid expense name and amount.',
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
                      category: category,
                      date: selectedDate,
                    );

                    setState(() {
                      expenses.insert(0, newExpense);
                    });

                    await saveExpenses();

                    if (mounted) {
                      Navigator.pop(dialogContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Expense added successfully!',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Add Expense'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    amountController.dispose();
  }

  // ------------------------------------------------------------
  // DELETE EXPENSE
  // ------------------------------------------------------------

  Future<void> deleteExpense(Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Delete Expense?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${expense.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red.shade700,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        expenses.removeWhere(
          (item) => item.id == expense.id,
        );
      });

      await saveExpenses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted.'),
          ),
        );
      }
    }
  }

  // ------------------------------------------------------------
  // CATEGORY ICON
  // ------------------------------------------------------------

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.directions_bus_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      case 'Entertainment':
        return Icons.movie_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final isWideScreen = screenWidth >= 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F7FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: isWideScreen ? 40 : 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Tracker',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: Color(0xFF171827),
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Manage your money with ease',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              tooltip: 'Add Expense',
              onPressed: showAddExpenseDialog,
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.indigo,
              ),
            ),
          ),
        ],
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 1100,
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isWideScreen ? 40 : 20,
              vertical: 15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ------------------------------------------------
                // BALANCE CARD
                // ------------------------------------------------

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4F46E5),
                        Color(0xFF7C3AED),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.22),
                        blurRadius: 25,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -40,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Positioned(
                        right: 30,
                        bottom: -70,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),

                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white.withOpacity(0.15),
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Available Balance',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text(
                            '₹${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'You have spent ₹${totalExpenses.toStringAsFixed(0)} this month',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 22),

                          ClipRRect(
                            borderRadius:
                                BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: expensePercentage,
                              minHeight: 8,
                              backgroundColor:
                                  Colors.white.withOpacity(0.18),
                              valueColor:
                                  const AlwaysStoppedAnimation(
                                Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Monthly spending',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${(expensePercentage * 100).toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ------------------------------------------------
                // SUMMARY CARDS
                // ------------------------------------------------

                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: 'Income',
                        amount:
                            '₹${income.toStringAsFixed(0)}',
                        icon: Icons.arrow_downward_rounded,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: SummaryCard(
                        title: 'Expenses',
                        amount:
                            '₹${totalExpenses.toStringAsFixed(0)}',
                        icon: Icons.arrow_upward_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ------------------------------------------------
                // TRANSACTIONS HEADER
                // ------------------------------------------------

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF171827),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Keep track of where your money goes',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    if (isWideScreen)
                      ElevatedButton.icon(
                        onPressed: showAddExpenseDialog,
                        icon: const Icon(
                          Icons.add_rounded,
                          size: 19,
                        ),
                        label: const Text('Add Expense'),
                      ),
                  ],
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // CATEGORY FILTER
                // ------------------------------------------------

                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          selectedCategory == category;

                      return ChoiceChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (category != 'All') ...[
                              Icon(
                                getCategoryIcon(category),
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(category),
                          ],
                        ),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedCategory = category;
                          });
                        },
                        selectedColor: Colors.indigo,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF555766),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // ------------------------------------------------
                // EXPENSE LIST
                // ------------------------------------------------

                if (filteredExpenses.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 55,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.indigo.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: Colors.indigo,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No expenses found',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          selectedCategory == 'All'
                              ? 'Start adding your expenses to see them here.'
                              : 'No expenses in the $selectedCategory category.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: showAddExpenseDialog,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Expense'),
                        ),
                      ],
                    ),
                  )
                else
                  ...filteredExpenses.map(
                    (expense) => ExpenseTile(
                      expense: expense,
                      onDelete: () => deleteExpense(expense),
                    ),
                  ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),

      // ----------------------------------------------------------
      // FLOATING ACTION BUTTON
      // ----------------------------------------------------------

      floatingActionButton: FloatingActionButton.extended(
        onPressed: showAddExpenseDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.add_rounded),
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