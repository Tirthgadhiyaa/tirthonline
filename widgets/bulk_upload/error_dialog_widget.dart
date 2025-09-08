// lib/widgets/bulk_upload/error_dialog_widget.dart

import 'package:flutter/material.dart';
import 'package:jewellery_diamond/widgets/bulk_upload/excel_like_error_table.dart';
import 'package:jewellery_diamond/widgets/bulk_upload/error_summary_widget.dart';
import 'package:jewellery_diamond/widgets/bulk_upload/excel_export_service.dart';

class ErrorDialogWidget extends StatefulWidget {
  final Map<String, dynamic> errorData;
  final String summary;
  final List<Map<String, dynamic>> rowErrors;
  final List<Map<String, dynamic>> duplicateStocks;

  const ErrorDialogWidget({
    Key? key,
    required this.errorData,
    required this.summary,
    required this.rowErrors,
    required this.duplicateStocks,
  }) : super(key: key);

  @override
  State<ErrorDialogWidget> createState() => _ErrorDialogWidgetState();
}

class _ErrorDialogWidgetState extends State<ErrorDialogWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;
  bool _isExporting = false;
  bool _showSplitView = true;
  double _splitRatio = 0.7;

  // For smooth divider drag
  final GlobalKey _dialogKey = GlobalKey();
  double? _dialogWidth;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
    );
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    // Initialize animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    // Start the animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final importedCount = widget.errorData['imported'] ?? 0;
    final updatedCount = widget.errorData['updated'] ?? 0;
    final failedCount = widget.errorData['failed'] ?? 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Dialog(
          key: _dialogKey,
          insetPadding: const EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Update dialog width for drag calculations
              _dialogWidth = constraints.maxWidth;
              return Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with title, toggle button, and close button
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Import Results',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                widget.summary,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Toggle split view button
                        IconButton(
                          icon: Icon(_showSplitView
                              ? Icons.view_agenda
                              : Icons.view_column),
                          tooltip:
                              _showSplitView ? 'Full Width View' : 'Split View',
                          onPressed: () {
                            setState(() {
                              _showSplitView = !_showSplitView;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Main content with tabs and split view
                    Expanded(
                      child: _showSplitView
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left side: Excel-like table with errors
                                Expanded(
                                  flex: (_splitRatio * 10).round(),
                                  child: _buildMainContent(),
                                ),

                                // Draggable divider (native smooth)
                                MouseRegion(
                                  cursor: SystemMouseCursors.resizeColumn,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onHorizontalDragStart: (details) {},
                                    onHorizontalDragUpdate: (details) {
                                      if (_dialogWidth == null) return;
                                      final RenderBox box = _dialogKey
                                          .currentContext
                                          ?.findRenderObject() as RenderBox;
                                      final localOffset = box.globalToLocal(
                                          details.globalPosition);
                                      double newRatio =
                                          (localOffset.dx / _dialogWidth!)
                                              .clamp(0.3, 0.8);
                                      setState(() {
                                        _splitRatio = newRatio;
                                      });
                                    },
                                    onHorizontalDragEnd: (details) {},
                                    child: Container(
                                      width: 6,
                                      height: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.drag_indicator,
                                                color: Colors.grey.shade600,
                                                size: 5),
                                            const SizedBox(height: 8),
                                            Icon(Icons.drag_indicator,
                                                color: Colors.grey.shade600,
                                                size: 5),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Right side: Summary and statistics
                                Expanded(
                                  flex: ((1 - _splitRatio) * 10).round(),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: ErrorSummaryWidget(
                                      importedCount: importedCount,
                                      updatedCount: updatedCount,
                                      failedCount: failedCount,
                                      errorCount: widget.rowErrors.length,
                                      duplicateCount:
                                          widget.duplicateStocks.length,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : _buildMainContent(),
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Footer with action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isExporting
                              ? null
                              : () async {
                                  setState(() {
                                    _isExporting = true;
                                  });

                                  try {
                                    await ExcelExportService
                                        .exportErrorsToExcel(
                                      rowErrors: widget.rowErrors,
                                      duplicateStocks: widget.duplicateStocks,
                                      summary: widget.summary,
                                    );

                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Error report exported successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('Failed to export: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isExporting = false;
                                      });
                                    }
                                  }
                                },
                          icon: _isExporting
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(_isExporting
                              ? 'Exporting...'
                              : 'Export Error Report'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton.icon(
                          onPressed: _isExporting
                              ? null
                              : () async {
                                  setState(() {
                                    _isExporting = true;
                                  });
                                  try {
                                    await ExcelExportService
                                        .exportCleanErrorSheet(
                                      rowErrors: widget.rowErrors,
                                    );
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Clean error sheet exported successfully'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    print(e);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'Failed to export clean error sheet: $e'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isExporting = false;
                                      });
                                    }
                                  }
                                },
                          icon: const Icon(Icons.file_download),
                          label: const Text('Export Clean Error Sheet'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Acknowledge'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: _currentTabIndex == 0 ? Colors.red : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Validation Errors (${widget.rowErrors.length})',
                      style: TextStyle(
                        fontWeight: _currentTabIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copy_all,
                      color:
                          _currentTabIndex == 1 ? Colors.orange : Colors.grey,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Duplicates (${widget.duplicateStocks.length})',
                      style: TextStyle(
                        fontWeight: _currentTabIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tab content
        Expanded(
          child: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            controller: _tabController,
            children: [
              // Validation errors tab
              ExcelLikeErrorTable(rowErrors: widget.rowErrors),

              // Duplicates tab
              _buildDuplicatesTable(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDuplicatesTable() {
    if (widget.duplicateStocks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 48),
            SizedBox(height: 16),
            Text(
              'No duplicate stock numbers found',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.orange.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Text(
                    'Row',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Stock Number',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'Existing Product ID',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table body
          Expanded(
            child: ListView.builder(
              itemCount: widget.duplicateStocks.length,
              itemBuilder: (context, index) {
                final duplicate = widget.duplicateStocks[index];
                return Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.white : Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Text(
                          duplicate['row'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          duplicate['stock_number'] ?? '',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          duplicate['existing_product_id'] ?? '',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
