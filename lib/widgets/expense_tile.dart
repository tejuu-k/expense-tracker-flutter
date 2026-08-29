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
        return Icons.restaurant_rounded;
      case 'Travel':
        return Icons.directions_bus_rounded;
      case 'Shopping':
        return Icons.shopping_bag_rounded;
      case 'Bills':
        return Icons.receipt_long_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                getCategoryIcon(),
                color: primaryColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${expense.category} • '
                    '${expense.date.day}/'
                    '${expense.date.month}/'
                    '${expense.date.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end,
              children: [
                Text(
                  '- ₹${expense.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}