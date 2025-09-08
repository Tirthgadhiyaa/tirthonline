// lib/screens/admin/bulk_upload/bulk_upload_screen.dart
import 'dart:html' as html;
import 'package:excel/excel.dart' as ex;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_bloc.dart';
import 'package:jewellery_diamond/core/widgets/custom_snackbar.dart';

import '../../../bloc/diamondproduct_bloc/diamond_event.dart';
import '../../../bloc/diamondproduct_bloc/diamond_state.dart';
import '../../../widgets/drag_drop_upload.dart';

class BulkUploadScreen extends StatefulWidget {
  static const String routeName = '/bulk-upload';

  const BulkUploadScreen({Key? key}) : super(key: key);

  @override
  _BulkUploadScreenState createState() => _BulkUploadScreenState();
}

class _BulkUploadScreenState extends State<BulkUploadScreen> {
  String? pendingUploadType;
  List<String> requiredHeaders = [
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
  final isLoading = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                  // Container(
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: BoxDecoration(
                  //     color: primaryColor.withOpacity(0.1),
                  //     borderRadius: BorderRadius.circular(12),
                  //   ),
                  //   child: Icon(
                  //     FontAwesomeIcons.fileExcel,
                  //     color: primaryColor,
                  //     size: 24,
                  //   ),
                  // ),
                  // const SizedBox(width: 16),
                  Column(
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
                ],
              ),
            ),

            // Main content
            LayoutBuilder(
              builder: (context, constraints) {
                final isWideScreen = constraints.maxWidth > 900;

                return isWideScreen
                    ? _buildWideLayout(primaryColor)
                    : _buildNarrowLayout(primaryColor);
              },
            ),

            // Status section
            if (selectedFile != null)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.withOpacity(0.9)),
                ),
                margin: const EdgeInsets.only(top: 24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'File Ready for Upload',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                selectedFile?.name ?? 'Selected file',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                selectedFile = null;
                                selectedFileBytes = null;
                              });
                              _uploadKey.currentState?.clearAll();
                            },
                            icon: const Icon(Icons.close),
                            label: const Text('Remove'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      BlocListener<DiamondBloc, DiamondState>(
                        listener: (context, state) {
                          if (state is DiamondLoading) {
                            setState(() {
                              isUploading = true;
                            });
                          } else {
                            setState(() {
                              isUploading = false;
                            });
                            if (state is DiamondSuccess) {
                              showCustomSnackBar(
                                context: context,
                                message: state.message,
                                backgroundColor: Colors.green,
                              );
                              setState(() {
                                selectedFile = null;
                                selectedFileBytes = null;
                              });
                              _uploadKey.currentState?.clearAll();
                            } else if (state is DiamondFailure) {
                              showCustomSnackBar(
                                context: context,
                                message: state.error,
                                backgroundColor: Colors.red,
                              );
                            }
                          }
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isUploading
                                ? null
                                : () async {
                              bool isDialogProcessing = false;
                              await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) {
                                  return  AlertDialog(
                                    title: const Text("Select Upload Type"),
                                    content: ValueListenableBuilder<bool>(
                                      valueListenable: isLoading,
                                      builder: (context,isDialogProcessing,_) {
                                        return isDialogProcessing
                                            ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 20),
                                            Text("Processing, please wait..."),
                                          ],
                                        )
                                            : const Text("Do you want to Insert or Update records?");
                                      }
                                    ),
                                    actions: isDialogProcessing
                                        ? []
                                        : [
                                      TextButton(
                                        onPressed: () async {
                                          isLoading.value = true;
                                          final success = await processExcelFile(
                                            isUpdate: false,
                                            showErrorInDialogContext: context,
                                          );

                                          isLoading.value = false;
                                          Navigator.pop(context);

                                        },
                                        child: const Text("Insert"),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          isLoading.value = true;

                                          /*final success = await p*//*rocessExcelFile(
                                            isUpdate: true,
                                            showErrorInDialogContext: context,
                                          );*/
                                          await Future.delayed(Duration(seconds: 3));
                                          isLoading.value = true;
                                          Navigator.pop(context);
                                        },
                                        child: const Text("Update"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                            icon: isUploading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload),
                            label: Text(
                              isUploading
                                  ? 'Processing...'
                                  : 'Process Bulk Upload',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Future<bool> processExcelFile({
    required bool isUpdate,
    required BuildContext showErrorInDialogContext,
  }) async {
    try {
      final excel = ex.Excel.decodeBytes(selectedFileBytes!);
      final sheet = excel.tables[excel.tables.keys.first];

      if (sheet == null || sheet.maxCols == 0) {
        await showDialog(
          context: showErrorInDialogContext,
          builder: (context) => AlertDialog(
            title: const Text("Invalid Excel"),
            content: const Text("The sheet is empty or corrupted."),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return false;
      }

      final headers = sheet.rows.first
          .map((cell) => cell?.value.toString().trim())
          .toList();

      final missingFields = requiredHeaders
          .where((field) => !headers.contains(field))
          .toList();

      if (missingFields.isNotEmpty) {
        await showDialog(
          context: showErrorInDialogContext,
          builder: (context) => AlertDialog(
            title: const Text("Missing Columns"),
            content: Text("Missing: ${missingFields.join(', ')}"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
        return false;
      }

      context.read<DiamondBloc>().add(
        UploadDiamondFile(
          file: selectedFileBytes!,
          fileName: selectedFile!.name,
          is_Update: isUpdate,
        ),
      );

      return true;
    } catch (e) {
      await showDialog(
        context: showErrorInDialogContext,
        builder: (context) => AlertDialog(
          title: const Text("Unexpected Error"),
          content: Text("Error: $e"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return false;
    }
  }


  html.File? selectedFile;
  Uint8List? selectedFileBytes;
  bool isUploading = false;

  final GlobalKey<UploadSectionState> _uploadKey =
      GlobalKey<UploadSectionState>();

  Widget _buildWideLayout(Color primaryColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel - Instructions
        Expanded(
          flex: 4,
          child: _buildInstructionsCard(primaryColor),
        ),
        const SizedBox(width: 24),
        // Right panel - Upload
        Expanded(
          flex: 6,
          child: _buildUploadCard(primaryColor),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(Color primaryColor) {
    return Column(
      children: [
        _buildInstructionsCard(primaryColor),
        const SizedBox(height: 24),
        _buildUploadCard(primaryColor),
      ],
    );
  }

  Widget _buildInstructionsCard(Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
            const SizedBox(height: 16),
            _buildInstructionStep(
              number: '4',
              title: 'Process Data',
              description: 'We\'ll process and validate your data',
              icon: Icons.settings,
              color: Colors.purple,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Make sure your data follows the template format to avoid errors during import.",
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                ],
              ),
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
                    showCustomSnackBar(
                      context: context,
                      message: "Template downloaded successfully!",
                      backgroundColor: Colors.green,
                    );
                  } catch (e) {
                    showCustomSnackBar(
                      context: context,
                      message: "Error downloading template: $e",
                      backgroundColor: Colors.red,
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

  Widget _buildUploadCard(Color primaryColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
                  FontAwesomeIcons.fileImport,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Upload Your File',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Select or drag and drop your Excel file below to begin the upload process.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            UploadSection(
              key: _uploadKey,
              title: "Upload Excel File",
              subtitle: "Drag and drop your completed template file here",
              icon: FontAwesomeIcons.fileExcel,
              allowedExtensions: ['csv', 'xlsx', 'xls'],
              onFilesSelected: (files) async {
                if (files.isNotEmpty) {
                  final file = files.first;
                  final reader = html.FileReader();
                  reader.readAsArrayBuffer(file);
                  await reader.onLoad.first;
                  final Uint8List fileBytes = reader.result as Uint8List;
                  setState(() {
                    selectedFile = file;
                    selectedFileBytes = fileBytes;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Supported Formats",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFormatItem(
                        icon: FontAwesomeIcons.fileExcel,
                        label: "Excel (.xlsx)",
                        color: Colors.green,
                      ),
                      _buildFormatItem(
                        icon: FontAwesomeIcons.fileExcel,
                        label: "Excel 97-2003 (.xls)",
                        color: Colors.green.shade700,
                      ),
                      _buildFormatItem(
                        icon: FontAwesomeIcons.fileCsv,
                        label: "CSV (.csv)",
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (selectedFile == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Please upload a file to continue with the bulk upload process.",
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
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
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
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
              Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormatItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
