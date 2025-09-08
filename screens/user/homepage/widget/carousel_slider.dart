// lib/screens/user/homepage/widget/carousel_slider.dart
import 'package:flutter/material.dart';
import 'package:jewellery_diamond/gen/assets.gen.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../product_list_page/widgets/product_card_widget.dart';
import '../../../../models/product_response_model.dart';

class HomePageCarouselSlider extends StatefulWidget {
  const HomePageCarouselSlider({super.key});

  @override
  State<HomePageCarouselSlider> createState() => _HomePageCarouselSliderState();
}

class _HomePageCarouselSliderState extends State<HomePageCarouselSlider>
    with TickerProviderStateMixin {
  // Controllers
  late PageController _pageController;
  late AnimationController _revealController;
  late AnimationController _detailsController;
  late AnimationController _shimmerController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _parallaxController;
  late AnimationController _pulseController;

  // Interaction state
  int _currentIndex = 0;
  bool _isExploring = false;
  Offset _mousePosition = Offset.zero;

  // Collection items with rich details
  final List<JewelryStory> _jewelryStories = [
    JewelryStory(
      title: "Diamond Constellation",
      tagline: "BRILLIANCE IN HARMONY",
      mainImage:
          "https://mir-s3-cdn-cf.behance.net/project_modules/fs/0915cb29655437.5e29731d37ced.jpg",
      detailImage:
          "https://images.pexels.com/photos/13595793/pexels-photo-13595793.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      storyElements: [
        StoryElement(
          icon: Icons.diamond,
          title: "Center Diamond",
          description: "2.5 carat round brilliant cut, F color, VS1",
          position: const Offset(0.5, 0.5),
        ),
        StoryElement(
          icon: Icons.star_outline,
          title: "Constellation Design",
          description: "Inspired by the Lyra constellation",
          position: const Offset(0.2, 0.3),
        ),
        StoryElement(
          icon: Icons.architecture,
          title: "White Gold Band",
          description: "14K white gold with micro-pavé setting",
          position: const Offset(0.8, 0.4),
        ),
      ],
      color: const Color(0xFFD4AF37),
      story:
          "Our Diamond Constellation series maps the stars to create unique, meaningful jewelry. Each piece tells a celestial story that's as unique as your own journey.",
      price: "\$15,750",
    ),
    JewelryStory(
      title: "Emerald Enchantment",
      tagline: "NATURE'S PERFECT GEM",
      mainImage:
          "https://laxmi-storage.s3.ap-south-1.amazonaws.com/products/show-case/upscalemedia-transformed-processed(lightpdf.com).jpg",
      detailImage:
          "https://images.pexels.com/photos/248077/pexels-photo-248077.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      storyElements: [
        StoryElement(
          icon: Icons.grass,
          title: "Colombian Emerald",
          description: "4.2 carat emerald with vivid green color",
          position: const Offset(0.3, 0.4),
        ),
        StoryElement(
          icon: Icons.auto_awesome,
          title: "Baguette Diamonds",
          description: "Framed by 18 baguette-cut diamonds",
          position: const Offset(0.7, 0.6),
        ),
        StoryElement(
          icon: Icons.architecture,
          title: "18K Gold Setting",
          description: "Vintage-inspired filigree design",
          position: const Offset(0.5, 0.8),
        ),
      ],
      color: const Color(0xFF2E7D32),
      story:
          "Each emerald in our collection is ethically sourced from Colombia, known for producing the world's finest emeralds with their characteristic vivid green color.",
      price: "\$9,800",
    ),
    JewelryStory(
      title: "Ruby Passion",
      tagline: "ETERNAL FIRE WITHIN",
      mainImage:
          "https://mir-s3-cdn-cf.behance.net/project_modules/fs/5e8f06137104869.62051c26d939b.jpg",
      detailImage:
          "https://images.pexels.com/photos/28939437/pexels-photo-28939437/free-photo-of-intricate-gold-necklace-with-pearl-accents.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      storyElements: [
        StoryElement(
          icon: Icons.local_fire_department_outlined,
          title: "Burmese Ruby",
          description: "3.8 carat pigeon-blood ruby",
          position: const Offset(0.6, 0.4),
        ),
        StoryElement(
          icon: Icons.auto_awesome,
          title: "Diamond Accent",
          description: "Surrounded by 32 round brilliant diamonds",
          position: const Offset(0.3, 0.7),
        ),
        StoryElement(
          icon: Icons.architecture,
          title: "Rose Gold Setting",
          description: "18K rose gold with vintage milgrain detail",
          position: const Offset(0.7, 0.8),
        ),
      ],
      color: const Color(0xFFB71C1C),
      story:
          "The vibrant red of our ruby collection symbolizes passion and love. Each stone undergoes minimal treatment to preserve its natural beauty and character.",
      price: "\$11,200",
    ),
    JewelryStory(
      title: "The Royal Sapphire",
      tagline: "A LEGACY OF ELEGANCE",
      mainImage:
          "https://plus.unsplash.com/premium_photo-1692138270836-893cffcedecf?q=80&w=1632&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      detailImage:
          "https://images.pexels.com/photos/13595642/pexels-photo-13595642.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
      storyElements: [
        StoryElement(
          icon: Icons.diamond_outlined,
          title: "Rare Blue Sapphire",
          description: "5.7 carat Kashmir sapphire of exceptional clarity",
          position: const Offset(0.7, 0.3),
        ),
        StoryElement(
          icon: Icons.auto_awesome,
          title: "Diamond Halo",
          description: "Surrounded by 24 brilliant-cut diamonds",
          position: const Offset(0.2, 0.6),
        ),
        StoryElement(
          icon: Icons.architecture,
          title: "Platinum Setting",
          description: "Hand-crafted by master artisans",
          position: const Offset(0.8, 0.7),
        ),
      ],
      color: const Color(0xFF3366CC),
      story:
          "Inspired by royal jewels, this sapphire pendant represents timeless elegance and sophistication. Each stone is carefully selected for its exceptional color and clarity.",
      price: "\$12,500",
    ),
    JewelryStory(
      title: "Featured Collection",
      tagline: "EXPLORE OUR FINEST",
      mainImage: "", // Special slide, no main image needed
      detailImage: "",
      storyElements: [],
      color: const Color(0xFFD4AF37),
      story: "",
      price: "",
      isSpecialSlide: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController(
      viewportFraction: 1.0,
      initialPage: _currentIndex,
    );

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _detailsController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _parallaxController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Auto-advance when not in exploration mode
    _startAutoAdvance();
  }

  void _startAutoAdvance() {
    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;
      if (!_isExploring) {
        final nextIndex = (_currentIndex + 1) % _jewelryStories.length;
        _animateToPage(nextIndex);
      }
      _startAutoAdvance();
    });
  }

  void _animateToPage(int index) {
    _revealController.reverse().then((_) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuint,
      );
      setState(() {
        _currentIndex = index;
        _isExploring = false;
      });
      _detailsController.reset();
      _revealController.forward();
    });
  }

  void _toggleExploreMode() {
    setState(() {
      _isExploring = !_isExploring;
    });

    if (_isExploring) {
      _detailsController.forward();
    } else {
      _detailsController.reverse();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _revealController.dispose();
    _detailsController.dispose();
    _shimmerController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _parallaxController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeController.value,
          child: Container(
            height: size.height,
            width: double.infinity,
            color: Colors.black,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Animated background pattern
                AnimatedBuilder(
                  animation: _parallaxController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.08,
                      child: Transform.translate(
                        offset: Offset(
                          math.sin(_parallaxController.value * math.pi) * 10,
                          math.cos(_parallaxController.value * math.pi) * 10,
                        ),
                        child: CustomPaint(
                          painter: LuxuryPatternPainter(
                            color: _jewelryStories[_currentIndex].color,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Full-screen PageView for images with Ken Burns effect
                PageView.builder(
                  controller: _pageController,
                  itemCount: _jewelryStories.length,
                  onPageChanged: (index) {
                    if (!_isExploring) {
                      setState(() {
                        _currentIndex = index;
                      });
                    }
                  },
                  itemBuilder: (context, index) {
                    final story = _jewelryStories[index];
                    if (story.isSpecialSlide) {
                      return _buildSpecialSlide();
                    }

                    return AnimatedBuilder(
                      animation: Listenable.merge(
                          [_revealController, _parallaxController]),
                      builder: (context, child) {
                        // Ken Burns effect - subtle zoom and pan
                        final zoomFactor = 1.05 +
                            0.01 *
                                math.sin(_parallaxController.value * math.pi);
                        final offsetX = 10 *
                            math.cos(_parallaxController.value * math.pi * 2);
                        final offsetY = 10 *
                            math.sin(_parallaxController.value * math.pi * 2);

                        return Opacity(
                          opacity: _revealController.value,
                          child: Transform.scale(
                            scale: zoomFactor,
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(story.mainImage),
                                  fit: BoxFit.cover,
                                  colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.3),
                                    BlendMode.darken,
                                  ),
                                ),
                              ),
                              // Apply a subtle vignette effect
                              foregroundDecoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: const [0.6, 1.0],
                                  radius: 1.2,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                // Overlay for content
                Positioned.fill(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _isExploring ? 0.85 : 0.0,
                    child: Container(
                      color: Colors.black,
                    ),
                  ),
                ),

                // Centered content overlay
                Positioned.fill(
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Spacer to push content to bottom
                        const Spacer(),

                        // Detail content when exploring
                        if (_isExploring &&
                            !_jewelryStories[_currentIndex].isSpecialSlide)
                          Expanded(
                            flex: 3,
                            child: AnimatedBuilder(
                              animation: _detailsController,
                              builder: (context, child) {
                                return Opacity(
                                  opacity: _detailsController.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Story elements in a row or column based on screen size
                                        Expanded(
                                          child: isMobile
                                              ? ListView(
                                                  children: _jewelryStories[
                                                          _currentIndex]
                                                      .storyElements
                                                      .map((element) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 16),
                                                            child: _buildStoryElement(
                                                                element,
                                                                _jewelryStories[
                                                                        _currentIndex]
                                                                    .color),
                                                          ))
                                                      .toList(),
                                                )
                                              : Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: _jewelryStories[
                                                          _currentIndex]
                                                      .storyElements
                                                      .map((element) =>
                                                          _buildStoryElement(
                                                              element,
                                                              _jewelryStories[
                                                                      _currentIndex]
                                                                  .color))
                                                      .toList(),
                                                ),
                                        ),

                                        // Story text
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "THE STORY",
                                                style: TextStyle(
                                                  color: _jewelryStories[
                                                          _currentIndex]
                                                      .color,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 2,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Text(
                                                _jewelryStories[_currentIndex]
                                                    .story,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  height: 1.6,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // Bottom section with title and controls
                        Container(
                          padding: const EdgeInsets.only(
                            left: 40,
                            right: 40,
                            bottom: 40,
                            top: 20,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 1.0],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title section with enhanced animation - now at bottom left
                              AnimatedBuilder(
                                animation: Listenable.merge(
                                    [_revealController, _scaleController]),
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _revealController.value *
                                        _scaleController.value,
                                    child: Transform.translate(
                                      offset: Offset(
                                          0, 30 - 30 * _revealController.value),
                                      child: Transform.scale(
                                        scale: 0.9 +
                                            (_scaleController.value * 0.1),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Animated brand text with shimmer effect
                                            ShaderMask(
                                              shaderCallback: (bounds) {
                                                return LinearGradient(
                                                  colors: [
                                                    _jewelryStories[
                                                            _currentIndex]
                                                        .color
                                                        .withOpacity(0.5),
                                                    _jewelryStories[
                                                            _currentIndex]
                                                        .color,
                                                    _jewelryStories[
                                                            _currentIndex]
                                                        .color
                                                        .withOpacity(0.5),
                                                  ],
                                                  stops: [
                                                    0.0,
                                                    _shimmerController.value,
                                                    1.0,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ).createShader(bounds);
                                              },
                                              child: const Text(
                                                "LAXMI JEWELS PRESENTS",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 3,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 10),

                                            // Main title with dramatic styling
                                            Text(
                                              _jewelryStories[_currentIndex]
                                                  .title,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: isMobile ? 18 : 28,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1,
                                                shadows: [
                                                  Shadow(
                                                    color: _jewelryStories[
                                                            _currentIndex]
                                                        .color
                                                        .withOpacity(0.7),
                                                    blurRadius: 10,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 8),

                                            // Tagline with animated pulse effect
                                            AnimatedBuilder(
                                                animation: _pulseController,
                                                builder: (context, child) {
                                                  return Transform.scale(
                                                    scale: 1.0 +
                                                        (_pulseController
                                                                .value *
                                                            0.03),
                                                    child: Text(
                                                      _jewelryStories[
                                                              _currentIndex]
                                                          .tagline,
                                                      style: TextStyle(
                                                        color: _jewelryStories[
                                                                _currentIndex]
                                                            .color,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        letterSpacing: 2,
                                                      ),
                                                    ),
                                                  );
                                                }),

                                            // Price tag with elegant styling
                                            if (!_jewelryStories[_currentIndex]
                                                .isSpecialSlide)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 16),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: _jewelryStories[
                                                            _currentIndex]
                                                        .color
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                      color: _jewelryStories[
                                                              _currentIndex]
                                                          .color,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    _jewelryStories[
                                                            _currentIndex]
                                                        .price,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 24),

                              // Controls row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Page indicators with animated transitions
                                  Row(
                                    children: List.generate(
                                      _jewelryStories.length,
                                      (index) => GestureDetector(
                                        onTap: () {
                                          if (!_isExploring) {
                                            _animateToPage(index);
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          margin:
                                              const EdgeInsets.only(right: 8),
                                          width:
                                              _currentIndex == index ? 30 : 10,
                                          height: 4,
                                          decoration: BoxDecoration(
                                            color: _currentIndex == index
                                                ? _jewelryStories[index].color
                                                : Colors.white.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Explore toggle button with enhanced animation
                                  if (!_jewelryStories[_currentIndex]
                                      .isSpecialSlide)
                                    AnimatedBuilder(
                                        animation: _pulseController,
                                        builder: (context, child) {
                                          return Transform.scale(
                                            scale: _isExploring
                                                ? 1.0
                                                : 1.0 +
                                                    (_pulseController.value *
                                                        0.05),
                                            child: GestureDetector(
                                              onTap: _toggleExploreMode,
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 15,
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: _isExploring
                                                      ? _jewelryStories[
                                                              _currentIndex]
                                                          .color
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: _jewelryStories[
                                                            _currentIndex]
                                                        .color,
                                                    width: 1,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  boxShadow: _isExploring
                                                      ? []
                                                      : [
                                                          BoxShadow(
                                                            color: _jewelryStories[
                                                                    _currentIndex]
                                                                .color
                                                                .withOpacity(
                                                                    0.3),
                                                            blurRadius: 8,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      _isExploring
                                                          ? Icons.close
                                                          : Icons
                                                              .explore_outlined,
                                                      color: _isExploring
                                                          ? Colors.black
                                                          : _jewelryStories[
                                                                  _currentIndex]
                                                              .color,
                                                      size: 16,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      _isExploring
                                                          ? "CLOSE"
                                                          : "EXPLORE",
                                                      style: TextStyle(
                                                        color: _isExploring
                                                            ? Colors.black
                                                            : _jewelryStories[
                                                                    _currentIndex]
                                                                .color,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating decorative elements
                if (!_isExploring)
                  AnimatedBuilder(
                      animation: _parallaxController,
                      builder: (context, child) {
                        return Positioned(
                          top: size.height * 0.2 +
                              (10 *
                                  math.sin(
                                      _parallaxController.value * math.pi)),
                          right: size.width * 0.1 +
                              (5 *
                                  math.cos(
                                      _parallaxController.value * math.pi)),
                          child: Opacity(
                            opacity: 0.7,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    _jewelryStories[_currentIndex]
                                        .color
                                        .withOpacity(0.5),
                                    _jewelryStories[_currentIndex]
                                        .color
                                        .withOpacity(0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialSlide() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background pattern
          Opacity(
            opacity: 0.1,
            child: CustomPaint(
              painter: LuxuryPatternPainter(
                color: _jewelryStories[_currentIndex].color,
              ),
            ),
          ),

          // Floating product cards
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    // First card
                    Positioned(
                      left: constraints.maxWidth * 0.1,
                      top: constraints.maxHeight * 0.2,
                      child: Transform.rotate(
                        angle: -0.1,
                        child: SizedBox(
                          width: constraints.maxWidth * 0.25,
                          height: constraints.maxHeight * 0.6,
                          child: ProductCard(
                            product: Product(
                              id: "1",
                              name: "Diamond Eternity Ring",
                              price: 8500,
                              images: [
                                "https://images.pexels.com/photos/5442465/pexels-photo-5442465.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
                              ],
                              certificateUrl: [],
                              videoUrl: [],
                              isFeatured: true,
                              sellerId: "1",
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              shape: ["Round"],
                              carat: 1.5,
                              cut: "Excellent",
                            ),
                            onAddToCart: () {},
                            onAddToWishlist: () {},
                            wishList: const [],
                          ),
                        ),
                      ),
                    ),

                    // Second card
                    Positioned(
                      right: constraints.maxWidth * 0.15,
                      top: constraints.maxHeight * 0.3,
                      child: Transform.rotate(
                        angle: 0.1,
                        child: SizedBox(
                          width: constraints.maxWidth * 0.25,
                          height: constraints.maxHeight * 0.6,
                          child: ProductCard(
                            product: Product(
                              id: "2",
                              name: "Sapphire Pendant",
                              price: 6500,
                              images: [
                                "https://images.pexels.com/photos/248077/pexels-photo-248077.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
                              ],
                              certificateUrl: [],
                              videoUrl: [],
                              isFeatured: true,
                              sellerId: "1",
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              shape: ["Oval"],
                              carat: 2.0,
                              cut: "Very Good",
                            ),
                            onAddToCart: () {},
                            onAddToWishlist: () {},
                            wishList: const [],
                          ),
                        ),
                      ),
                    ),

                    // Third card
                    Positioned(
                      left: constraints.maxWidth * 0.3,
                      bottom: constraints.maxHeight * 0.1,
                      child: Transform.rotate(
                        angle: -0.05,
                        child: SizedBox(
                          width: constraints.maxWidth * 0.25,
                          height: constraints.maxHeight * 0.6,
                          child: ProductCard(
                            product: Product(
                              id: "3",
                              name: "Emerald Earrings",
                              price: 7200,
                              images: [
                                "https://images.pexels.com/photos/13595793/pexels-photo-13595793.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
                              ],
                              certificateUrl: [],
                              videoUrl: [],
                              isFeatured: true,
                              sellerId: "1",
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                              shape: ["Pear"],
                              carat: 1.8,
                              cut: "Excellent",
                            ),
                            onAddToCart: () {},
                            onAddToWishlist: () {},
                            wishList: const [],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryElement(StoryElement element, Color color) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              element.icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            element.title,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            element.description,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Luxury pattern painter
class LuxuryPatternPainter extends CustomPainter {
  final Color color;

  LuxuryPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const double spacing = 40;
    final double rows = size.height / spacing;
    final double cols = size.width / spacing;

    // Draw horizontal lines
    for (int i = 0; i <= rows; i++) {
      final double y = i * spacing;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical lines
    for (int i = 0; i <= cols; i++) {
      final double x = i * spacing;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw diagonal pattern
    for (int i = -20; i <= rows + 20; i++) {
      final double y1 = i * spacing;
      canvas.drawLine(
        Offset(0, y1),
        Offset(size.width, y1 + size.width),
        paint,
      );
      canvas.drawLine(
        Offset(0, y1 + size.width),
        Offset(size.width, y1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class JewelryStory {
  final String title;
  final String tagline;
  final String mainImage;
  final String detailImage;
  final List<StoryElement> storyElements;
  final Color color;
  final String story;
  final String price;
  final bool isSpecialSlide;

  JewelryStory({
    required this.title,
    required this.tagline,
    required this.mainImage,
    required this.detailImage,
    required this.storyElements,
    required this.color,
    required this.story,
    required this.price,
    this.isSpecialSlide = false,
  });
}

class StoryElement {
  final IconData icon;
  final String title;
  final String description;
  final Offset position;

  StoryElement({
    required this.icon,
    required this.title,
    required this.description,
    required this.position,
  });
}
