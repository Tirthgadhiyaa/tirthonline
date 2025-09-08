// lib/widgets/bulk_upload/error_summary_widget.dart

import 'package:flutter/material.dart';

class ErrorSummaryWidget extends StatelessWidget {
  final int importedCount;
  final int updatedCount;
  final int failedCount;
  final int errorCount;
  final int duplicateCount;

  const ErrorSummaryWidget({
    Key? key,
    required this.importedCount,
    required this.updatedCount,
    required this.failedCount,
    required this.errorCount,
    required this.duplicateCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalCount = importedCount + updatedCount + failedCount;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Import Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Circular progress indicator
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                children: [
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: totalCount > 0 ? importedCount / totalCount : 0,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: totalCount > 0
                          ? (importedCount + updatedCount) / totalCount
                          : 0,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 12,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        totalCount > 0 && failedCount > 0
                            ? Colors.red
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          totalCount.toString(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Total Items',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Statistics
          _buildStatItem(
            context,
            label: 'Imported',
            count: importedCount,
            total: totalCount,
            color: Colors.green,
            icon: Icons.check_circle,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            context,
            label: 'Updated',
            count: updatedCount,
            total: totalCount,
            color: Colors.blue,
            icon: Icons.update,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            context,
            label: 'Failed',
            count: failedCount,
            total: totalCount,
            color: Colors.red,
            icon: Icons.error,
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),

          // Error breakdown
          const Text(
            'Error Breakdown',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildErrorTypeItem(
            context,
            label: 'Validation Errors',
            count: errorCount,
            color: Colors.red,
            icon: Icons.error_outline,
          ),
          const SizedBox(height: 12),
          _buildErrorTypeItem(
            context,
            label: 'Duplicate Stocks',
            count: duplicateCount,
            color: Colors.orange,
            icon: Icons.copy_all,
          ),

          const SizedBox(height: 32),

          // Tips section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text(
                      'Tips for Fixing Errors',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Check for invalid values in highlighted cells',
                  style: TextStyle(fontSize: 12),
                ),
                const Text(
                  '• Ensure all required fields are filled',
                  style: TextStyle(fontSize: 12),
                ),
                const Text(
                  '• Use unique stock numbers for each item',
                  style: TextStyle(fontSize: 12),
                ),
                const Text(
                  '• Verify that values match expected formats',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String label,
    required int count,
    required int total,
    required Color color,
    required IconData icon,
  }) {
    final percentage =
        total > 0 ? (count / total * 100).toStringAsFixed(1) : '0.0';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$count items',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$percentage%',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(
              width: 60,
              height: 4,
              child: LinearProgressIndicator(
                value: total > 0 ? count / total : 0,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorTypeItem(
    BuildContext context, {
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
