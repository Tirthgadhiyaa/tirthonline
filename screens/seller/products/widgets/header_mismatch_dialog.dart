// lib/screens/seller/products/widgets/header_mismatch_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_saver/file_saver.dart';

class HeaderMismatchDialog extends StatefulWidget {
  final List<String> missingHeaders;
  final List<String> extraHeaders;
  final List<String> requiredHeaders;

  const HeaderMismatchDialog({
    Key? key,
    required this.missingHeaders,
    required this.extraHeaders,
    required this.requiredHeaders,
  }) : super(key: key);

  @override
  State<HeaderMismatchDialog> createState() => _HeaderMismatchDialogState();
}

class _HeaderMismatchDialogState extends State<HeaderMismatchDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showSampleHeaders = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header section with gradient background
            _buildHeader(),
            
            // Tab bar
            _buildTabBar(),
            
            // Tab content
            _buildTabContent(),
            
            // Divider
            Divider(height: 1, color: Colors.grey.shade300),
            
            // Help section
            _buildHelpSection(),
            
            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade300, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Excel Header Mismatch',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your file has header issues that need to be fixed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.orange.shade50,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.orange.shade900,
        unselectedLabelColor: Colors.grey.shade700,
        indicatorColor: Colors.orange.shade700,
        tabs: [
          Tab(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline,
                    color: widget.missingHeaders.isNotEmpty
                        ? Colors.red
                        : Colors.grey),
                const SizedBox(width: 8),
                Text('Missing (${widget.missingHeaders.length})'),
              ],
            ),
          ),
          Tab(
            icon: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_circle_outline,
                    color: widget.extraHeaders.isNotEmpty
                        ? Colors.orange
                        : Colors.grey),
                const SizedBox(width: 8),
                Text('Extra (${widget.extraHeaders.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return SizedBox(
      height: 250,
      child: TabBarView(
        controller: _tabController,
        children: [
          // Missing headers tab
          _buildMissingHeadersTab(),

          // Extra headers tab
          _buildExtraHeadersTab(),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.blue.shade50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  _showSampleHeaders = !_showSampleHeaders;
                });
              },
              child: Row(
                children: [
                  Icon(
                    _showSampleHeaders
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Required Headers Reference',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ],
              ),
            ),
            if (_showSampleHeaders) ...[
              const SizedBox(height: 12),
              Container(
                height: 120,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.requiredHeaders
                        .map((header) => Chip(
                              label: Text(header,
                                  style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.blue.shade100,
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton.icon(
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
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.download),
            label: const Text('Download Template'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingHeadersTab() {
    if (widget.missingHeaders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 16),
            const Text(
              'All required headers are present!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'These required headers are missing from your file. Please add them exactly as shown.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Missing Headers:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.missingHeaders.length,
            itemBuilder: (context, index) {
              final header = widget.missingHeaders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.red.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.red.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                  title: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Required header'),
                  trailing: Icon(Icons.warning, color: Colors.red.shade700),
                ),
              );
            },
          ),
          const SizedBox(height : 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tip: Headers are case-sensitive. Make sure they match exactly as shown in the template.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraHeadersTab() {
    if (widget.extraHeaders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              'No extra headers found!',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'These extra headers were found in your file. They will be ignored during import.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Extra Headers:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.extraHeaders.length,
            itemBuilder: (context, index) {
              final header = widget.extraHeaders[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: Colors.orange.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.orange.shade200),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange.shade100,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.orange.shade900),
                    ),
                  ),
                  title: Text(
                    header,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Unknown header'),
                  trailing: Icon(Icons.info, color: Colors.orange.shade700),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Tip: Remove extra columns or rename them to match the required headers if they contain important data.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
