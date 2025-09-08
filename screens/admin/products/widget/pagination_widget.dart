// lib/screens/admin/products/widget/pagination_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' show min;

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalItems;
  final int itemsPerPage;
  final Function(int) onPageChanged;
  final bool showContainer; // New parameter to control container styling

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalItems,
    required this.itemsPerPage,
    required this.onPageChanged,
    this.showContainer = false, // Default to false for flexibility
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems <= 0) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        int totalPages = (totalItems / itemsPerPage).ceil();
        int visiblePages =
            isSmallScreen ? 3 : 5; // Fewer pages on small screens

        List<Widget> pageButtons = [];

        // First Page Button
        pageButtons.add(
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: currentPage > 1 ? () => onPageChanged(1) : null,
            tooltip: 'First Page',
            color: currentPage > 1
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            iconSize: isSmallScreen ? 18 : 20,
            padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
            constraints: BoxConstraints(
                minWidth: isSmallScreen ? 28 : 32,
                minHeight: isSmallScreen ? 28 : 32),
          ),
        );

        // Previous Button
        pageButtons.add(
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            tooltip: 'Previous Page',
            color: currentPage > 1
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            iconSize: isSmallScreen ? 18 : 20,
            padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
            constraints: BoxConstraints(
                minWidth: isSmallScreen ? 28 : 32,
                minHeight: isSmallScreen ? 28 : 32),
          ),
        );

        int halfVisible = visiblePages ~/ 2;
        int startPage = (currentPage - halfVisible).clamp(1, totalPages);
        int endPage = (startPage + visiblePages - 1).clamp(1, totalPages);

        if (endPage - startPage + 1 < visiblePages) {
          startPage = (endPage - visiblePages + 1).clamp(1, totalPages);
        }

        // Show first page and ...
        if (startPage > 1) {
          pageButtons
              .add(_pageButton(1, context, isSmallScreen: isSmallScreen));
          if (startPage > 2) {
            pageButtons.add(Text(
              "...",
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.grey.shade600,
              ),
            ));
          }
        }

        // Show visible page buttons
        for (int i = startPage; i <= endPage; i++) {
          pageButtons.add(_pageButton(i, context,
              isSelected: i == currentPage, isSmallScreen: isSmallScreen));
        }

        // Show last page and ...
        if (endPage < totalPages) {
          if (endPage < totalPages - 1) {
            pageButtons.add(Text(
              "...",
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.grey.shade600,
              ),
            ));
          }
          pageButtons.add(
              _pageButton(totalPages, context, isSmallScreen: isSmallScreen));
        }

        // Next Button
        pageButtons.add(
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(currentPage + 1)
                : null,
            tooltip: 'Next Page',
            color: currentPage < totalPages
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            iconSize: isSmallScreen ? 18 : 20,
            padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
            constraints: BoxConstraints(
                minWidth: isSmallScreen ? 28 : 32,
                minHeight: isSmallScreen ? 28 : 32),
          ),
        );

        // Last Page Button
        pageButtons.add(
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: currentPage < totalPages
                ? () => onPageChanged(totalPages)
                : null,
            tooltip: 'Last Page',
            color: currentPage < totalPages
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            iconSize: isSmallScreen ? 18 : 20,
            padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
            constraints: BoxConstraints(
                minWidth: isSmallScreen ? 28 : 32,
                minHeight: isSmallScreen ? 28 : 32),
          ),
        );

        Widget paginationContent = Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: pageButtons,
            ),
            SizedBox(width: isSmallScreen ? 12 : 16),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: isSmallScreen ? 4 : 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
              ),
              child: Text(
                '$currentPage of $totalPages',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 10 : 12,
                ),
              ),
            ),
          ],
        );

        // Only show container if explicitly requested
        if (showContainer) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                vertical: isSmallScreen ? 8 : 12,
                horizontal: isSmallScreen ? 12 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: paginationContent,
          );
        }

        return paginationContent;
      },
    );
  }

  Widget _pageButton(int page, BuildContext context,
      {bool isSelected = false, bool isSmallScreen = false}) {
    return InkWell(
      onTap: () => onPageChanged(page),
      child: Container(
        width: isSmallScreen ? 28 : 32,
        height: isSmallScreen ? 28 : 32,
        margin: const EdgeInsets.only(right: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          page.toString(),
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 10 : 12,
          ),
        ),
      ),
    );
  }
}
