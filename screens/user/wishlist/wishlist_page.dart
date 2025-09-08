import 'package:flutter/material.dart';
import 'package:jewellery_diamond/core/layout/base_layout.dart';
import 'package:jewellery_diamond/screens/user/product_list_page/widgets/product_grid_widget.dart';
import '../../../models/product_response_model.dart';

/// Example of a Wishlist Screen for a diamond/jewelry store.
class WishlistScreen extends StatefulWidget {
  static const routeName = "/wishlist";
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  // Mock data for demonstration:
  List<Product> wishlistProducts = [];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Adjust columns for responsiveness
    final crossAxisCount = width > 800 ? 4 : 1;

    return BaseLayout(
      body: wishlistProducts.isEmpty
          ? _buildEmptyWishlist()
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Wishlist",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ProductGrid(
                    products: wishlistProducts,
                    wishlistProducts:
                        wishlistProducts.map((e) => e.name ?? '').toList(),
                  ),
                  // GridView.builder(
                  //   shrinkWrap: true,
                  //   itemCount: wishlistProducts.length,
                  //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  //     crossAxisCount: crossAxisCount,
                  //     mainAxisSpacing: 16,
                  //     crossAxisSpacing: 16,
                  //     // Adjust aspect ratio for your design preference
                  //     childAspectRatio: crossAxisCount == 1 ? 2.8 : 1.2,
                  //   ),
                  //   itemBuilder: (context, index) {
                  //     final product = wishlistProducts[index];
                  //     return ProductCard(product: product);
                  //   },
                  // ),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyWishlist() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            "Your Wishlist is empty",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Browse our collection and add items to your wishlist.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistCard(Product product) {
    final imageUrl = product.images.isNotEmpty
        ? product.images.first
        : "https://via.placeholder.com/150?text=No+Image";

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildAttributeChip("Shape: ${product.shape}"),
                      const SizedBox(width: 8),
                      _buildAttributeChip("${product.carat} ct"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildAttributeChip("Cut: ${product.cut}"),
                      const SizedBox(width: 8),
                      _buildAttributeChip("Color: ${product.color}"),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildAttributeChip("Clarity: ${product.clarity}"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "\$${product.price?.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Action Buttons
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // TODO: Add to cart logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("${product.name} added to cart"),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Add to Cart"),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          setState(() {
                            wishlistProducts.remove(product);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("${product.name} removed from wishlist"),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                          side: const BorderSide(color: Colors.redAccent),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Remove"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Small helper for displaying diamond attributes as decorative chips.
  Widget _buildAttributeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}
