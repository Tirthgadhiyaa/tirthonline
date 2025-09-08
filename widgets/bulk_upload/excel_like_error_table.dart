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
  final ScrollController _pinnedVerticalScrollController = ScrollController();

  // Pinning state
  late Set<String> _pinnedColumns;

  @override
  void initState() {
    super.initState();
    // Get all unique columns
    final Set<String> allColumns = {};
    for (final rowError in widget.rowErrors) {
      final rowData = rowError['data'] as Map<String, dynamic>?;
      if (rowData != null) {
        allColumns.addAll(rowData.keys);
      }
    }
    // Pin 'Stock Number' by default if present
    _pinnedColumns = {};
    if (allColumns.contains('Stock Number')) {
      _pinnedColumns.add('Stock Number');
    }
    // Sync vertical scroll between pinned and unpinned
    _verticalScrollController.addListener(() {
      if (_pinnedVerticalScrollController.hasClients &&
          (_pinnedVerticalScrollController.offset !=
              _verticalScrollController.offset)) {
        _pinnedVerticalScrollController
            .jumpTo(_verticalScrollController.offset);
      }
    });
    _pinnedVerticalScrollController.addListener(() {
      if (_verticalScrollController.hasClients &&
          (_verticalScrollController.offset !=
              _pinnedVerticalScrollController.offset)) {
        _verticalScrollController
            .jumpTo(_pinnedVerticalScrollController.offset);
      }
    });
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    _verticalScrollController.dispose();
    _pinnedVerticalScrollController.dispose();
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
    final List<String> pinnedColumns =
        sortedColumns.where((c) => _pinnedColumns.contains(c)).toList();
    final List<String> unpinnedColumns =
        sortedColumns.where((c) => !_pinnedColumns.contains(c)).toList();

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
                        controller: _pinnedVerticalScrollController,
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

              // Pinned columns panel
              if (pinnedColumns.isNotEmpty)
                SizedBox(
                  width: pinnedColumns.length * 153.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      border: Border(
                        right: BorderSide(color: Colors.grey.shade300),
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Header row for pinned columns
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: pinnedColumns.map((column) {
                              return Container(
                                width: 152,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  border: Border(
                                    right:
                                        BorderSide(color: Colors.grey.shade300),
                                    bottom:
                                        BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      column,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _pinnedColumns.remove(column);
                                        });
                                      },
                                      child: const Icon(Icons.push_pin,
                                          size: 16, color: Colors.orange),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // Data rows for pinned columns
                        Expanded(
                          child: ListView.builder(
                            controller: _pinnedVerticalScrollController,
                            itemCount: widget.rowErrors.length,
                            itemBuilder: (context, index) {
                              final rowError = widget.rowErrors[index];
                              final rowData =
                                  rowError['data'] as Map<String, dynamic>?;
                              final errors = List<Map<String, dynamic>>.from(
                                  rowError['errors'] ?? []);
                              final isSelected = _selectedRowIndex == index;
                              final Set<String> errorFields = {};
                              for (final error in errors) {
                                final field =
                                    error['excel_field'] ?? error['field'];
                                if (field != null) {
                                  errorFields.add(field.toString());
                                }
                              }
                              return Row(
                                children: pinnedColumns.map((column) {
                                  final hasError = errorFields.contains(column);
                                  final cellValue =
                                      rowData?[column]?.toString() ?? '';
                                  return Container(
                                    width: 152,
                                    height: 40,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    alignment: Alignment.centerLeft,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue.shade100
                                          : (index % 2 == 0
                                              ? Colors.white
                                              : Colors.grey.shade50),
                                      border: Border(
                                        right: BorderSide(
                                            color: Colors.grey.shade300),
                                        bottom: BorderSide(
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
                                            message: _getErrorMessageForField(
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
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Right panel: Scrollable unpinned data cells
              Expanded(
                child: Scrollbar(
                  controller: _horizontalScrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalScrollController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: unpinnedColumns.length * 152,
                      child: Column(
                        children: [
                          // Header row for unpinned columns
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
                              children: unpinnedColumns.map((column) {
                                return Container(
                                  width: 150,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          column,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _pinnedColumns.add(column);
                                          });
                                        },
                                        child: const Icon(
                                            Icons.push_pin_outlined,
                                            size: 16,
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),

                          // Data rows for unpinned columns
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
                                    children: unpinnedColumns.map((column) {
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
