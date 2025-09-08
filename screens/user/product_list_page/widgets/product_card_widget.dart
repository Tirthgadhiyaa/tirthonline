import 'package:flash_image/flash_image.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

import '../../../../models/product_response_model.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function? onAddToCart;
  final Function? onAddToWishlist;
  final List<String> wishList;

  const ProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onAddToWishlist,
    required this.wishList,
  });

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentIndex = 0;
  bool _isHovered = false;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _borderController;
  late AnimationController _darkenController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _borderAnimation;
  late Animation<double> _darkenAnimation;

  final Color _goldAccent = const Color(0xFFD4AF37);
  final Color _platinumAccent = const Color(0xFFE5E4E2);
  final Color _sapphireBlue = const Color(0xFF0F52BA);
  final Color _rubyRed = const Color(0xFFE0115F);
  final Color _emeraldGreen = const Color(0xFF046307);
  final Color _darkBlue = const Color(0xFF0A1A2A);

  late Color _gemColor;
  late Color _secondaryGemColor;

  @override
  void initState() {
    super.initState();

    _setGemColors();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _borderController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _darkenController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: math.pi * 2).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOutCubic),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _borderController, curve: Curves.easeInOut),
    );

    _darkenAnimation = Tween<double>(begin: 0.0, end: 0.7).animate(
      CurvedAnimation(parent: _darkenController, curve: Curves.easeOut),
    );
  }

  void _setGemColors() {
    final name = widget.product.name?.toLowerCase() ?? '';

    if (name.contains('diamond')) {
      _gemColor = _platinumAccent;
      _secondaryGemColor = Colors.white;
    } else if (name.contains('ruby') || name.contains('red')) {
      _gemColor = _rubyRed;
      _secondaryGemColor = _goldAccent;
    } else if (name.contains('sapphire') || name.contains('blue')) {
      _gemColor = _sapphireBlue;
      _secondaryGemColor = _platinumAccent;
    } else if (name.contains('emerald') || name.contains('green')) {
      _gemColor = _emeraldGreen;
      _secondaryGemColor = _goldAccent;
    } else {
      _gemColor = _goldAccent;
      _secondaryGemColor = _platinumAccent;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _borderController.dispose();
    _darkenController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.product.images.isEmpty) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentIndex < widget.product.images.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _stopAutoScroll() {
    _timer?.cancel();
  }

  void _onDotTapped(int index) {
    _stopAutoScroll();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _scaleAnimation,
        _rotateAnimation,
        _borderAnimation,
        _darkenAnimation
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
                width: 0.5,
              ),
            ),
            child: MouseRegion(
              onEnter: (_) {
                setState(() => _isHovered = true);
                _startAutoScroll();
                _scaleController.forward();
                _rotateController.repeat(period: const Duration(seconds: 20));
                _borderController.forward();
                _darkenController.forward();
              },
              onExit: (_) {
                setState(() => _isHovered = false);
                _stopAutoScroll();
                _scaleController.reverse();
                _rotateController.stop();
                _borderController.reverse();
                _darkenController.reverse();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: Stack(
                            children: [
                              if (widget.product.images.isNotEmpty)
                                PageView.builder(
                                  controller: _pageController,
                                  itemCount: widget.product.images.length,
                                  onPageChanged: _updateIndex,
                                  itemBuilder: (context, index) {
                                    return FlashImage(
                                      imgURL: widget.product.images[index],
                                      boxfit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    );
                                  },
                                ),
                              AnimatedBuilder(
                                animation: _darkenAnimation,
                                builder: (context, child) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          _darkBlue.withOpacity(
                                              _darkenAnimation.value * 0.3),
                                          _darkBlue.withOpacity(
                                              _darkenAnimation.value),
                                        ],
                                        stops: const [0.3, 1.0],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        if (widget.product.price != null &&
                            widget.product.price! > 50000)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _goldAccent,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Text(
                                'LUXURY',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Column(
                            children: [
                              _buildActionButton(
                                icon: widget.wishList
                                        .contains(widget.product.name)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                onPressed: () {
                                  widget.onAddToWishlist?.call();
                                },
                                isActive: widget.wishList
                                    .contains(widget.product.name),
                                activeColor: _rubyRed,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.0,
                            color: Color(0XFF1B1F3B),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                        '₹${widget.product.price?.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' + Tax',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  color: _goldAccent,
                                  size: 14,
                                );
                              }),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (widget.product.shape?.isNotEmpty == true)
                              _buildFeatureTag(
                                widget.product.shape!.first,
                                icon: Icons.circle_outlined,
                              ),
                            if (widget.product.carat != null)
                              _buildFeatureTag(
                                '${widget.product.carat} Carat',
                                icon: Icons.diamond_outlined,
                              ),
                            if (widget.product.cut != null &&
                                widget.product.cut!.isNotEmpty)
                              _buildFeatureTag(
                                widget.product.cut!,
                                icon: Icons.cut_outlined,
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            widget.onAddToCart?.call();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF800020),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 19,
                              horizontal: 16,
                            ),
                          ),
                          child: const Text(
                            'ADD TO CART',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    Color? activeColor,
  }) {
    final color = isActive ? (activeColor ?? _gemColor) : _darkBlue;

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: color,
        ),
        onPressed: onPressed,
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
        padding: const EdgeInsets.all(8),
        splashRadius: 20,
      ),
    );
  }

  Widget _buildFeatureTag(String text, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0XFF1B1F3B),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
