import 'package:flutter/material.dart';

class DividerSection extends StatelessWidget {
  final String title;

  const DividerSection({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(thickness: 1, color: Colors.grey)),
        ],
      ),
    );
  }
}
