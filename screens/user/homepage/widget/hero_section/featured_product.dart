import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class FeaturedProductWidget extends StatelessWidget {
  final bool isMobile;
  final ColorScheme colorScheme;
  final AnimationController slideController;

  const FeaturedProductWidget({
    super.key,
    required this.isMobile,
    required this.colorScheme,
    required this.slideController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 80,
        horizontal: isMobile ? 20 : 60,
      ),
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      child: Column(
        children: [
          // Featured product showcase
          isMobile
              ? Column(
                  children: [
                    _buildFeaturedProductImage(colorScheme),
                    const SizedBox(height: 40),
                    _buildFeaturedProductInfo(isMobile, colorScheme),
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: _buildFeaturedProductImage(colorScheme),
                    ),
                    Expanded(
                      flex: 4,
                      child: _buildFeaturedProductInfo(isMobile, colorScheme),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductImage(ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (1 - slideController.value) * 50,
            0,
          ),
          child: Opacity(
            opacity: slideController.value,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Main image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl:
                          "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?q=80&w=1970",
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colorScheme.surfaceVariant,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: colorScheme.surfaceVariant,
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),

                  // Floating badge
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4AF37),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "BESTSELLER",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  // 360° view button
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.view_in_ar,
                        color: Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedProductInfo(bool isMobile, ColorScheme colorScheme) {
    return AnimatedBuilder(
      animation: slideController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (1 - slideController.value) * -50,
            0,
          ),
          child: Opacity(
            opacity: slideController.value,
            child: Padding(
              padding: EdgeInsets.only(left: isMobile ? 0 : 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Collection name
                  Text(
                    "SIGNATURE COLLECTION",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Product name
                  Text(
                    "The Celestial Diamond Bracelet",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: isMobile ? 28 : 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Price
                  Row(
                    children: [
                      Text(
                        "\$4,850",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "SAVE 15%",
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Description
                  Text(
                    "Crafted in 18K white gold, this exquisite bracelet features 3.2 carats of round brilliant diamonds in a celestial-inspired design. Each stone is meticulously selected for exceptional brilliance and set in a secure prong setting.",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Features
                  Column(
                    children: [
                      _buildFeatureRow(
                        icon: Icons.diamond_outlined,
                        title: "3.2 carats total weight",
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 15),
                      _buildFeatureRow(
                        icon: Icons.verified_outlined,
                        title: "GIA certified diamonds",
                        colorScheme: colorScheme,
                      ),
                      const SizedBox(height: 15),
                      _buildFeatureRow(
                        icon: Icons.workspace_premium_outlined,
                        title: "Lifetime warranty",
                        colorScheme: colorScheme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // CTA buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/product/celestial-diamond-bracelet');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "VIEW DETAILS",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: IconButton(
                          onPressed: () {
                            // Add to wishlist
                          },
                          icon: const Icon(
                            Icons.favorite_outline,
                            size: 20,
                          ),
                          color: colorScheme.onSurface,
                          padding: const EdgeInsets.all(12),
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
            size: 16,
          ),
        ),
        const SizedBox(width: 15),
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
