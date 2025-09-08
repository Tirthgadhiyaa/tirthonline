// lib/widgets/bulk_upload/error_card_widget.dart

import 'package:flutter/material.dart';

class ErrorCardWidget extends StatefulWidget {
  final Map<String, dynamic> rowError;

  const ErrorCardWidget({
    Key? key,
    required this.rowError,
  }) : super(key: key);

  @override
  State<ErrorCardWidget> createState() => _ErrorCardWidgetState();
}

class _ErrorCardWidgetState extends State<ErrorCardWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rowNum = widget.rowError['row'];
    final errors =
        List<Map<String, dynamic>>.from(widget.rowError['errors'] ?? []);
    final rowData = widget.rowError['data'] as Map<String, dynamic>?;
    final stockNumber = rowData?['Stock Number'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      "Row $rowNum",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (stockNumber.isNotEmpty)
                    Text(
                      "Stock: $stockNumber",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${errors.length} ${errors.length == 1 ? 'Error' : 'Errors'}",
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.red.shade800,
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

                      // Tab bar
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.red.shade800,
                        unselectedLabelColor: Colors.grey.shade700,
                        indicatorColor: Colors.red.shade800,
                        tabs: const [
                          Tab(text: "Errors"),
                          Tab(text: "Row Data"),
                        ],
                      ),

                      // Tab content
                      SizedBox(
                        height: 250, // Fixed height for tab content
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Errors tab
                            _buildErrorsTab(errors),

                            // Row data tab
                            _buildRowDataTab(rowData, errors),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorsTab(List<Map<String, dynamic>> errors) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.separated(
        itemCount: errors.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final error = errors[index];
          final fieldName = error['excel_field'] ?? error['field'] ?? 'Field';
          final errorMessage = error['error'] ?? 'Unknown error';

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${index + 1}",
                  style: TextStyle(
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fieldName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRowDataTab(
      Map<String, dynamic>? rowData, List<Map<String, dynamic>> errors) {
    if (rowData == null) {
      return const Center(child: Text("No row data available"));
    }

    // Create a list of field names that have errors
    final errorFields =
        errors.map((e) => e['excel_field'] ?? e['field']).toSet();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Interactive table visualization
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: rowData.entries.map((entry) {
                  final hasError = errorFields.contains(entry.key);

                  return Container(
                    decoration: BoxDecoration(
                      color: hasError ? Colors.red.shade50 : null,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Field name
                        Container(
                          width: 150,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            color: hasError
                                ? Colors.red.shade100
                                : Colors.grey.shade50,
                          ),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: hasError ? Colors.red.shade800 : null,
                            ),
                          ),
                        ),

                        // Field value
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              entry.value?.toString() ?? '',
                              style: TextStyle(
                                color: hasError ? Colors.red.shade800 : null,
                              ),
                            ),
                          ),
                        ),

                        // Error indicator
                        if (hasError)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Tooltip(
                              message: "This field has an error",
                              child: Icon(
                                Icons.error,
                                color: Colors.red.shade800,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
