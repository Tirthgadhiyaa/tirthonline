import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CraftsmanshipWidget extends StatefulWidget {
  final bool isMobile;
  final ColorScheme colorScheme;

  const CraftsmanshipWidget({
    super.key,
    required this.isMobile,
    required this.colorScheme,
  });

  @override
  State<CraftsmanshipWidget> createState() => _CraftsmanshipWidgetState();
}

class _CraftsmanshipWidgetState extends State<CraftsmanshipWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: widget.isMobile ? 20 : 60),
            child: Column(
              children: [
                // Craftsmanship highlights
                widget.isMobile
                    ? Column(
                        children: [
                          _buildCraftsmanshipItem(
                            icon: Icons.diamond_outlined,
                            title: "Exquisite Materials",
                            description:
                                "We meticulously select only the most exceptional diamonds and precious metals, ensuring each piece meets our exacting standards of quality and beauty.",
                          ),
                          const SizedBox(height: 50),
                          _buildCraftsmanshipItem(
                            icon: Icons.handyman_outlined,
                            title: "Master Artisans",
                            description:
                                "Our master craftsmen bring decades of expertise to every creation, combining traditional techniques with innovative approaches to jewelry making.",
                          ),
                          const SizedBox(height: 50),
                          _buildCraftsmanshipItem(
                            icon: Icons.design_services_outlined,
                            title: "Bespoke Excellence",
                            description:
                                "Each piece is thoughtfully designed to capture your unique story, creating timeless jewelry that becomes a cherished part of your legacy.",
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildCraftsmanshipItem(
                              icon: Icons.diamond_outlined,
                              title: "Exquisite Materials",
                              description:
                                  "We meticulously select only the most exceptional diamonds and precious metals, ensuring each piece meets our exacting standards of quality and beauty.",
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: _buildCraftsmanshipItem(
                              icon: Icons.handyman_outlined,
                              title: "Master Artisans",
                              description:
                                  "Our master craftsmen bring decades of expertise to every creation, combining traditional techniques with innovative approaches to jewelry making.",
                            ),
                          ),
                          const SizedBox(width: 40),
                          Expanded(
                            child: _buildCraftsmanshipItem(
                              icon: Icons.design_services_outlined,
                              title: "Bespoke Excellence",
                              description:
                                  "Each piece is thoughtfully designed to capture your unique story, creating timeless jewelry that becomes a cherished part of your legacy.",
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          // CTA button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ElevatedButton(
              onPressed: () {
                context.push('/about/craftsmanship');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                "EXPLORE OUR CRAFTSMANSHIP",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCraftsmanshipItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFD4AF37),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: const Color(0xFFD4AF37),
              size: 36,
            ),
          ),

          const SizedBox(height: 30),

          // Title
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // Description
          Text(
            description,
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 16,
              height: 1.6,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
