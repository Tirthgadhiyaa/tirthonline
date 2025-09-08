// lib/widgets/bulk_upload/instructions_card_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_saver/file_saver.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InstructionsCardWidget extends StatelessWidget {
  final Color primaryColor;

  const InstructionsCardWidget({
    Key? key,
    required this.primaryColor,
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
                  FontAwesomeIcons.circleInfo,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'How It Works',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInstructionStep(
              number: '1',
              title: 'Download Template',
              description: 'Get our Excel template with the correct format',
              icon: Icons.download_rounded,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              number: '2',
              title: 'Fill in Details',
              description: 'Add your product information to the template',
              icon: Icons.edit_document,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              number: '3',
              title: 'Upload File',
              description: 'Upload your completed Excel file',
              icon: Icons.upload_file,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  try {
                    ByteData data = await rootBundle
                        .load('assets/excel_sample/Upload File Sample.xlsx');
                    Uint8List bytes = data.buffer.asUint8List();
                    await FileSaver.instance.saveFile(
                      name: "Diamond_Upload_Template.xlsx",
                      bytes: bytes,
                      ext: "xlsx",
                      mimeType: MimeType.csv,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Template downloaded successfully!"),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Error downloading template: $e"),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.download, size: 20),
                label: const Text(
                  "Download Template",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: primaryColor),
                  foregroundColor: primaryColor,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          icon,
          color: color,
          size: 24,
        ),
      ],
    );
  }
}
