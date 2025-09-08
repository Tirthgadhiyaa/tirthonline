// lib/widgets/bulk_upload/excel_export_service.dart

import 'dart:html' as html;
import 'package:excel/excel.dart';

class ExcelExportService {
  static Future<void> exportErrorsToExcel({
    required List<Map<String, dynamic>> rowErrors,
    required List<Map<String, dynamic>> duplicateStocks,
    required String summary,
  }) async {
    try {
      final excel = Excel.createExcel();
      // Remove the default sheet
      final defaultSheet = excel.sheets.keys.first;
      excel.delete(defaultSheet);

      // Create sheets
      final errorSheet = excel["Validation Errors"];
      final duplicateSheet = excel['Duplicate Stocks'];
      final summarySheet = excel['Summary'];
      // Add summary information
      _createSummarySheet(
          summarySheet, summary, rowErrors.length, duplicateStocks.length);

      // Add validation errors
      _createErrorSheet(errorSheet, rowErrors);

      // Add duplicate stocks
      _createDuplicateSheet(duplicateSheet, duplicateStocks);

      // Convert to bytes
      final bytes = excel.encode();

      if (bytes != null) {
        // Create a blob and download
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download',
              'Import_Errors_${DateTime.now().millisecondsSinceEpoch}.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      print('Error exporting to Excel: $e');
      rethrow; // Rethrow to allow caller to handle the error
    }
  }

  /// Exports only the error rows' data as a clean Excel file for correction and re-upload
  static Future<void> exportCleanErrorSheet({
    required List<Map<String, dynamic>> rowErrors,
  }) async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Clean Error Sheet'];

      if (rowErrors.isEmpty) {
        sheet.cell(CellIndex.indexByString('A1')).value =
            sanitizeCellValue('No error rows');
      } else {
        // Get all unique columns from all error rows
        final Set<String> allColumns = {};
        for (final rowError in rowErrors) {
          final rowData = rowError['data'] as Map<String, dynamic>?;
          if (rowData != null) {
            allColumns.addAll(rowData.keys);
          }
        }
        final List<String> sortedColumns = allColumns.toList()..sort();

        // Write header row with style
        for (int i = 0; i < sortedColumns.length; i++) {
          final colLetter = _getColumnLetter(i);
          final cell = sheet.cell(CellIndex.indexByString('${colLetter}1'));
          cell.value = sanitizeCellValue(sortedColumns[i]);
          cell.cellStyle = CellStyle(
            bold: true,
            fontSize: 12,
            backgroundColorHex: '#D9E1F2', // light blue
            horizontalAlign: HorizontalAlign.Center,
          );
        }

        // Write data rows with alternating colors
        for (int rowIndex = 0; rowIndex < rowErrors.length; rowIndex++) {
          final rowData = rowErrors[rowIndex]['data'] as Map<String, dynamic>?;
          if (rowData != null) {
            final isEven = rowIndex % 2 == 0;
            final bgColor = isEven ? '#FFFFFF' : '#F2F2F2'; // white/gray
            for (int colIndex = 0;
                colIndex < sortedColumns.length;
                colIndex++) {
              final colLetter = _getColumnLetter(colIndex);
              final value = rowData[sortedColumns[colIndex]];
              final cell = sheet
                  .cell(CellIndex.indexByString('${colLetter}${rowIndex + 2}'));
              cell.value = sanitizeCellValue(value);
              cell.cellStyle = CellStyle(
                backgroundColorHex: bgColor,
                horizontalAlign: HorizontalAlign.Center,
              );
            }
          }
        }

        // Set a reasonable column width for all columns (if supported)
        // (This is a no-op in some versions of the package, but harmless)
        try {
          for (int i = 0; i < sortedColumns.length; i++) {
            sheet.setColWidth(i, 20);
          }
        } catch (e) {
          // ignore if not supported
        }
      }

      // Save and download
      final bytes = excel.encode();
      if (bytes != null) {
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download',
              'Clean_Error_Sheet_${DateTime.now().millisecondsSinceEpoch}.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      }
    } catch (e) {
      print('Error exporting clean error sheet: $e');
      rethrow;
    }
  }

  /// Sanitizes cell values to ensure they can be properly stored in Excel
  static dynamic sanitizeCellValue(dynamic value) {
    if (value == null) return '';
    if (value is num) {
      if (value is double &&
          (value.isNaN ||
              value == double.infinity ||
              value == -double.infinity)) {
        return '';
      }
      return value;
    }
    if (value is String || value is bool || value is DateTime)
      return value.toString();
    return value.toString();
  }

  static void _createSummarySheet(
    Sheet sheet,
    String summary,
    int errorCount,
    int duplicateCount,
  ) {
    try {
      // Add title with styling
      final titleCell = sheet.cell(CellIndex.indexByString('A1'));
      titleCell.value = sanitizeCellValue('Import Summary');
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
        fontColorHex: '#000000',
      );

      // Merge cells for title
      sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('C1'));

      // Add summary text
      final summaryCell = sheet.cell(CellIndex.indexByString('A2'));
      summaryCell.value = sanitizeCellValue(summary);
      sheet.merge(CellIndex.indexByString('A2'), CellIndex.indexByString('C2'));

      // Add section header
      sheet.cell(CellIndex.indexByString('A4')).value =
          sanitizeCellValue('Error Statistics');
      sheet.cell(CellIndex.indexByString('A4')).cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
        fontColorHex: '#000000',
        backgroundColorHex: '#E0E0E0',
      );
      sheet.merge(CellIndex.indexByString('A4'), CellIndex.indexByString('C4'));

      // Add error counts table header
      sheet.cell(CellIndex.indexByString('A5')).value =
          sanitizeCellValue('Error Type');
      sheet.cell(CellIndex.indexByString('B5')).value =
          sanitizeCellValue('Count');
      sheet.cell(CellIndex.indexByString('C5')).value =
          sanitizeCellValue('Percentage');

      sheet.cell(CellIndex.indexByString('A5')).cellStyle =
          CellStyle(bold: true, backgroundColorHex: '#F0F0F0');
      sheet.cell(CellIndex.indexByString('B5')).cellStyle =
          CellStyle(bold: true, backgroundColorHex: '#F0F0F0');
      sheet.cell(CellIndex.indexByString('C5')).cellStyle =
          CellStyle(bold: true, backgroundColorHex: '#F0F0F0');

      // Calculate total errors
      final totalErrors = errorCount + duplicateCount;
      final errorPercentage = totalErrors > 0
          ? (errorCount / totalErrors * 100).toStringAsFixed(1) + '%'
          : '0%';
      final duplicatePercentage = totalErrors > 0
          ? (duplicateCount / totalErrors * 100).toStringAsFixed(1) + '%'
          : '0%';

      // Add validation errors row
      sheet.cell(CellIndex.indexByString('A6')).value =
          sanitizeCellValue('Validation Errors');
      sheet.cell(CellIndex.indexByString('B6')).value =
          sanitizeCellValue(errorCount);
      sheet.cell(CellIndex.indexByString('C6')).value =
          sanitizeCellValue(errorPercentage);

      // Add duplicate stocks row
      sheet.cell(CellIndex.indexByString('A7')).value =
          sanitizeCellValue('Duplicate Stocks');
      sheet.cell(CellIndex.indexByString('B7')).value =
          sanitizeCellValue(duplicateCount);
      sheet.cell(CellIndex.indexByString('C7')).value =
          sanitizeCellValue(duplicatePercentage);

      // Add total row
      sheet.cell(CellIndex.indexByString('A8')).value =
          sanitizeCellValue('Total');
      sheet.cell(CellIndex.indexByString('B8')).value =
          sanitizeCellValue(totalErrors);
      sheet.cell(CellIndex.indexByString('C8')).value =
          sanitizeCellValue('100%');

      sheet.cell(CellIndex.indexByString('A8')).cellStyle =
          CellStyle(bold: true);
      sheet.cell(CellIndex.indexByString('B8')).cellStyle =
          CellStyle(bold: true);
      sheet.cell(CellIndex.indexByString('C8')).cellStyle =
          CellStyle(bold: true);

      // Add timestamp
      sheet.cell(CellIndex.indexByString('A10')).value =
          sanitizeCellValue('Report Generated:');
      sheet.cell(CellIndex.indexByString('B10')).value =
          sanitizeCellValue(DateTime.now().toString().substring(0, 19));
      sheet.merge(
          CellIndex.indexByString('B10'), CellIndex.indexByString('C10'));

      // Column width setting is not supported by the excel package and is commented out.
    } catch (e) {
      print('Error creating summary sheet: $e');
      // Create a simple summary if the detailed one fails
      sheet.cell(CellIndex.indexByString('A1')).value =
          sanitizeCellValue('Import Summary');
      sheet.cell(CellIndex.indexByString('A2')).value =
          sanitizeCellValue(summary);
      sheet.cell(CellIndex.indexByString('A3')).value =
          sanitizeCellValue('Validation Errors: $errorCount');
      sheet.cell(CellIndex.indexByString('A4')).value =
          sanitizeCellValue('Duplicate Stocks: $duplicateCount');
    }
  }

  static void _createErrorSheet(
      Sheet sheet, List<Map<String, dynamic>> rowErrors) {
    if (rowErrors.isEmpty) {
      sheet.cell(CellIndex.indexByString('A1')).value =
          sanitizeCellValue('No validation errors found');
      return;
    }

    try {
      // Get all unique column names from all rows
      final Set<String> allColumns = {};
      for (final rowError in rowErrors) {
        final rowData = rowError['data'] as Map<String, dynamic>?;
        if (rowData != null) {
          allColumns.addAll(rowData.keys);
        }
      }

      // Sort columns to ensure consistent order
      final List<String> sortedColumns = allColumns.toList()..sort();

      // Create header row
      sheet.cell(CellIndex.indexByString('A1')).value =
          sanitizeCellValue('Row');
      sheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#DDDDDD',
      );

      // Add column headers
      for (int i = 0; i < sortedColumns.length; i++) {
        final colLetter = _getColumnLetter(i + 1); // B, C, D, etc.
        sheet.cell(CellIndex.indexByString('${colLetter}1')).value =
            sanitizeCellValue(sortedColumns[i]);
        sheet.cell(CellIndex.indexByString('${colLetter}1')).cellStyle =
            CellStyle(
          bold: true,
          backgroundColorHex: '#DDDDDD',
        );
      }

      // Add error column
      final errorColLetter = _getColumnLetter(sortedColumns.length + 1);
      sheet.cell(CellIndex.indexByString('${errorColLetter}1')).value =
          sanitizeCellValue('Errors');
      sheet.cell(CellIndex.indexByString('${errorColLetter}1')).cellStyle =
          CellStyle(
        bold: true,
        backgroundColorHex: '#FFCCCC',
      );

      // Add data rows
      for (int rowIndex = 0; rowIndex < rowErrors.length; rowIndex++) {
        final rowError = rowErrors[rowIndex];
        final rowNum = rowError['row'];
        final rowData = rowError['data'] as Map<String, dynamic>?;
        final errors =
            List<Map<String, dynamic>>.from(rowError['errors'] ?? []);

        // Create a set of fields with errors
        final Map<String, String> errorFieldMessages = {};
        for (final error in errors) {
          final field = error['excel_field'] ?? error['field'];
          final errorMsg = error['error'] ?? 'Unknown error';
          if (field != null) {
            errorFieldMessages[field.toString()] = errorMsg.toString();
          }
        }

        // Add row number
        sheet.cell(CellIndex.indexByString('A${rowIndex + 2}')).value =
            sanitizeCellValue(rowNum);

        // Add data cells
        for (int colIndex = 0; colIndex < sortedColumns.length; colIndex++) {
          final column = sortedColumns[colIndex];
          final colLetter = _getColumnLetter(colIndex + 1);
          final cellValue = rowData?[column];
          final hasError = errorFieldMessages.containsKey(column);

          sheet
              .cell(CellIndex.indexByString('${colLetter}${rowIndex + 2}'))
              .value = sanitizeCellValue(cellValue);

          if (hasError) {
            sheet
                .cell(CellIndex.indexByString('${colLetter}${rowIndex + 2}'))
                .cellStyle = CellStyle(
              backgroundColorHex: '#FFCCCC',
              bold: true,
            );
          }
        }

        // Add error messages
        final errorColLetter = _getColumnLetter(sortedColumns.length + 1);
        final errorMessages = errors.map((e) {
          final field = e['excel_field'] ?? e['field'] ?? 'Unknown';
          final message = e['error'] ?? 'Unknown error';
          return '$field: $message';
        }).join('\n');

        sheet
            .cell(CellIndex.indexByString('${errorColLetter}${rowIndex + 2}'))
            .value = sanitizeCellValue(errorMessages);
        sheet
            .cell(CellIndex.indexByString('${errorColLetter}${rowIndex + 2}'))
            .cellStyle = CellStyle(
          backgroundColorHex: '#FFCCCC',
        );
      }

      // Column width setting is not supported by the excel package and is commented out.
    } catch (e) {
      print('Error creating error sheet: $e');
      // Create a simple error sheet if the detailed one fails
      sheet.cell(CellIndex.indexByString('A1')).value =
          sanitizeCellValue('Validation Errors');

      for (int i = 0; i < rowErrors.length; i++) {
        final rowError = rowErrors[i];
        final rowNum = rowError['row'];
        final errors =
            List<Map<String, dynamic>>.from(rowError['errors'] ?? []);

        sheet.cell(CellIndex.indexByString('A${i + 2}')).value =
            sanitizeCellValue('Row $rowNum:');

        final errorMessages = errors.map((e) {
          final field = e['excel_field'] ?? e['field'] ?? 'Unknown';
          final message = e['error'] ?? 'Unknown error';
          return '$field: $message';
        }).join('; ');

        sheet.cell(CellIndex.indexByString('B${i + 2}')).value =
            sanitizeCellValue(errorMessages);
      }
    }
  }

  static void _createDuplicateSheet(
      Sheet sheet, List<Map<String, dynamic>> duplicateStocks) {
    if (duplicateStocks.isEmpty) {
      sheet.cell(CellIndex.indexByString('A1')).value =
          sanitizeCellValue('No duplicate stocks found');
      return;
    }

    try {
      // Create header row
      sheet.cell(CellIndex.indexByString('A1')).value =
          sanitizeCellValue('Row');
      sheet.cell(CellIndex.indexByString('B1')).value =
          sanitizeCellValue('Stock Number');
      sheet.cell(CellIndex.indexByString('C1')).value =
          sanitizeCellValue('Existing Product ID');

      sheet.cell(CellIndex.indexByString('A1')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#FFEECC',
      );
      sheet.cell(CellIndex.indexByString('B1')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#FFEECC',
      );
      sheet.cell(CellIndex.indexByString('C1')).cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: '#FFEECC',
      );

      // Add data rows
      for (int i = 0; i < duplicateStocks.length; i++) {
        final duplicate = duplicateStocks[i];

        sheet.cell(CellIndex.indexByString('A${i + 2}')).value =
            sanitizeCellValue(duplicate['row']);
        sheet.cell(CellIndex.indexByString('B${i + 2}')).value =
            sanitizeCellValue(duplicate['stock_number'] ?? '');
        sheet.cell(CellIndex.indexByString('C${i + 2}')).value =
            sanitizeCellValue(duplicate['existing_product_id'] ?? '');

        // Highlight stock number
        sheet.cell(CellIndex.indexByString('B${i + 2}')).cellStyle = CellStyle(
          backgroundColorHex: '#FFEECC',
          bold: true,
        );
      }

      // Column width setting is not supported by the excel package and is commented out.
    } catch (e) {
      print('Error creating duplicate sheet: $e');
      // Create a simple duplicate sheet if the detailed one fails
      sheet.cell(CellIndex.indexByString('A1')).value =
          sanitizeCellValue('Duplicate Stocks');

      for (int i = 0; i < duplicateStocks.length; i++) {
        final duplicate = duplicateStocks[i];
        sheet.cell(CellIndex.indexByString('A${i + 2}')).value = sanitizeCellValue(
            'Row ${duplicate['row']}: ${duplicate['stock_number'] ?? ''} (ID: ${duplicate['existing_product_id'] ?? ''})');
      }
    }
  }

  /// Helper method to convert column index to Excel column letter
  static String _getColumnLetter(int columnIndex) {
    // Handle columns beyond Z (AA, AB, etc.)
    if (columnIndex < 26) {
      return String.fromCharCode('A'.codeUnitAt(0) + columnIndex);
    } else {
      final firstChar =
          String.fromCharCode('A'.codeUnitAt(0) + (columnIndex ~/ 26) - 1);
      final secondChar =
          String.fromCharCode('A'.codeUnitAt(0) + (columnIndex % 26));
      return '$firstChar$secondChar';
    }
  }
}
