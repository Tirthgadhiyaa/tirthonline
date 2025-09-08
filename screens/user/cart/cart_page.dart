import 'package:flutter/material.dart';

import '../../../core/layout/base_layout.dart';
import '../../../data/models/cart_item.dart';

class CartPage extends StatefulWidget {
  static const routeName = '/cart';
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartPage> {
  // Mock data for demonstration using jewellery/diamond products
  List<CartItem> items = [
    CartItem(
      productId: 1,
      name: "Diamond Ring",
      shape: "Round",
      carat: 1.2,
      cut: "Excellent",
      color: "D",
      clarity: "IF",
      price: 5000.00,
      quantity: 1,
      imageUrls: [
        "https://www.tanishq.co.in/dw/image/v2/BKCK_PRD/on/demandware.static/-/Sites-Tanishq-product-catalog/default/dwea514af4/images/hi-res/50K4I1SIKAGA02_1.jpg?sw=640&sh=640",
        "https://example.com/diamond1_alt.jpg",
        "https://example.com/diamond1_alt2.jpg",
      ],
    ),
    CartItem(
      productId: 2,
      name: "Luxury Necklace",
      shape: "Oval",
      carat: 2.5,
      cut: "Very Good",
      color: "E",
      clarity: "VVS1",
      price: 12000.00,
      quantity: 1,
      imageUrls: [
        "https://www.tanishq.co.in/dw/image/v2/BKCK_PRD/on/demandware.static/-/Sites-Tanishq-product-catalog/default/dwea514af4/images/hi-res/50K4I1SIKAGA02_1.jpg?sw=640&sh=640",
        "https://example.com/necklace1_alt.jpg",
        "https://example.com/necklace1_alt2.jpg",
      ],
    ),
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    // Calculate subtotal for summary
    double subtotal = 0;
    for (final item in items) {
      subtotal += item.price * item.quantity;
    }

    // Simple responsive breakpoint
    final bool isWideScreen = MediaQuery.of(context).size.width > 900;

    return BaseLayout(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Flex(
              direction: isWideScreen ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cart Items Section
                Expanded(
                  flex: isWideScreen ? 3 : 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // List of Cart Items with individual delete icons
                      Column(
                        children: items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _buildCartItemCard(item, index);
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                if (isWideScreen)
                  const SizedBox(width: 24)
                else
                  const SizedBox(height: 24),
                // Summary Section
                SizedBox(
                  width: isWideScreen
                      ? constraints.maxWidth * 0.3
                      : double.infinity,
                  child: _buildSummaryCard(subtotal),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds each cart item card for jewellery/diamond products with a delete icon.
  Widget _buildCartItemCard(CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Item Image (using the first imageUrl)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.imageUrls.first,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Name
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Jewellery/Diamond Attributes
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildTag("Shape: ${item.shape}"),
                      _buildTag("Carat: ${item.carat}"),
                      _buildTag("Cut: ${item.cut}"),
                      _buildTag("Color: ${item.color}"),
                      _buildTag("Clarity: ${item.clarity}"),
                    ],
                  ),
                ],
              ),
            ),
            // Price and Quantity Controls
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          items.removeAt(index);
                        });
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onTap: () {
                        setState(() {
                          if (item.quantity > 1) {
                            // Decrease quantity
                            items[index] = CartItem(
                              productId: item.productId,
                              name: item.name,
                              shape: item.shape,
                              carat: item.carat,
                              cut: item.cut,
                              color: item.color,
                              clarity: item.clarity,
                              price: item.price,
                              quantity: item.quantity - 1,
                              imageUrls: item.imageUrls,
                            );
                          } else {
                            // Remove item if quantity reaches 0
                            items.removeAt(index);
                          }
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onTap: () {
                        setState(() {
                          items[index] = CartItem(
                            productId: item.productId,
                            name: item.name,
                            shape: item.shape,
                            carat: item.carat,
                            cut: item.cut,
                            color: item.color,
                            clarity: item.clarity,
                            price: item.price,
                            quantity: item.quantity + 1,
                            imageUrls: item.imageUrls,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a small tag widget for displaying attributes.
  Widget _buildTag(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }

  /// Builds the quantity increment/decrement button.
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(
          icon,
          size: 16,
          color: Colors.black87,
        ),
      ),
    );
  }

  /// Builds the summary section on the right/bottom.
  Widget _buildSummaryCard(double subtotal) {
    const double shippingCost = 5.00; // Example shipping cost
    final double total = subtotal + shippingCost;

    return Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Summary Order",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow("Subtotal", "\$${subtotal.toStringAsFixed(2)}"),
            const SizedBox(height: 8),
            _buildSummaryRow(
                "Shipping", "\$${shippingCost.toStringAsFixed(2)}"),
            const Divider(height: 24, color: Colors.grey),
            _buildSummaryRow("Total", "\$${total.toStringAsFixed(2)}",
                isBold: true),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  // Handle checkout logic here
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Buy Now",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a row for the summary section (label + value).
  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
