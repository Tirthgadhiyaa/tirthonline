// lib/screens/user_panel/purchasegood/purchasegood_user.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_event.dart';

import '../../../bloc/diamondproduct_bloc/diamond_bloc.dart';
import '../../../bloc/diamondproduct_bloc/diamond_state.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../models/diamond_product_model.dart';
import 'dart:math' as math;

import '../../../widgets/responsive_ui.dart';

class PurchasegoodUser extends StatefulWidget {
  static const String routeName = '/user-purchase';

  const PurchasegoodUser({super.key});

  @override
  State<PurchasegoodUser> createState() => _PurchasegoodUserState();
}

class _PurchasegoodUserState extends State<PurchasegoodUser>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<String> selectedIds = [];
  Map<String, DiamondProduct> selectedDiamonds = {};
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _tableAnimation;

  int get totalPieces => selectedDiamonds.length;

  double get totalCarats => selectedDiamonds.values
      .fold(0.0, (sum, diamond) => sum + (diamond.carat ?? 0.0));

  double get totalAmount => selectedDiamonds.values
      .fold(0.0, (sum, diamond) => sum + (diamond.price ?? 0.0));

  double get avgPricePerCarat =>
      totalCarats > 0 ? totalAmount / totalCarats : 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create animations
    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _tableAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchProducts() {
    context.read<DiamondBloc>().add(FetchOrders());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<DiamondBloc, DiamondState>(
      listener: (context, state) {
        if (state is BuyerProductExportSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          _fetchProducts();
        } else if (state is DiamondFailure) {
          showCustomSnackBar(
            context: context,
            message: state.error,
            backgroundColor: Colors.red,
          );
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Animated Header
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(_headerAnimation),
                child: _buildHeader(theme),
              ),
            ),

            // Action Bar
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(_headerAnimation),
                child: _buildActionBar(theme),
              ),
            ),

            // Main Content
            Expanded(
              child: FadeTransition(
                opacity: _tableAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_tableAnimation),
                  child: BlocBuilder<DiamondBloc, DiamondState>(
                    builder: (context, state) {
                      if (state is DiamondLoading) {
                        return _buildLoadingState(theme);
                      } else if (state is DiamondFailure) {
                        return _buildErrorState(state.error, theme);
                      } else if (state is OrderslistLoaded) {
                        return state.orderslist.isEmpty
                            ? _buildEmptyState(theme)
                            : _buildDiamondTable(state, theme);
                      }
                      return Container();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
              Icons.inventory_2_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Confirm Goods',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Confirmed goods ready for processing',
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
            valueColor: Colors.green,
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
    Color? valueColor,
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
                color: valueColor ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
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
          if (state is OrderslistLoaded) {
            final hasOrders = state.orderslist.isNotEmpty;
            final allSelected =
                hasOrders && selectedIds.length == state.orderslist.length;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (hasOrders)
                      Row(
                        children: [
                          Checkbox(
                            value: allSelected,
                            onChanged: (value) => _selectAll(state.orderslist),
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
                                  : '${selectedIds.length} of ${state.orderslist.length} selected',
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
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: hasOrders
                          ? () => context.read<DiamondBloc>().add(
                              ExportBuyerOrdersProductsToExcel(
                                  productIds: selectedIds.isEmpty
                                      ? state.orderslist
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
                      // onPressed: selectedIds.isNotEmpty
                      //     ? () => context
                      //         .read<DiamondBloc>()
                      //         .add(RemoveFromOrders(selectedIds))
                      //     : null,
                      onPressed: null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Delete"),
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
            'Loading your confirmed goods...',
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
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Confirmed Goods Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add goods to your confirmed list to track them',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to goods listing
            },
            icon: const Icon(Icons.diamond_outlined),
            label: const Text('Browse Goods'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondTable(OrderslistLoaded state, ThemeData theme) {
    final isMobile = Device.mobile(context);
    final isTablet = Device.tablet(context);
    final isDesktop = Device.desktop(context);
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
              width: math.max(availableWidth, 1200),
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
                          WidgetStateProperty.all<Color>(Colors.white),
                      headingRowColor: WidgetStateProperty.all<Color>(
                          Theme.of(context).colorScheme.primary),
                      dividerThickness: 0.0,
                      headingRowHeight: 40,
                      columnSpacing: isDesktop
                          ? 50
                          : isTablet
                              ? 30
                              : 20,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                      showCheckboxColumn: false,
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
                      rows: state.orderslist.asMap().entries.map((entry) {
                        int index = entry.key;
                        var diamond = entry.value;
                        final isSelected = selectedIds.contains(diamond.id);

                        return DataRow(
                          color: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return theme.colorScheme.primary
                                  .withOpacity(0.05);
                            }
                            if (isSelected) {
                              return theme.colorScheme.primary.withOpacity(0.1);
                            }
                            return index.isEven
                                ? Colors.white
                                : Colors.grey.shade50;
                          }),
                          cells: [
                            DataCell(
                              Checkbox(
                                value: isSelected,
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedIds.add(diamond.id ?? '');
                                      selectedDiamonds[diamond.id ?? ""] =
                                          diamond;
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
                            DataCell(Text(diamond.stockNumber ?? "")),
                            DataCell(_buildStatusBadge(state.status ?? 'N/A')),
                            DataCell(Text(
                                diamond.carat?.toStringAsFixed(2) ?? 'N/A')),
                            DataCell(Text(diamond.price != null
                                ? '\$${diamond.price}'
                                : 'N/A')),
                            DataCell(Text(diamond.shape?.join(', ') ?? 'N/A')),
                            DataCell(Text(diamond.color ?? 'N/A')),
                            DataCell(Text(diamond.clarity ?? 'N/A')),
                            DataCell(Text(diamond.cut ?? 'N/A')),
                            DataCell(Text(diamond.polish ?? 'N/A')),
                            DataCell(Text(diamond.symmetry ?? 'N/A')),
                            DataCell(Text(diamond.fluorescence ?? 'N/A')),
                            DataCell(Text(diamond.certificateLab ?? 'N/A')),
                            DataCell(Text(diamond.certificateNumber ?? 'N/A')),
                            DataCell(Text(
                              '${diamond.length?.toStringAsFixed(2) ?? 'N/A'} × ${diamond.width?.toStringAsFixed(2) ?? 'N/A'} × ${diamond.height?.toStringAsFixed(2) ?? 'N/A'}',
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

  Widget _buildStatusBadge(String status) {
    final Map<String, Color> statusColors = {
      'pending': Colors.amber,
      'processing': Colors.orange,
      'shipped': Colors.deepPurple,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };
    final Color backgroundColor =
        (statusColors[status.toLowerCase()] ?? Colors.grey).withOpacity(0.15);
    final Color foregroundColor =
        statusColors[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
            fontSize: 12, color: foregroundColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _selectAll(List<DiamondProduct> diamonds) {
    setState(() {
      if (selectedIds.length == diamonds.length) {
        // If all are selected, deselect all
        selectedIds.clear();
        selectedDiamonds.clear();
      } else {
        // Otherwise, select all
        selectedIds = diamonds
            .map((d) => d.id ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
        selectedDiamonds = {
          for (var diamond in diamonds)
            if (diamond.id != null) diamond.id!: diamond
        };
      }
    });
  }
}
