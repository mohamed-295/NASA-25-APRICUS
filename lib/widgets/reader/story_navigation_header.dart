import 'package:flutter/material.dart';

class StoryNavigationHeader extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onBack;

  const StoryNavigationHeader({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 12, top: 4, bottom: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 40),
            onPressed: onBack,
            color: Colors.white,
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$currentPage / $totalPages',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
