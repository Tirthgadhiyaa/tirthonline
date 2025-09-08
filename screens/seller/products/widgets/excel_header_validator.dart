// lib/screens/seller/products/widgets/excel_header_validator.dart

import 'dart:async';
import 'package:excel/excel.dart' as ex;
import 'package:flutter/foundation.dart';

class HeaderCheckResult {
  final bool valid;
  final List<String> missingHeaders;
  final List<String> extraHeaders;
  final String? error;

  HeaderCheckResult(
      {required this.valid,
      this.missingHeaders = const [],
      this.extraHeaders = const [],
      this.error});
}

class ExcelHeaderValidator {
  /// Validates Excel headers against required headers
  /// Returns a Future with HeaderCheckResult
  static Future<HeaderCheckResult> validateHeaders(
    Uint8List fileBytes,
    List<String> requiredHeaders,
  ) async {
    // For web, we'll use a different approach to avoid freezing the UI
    if (kIsWeb) {
      return _validateHeadersForWeb(fileBytes, requiredHeaders);
    } else {
      // For non-web platforms, we can still use compute
      try {
        return await compute(_validateHeadersInIsolate, {
          'fileBytes': fileBytes,
          'requiredHeaders': requiredHeaders,
        });
      } catch (e) {
        return HeaderCheckResult(
          valid: false,
          error: 'Error validating headers: $e',
        );
      }
    }
  }

  /// Web-friendly validation that doesn't block the UI thread
  static Future<HeaderCheckResult> _validateHeadersForWeb(
    Uint8List fileBytes,
    List<String> requiredHeaders,
  ) async {
    // Create a completer to resolve when processing is done
    final completer = Completer<HeaderCheckResult>();

    // Use Future.delayed to give the UI thread a chance to update
    Future.delayed(Duration.zero, () async {
      try {
        // Step 1: Decode the Excel file
        ex.Excel? excel;
        try {
          excel = ex.Excel.decodeBytes(fileBytes);
        } catch (e) {
          completer.complete(HeaderCheckResult(
            valid: false,
            error: 'Could not decode Excel file: $e',
          ));
          return;
        }

        // Allow UI to update
        await Future.delayed(const Duration(milliseconds: 50));

        // Step 2: Check if there are any sheets
        if (excel.tables.isEmpty) {
          completer.complete(HeaderCheckResult(
            valid: false,
            error: 'No sheets found in Excel file.',
          ));
          return;
        }

        // Step 3: Get the first sheet
        final table = excel.tables.values.first;
        if (table.maxRows == 0) {
          completer.complete(HeaderCheckResult(
            valid: false,
            error: 'Excel file is empty.',
          ));
          return;
        }

        // Allow UI to update
        await Future.delayed(const Duration(milliseconds: 50));

        // Step 4: Get the headers
        final firstRow = table.rows.first;
        if (firstRow.isEmpty) {
          completer.complete(HeaderCheckResult(
            valid: false,
            error: 'Header row is empty.',
          ));
          return;
        }

        // Step 5: Extract header names
        final List<String> fileHeaders = [];
        for (var cell in firstRow) {
          if (cell != null && cell.value != null) {
            final headerValue = cell.value.toString().trim();
            if (headerValue.isNotEmpty) {
              fileHeaders.add(headerValue);
            }
          }
        }

        if (fileHeaders.isEmpty) {
          completer.complete(HeaderCheckResult(
            valid: false,
            error: 'No valid headers found in the file.',
          ));
          return;
        }

        // Allow UI to update
        await Future.delayed(const Duration(milliseconds: 50));

        // Step 6: Find missing and extra headers
        final missing =
            requiredHeaders.where((h) => !fileHeaders.contains(h)).toList();

        final extra =
            fileHeaders.where((h) => !requiredHeaders.contains(h)).toList();

        if (missing.isNotEmpty || extra.isNotEmpty) {
          completer.complete(HeaderCheckResult(
            valid: false,
            missingHeaders: missing,
            extraHeaders: extra,
          ));
          return;
        }

        // All checks passed
        completer.complete(HeaderCheckResult(valid: true));
      } catch (e) {
        completer.complete(HeaderCheckResult(
          valid: false,
          error: 'Could not read the Excel file.\n\nError: $e',
        ));
      }
    });

    return completer.future;
  }

  /// Internal method to be run in isolate (for non-web platforms)
  static HeaderCheckResult _validateHeadersInIsolate(
      Map<String, dynamic> params) {
    final Uint8List fileBytes = params['fileBytes'];
    final List<String> requiredHeaders = params['requiredHeaders'];

    try {
      final excel = ex.Excel.decodeBytes(fileBytes);
      if (excel.tables.isEmpty) {
        return HeaderCheckResult(
            valid: false, error: 'No sheets found in Excel file.');
      }

      final table = excel.tables.values.first;
      if (table.maxRows == 0) {
        return HeaderCheckResult(valid: false, error: 'Excel file is empty.');
      }

      // Get the first row (headers)
      final firstRow = table.rows.first;
      if (firstRow.isEmpty) {
        return HeaderCheckResult(valid: false, error: 'Header row is empty.');
      }

      // Extract header names, handling null values
      final List<String> fileHeaders = [];
      for (var cell in firstRow) {
        if (cell != null && cell.value != null) {
          final headerValue = cell.value.toString().trim();
          if (headerValue.isNotEmpty) {
            fileHeaders.add(headerValue);
          }
        }
      }

      if (fileHeaders.isEmpty) {
        return HeaderCheckResult(
            valid: false, error: 'No valid headers found in the file.');
      }

      // Find missing and extra headers
      final missing =
          requiredHeaders.where((h) => !fileHeaders.contains(h)).toList();

      final extra =
          fileHeaders.where((h) => !requiredHeaders.contains(h)).toList();

      if (missing.isNotEmpty || extra.isNotEmpty) {
        return HeaderCheckResult(
            valid: false, missingHeaders: missing, extraHeaders: extra);
      }

      return HeaderCheckResult(valid: true);
    } catch (e) {
      return HeaderCheckResult(
          valid: false, error: 'Could not read the Excel file.\n\nError: $e');
    }
  }
}
