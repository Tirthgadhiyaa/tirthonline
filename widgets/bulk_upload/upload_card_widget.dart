// lib/widgets/bulk_upload/upload_card_widget.dart

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jewellery_diamond/widgets/drag_drop_upload.dart';
import 'dart:html' as html;

class UploadCardWidget extends StatelessWidget {
  final Color primaryColor;
  final GlobalKey<UploadSectionState> uploadKey;
  final Function(List<html.File>) onFilesSelected;

  const UploadCardWidget({
    Key? key,
    required this.primaryColor,
    required this.uploadKey,
    required this.onFilesSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.9)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  FontAwesomeIcons.fileImport,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Upload Your File',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select or drag and drop your Excel file below to begin the upload process.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            UploadSection(
              key: uploadKey,
              title: "Upload Excel File",
              subtitle: "Drag and drop your completed template file here",
              icon: FontAwesomeIcons.fileExcel,
              allowedExtensions: ['csv', 'xlsx', 'xls'],
              onFilesSelected: onFilesSelected,
            ),
            const SizedBox(height: 24),
            _buildSupportedFormatsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportedFormatsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Supported Formats",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFormatItem(
                icon: FontAwesomeIcons.fileExcel,
                label: "Excel (.xlsx)",
                color: Colors.green,
              ),
              _buildFormatItem(
                icon: FontAwesomeIcons.fileExcel,
                label: "Excel 97-2003 (.xls)",
                color: Colors.green.shade700,
              ),
              _buildFormatItem(
                icon: FontAwesomeIcons.fileCsv,
                label: "CSV (.csv)",
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
