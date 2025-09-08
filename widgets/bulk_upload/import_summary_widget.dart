// lib/widgets/bulk_upload/import_summary_widget.dart

import 'package:flutter/material.dart';

class ImportSummaryWidget extends StatelessWidget {
  final String summary;

  const ImportSummaryWidget({
    Key? key,
    required this.summary,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Parse the summary to extract numbers
    final importedCount = _extractNumber(summary, 'imported');
    final updatedCount = _extractNumber(summary, 'updated');
    final failedCount = _extractNumber(summary, 'failed');
    final totalCount = importedCount + updatedCount + failedCount;

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Text(
                    "Import Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Visual summary with progress indicators
              Row(
                children: [
                  _buildSummaryItem(
                    context,
                    count: importedCount,
                    total: totalCount,
                    label: "Imported",
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                  _buildSummaryItem(
                    context,
                    count: updatedCount,
                    total: totalCount,
                    label: "Updated",
                    color: Colors.blue,
                    icon: Icons.update,
                  ),
                  _buildSummaryItem(
                    context,
                    count: failedCount,
                    total: totalCount,
                    label: "Failed",
                    color: Colors.red,
                    icon: Icons.error,
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Text(
                summary,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _extractNumber(String text, String keyword) {
    final regex = RegExp('(\\d+)\\s+$keyword');
    final match = regex.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1) ?? '0') ?? 0;
    }
    return 0;
  }

  Widget _buildSummaryItem(
    BuildContext context, {
    required int count,
    required int total,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final percentage = total > 0 ? count / total : 0.0;

    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  strokeWidth: 8,
                ),
              ),
              Icon(
                icon,
                color: color,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
