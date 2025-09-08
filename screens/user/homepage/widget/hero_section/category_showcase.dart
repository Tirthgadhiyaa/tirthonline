import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'models.dart';

class CategoryShowcaseWidget extends StatelessWidget {
  final List<CategoryShowcase> categories;
  final String selectedCategory;
  final Function(String) onCategorySelected;
  final AnimationController shimmerController;

  const CategoryShowcaseWidget({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    required this.shimmerController,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;
    final isTablet = size.width < 900 && size.width >= 600;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 60,
        horizontal: isMobile ? 20 : 60,
      ),
      color: colorScheme.surface,
      child: Column(
        children: [
          // Category grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile
                  ? 2
                  : isTablet
                      ? 3
                      : 5,
              childAspectRatio: 0.8,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.name == selectedCategory;

              return TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: 0.95 + (value * 0.05),
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: StatefulBuilder(
                    builder: (context, setState) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        transform: Matrix4.identity()
                          ..scale(isHovered ? 1.05 : 1.0),
                        transformAlignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            onCategorySelected(category.name);
                            context.goNamed(
                              AppRouteNames.productListByType,
                              pathParameters: {
                                'type': category.name.toLowerCase()
                              },
                            );
                          },
                          onTapDown: (_) => setState(() => isHovered = true),
                          onTapUp: (_) => setState(() => isHovered = false),
                          onTapCancel: () => setState(() => isHovered = false),
                          child: AnimatedBuilder(
                            animation: shimmerController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.shadow
                                          .withOpacity(isHovered ? 0.2 : 0.1),
                                      blurRadius: isHovered ? 15 : 10,
                                      spreadRadius: isHovered ? 2 : 1,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Category image
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: CachedNetworkImage(
                                        imageUrl: category.image,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                          color: colorScheme.surfaceVariant,
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                          color: colorScheme.surfaceVariant,
                                          child: const Icon(Icons.error),
                                        ),
                                      ),
                                    ),

                                    // Overlay
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(
                                                isHovered ? 0.7 : 0.6),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Category name and icon
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // Icon with shimmer effect
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(
                                                    isHovered ? 0.3 : 0.2),
                                                border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(isHovered
                                                          ? 0.4
                                                          : 0.3),
                                                  width: isHovered ? 1.5 : 1,
                                                ),
                                              ),
                                              child: ShaderMask(
                                                shaderCallback: (bounds) {
                                                  return LinearGradient(
                                                    colors: [
                                                      Colors.white
                                                          .withOpacity(0.8),
                                                      Colors.white,
                                                      Colors.white
                                                          .withOpacity(0.8),
                                                    ],
                                                    stops: [
                                                      0.0,
                                                      shimmerController.value,
                                                      1.0,
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ).createShader(bounds);
                                                },
                                                child: FaIcon(
                                                  category.icon,
                                                  color: Colors.white,
                                                  size: isHovered ? 20 : 18,
                                                ),
                                              ),
                                            ),

                                            const SizedBox(height: 10),

                                            // Category name
                                            Text(
                                              category.name,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isHovered ? 17 : 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Selection indicator
                                    if (isSelected)
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.check,
                                            color: colorScheme.primary,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Add this at the top of the file, after the imports
bool isHovered = false;
