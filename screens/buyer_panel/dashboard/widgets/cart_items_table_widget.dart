// lib/screens/user_panel/dashboard/widgets/cart_items_table_widget.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jewellery_diamond/models/diamond_product_model.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';

class CartItemsTableWidget extends StatefulWidget {
  final List<DiamondProduct> diamondList;
  final ScrollController scrollController;
  final Function(DiamondProduct)? onViewDetails;
  final Function(DiamondProduct)? onRemoveFromCart;

  const CartItemsTableWidget({
    Key? key,
    required this.diamondList,
    required this.scrollController,
    this.onViewDetails,
    this.onRemoveFromCart,
  }) : super(key: key);

  @override
  State<CartItemsTableWidget> createState() => _CartItemsTableWidgetState();
}

class _CartItemsTableWidgetState extends State<CartItemsTableWidget> {
  int _hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.diamondList.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Cart Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  // Navigate to cart page
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              // Estimate the minimum width required for the table
              // (You can adjust these values based on your column content)
              const minTableWidth =
                  900.0; // Example: 8 columns * 110px + spacing
              final availableWidth = constraints.maxWidth;

              Widget table = Theme(
                data: Theme.of(context).copyWith(
                  dividerTheme: DividerThemeData(
                    color: Colors.grey.shade300,
                    space: 0,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                ),
                child: DataTable(
                  dataRowColor: MaterialStateProperty.all<Color>(Colors.white),
                  headingRowColor: MaterialStateProperty.resolveWith(
                    (states) => Theme.of(context).colorScheme.primary,
                  ),
                  dividerThickness: 0.0,
                  headingRowHeight: 40,
                  dataRowHeight: 50,
                  columnSpacing: Device.desktop(context)
                      ? 50
                      : Device.tablet(context)
                          ? 30
                          : 20,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  dataTextStyle: TextStyle(
                    fontSize: Device.mobile(context)
                        ? 12
                        : Device.tablet(context)
                            ? 13
                            : 14,
                    color: Colors.black,
                  ),
                  columns: const [
                    DataColumn(
                        label: Text('Stock Number', textAlign: TextAlign.left)),
                    DataColumn(
                        label: Text('Carat', textAlign: TextAlign.center)),
                    DataColumn(
                        label: Text('Price', textAlign: TextAlign.right)),
                    DataColumn(label: Text('Shape', textAlign: TextAlign.left)),
                    DataColumn(
                        label: Text('Color', textAlign: TextAlign.center)),
                    DataColumn(
                        label: Text('Clarity', textAlign: TextAlign.center)),
                    DataColumn(label: Text('Cut', textAlign: TextAlign.center)),
                    DataColumn(
                        label: Text('Actions', textAlign: TextAlign.center)),
                  ],
                  rows: widget.diamondList.asMap().entries.map((entry) {
                    int index = entry.key;
                    var diamond = entry.value;
                    return DataRow(
                      color: MaterialStateColor.resolveWith((states) {
                        if (_hoverIndex == index) {
                          return Colors.grey.shade100;
                        }
                        return index.isEven
                            ? Colors.white
                            : Colors.grey.shade50;
                      }),
                      cells: [
                        DataCell(Align(
                            alignment: Alignment.centerLeft,
                            child: Text(diamond.stockNumber ?? ""))),
                        DataCell(Align(
                            alignment: Alignment.center,
                            child: Text(
                                diamond.carat?.toStringAsFixed(2) ?? 'N/A'))),
                        DataCell(Align(
                            alignment: Alignment.centerRight,
                            child: Text(diamond.price != null
                                ? '\$${diamond.price}'
                                : 'N/A'))),
                        DataCell(Align(
                            alignment: Alignment.centerLeft,
                            child: Text(diamond.shape?.join(', ') ?? 'N/A'))),
                        DataCell(Align(
                            alignment: Alignment.center,
                            child: Text(diamond.color ?? 'N/A'))),
                        DataCell(Align(
                            alignment: Alignment.center,
                            child: Text(diamond.clarity ?? 'N/A'))),
                        DataCell(Align(
                            alignment: Alignment.center,
                            child: Text(diamond.cut ?? 'N/A'))),
                        DataCell(
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.visibility,
                                    size: 18, color: Colors.blue),
                                onPressed: () {
                                  widget.onViewDetails?.call(diamond);
                                },
                                tooltip: 'View Details',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    size: 18, color: Colors.red),
                                onPressed: () {
                                  widget.onRemoveFromCart?.call(diamond);
                                },
                                tooltip: 'Remove from Cart',
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              );

              if (availableWidth < minTableWidth) {
                // Not enough space, make it horizontally scrollable
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: widget.scrollController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: minTableWidth),
                    child: table,
                  ),
                );
              } else {
                // Enough space, use full width
                return table;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Cart Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add diamonds to your cart to see them here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to product listing
                  },
                  icon: const Icon(Icons.diamond_outlined),
                  label: const Text('Browse Diamonds'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
