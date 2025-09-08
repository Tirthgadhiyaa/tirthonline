// lib/screens/seller/products/widgets/bulk_upload_options_dialog.dart

import 'package:flutter/material.dart';

class BulkUploadOptionsDialog extends StatefulWidget {
  const BulkUploadOptionsDialog({Key? key}) : super(key: key);

  @override
  State<BulkUploadOptionsDialog> createState() => _BulkUploadOptionsDialogState();
}

class _BulkUploadOptionsDialogState extends State<BulkUploadOptionsDialog> {
  bool? _selectedOption; // false = Insert Only, true = Insert & Update

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      title: Row(
        children: [
          Icon(Icons.upload_file,
              color: Theme.of(context).colorScheme.primary, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Bulk Upload Options',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How should we handle products that already exist in your inventory?',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          // Stepper-like visuals
          Row(
            children: [
              _StepCircle(number: 1, selected: _selectedOption == false),
              Container(width: 32, height: 2, color: Colors.grey.shade300),
              _StepCircle(number: 2, selected: _selectedOption == true),
            ],
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _selectedOption = false),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: _selectedOption == false
                          ? Colors.green.shade100
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedOption == false
                            ? Colors.green.shade700
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: ListTile(
                      leading:
                          Icon(Icons.add_box, color: Colors.green.shade700),
                      title: const Text('Insert Only'),
                      subtitle: const Text(
                          'Only new products will be added. Existing products will be skipped.'),
                      trailing: _selectedOption == false
                          ? Icon(Icons.check_circle,
                              color: Colors.green.shade700)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => setState(() => _selectedOption = true),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: _selectedOption == true
                          ? Colors.blue.shade100
                          : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _selectedOption == true
                            ? Colors.blue.shade700
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: ListTile(
                      leading: Icon(Icons.update, color: Colors.blue.shade700),
                      title: const Text('Insert & Update'),
                      subtitle: const Text(
                          'New products will be added, and existing products will be updated with the new data.'),
                      trailing: _selectedOption == true
                          ? Icon(Icons.check_circle,
                              color: Colors.blue.shade700)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Tip: Use "Insert & Update" if you want to refresh existing product details in bulk.',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedOption == null
              ? null
              : () => Navigator.of(context).pop(_selectedOption),
          icon: const Icon(Icons.check),
          label: const Text('Continue'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedOption == true
                ? Colors.blue.shade700
                : Colors.green.shade700,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            minimumSize: const Size(120, 44),
          ),
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int number;
  final bool selected;
  const _StepCircle({required this.number, required this.selected});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : Colors.grey.shade300,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade400,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
