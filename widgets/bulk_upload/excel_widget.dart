// lib/widgets/bulk_upload/excel_like_error_table.dart

import 'package:flutter/material.dart';

class ExcelLikeErrorTable extends StatefulWidget {
  final List<Map<String, dynamic>> rowErrors;

  const ExcelLikeErrorTable({
    Key? key,
    required this.rowErrors,
  }) : super(key: key);

  @override
  State<ExcelLikeErrorTable> createState() => _ExcelLikeErrorTableState();
}

class _ExcelLikeErrorTableState extends State<ExcelLikeErrorTable> {
  int? _selectedRowIndex;
  Map<String, dynamic>? _selectedRowData;
  List<Map<String, dynamic>>? _selectedRowErrors;
  final ScrollController _horizontalScrollController = ScrollController();
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rowErrors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              'No validation errors found',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    // Get all unique column names from all rows
    final Set<String> allColumns = {};
    for (final rowError in widget.rowErrors) {
      final rowData = rowError['data'] as Map<String, dynamic>?;
      if (rowData != null) {
        allColumns.addAll(rowData.keys);
      }
    }

    // Sort columns to ensure consistent order
    final List<String> sortedColumns = allColumns.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Excel-like table
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left panel: Row numbers and selection
              Container(
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                    top: BorderSide(color: Colors.grey.shade300),
                    left: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Column(
                  children: [
                    // Header cell
                    Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border(
                          bottom: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text(
                        'Row',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Row numbers
                    Expanded(
                      child: ListView.builder(
                        controller: _verticalScrollController,
                        itemCount: widget.rowErrors.length,
                        itemBuilder: (context, index) {
                          final rowError = widget.rowErrors[index];
                          final rowNum = rowError['row'];
                          final isSelected = _selectedRowIndex == index;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (_selectedRowIndex == index) {
                                  // Deselect if already selected
                                  _selectedRowIndex = null;
                                  _selectedRowData = null;
                                  _selectedRowErrors = null;
                                } else {
                                  // Select this row
                                  _selectedRowIndex = index;
                                  _selectedRowData =
                                      rowError['data'] as Map<String, dynamic>?;
                                  _selectedRowErrors =
                                      List<Map<String, dynamic>>.from(
                                          rowError['errors'] ?? []);
                                }
                              });
                            },
                            child: Container(
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade100
                                    : (index % 2 == 0
                                        ? Colors.white
                                        : Colors.grey.shade50),
                                border: Border(
                                  bottom:
                                      BorderSide(color: Colors.grey.shade300),
                                ),
                              ),
                              child: Text(
                                rowNum.toString(),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? Colors.blue.shade800
                                      : Colors.black,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Right panel: Scrollable data cells
              Expanded(
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: sortedColumns.length * 150, // Fixed width columns
                      child: Column(
                        children: [
                          // Header row
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border(
                                top: BorderSide(color: Colors.grey.shade300),
                                bottom: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: Row(
                              children: sortedColumns.map((column) {
                                return Container(
                                  width: 150,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Text(
                                    column,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Data rows
                          Expanded(
                            child: ListView.builder(
                              controller: _verticalScrollController,
                              itemCount: widget.rowErrors.length,
                              itemBuilder: (context, index) {
                                final rowError = widget.rowErrors[index];
                                final rowData =
                                    rowError['data'] as Map<String, dynamic>?;
                                final errors = List<Map<String, dynamic>>.from(
                                    rowError['errors'] ?? []);
                                final isSelected = _selectedRowIndex == index;

                                // Create a set of fields with errors
                                final Set<String> errorFields = {};
                                for (final error in errors) {
                                  final field =
                                      error['excel_field'] ?? error['field'];
                                  if (field != null) {
                                    errorFields.add(field.toString());
                                  }
                                }

                                return Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue.shade100
                                        : (index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey.shade50),
                                    border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Row(
                                    children: sortedColumns.map((column) {
                                      final hasError =
                                          errorFields.contains(column);
                                      final cellValue =
                                          rowData?[column]?.toString() ?? '';

                                      return Container(
                                        width: 150,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8),
                                        alignment: Alignment.centerLeft,
                                        decoration: BoxDecoration(
                                          color: hasError
                                              ? Colors.red.shade50
                                              : null,
                                          border: Border(
                                            right: BorderSide(
                                                color: Colors.grey.shade300),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                cellValue,
                                                style: TextStyle(
                                                  color: hasError
                                                      ? Colors.red.shade900
                                                      : null,
                                                  fontWeight: hasError
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (hasError)
                                              Tooltip(
                                                message:
                                                    _getErrorMessageForField(
                                                        errors, column),
                                                child: Icon(
                                                  Icons.error,
                                                  color: Colors.red.shade700,
                                                  size: 16,
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Error details panel (shown when a row is selected)
        if (_selectedRowIndex != null &&
            _selectedRowErrors != null &&
            _selectedRowErrors!.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Errors in Row ${widget.rowErrors[_selectedRowIndex!]['row']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.red),
                const SizedBox(height: 8),
                ...(_selectedRowErrors ?? []).map((error) {
                  final field =
                      error['excel_field'] ?? error['field'] ?? 'Unknown field';
                  final errorMessage = error['error'] ?? 'Unknown error';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          margin: const EdgeInsets.only(right: 8, top: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.priority_high,
                            color: Colors.red.shade900,
                            size: 12,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                errorMessage.toString(),
                                style: TextStyle(
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }

  String _getErrorMessageForField(
      List<Map<String, dynamic>> errors, String field) {
    for (final error in errors) {
      final errorField = error['excel_field'] ?? error['field'];
      if (errorField == field) {
        return error['error'] ?? 'Unknown error';
      }
    }
    return 'Unknown error';
  }
}
