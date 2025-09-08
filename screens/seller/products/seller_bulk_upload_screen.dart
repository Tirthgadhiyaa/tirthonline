// lib/screens/seller/products/seller_bulk_upload_screen.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:jewellery_diamond/bloc/seller_product_bloc/seller_product_bloc.dart';
import 'package:jewellery_diamond/bloc/seller_product_bloc/seller_product_event.dart';
import 'package:jewellery_diamond/widgets/drag_drop_upload.dart';
import 'package:jewellery_diamond/widgets/loading_overlay.dart';
import 'package:jewellery_diamond/widgets/web_loading_overlay.dart';
import 'dart:html' as html;
import 'dart:typed_data';

import '../../../bloc/seller_product_bloc/seller_product_state.dart';
import '../../../widgets/bulk_upload/error_dialog_widget.dart';
import '../../../widgets/bulk_upload/instructions_card_widget.dart';
import '../../../widgets/bulk_upload/upload_card_widget.dart';
import '../../../widgets/bulk_upload/selected_file_card_widget.dart';
import 'widgets/bulk_upload_options_dialog.dart';
import 'widgets/header_mismatch_dialog.dart';
import 'widgets/excel_header_validator.dart';

class SellerBulkUploadScreen extends StatefulWidget {
  const SellerBulkUploadScreen({super.key});

  @override
  State<SellerBulkUploadScreen> createState() => _SellerBulkUploadScreenState();
}

class _SellerBulkUploadScreenState extends State<SellerBulkUploadScreen> {
  html.File? selectedFile;
  Uint8List? selectedFileBytes;
  bool isUploading = false;
  bool isValidatingHeaders = false;
  final GlobalKey<UploadSectionState> _uploadKey =
      GlobalKey<UploadSectionState>();

  // Data structures for error display
  List<Map<String, dynamic>> rowErrors = [];
  List<Map<String, dynamic>> duplicateStocks = [];
  String importSummary = "";
  Map<String, dynamic> errorData = {};

  // Required headers list
  final List<String> requiredHeaders = [
    'Sr',
    'Stock Number',
    'Location',
    'Lab',
    'Report Number',
    'Shape',
    'Weight',
    'Price',
    'Rapa',
    'Color',
    'Fancy Color',
    'Fancy Color Intensity',
    'Clarity',
    'CUT',
    'Polish',
    'Sym',
    'Disc%',
    'Length',
    'Width',
    'Height',
    'Table',
    'Crown H.',
    'P.Depth',
    'Depth %',
    'C.Angle',
    'P.Angle',
    'Culet',
    'Girdle %',
    'Ratio',
    'Treatment',
    'Eye Clean',
    'Shade',
    'Fluo.',
    'Transparency',
    'Girdle',
    'Decription',
    'CERTIFICATE LINK',
    'Video',
    'IMAGE'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    Widget content = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            _buildHeader(),

            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 900;
                return isWideScreen
                    ? _buildWideLayout(primaryColor)
                    : _buildNarrowLayout(primaryColor);
              },
            ),

            // Selected file status section
            if (selectedFile != null)
              SelectedFileCard(
                fileName: selectedFile!.name,
                isUploading: isUploading,
                loadingText: isUploading
                    ? 'Processing upload...'
                    : 'Process Bulk Upload',
                onRemove: () {
                  if (mounted) {
                    setState(() {
                      selectedFile = null;
                      selectedFileBytes = null;
                      rowErrors = [];
                      duplicateStocks = [];
                      importSummary = "";
                      errorData = {};
                    });
                    _uploadKey.currentState?.clearAll();
                  }
                },
                onUpload: () => _handleUpload(),
              ),

            // BlocConsumer for handling validation errors
            BlocConsumer<SellerProductBloc, SellerProductState>(
              listener: (context, state) {
                _handleBlocState(state);
              },
              builder: (context, state) {
                return const SizedBox
                    .shrink(); // We'll show errors in a dialog instead
              },
            )
          ],
        ),
      ),
    );

    // Use the appropriate loading overlay based on platform
    if (kIsWeb) {
      return WebLoadingOverlay(
        isLoading: isValidatingHeaders,
        message: 'Validating Excel headers...',
        child: content,
      );
    } else {
      return LoadingOverlay(
        isLoading: isValidatingHeaders,
        message: 'Validating Excel headers...',
        child: content,
      );
    }
  }

  Future<void> _handleUpload() async {
    if (!mounted) return;

    // Set loading state first
    setState(() {
      isValidatingHeaders = true;
    });

    try {
      // Validate headers
      final headerResult = await ExcelHeaderValidator.validateHeaders(
        selectedFileBytes!,
        requiredHeaders,
      );

      if (!mounted) return;

      setState(() {
        isValidatingHeaders = false;
      });

      if (!headerResult.valid) {
        if (headerResult.error != null) {
          await _showErrorDialog(headerResult.error!);
        } else {
          await showDialog(
            context: context,
            builder: (context) => HeaderMismatchDialog(
              missingHeaders: headerResult.missingHeaders,
              extraHeaders: headerResult.extraHeaders,
              requiredHeaders: requiredHeaders,
            ),
          );
        }
        return;
      }

      // Show upload options dialog
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => const BulkUploadOptionsDialog(),
      );

      if (result != null && mounted) {
        setState(() {
          isUploading = true;
          rowErrors = [];
          duplicateStocks = [];
          importSummary = "";
          errorData = {};
        });

        try {
          context.read<SellerProductBloc>().add(
                BulkUploadSellerProducts(
                  file: selectedFileBytes!,
                  fileName: selectedFile!.name,
                  updateExisting: result,
                ),
              );
        } catch (e) {
          _showErrorSnackBar('Error: $e');
          if (mounted) {
            setState(() {
              isUploading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isValidatingHeaders = false;
        });
        _showErrorSnackBar('Error validating file: $e');
      }
    }
  }

  Future<void> _showErrorDialog(String message) {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Excel Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleBlocState(SellerProductState state) {
    if (!mounted) return;

    if (state is SellerProductUploadValidationError) {
      setState(() {
        isUploading = false;
        errorData = state.errorData;

        // Set import summary
        importSummary =
            "Import completed with ${errorData['imported'] ?? 0} products imported, "
            "${errorData['updated'] ?? 0} products updated, "
            "${errorData['failed'] ?? 0} products failed.";

        // Extract row errors
        if (errorData.containsKey('errors')) {
          rowErrors = List<Map<String, dynamic>>.from(errorData['errors']);
        }

        // Extract duplicate stocks
        if (errorData.containsKey('duplicate_stocks')) {
          duplicateStocks =
              List<Map<String, dynamic>>.from(errorData['duplicate_stocks']);
        }
      });

      // Show the error dialog
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ErrorDialogWidget(
            errorData: errorData,
            summary: importSummary,
            rowErrors: rowErrors,
            duplicateStocks: duplicateStocks,
          ),
        );
      });
    } else if (state is SellerProductEditSuccess) {
      setState(() {
        isUploading = false;
        selectedFile = null;
        selectedFileBytes = null;
        rowErrors = [];
        duplicateStocks = [];
        importSummary = "";
        errorData = {};
      });

      if (_uploadKey.currentState != null) {
        _uploadKey.currentState!.clearAll();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is SellerProductError) {
      setState(() {
        isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bulk Upload Products',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload multiple diamond products at once using Excel',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideLayout(Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - Instructions
        Expanded(
          flex: 4,
          child: InstructionsCardWidget(primaryColor: primaryColor),
        ),
        const SizedBox(width: 24),
        // Right panel - Upload
        Expanded(
          flex: 6,
          child: UploadCardWidget(
            primaryColor: primaryColor,
            uploadKey: _uploadKey,
            onFilesSelected: _handleFileSelection,
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(Color primaryColor) {
    return Column(
      children: [
        InstructionsCardWidget(primaryColor: primaryColor),
        const SizedBox(height: 24),
        UploadCardWidget(
          primaryColor: primaryColor,
          uploadKey: _uploadKey,
          onFilesSelected: _handleFileSelection,
        ),
      ],
    );
  }

  void _handleFileSelection(List<html.File> files) async {
    if (files.isNotEmpty && mounted) {
      final file = files.first;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);

      try {
        await reader.onLoad.first;
        if (mounted) {
          setState(() {
            selectedFile = file;
            selectedFileBytes = reader.result as Uint8List;
            rowErrors = [];
            duplicateStocks = [];
            importSummary = "";
            errorData = {};
          });
        }
      } catch (e) {
        _showErrorSnackBar('Error reading file: $e');
      }
    }
  }
}
