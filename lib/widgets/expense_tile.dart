import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseTile extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onDelete,
  });

  IconData getCategoryIcon() {
    switch (expense.category) {
      case 'Food':
        return Icons.restaurant;
      case 'Travel':
        return Icons.directions_bus;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Bills':
        return Icons.receipt_long;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(getCategoryIcon()),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${expense.category} • '
          '${expense.date.day}/${expense.date.month}/${expense.date.year}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '₹${expense.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}