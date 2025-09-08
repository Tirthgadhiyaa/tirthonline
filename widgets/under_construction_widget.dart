import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class UnderConstructionWidget extends StatefulWidget {
  final String? message;
  final String? subtitle;
  final String? estimatedTime;
  final IconData? icon;
  final Color? primaryColor;
  final Color? secondaryColor;
  final double? iconSize;
  final TextStyle? textStyle;
  final bool showBackgroundPatterns;
  final bool showFooter;

  const UnderConstructionWidget({
    Key? key,
    this.message,
    this.subtitle,
    this.estimatedTime,
    this.icon,
    this.primaryColor,
    this.secondaryColor,
    this.iconSize,
    this.textStyle,
    this.showBackgroundPatterns = true,
    this.showFooter = true,
  }) : super(key: key);

  @override
  State<UnderConstructionWidget> createState() =>
      _UnderConstructionWidgetState();
}

class _UnderConstructionWidgetState extends State<UnderConstructionWidget>
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
    final primaryColor = widget.primaryColor ?? theme.primaryColor;
    final secondaryColor =
        widget.secondaryColor ?? primaryColor.withOpacity(0.7);
    final size = MediaQuery.of(context).size;

    return SizedBox(
      width: double.infinity,
      height: size.height - 400,
      child: Stack(
        children: [
          // Background patterns
          if (widget.showBackgroundPatterns)
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
                                widget.icon ?? FontAwesomeIcons.hardHat,
                                size: widget.iconSize ?? 60,
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
                      widget.message ?? 'Under Construction',
                      style: widget.textStyle ??
                          TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onBackground,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Text(
                          widget.subtitle!,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

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
                                        secondaryColor,
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

                    if (widget.estimatedTime != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.estimatedTime!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Footer
          if (widget.showFooter)
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
