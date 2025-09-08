import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_bloc.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_event.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_state.dart';
import 'package:jewellery_diamond/models/diamond_product_model.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';
import 'package:jewellery_diamond/core/widgets/custom_snackbar.dart';

class PendingHoldView extends StatefulWidget {
  final AnimationController animationController;
  final Animation<double> headerAnimation;
  final Animation<double> tableAnimation;

  const PendingHoldView({
    super.key,
    required this.animationController,
    required this.headerAnimation,
    required this.tableAnimation,
  });

  @override
  State<PendingHoldView> createState() => _PendingHoldViewState();
}

class _PendingHoldViewState extends State<PendingHoldView> {
  final ScrollController _scrollController = ScrollController();
  List<String> selectedIds = [];
  Map<String, DiamondProduct> selectedDiamonds = {};

  int get totalPieces => selectedDiamonds.length;
  double get totalCarats => selectedDiamonds.values.fold(0.0, (sum, diamond) => sum + (diamond.carat ?? 0.0));
  double get totalAmount => selectedDiamonds.values.fold(0.0, (sum, diamond) => sum + (diamond.price ?? 0.0));
  double get avgPricePerCarat => totalCarats > 0 ? totalAmount / totalCarats : 0.0;

  void _fetchProducts() {
    context.read<DiamondBloc>().add(FetchHold(status:"pending"));
  }

  void _changePage(int page) {
    final diamondState = context.read<DiamondBloc>().state;
    if (diamondState is HoldlistLoaded) {
      if (page < 1 || page > diamondState.totalPages) return;
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
      context.read<DiamondBloc>().add(ChangeHoldPage(page: page));
    }
  }

  void _selectAll(List<DiamondProduct> diamonds) {
    setState(() {
      if (selectedIds.length == diamonds.length) {
        selectedIds.clear();
        selectedDiamonds.clear();
      } else {
        selectedIds = diamonds.map((d) => d.id ?? '').where((id) => id.isNotEmpty).toList();
        selectedDiamonds = {for (var diamond in diamonds) if (diamond.id != null) diamond.id!: diamond};
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        FadeTransition(
          opacity: widget.headerAnimation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -0.2), end: Offset.zero).animate(widget.headerAnimation),
            child: _buildHeader(theme),
          ),
        ),
        FadeTransition(
          opacity: widget.headerAnimation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero).animate(widget.headerAnimation),
            child: _buildActionBar(theme),
          ),
        ),
        Expanded(
          child: FadeTransition(
            opacity: widget.tableAnimation,
            child: SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(widget.tableAnimation),
              child: BlocBuilder<DiamondBloc, DiamondState>(
                builder: (context, state) {
                  if (state is DiamondLoading) {
                    return _buildLoadingState(theme);
                  } else if (state is DiamondFailure) {
                    return _buildErrorState(state.error, theme);
                  } else if (state is HoldlistLoaded) {
                    return state.holdlist.isEmpty ? _buildEmptyState(theme) : _buildDiamondTable(state, theme);
                  }
                  return Container();
                },
              ),
            ),
          ),
        ),
        BlocBuilder<DiamondBloc, DiamondState>(
          builder: (context, state) {
            if (state is HoldlistLoaded && state.holdlist.isNotEmpty) {
              return _buildPaginationControls(state, theme);
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.hourglass_top_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Pending Hold Stones Request',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Diamonds reserved for 48 hours',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildStatsSummary(theme),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(
            icon: Icons.diamond_outlined,
            value: totalPieces.toString(),
            label: 'Pieces',
            theme: theme,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.scale,
            value: totalCarats.toStringAsFixed(2),
            label: 'Carats',
            theme: theme,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.attach_money,
            value: '\$${totalAmount.toStringAsFixed(2)}',
            label: 'Total',
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildActionBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: BlocBuilder<DiamondBloc, DiamondState>(
        builder: (context, state) {
          if (state is HoldlistLoaded) {
            final hasHolds = state.holdlist.isNotEmpty;
            final allSelected =
                hasHolds && selectedIds.length == state.holdlist.length;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Selection info
                Row(
                  children: [
                    // Select all checkbox
                    if (hasHolds)
                      Row(
                        children: [
                          Checkbox(
                            value: allSelected,
                            onChanged: (value) =>
                                _selectAll(state.holdlist.map((e) => e.product).toList()),
                            activeColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            allSelected ? 'Deselect All' : 'Select All',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: selectedIds.isNotEmpty
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              selectedIds.isEmpty
                                  ? 'No items selected'
                                  : '${selectedIds.length} of ${state.holdlist.length} selected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: selectedIds.isNotEmpty
                                    ? theme.colorScheme.primary
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Right side - Action buttons
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: hasHolds
                          ? () => context.read<DiamondBloc>().add(
                          ExportBuyerHoldProductsToExcel(
                              productIds: selectedIds.isEmpty
                                  ? state.holdlist
                                  .map((e) => e.id ?? '')
                                  .toList()
                                  : selectedIds))
                          : null,
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text("Export"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: selectedIds.isNotEmpty
                          ? () => context
                          .read<DiamondBloc>()
                          .add(RemoveFromHold(selectedIds))
                          : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Release"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                    ),
                    // const SizedBox(width: 12),
                    // FilledButton.icon(
                    //   onPressed: selectedIds.isNotEmpty
                    //       ? () {
                    //     List<Map<String, dynamic>> orderProducts =
                    //     selectedDiamonds.entries.map((entry) {
                    //       final diamond = entry.value;
                    //       return {
                    //         "product_id": diamond.id,
                    //         "price_per_unit": diamond.price,
                    //       };
                    //     }).toList();
                    //     context
                    //         .read<DiamondBloc>()
                    //         .add(AddToOrders(orderProducts));
                    //     context
                    //         .read<DiamondBloc>()
                    //         .add(RemoveFromHold(selectedIds));
                    //   }
                    //       : null,
                    //   icon: const Icon(Icons.check_circle_outline, size: 18),
                    //   label: const Text("Order"),
                    //   style: FilledButton.styleFrom(
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 16, vertical: 10),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your hold stones...',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.hourglass_empty_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Hold Stones Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add stones to your hold list to track them',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to diamond listing
            },
            icon: const Icon(Icons.diamond_outlined),
            label: const Text('Browse Diamonds'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondTable(HoldlistLoaded state, ThemeData theme) {
    // Calculate available width for the table
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Container(
          width: availableWidth,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              // Make the table at least as wide as the available space
              width: max(availableWidth, 1200),
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent &&
                      event.scrollDelta.dy != 0) {
                    if (event.kind == PointerDeviceKind.mouse &&
                        RawKeyboard.instance.keysPressed
                            .contains(LogicalKeyboardKey.shiftLeft)) {
                      _scrollController.jumpTo(
                        _scrollController.position.pixels +
                            event.scrollDelta.dy,
                      );
                    }
                  }
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      dividerTheme: DividerThemeData(
                        color: Colors.grey.shade200,
                        space: 0,
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                      ),
                    ),
                    child: DataTable(
                      dataRowColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                      headingRowColor: MaterialStateProperty.resolveWith(
                            (states) => theme.colorScheme.primary,
                      ),
                      dividerThickness: 0.5,
                      headingRowHeight: 48,
                      dataRowHeight: 56,
                      horizontalMargin: 16,
                      columnSpacing: 24,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13,
                      ),
                      dataTextStyle: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      columns: const [
                        DataColumn(label: Text('')),
                        DataColumn(
                            label: Flexible(
                                child: Text(
                                  'Stock Number',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ))),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Carat')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Shape')),
                        DataColumn(label: Text('Color')),
                        DataColumn(label: Text('Clarity')),
                        DataColumn(label: Text('Cut')),
                        DataColumn(label: Text('Polish')),
                        DataColumn(label: Text('Symmetry')),
                        DataColumn(label: Text('Fluorescence')),
                        DataColumn(
                            label: Flexible(
                                child: Text(
                                  'Certificate Lab',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ))),
                        DataColumn(
                            label: Flexible(
                                child: Text(
                                  'Certificate Number',
                                  softWrap: true,
                                  textAlign: TextAlign.center,
                                ))),
                        DataColumn(label: Text('Measurements')),
                      ],
                      rows: state.holdlist.asMap().entries.map((entry) {
                        int index = entry.key;
                        var diamond = entry.value;
                        final isSelected = selectedIds.contains(diamond.id);

                        return DataRow(
                          color: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return theme.colorScheme.primary.withOpacity(0.05);
                            }
                            if (isSelected) {
                              return theme.colorScheme.primary.withOpacity(0.1);
                            }
                            return index.isEven ? Colors.white : Colors.grey.shade50;
                          }),
                          cells: [
                            DataCell(
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    final product = diamond.product;
                                    if (value == true) {
                                      selectedIds.add(diamond.id ?? '');
                                      selectedDiamonds[product.id ?? ""] = product;
                                    } else {
                                      selectedDiamonds.remove(diamond.id);
                                      selectedIds.remove(diamond.id ?? '');
                                    }
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: theme.colorScheme.primary,
                              ),
                            ),
                            DataCell(Text(diamond.product.stockNumber ?? "")),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(diamond.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  diamond.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(diamond.status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(diamond.product.carat?.toStringAsFixed(2) ?? 'N/A')),
                            DataCell(Text(diamond.product.price != null
                                ? '\$${diamond.product.price}'
                                : 'N/A')),
                            DataCell(Text(diamond.product.shape?.join(', ') ?? 'N/A')),
                            DataCell(Text(diamond.product.color ?? 'N/A')),
                            DataCell(Text(diamond.product.clarity ?? 'N/A')),
                            DataCell(Text(diamond.product.cut ?? 'N/A')),
                            DataCell(Text(diamond.product.polish ?? 'N/A')),
                            DataCell(Text(diamond.product.symmetry ?? 'N/A')),
                            DataCell(Text(diamond.product.fluorescence ?? 'N/A')),
                            DataCell(Text(diamond.product.certificateLab ?? 'N/A')),
                            DataCell(Text(diamond.product.certificateNumber ?? 'N/A')),
                            DataCell(Text(
                              '${diamond.product.length?.toStringAsFixed(2) ?? 'N/A'} × '
                                  '${diamond.product.width?.toStringAsFixed(2) ?? 'N/A'} × '
                                  '${diamond.product.height?.toStringAsFixed(2) ?? 'N/A'}',
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildPaginationControls(HoldlistLoaded state, ThemeData theme) {
    final currentPage = state.currentPage;
    final totalPages = state.totalPages;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pagination
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 1 ? () => _changePage(1) : null,
                tooltip: 'First Page',
                color: theme.colorScheme.primary,
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                currentPage > 1 ? () => _changePage(currentPage - 1) : null,
                tooltip: 'Previous Page',
                color: theme.colorScheme.primary,
                iconSize: 20,
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$currentPage of $totalPages',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => _changePage(currentPage + 1)
                    : null,
                tooltip: 'Next Page',
                color: theme.colorScheme.primary,
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages
                    ? () => _changePage(totalPages)
                    : null,
                tooltip: 'Last Page',
                color: theme.colorScheme.primary,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

}
