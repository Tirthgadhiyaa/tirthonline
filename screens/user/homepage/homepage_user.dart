// lib/screens/user/homepage/homepage_user.dart
import 'package:flutter/material.dart';
import 'package:jewellery_diamond/core/layout/base_layout.dart';
import 'package:jewellery_diamond/gen/assets.gen.dart';
import 'package:jewellery_diamond/models/diamond_product_model.dart';
import 'package:jewellery_diamond/screens/user/homepage/widget/carousel_slider.dart';
import 'package:jewellery_diamond/screens/user/product_list_page/widgets/product_grid_widget.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../models/product_response_model.dart';
import '../../../models/diamond_product_model.dart';
import 'widget/company_banner.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_bloc.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_state.dart';
import 'package:jewellery_diamond/core/widgets/header.dart';
import 'package:jewellery_diamond/core/widgets/footer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'widget/hero_section/custom_design_service.dart';
import 'widget/hero_section/education_center.dart';
import 'widget/hero_section/lab_grown_banner.dart';
import 'widget/hero_section/models.dart';
import 'widget/hero_section/category_showcase.dart';
import 'widget/hero_section/featured_product.dart';
import 'widget/hero_section/testimonials.dart';
import 'widget/hero_section/craftsmanship.dart';
import 'package:jewellery_diamond/cubit/navigation_bloc.dart';

class HomepageUser extends StatefulWidget {
  static const routeName = '/';

  const HomepageUser({super.key});

  @override
  State<HomepageUser> createState() => _HomepageUserState();
}

class _HomepageUserState extends State<HomepageUser>
    with TickerProviderStateMixin {
  final List<String> bannerImages = [
    Assets.images.Necklace.path,
    Assets.images.Necklace.path,
    Assets.images.Necklace.path,
    Assets.images.Necklace.path,
  ];

  // Sample diamond products for the diamonds table section
  final List<DiamondProduct> sampleDiamondProducts = [
    DiamondProduct(
      id: '1',
      stockNumber: 'DIA001',
      shape: ['Round'],
      carat: 1.5,
      color: 'D',
      clarity: 'VS1',
      cut: 'Excellent',
      polish: 'Excellent',
      symmetry: 'Excellent',
      certificateLab: 'GIA',
      tablePercentage: 58.0,
      depth: 61.5,
    ),
    DiamondProduct(
      id: '2',
      stockNumber: 'DIA002',
      shape: ['Princess'],
      carat: 2.0,
      color: 'E',
      clarity: 'VS2',
      cut: 'Very Good',
      polish: 'Excellent',
      symmetry: 'Very Good',
      certificateLab: 'IGI',
      tablePercentage: 60.0,
      depth: 62.0,
    ),
    DiamondProduct(
      id: '3',
      stockNumber: 'DIA003',
      shape: ['Oval'],
      carat: 1.75,
      color: 'F',
      clarity: 'VVS1',
      cut: 'Excellent',
      polish: 'Excellent',
      symmetry: 'Excellent',
      certificateLab: 'GIA',
      tablePercentage: 59.0,
      depth: 61.0,
    ),
  ];

  final ScrollController _scrollController = ScrollController();

  // Hero section controllers
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;

  String _selectedCategory = "Engagement";

  // Category showcase data
  final List<CategoryShowcase> _categories = [
    CategoryShowcase(
      name: "Engagement",
      image:
          "https://images.unsplash.com/photo-1607703829739-c05b7beddf60?q=80&w=1974",
      icon: FontAwesomeIcons.ring,
      route: "/category/engagement",
    ),
    CategoryShowcase(
      name: "Necklaces",
      image:
          "https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1974",
      icon: FontAwesomeIcons.gem,
      route: "/category/necklaces",
    ),
    CategoryShowcase(
      name: "Earrings",
      image:
          "https://images.unsplash.com/photo-1629224316810-9d8805b95e76?q=80&w=1970",
      icon: FontAwesomeIcons.solidStar,
      route: "/category/earrings",
    ),
    CategoryShowcase(
      name: "Bracelets",
      image:
          "https://images.unsplash.com/photo-1611591437281-460bfbe1220a?q=80&w=1970",
      icon: FontAwesomeIcons.circleNotch,
      route: "/category/bracelets",
    ),
    CategoryShowcase(
      name: "Watches",
      image:
          "https://images.unsplash.com/photo-1619946794135-5bc917a27793?q=80&w=1972",
      icon: FontAwesomeIcons.clock,
      route: "/category/watches",
    ),
  ];

  // Testimonials data
  final List<CustomerTestimonial> _testimonials = [
    CustomerTestimonial(
      name: "Sarah Johnson",
      location: "New York, USA",
      image:
          "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=1976",
      testimonial:
          "The craftsmanship of my engagement ring exceeded all expectations. The attention to detail is remarkable.",
      rating: 5,
      productPurchased: "Platinum Diamond Solitaire",
    ),
    CustomerTestimonial(
      name: "Michael Chen",
      location: "Toronto, Canada",
      image:
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=1974",
      testimonial:
          "The custom design process was seamless, and the final piece perfectly captured our vision.",
      rating: 5,
      productPurchased: "Custom Sapphire Pendant",
    ),
    CustomerTestimonial(
      name: "Emma Rodriguez",
      location: "London, UK",
      image:
          "https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=1974",
      testimonial:
          "The vintage-inspired earrings I purchased are simply stunning. I receive compliments every time I wear them.",
      rating: 5,
      productPurchased: "Art Deco Diamond Earrings",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _selectCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  // Common section title style
  Widget _buildSectionTitle(
      String title, String subtitle, BuildContext context, double fontSize) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 60),
      child: Column(
        children: [
          // Premium decorative element above title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 1,
                color: const Color(0xFFD1B563).withOpacity(0.6),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.diamond_outlined,
                  size: 16,
                  color: Color(0xFFD1B563),
                ),
              ),
              Container(
                width: 40,
                height: 1,
                color: const Color(0xFFD1B563).withOpacity(0.6),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // Elegant title with refined typography
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                const Color(0xFFD1B563),
                Theme.of(context).colorScheme.primary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w300,
                letterSpacing: 3.0,
                height: 1.2,
                color: Colors.white, // This will be replaced by the gradient
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 6),

          // Luxurious divider
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 60,
            height: 1.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFD1B563),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Refined subtitle with elegant styling
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: fontSize * 0.45,
                fontWeight: FontWeight.w300,
                fontFamily:
                    'Cormorant', // Consider using a serif font for luxury feel
                fontStyle: FontStyle.italic,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.8),
                letterSpacing: 0.5,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Animated decorative element (add this to your dependencies if needed)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD1B563).withOpacity(0.7),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 25 * value,
                        height: 1,
                        color: const Color(0xFFD1B563).withOpacity(0.5),
                      ),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFD1B563),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        width: 25 * value,
                        height: 1,
                        color: const Color(0xFFD1B563).withOpacity(0.5),
                      ),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFD1B563).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth <= 1300;

    return Scaffold(
      appBar: isSmallScreen
          ? AppBar(
              title: const Text("Laxmi Jewells"),
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              ),
              scrolledUnderElevation: 0,
              foregroundColor: Colors.black,
              toolbarTextStyle: const TextStyle(color: Colors.black),
              titleTextStyle: const TextStyle(color: Colors.black),
              iconTheme: const IconThemeData(color: Colors.black),
              actionsIconTheme: const IconThemeData(color: Colors.black),
            )
          : null,
      drawer: isSmallScreen ? const AppDrawer() : null,
      body: Stack(
        children: [
          // Main content with custom scroll view
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Content
              SliverToBoxAdapter(
                child: LayoutBuilder(builder: (context, constraints) {
                  double titleFontSize = constraints.maxWidth * 0.04;
                  titleFontSize = titleFontSize.clamp(24, 36).toDouble();

                  double subtitleFontSize = constraints.maxWidth * 0.025;
                  subtitleFontSize = subtitleFontSize.clamp(16, 22).toDouble();

                  double descFontSize = constraints.maxWidth * 0.018;
                  descFontSize = descFontSize.clamp(14, 18).toDouble();

                  final isMobile = constraints.maxWidth < 600;
                  final isTablet =
                      constraints.maxWidth < 900 && constraints.maxWidth >= 600;
                  final colorScheme = Theme.of(context).colorScheme;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1. Hero section with carousel - now full screen
                      SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: double.infinity,
                        child: const HomePageCarouselSlider(),
                      ),

                      const SizedBox(height: 100),

                      // 2. Category showcase
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: _buildSectionTitle(
                            "Browse Our Collections",
                            "Discover our exquisite range of jewelry categories",
                            context,
                            titleFontSize),
                      ),
                      CategoryShowcaseWidget(
                        categories: _categories,
                        selectedCategory: _selectedCategory,
                        onCategorySelected: _selectCategory,
                        shimmerController: _shimmerController,
                      ),

                      const SizedBox(height: 100),

                      // 3. Featured product
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: _buildSectionTitle(
                            "Featured Collection",
                            "Explore our handpicked selection of exceptional pieces",
                            context,
                            titleFontSize),
                      ),
                      FeaturedProductWidget(
                        isMobile: isMobile,
                        colorScheme: colorScheme,
                        slideController: _slideController,
                      ),

                      const SizedBox(height: 100),

                      // 4. Diamonds Table Section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            _buildSectionTitle(
                                "Featured Diamonds",
                                "Browse our collection of certified diamonds",
                                context,
                                titleFontSize),
                            ProductGrid(
                              products: sampleDiamondProducts,
                              isHorzontal: false,
                              wishlistProducts: [],
                              isDiamond: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),

                      // 5. Jewelry Section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            _buildSectionTitle(
                                "Exclusive Jewelry Collection",
                                "Timeless pieces crafted with precision and passion",
                                context,
                                titleFontSize),
                            ProductGrid(
                              products: sampleProducts,
                              isHorzontal: false,
                              wishlistProducts: [],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),

                      // 6. Custom design service
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: _buildSectionTitle(
                            "Custom Design Service",
                            "Transform your vision into a unique masterpiece",
                            context,
                            titleFontSize),
                      ),
                      CustomDesignServiceWidget(
                        isMobile: isMobile,
                        colorScheme: colorScheme,
                      ),

                      const SizedBox(height: 100),

                      // 7. Craftsmanship section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: _buildSectionTitle(
                            "The Art of Excellence",
                            "Where Tradition Meets Innovation",
                            context,
                            titleFontSize),
                      ),
                      CraftsmanshipWidget(
                        isMobile: isMobile,
                        colorScheme: colorScheme,
                      ),

                      const SizedBox(height: 100),

                      // 8. Testimonials section
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: _buildSectionTitle(
                            "Customer Testimonials",
                            "Hear what our valued customers have to say",
                            context,
                            titleFontSize),
                      ),
                      TestimonialsWidget(
                        testimonials: _testimonials,
                        isMobile: isMobile,
                        isTablet: isTablet,
                        colorScheme: colorScheme,
                      ),

                      const SizedBox(height: 100),

                      // 9. Contact banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: _buildSectionTitle(
                            "Get in Touch",
                            "We're here to help you find your perfect piece",
                            context,
                            titleFontSize),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: Column(
                          children: [
                            ContactBanner(),
                            SizedBox(height: 40),
                          ],
                        ),
                      ),

                      // Footer
                      const FooterWidget(),
                    ],
                  );
                }),
              ),
            ],
          ),
          // Header overlay for large screens only
          if (!isSmallScreen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MegaMenuHeader(
                scrollController: _scrollController,
                isHomePage: true,
              ),
            ),
        ],
      ),
    );
  }
}
