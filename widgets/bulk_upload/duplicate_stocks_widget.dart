// lib/widgets/bulk_upload/duplicate_stocks_widget.dart

import 'package:flutter/material.dart';

class DuplicateStocksWidget extends StatefulWidget {
  final List<Map<String, dynamic>> duplicates;

  const DuplicateStocksWidget({
    Key? key,
    required this.duplicates,
  }) : super(key: key);

  @override
  State<DuplicateStocksWidget> createState() => _DuplicateStocksWidgetState();
}

class _DuplicateStocksWidgetState extends State<DuplicateStocksWidget>
    with SingleTickerProviderStateMixin {
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Duplicate Stock Numbers",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.orange.shade200),
            ),
            child: Column(
              children: [
                // Header with expand/collapse
                InkWell(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                      if (isExpanded) {
                        _animationController.forward();
                      } else {
                        _animationController.reverse();
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber,
                            color: Colors.orange.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Found ${widget.duplicates.length} duplicate stock numbers",
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            "${widget.duplicates.length} items",
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        RotationTransition(
                          turns:
                              Tween(begin: 0.0, end: 0.5).animate(_animation),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Expandable content
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: isExpanded
                      ? Column(
                          children: [
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                "The following stock numbers already exist in the database and cannot be imported:",
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                            _buildDuplicatesTable(),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuplicatesTable() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Row', flex: 1),
                _buildHeaderCell('Stock Number', flex: 2),
                _buildHeaderCell('Existing Product ID', flex: 3),
              ],
            ),
          ),

          // Table rows
          ...widget.duplicates.map((duplicate) {
            return Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.orange.shade200),
                ),
              ),
              child: Row(
                children: [
                  _buildCell(duplicate['row'].toString(), flex: 1),
                  _buildCell(duplicate['stock_number'] ?? '', flex: 2),
                  _buildCell(duplicate['existing_product_id'] ?? '', flex: 3),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, {required int flex}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(text),
      ),
    );
  }
}
