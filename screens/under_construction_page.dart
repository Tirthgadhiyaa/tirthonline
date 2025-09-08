// lib/screens/under_construction_page.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;

class UnderConstructionPage extends StatefulWidget {
  final String title;
  final String? returnRoute;

  const UnderConstructionPage({
    Key? key,
    this.title = "Page Under Construction",
    this.returnRoute,
  }) : super(key: key);

  @override
  State<UnderConstructionPage> createState() => _UnderConstructionPageState();
}

class _UnderConstructionPageState extends State<UnderConstructionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Background patterns
          ...List.generate(20, (index) {
            final random = math.Random();
            return Positioned(
              left: random.nextDouble() * size.width,
              top: random.nextDouble() * size.height,
              child: Opacity(
                opacity: 0.05 + (random.nextDouble() * 0.05),
                child: Transform.rotate(
                  angle: random.nextDouble() * math.pi,
                  child: Icon(
                    FontAwesomeIcons.gem,
                    size: 20 + (random.nextDouble() * 40),
                    color: primaryColor,
                  ),
                ),
              ),
            );
          }),

          // Main content
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated construction icon
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            math.sin(_bounceAnimation.value * 2 * math.pi) * 10,
                          ),
                          child: Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                FontAwesomeIcons.hardHat,
                                size: 60,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Title
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Container(
                      constraints: const BoxConstraints(maxWidth: 600),
                      child: Text(
                        "We're working hard to bring you an amazing experience. This page is currently under construction and will be available soon.",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Progress indicator
                    Container(
                      width: 300,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Stack(
                        children: [
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                widthFactor: _animationController.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor,
                                        primaryColor.withOpacity(0.7),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Return button
                    if (widget.returnRoute != null)
                      ElevatedButton.icon(
                        onPressed: () {
                          context.go(widget.returnRoute!);
                        },
                        icon: const Icon(Icons.arrow_back),
                        label: const Text("Return to Dashboard"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Footer
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "© ${DateTime.now().year} DiamondHub. All rights reserved.",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
