import 'package:flash_api_call/flash_api_call.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flash_image/flash_image.dart';
import 'package:jewellery_diamond/core/layout/base_layout.dart';
import 'package:jewellery_diamond/models/product_response_model.dart' as api;
import 'package:jewellery_diamond/screens/user/product_list_page/widgets/product_grid_widget.dart';
import 'package:jewellery_diamond/widgets/cust_button.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/bloc/product_bloc/product_bloc.dart';
import 'package:jewellery_diamond/bloc/product_bloc/product_state.dart';
import 'package:jewellery_diamond/utils/product_adapter.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/services/api/product_service.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  int quantity = 1;
  late List<String> imageList;
  late String selectedImage;
  late List<String> videoList;
  bool isVideoSelected = false;
  VideoPlayerController? _videoPlayerController;
  bool _isVideoInitialized = false;
  String? selectedVideoUrl;

  final ScrollController _scrollController = ScrollController();
  int selectedIndex = 0;

  Timer? _debounceTimer;
  Offset? _lastProcessedOffset;
  Offset? _pointerOffset;
  bool _hovering = false;
  final GlobalKey _imageKey = GlobalKey();

  final double zoomScale = 2.5;
  final double zoomWindowSize = 500;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotateController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isWishlisted = false;
  int _selectedTab = 0;

  final Color _darkBlue = const Color(0xFF0A1A2A);

  late AnimationController _controller;
  late Animation<double> _animation;
  late PageController _pageController;
  final ProductService _productService = ProductService();
  late api.Product _product;
  bool _isLoading = true;
  String? _error;

  // Diamond clarity range for visual representation
  final List<String> _clarityRange = [
    'I3',
    'I2',
    'I1',
    'SI2',
    'SI1',
    'VS2',
    'VS1',
    'VVS2',
    'VVS1',
    'IF',
    'FL'
  ];

  // Diamond color range for visual representation (D is best, Z is worst)
  final List<String> _colorRange = [
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N'
  ];

  // Diamond cut quality range
  final List<String> _cutRange = [
    'Fair',
    'Good',
    'Very Good',
    'Excellent',
    'Ideal'
  ];

  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _loadProduct();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _pageController = PageController();
    _controller.forward();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutQuart,
    ));

    _fadeController.forward();
    _slideController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _rotateController.repeat(period: const Duration(seconds: 20));
      }
    });
  }

  Future<void> _loadProduct() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final product = await _productService.getProductById(widget.productId);
      if (product != null) {
        setState(() {
          _product = product;
          imageList = product.images;
          videoList = product.videoUrl;
          selectedImage = imageList.isNotEmpty
              ? imageList[0]
              : 'https://via.placeholder.com/400';
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Product not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        if (e is FlashException) {
          _error = e.getMessage;
        } else {
          _error = 'Something went wrong';
        }
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounceTimer?.cancel();
    _fadeController.dispose();
    _slideController.dispose();
    _rotateController.dispose();
    _controller.dispose();
    _pageController.dispose();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void increaseQuantity() => setState(() => quantity++);
  void decreaseQuantity() {
    if (quantity > 1) setState(() => quantity--);
  }

  void scrollLeft() {
    _scrollController.animateTo(
      math.max(0, _scrollController.offset - 100),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollRight() {
    _scrollController.animateTo(
      math.min(
        _scrollController.position.maxScrollExtent,
        _scrollController.offset + 100,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onHover(PointerHoverEvent event) {
    _debounceTimer?.cancel();
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(event.position);

    if (_lastProcessedOffset == null ||
        (_lastProcessedOffset! - local).distance > 2) {
      _debounceTimer = Timer(const Duration(milliseconds: 10), () {
        if (!mounted) return;
        setState(() {
          _pointerOffset = local;
          _lastProcessedOffset = local;
        });
      });
    }
  }

  Widget _shimmerLoadingProductDetails() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Container(
                        height: 250,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),

                      // Title
                      Container(
                        height: 20,
                        width: 200,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),

                      // Rating
                      Container(
                        height: 16,
                        width: 100,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),

                      // Price
                      Container(
                        height: 24,
                        width: 80,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),

                      // Description
                      ...List.generate(3, (index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Container(
                            height: 14,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      // Options
                      Row(
                        children: List.generate(3, (index) {
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            height: 32,
                            width: 64,
                            color: Colors.white,
                          );
                        }),
                      ),
                      const SizedBox(height: 24),

                      // Buttons
                      Container(
                        height: 48,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        height: 48,
                        width: double.infinity,
                        color: Colors.white,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Image
                      Container(
                        height: 400,
                        width: 400,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 32),

                      // Right: Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Container(
                              height: 24,
                              width: 300,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 12),

                            // Rating
                            Container(
                              height: 16,
                              width: 120,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),

                            // Price
                            Container(
                              height: 28,
                              width: 100,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 24),

                            // Description
                            ...List.generate(4, (index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  height: 14,
                                  width: double.infinity,
                                  color: Colors.white,
                                ),
                              );
                            }),
                            const SizedBox(height: 24),

                            // Options
                            Row(
                              children: List.generate(4, (index) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 12),
                                  height: 32,
                                  width: 64,
                                  color: Colors.white,
                                );
                              }),
                            ),
                            const SizedBox(height: 32),

                            // Buttons
                            Row(
                              children: [
                                Container(
                                  height: 48,
                                  width: 160,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  height: 48,
                                  width: 160,
                                  color: Colors.white,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return BaseLayout(
        body: _shimmerLoadingProductDetails(),
      );
    }

    if (_error != null) {
      return BaseLayout(
        body: SizedBox(
          height: 500,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                'Error loading product',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Product not found',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              CustButton(
                onPressed: _loadProduct,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (ctx, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final hPad = isMobile ? 16.0 : 50.0;

        return BaseLayout(
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
              child: Column(
                children: [
                  _buildBreadcrumbNavigation(),
                  if (isMobile) ...[
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: _buildProductImageWithZoom(isMobile),
                        ),
                      ),
                    ),
                    custSpace30Y,
                    _buildThumbnailGallery(),
                    custSpace30Y,
                    _buildDetailsColumn(),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                                child: Column(
                                  children: [
                                    _buildProductImageWithZoom(isMobile),
                                    custSpace30Y,
                                    _buildThumbnailGallery(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                            child: _buildDetailsColumn(),
                          ),
                        ),
                      ],
                    ),
                  ],
                  custSpace50Y,
                  if (_product.type == "Diamond" ||
                      _product.category == "Diamond") ...[
                    _buildDiamondDetailsSection(),
                    custSpace50Y,
                  ],
                  _buildElegantDivider("You May Also Like"),
                  custSpace30Y,
                  _buildProductRelatedGrid(_product),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBreadcrumbNavigation() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pushNamed(AppRouteNames.home),
            child: Text(
              "Home",
              style: TextStyle(
                color: _darkBlue.withOpacity(0.7),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: _darkBlue.withOpacity(0.7),
            ),
          ),
          GestureDetector(
            onTap: () {
              final category = _product?.category ?? 'Diamonds';
              final type = _product?.type ?? 'Diamond';
              final filters = <String, List<String>>{
                'Category': [category],
              };

              context.goNamed(
                AppRouteNames.productListByType,
                pathParameters: {'type': type},
                extra: {
                  'filters': filters,
                  'new_arrivals': false,
                },
              );
            },
            child: Text(
              _product?.category ?? "Diamonds",
              style: TextStyle(
                color: _darkBlue.withOpacity(0.7),
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: _darkBlue.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              _product?.name ?? "Product Name",
              style: TextStyle(
                color: _darkBlue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImageWithZoom(bool isMobile) {
    final imageWidget = Stack(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: isVideoSelected
                ? _buildVideoPlayer()
                : Image.network(
                    selectedImage,
                    fit: BoxFit.contain,
                    loadingBuilder: (c, child, prog) => prog == null
                        ? child
                        : Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                    errorBuilder: (c, e, st) => Center(
                      child: Icon(
                        Icons.error,
                        color: Theme.of(context).colorScheme.primary,
                        size: 40,
                      ),
                    ),
                  ),
          ),
        ),
        if (isVideoSelected &&
            !kIsWeb &&
            _videoPlayerController != null &&
            _isVideoInitialized)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_videoPlayerController!.value.isPlaying) {
                    _videoPlayerController!.pause();
                  } else {
                    _videoPlayerController!.play();
                  }
                });
              },
              child: Center(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Icon(
                    _videoPlayerController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 15,
          left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _darkBlue,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 14,
                ),
                const SizedBox(width: 6),
                const Text(
                  "CERTIFIED",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isMobile) {
      return InteractiveViewer(
        panEnabled: !isVideoSelected,
        minScale: 1,
        maxScale: isVideoSelected ? 1 : 3,
        child: imageWidget,
      );
    } else {
      return MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) {
          setState(() {
            _hovering = false;
            _pointerOffset = null;
            _lastProcessedOffset = null;
          });
          _debounceTimer?.cancel();
        },
        onHover: isVideoSelected ? null : _onHover,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Container(
                key: _imageKey,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: imageWidget,
              ),
            ),
            if (_hovering && _pointerOffset != null && !isVideoSelected)
              _buildZoomLens(),
          ],
        ),
      );
    }
  }

  Widget _buildZoomLens() {
    final box = _imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || _pointerOffset == null) return const SizedBox();
    final imageSize = box.size;
    final area = zoomWindowSize / zoomScale;

    double x =
        (_pointerOffset!.dx - area / 2).clamp(0.0, imageSize.width - area);
    double y =
        (_pointerOffset!.dy - area / 2).clamp(0.0, imageSize.height - area);

    return Positioned(
      left: x,
      top: y,
      width: area,
      height: area,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              width: 1.5),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (_videoPlayerController == null ||
        !_isVideoInitialized ||
        _chewieController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          child: Chewie(controller: _chewieController!),
        ),
        if (!_videoPlayerController!.value.isInitialized)
          const CircularProgressIndicator(),
      ],
    );
  }

  Widget _buildThumbnailGallery() {
    // Combine images and videos for the gallery
    final List<Map<String, dynamic>> galleryItems = [
      ...imageList.map((image) => {'type': 'image', 'url': image}),
      ...videoList.map((video) => {'type': 'video', 'url': video}),
    ];

    return SizedBox(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: galleryItems.length,
              itemBuilder: (ctx, i) {
                final item = galleryItems[i];
                bool isSelected = false;

                if (item['type'] == 'image') {
                  isSelected = selectedImage == item['url'] && !isVideoSelected;
                } else if (item['type'] == 'video') {
                  isSelected =
                      isVideoSelected && selectedVideoUrl == item['url'];
                }

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (item['type'] == 'image') {
                        // Reset video selection
                        isVideoSelected = false;
                        selectedVideoUrl = null;
                        _videoPlayerController?.dispose();
                        _chewieController?.dispose();
                        _videoPlayerController = null;
                        _chewieController = null;
                        _isVideoInitialized = false;
                        // Set image selection
                        selectedImage = item['url'];
                      } else {
                        // Reset image selection
                        selectedImage = imageList.first;
                        // Set video selection
                        isVideoSelected = true;
                        selectedVideoUrl = item['url'];
                        _videoPlayerController?.dispose();
                        _chewieController?.dispose();
                        _videoPlayerController =
                            VideoPlayerController.network(item['url']);
                        _videoPlayerController!.initialize().then((_) {
                          _chewieController = ChewieController(
                            videoPlayerController: _videoPlayerController!,
                            autoPlay: false,
                            looping: false,
                            aspectRatio:
                                _videoPlayerController!.value.aspectRatio,
                            allowFullScreen: true,
                            allowMuting: true,
                            showControls: true,
                            placeholder: Center(
                              child: Image.network(
                                selectedImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                          setState(() {
                            _isVideoInitialized = true;
                          });
                        });
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: item['type'] == 'image'
                              ? FlashImage(
                                  imgURL: item['url'],
                                  width: 100,
                                  height: 100,
                                  boxfit: BoxFit.cover,
                                )
                              : Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.black,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (isSelected && _isVideoInitialized)
                                        const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      else
                                        const Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      Positioned(
                                        bottom: 5,
                                        right: 5,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Icon(
                                            Icons.videocam,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // _buildNavigationButton(true),
          // _buildNavigationButton(false),
        ],
      ),
    );
  }

  Widget _buildNavigationButton(bool isLeft) {
    return Positioned(
      left: isLeft ? 0 : null,
      right: isLeft ? null : 0,
      child: Container(
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
            isLeft ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
            size: 16,
            color: _darkBlue,
          ),
          onPressed: () {
            if (!_scrollController.hasClients) return;

            final currentOffset = _scrollController.offset;
            final maxScroll = _scrollController.position.maxScrollExtent;
            final scrollAmount = 100.0;

            if (isLeft) {
              if (currentOffset > 0) {
                _scrollController.animateTo(
                  math.max(0, currentOffset - scrollAmount),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            } else {
              if (currentOffset < maxScroll) {
                _scrollController.animateTo(
                  math.min(maxScroll, currentOffset + scrollAmount),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          splashRadius: 20,
        ),
      ),
    );
  }

  Widget _buildDetailsColumn() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        return Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _product?.category?.toUpperCase() ?? "EARRINGS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    custSpace10Y,
                    Row(
                      children: [
                        Text(
                          _product?.name ?? "Luminous Pearl Drop Earrings",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: _darkBlue,
                            height: 1.2,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        _buildStatusWidget(),
                      ],
                    ),
                    custSpace15Y,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "₹${_product?.price ?? "12,999"}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "20% OFF",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _darkBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    custSpace10Y,
                    Text(
                      "EMI from ₹${(_product?.price ?? 12999) ~/ 12}/month",
                      style: TextStyle(
                        fontSize: 14,
                        color: _darkBlue.withOpacity(0.7),
                      ),
                    ),
                    custSpace20Y,
                    Row(
                      children: [
                        _buildFeatureChip(
                          _product.shape != null && _product.shape!.isNotEmpty
                              ? _product.shape!.first
                              : "Round",
                          Icons.diamond_outlined,
                        ),
                        const SizedBox(width: 10),
                        _buildFeatureChip(
                          "${_product.carat ?? "2.5"} Carat",
                          Icons.scale,
                        ),
                        const SizedBox(width: 10),
                        _buildFeatureChip(
                          _product.cut ?? "Excellent",
                          Icons.cut,
                        ),
                      ],
                    ),
                    custSpace30Y,
                    _buildRatingWidget(),
                    custSpace30Y,
                    Row(
                      children: [
                        Text(
                          "QUANTITY",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _darkBlue,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: _borderColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                onPressed: decreaseQuantity,
                                splashRadius: 20,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.symmetric(
                                    vertical: BorderSide(color: _borderColor),
                                  ),
                                ),
                                child: Text(
                                  quantity.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                onPressed: increaseQuantity,
                                splashRadius: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    custSpace30Y,
                    _buildActionButtons(),
                    custSpace30Y,
                    _buildQuickActionBar(),
                    custSpace40Y,
                    _buildTabbedContentSection(),
                  ],
                ),
              ),
            ),
            if (!isMobile && _hovering && _pointerOffset != null)
              ZoomViewWithLens(
                imagePath: selectedImage,
                imageKey: _imageKey,
                pointerOffset: _pointerOffset!,
                zoomScale: zoomScale,
                zoomWindowSize: zoomWindowSize,
              ),
          ],
        );
      },
    );
  }

  Widget _buildStatusWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            _getColorFromStatus(_product?.status ?? "active").withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _product.status ?? "In Stock",
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getColorFromStatus(String status) {
    switch (status) {
      case "active":
        return Colors.green;
      case "hold":
        return Colors.orange;
      case "sold":
        return Colors.red;
      case "inactive":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildRatingWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "4.8",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          custSpace8X,
          Row(
            children: List.generate(5, (index) {
              if (index < 4) {
                return Icon(Icons.star,
                    color: Theme.of(context).colorScheme.primary, size: 16);
              } else {
                return Stack(
                  children: [
                    Icon(Icons.star, color: Colors.grey.shade300, size: 16),
                    ClipRect(
                      clipper: _HalfClipper(),
                      child: Icon(Icons.star,
                          color: Theme.of(context).colorScheme.primary,
                          size: 16),
                    ),
                  ],
                );
              }
            }),
          ),
          custSpace8X,
          Container(
            height: 16,
            width: 1,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
          custSpace8X,
          Text(
            "42 Reviews",
            style: TextStyle(
              fontSize: 14,
              color: _darkBlue.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 18),
                  SizedBox(width: 8),
                  Text(
                    "ADD TO CART",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        custSpace15X,
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _darkBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flash_on,
                      color: Theme.of(context).colorScheme.secondary, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    "BUY NOW",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: _borderColor),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _iconTextButton(
            Icons.phone_outlined,
            "Enquiry",
            onTap: () {},
          ),
          _divider(),
          _iconTextButton(
            _isWishlisted ? Icons.favorite : Icons.favorite_border,
            "Wishlist",
            isActive: _isWishlisted,
            onTap: () {
              setState(() {
                _isWishlisted = !_isWishlisted;
              });
            },
          ),
          _divider(),
          _iconTextButton(
            Icons.share_outlined,
            "Share",
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildTabbedContentSection() {
    final tabs = [
      "DETAILS",
      if (_product.type == "Jewellery") "SPECIFICATIONS",
      "REVIEWS",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: _borderColor),
            ),
          ),
          child: Row(
            children: List.generate(tabs.length, (index) {
              final isSelected = _selectedTab == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTab = index;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color:
                          isSelected ? _darkBlue : _darkBlue.withOpacity(0.6),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 4),
          child: [
            _buildDescriptionContent(),
            if (_product.type == "Jewellery") _buildSpecificationsContent(),
            _buildReviewsContent(),
          ][_selectedTab],
        ),
      ],
    );
  }

  Widget _buildDescriptionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _product.description ?? "No description available",
          style: TextStyle(
            fontSize: 15,
            color: _darkBlue.withOpacity(0.8),
            height: 1.6,
            letterSpacing: 0.3,
          ),
        ),
        custSpace30Y,
        Text(
          "HIGHLIGHTS",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkBlue,
            letterSpacing: 1,
          ),
        ),
        custSpace15Y,
        if (_product.type == "Jewellery")
          Column(
            children: [
              _buildHighlightItem("Crafted in 18 Karat Yellow Gold"),
              _buildHighlightItem("Set with luminous pearls"),
              _buildHighlightItem(
                  "Perfect for both casual and formal occasions"),
              _buildHighlightItem("Comes with a luxury gift box"),
            ],
          )
        else
          Column(
            children: [
              _buildHighlightItem("Carat: ${_product.carat}"),
              _buildHighlightItem("Polish: ${_product.polish}"),
              _buildHighlightItem("Symmetry: ${_product.symmetry}"),
              _buildHighlightItem("Fluorescence: ${_product.fluorescence}"),
            ],
          ),
      ],
    );
  }

  Widget _buildHighlightItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: _darkBlue.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "METAL DETAILS",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkBlue,
            letterSpacing: 1,
          ),
        ),
        custSpace15Y,
        _buildDetailRow("18K", "Yellow", "2.935g", "Karatage",
            "Material Colour", "Gross Weight"),
        custSpace30Y,
        Text(
          "DIMENSIONS",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkBlue,
            letterSpacing: 1,
          ),
        ),
        custSpace15Y,
        _buildDetailRow(
            "Gold", "2 cm", "1 cm", "Metal", "Earring Height", "Earring Width"),
        custSpace30Y,
        Text(
          "GENERAL DETAILS",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkBlue,
            letterSpacing: 1,
          ),
        ),
        custSpace15Y,
        _buildDetailRow("Jewellery with Gemstones", "Drops", "Laxmi",
            "Jewellery Type", "Product Type", "Brand"),
        _buildDetailRow("Bestsellers", "Women", "Casual Wear", "Collection",
            "Gender", "Occasion"),
      ],
    );
  }

  Widget _buildReviewsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    "4.8",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "42 Reviews",
                    style: TextStyle(
                      fontSize: 14,
                      color: _darkBlue.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRatingBar(5, 0.7),
                  _buildRatingBar(4, 0.2),
                  _buildRatingBar(3, 0.05),
                  _buildRatingBar(2, 0.03),
                  _buildRatingBar(1, 0.02),
                ],
              ),
            ),
          ],
        ),
        custSpace30Y,
        _buildReviewItem(
          name: "Sophia R.",
          rating: 5,
          date: "2 months ago",
          comment:
              "Absolutely stunning earrings! The pearls catch the light beautifully and they're surprisingly lightweight. I've received so many compliments.",
        ),
        _buildReviewItem(
          name: "Aisha M.",
          rating: 4,
          date: "3 months ago",
          comment:
              "Beautiful design and excellent craftsmanship. The only reason for 4 stars instead of 5 is that the clasp is a bit difficult to manage.",
        ),
      ],
    );
  }

  Widget _buildRatingBar(int stars, double percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            "$stars",
            style: TextStyle(
              fontSize: 14,
              color: _darkBlue.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.star,
            color: Theme.of(context).colorScheme.primary,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${(percentage * 100).toInt()}%",
            style: TextStyle(
              fontSize: 14,
              color: _darkBlue.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required int rating,
    required String date,
    required String comment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _darkBlue,
                ),
              ),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: _darkBlue.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: _darkBlue.withOpacity(0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconTextButton(
    IconData icon,
    String text, {
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : _darkBlue.withOpacity(0.7),
          ),
          custSpace8X,
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color:
                  isActive ? Theme.of(context).colorScheme.primary : _darkBlue,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      height: 20,
      width: 1,
      color: _borderColor,
    );
  }

  Widget _buildDetailRow(String value1, String value2, String value3,
      String label1, String label2, String label3) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailColumn(value1, label1),
          Container(
            height: 40,
            width: 1,
            color: _borderColor,
          ),
          _buildDetailColumn(value2, label2),
          Container(
            height: 40,
            width: 1,
            color: _borderColor,
          ),
          _buildDetailColumn(value3, label3),
        ],
      ),
    );
  }

  Widget _buildDetailColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkBlue,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _darkBlue.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildProductRelatedGrid(api.Product product) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 350,
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoaded) {
                  final productsToShow = state.featuredProducts.products
                      .where((p) => p.id != product.id)
                      .take(4)
                      .toList();

                  return ProductGrid(
                    products: ProductAdapter.toUiProducts(productsToShow),
                    isHorzontal: true,
                    wishlistProducts: const [],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: _darkBlue,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantDivider(String text) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: _borderColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _darkBlue,
              letterSpacing: 1,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: _borderColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDiamondDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildElegantDivider("Diamond Details"),
        custSpace30Y,
        _buildDiamondCertificateInfo(),
        custSpace30Y,
        _buildDiamondQualityVisuals(),
      ],
    );
  }

  Widget _buildDiamondCertificateInfo() {
    if (_product == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "CERTIFICATE INFORMATION",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _darkBlue,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          custSpace20Y,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Certificate details
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCertificateDetailRow(
                      "Laboratory:",
                      _product?.certificateLab ?? "GIA",
                    ),
                    _buildCertificateDetailRow(
                      "Certificate Number:",
                      _product?.certificateNumber ?? "12345678",
                    ),
                    _buildCertificateDetailRow(
                      "Stock Number:",
                      _product?.stockNumber ?? "D123456",
                    ),
                    _buildCertificateDetailRow(
                      "Shape:",
                      _product?.shape?.join(", ") ?? "Round",
                    ),
                    custSpace15Y,
                    if (_product?.certificateUrl != null &&
                        _product!.certificateUrl.isNotEmpty)
                      ElevatedButton.icon(
                        onPressed: () async {
                          final url = Uri.parse(_product!.certificateUrl.first);
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          }
                        },
                        icon: const Icon(Icons.description_outlined),
                        label: const Text("View Certificate"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                  ],
                ),
              ),
              // Certificate image
              Expanded(
                flex: 2,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: _borderColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _product?.certificateLab != null
                      ? Image.asset(
                          "assets/images/certificates/${_product!.certificateLab?.toLowerCase() ?? 'gia'}.png",
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.verified,
                              size: 80,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.verified,
                            size: 80,
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _darkBlue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: _darkBlue.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondQualityVisuals() {
    if (_product == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DIAMOND QUALITY",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _darkBlue,
            letterSpacing: 1,
          ),
        ),
        custSpace20Y,
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return isMobile
                ? Column(
                    children: [
                      _buildQualityRatingCard(
                          "CUT", _product?.cut ?? "Excellent", _cutRange),
                      custSpace15Y,
                      _buildQualityRatingCard(
                          "COLOR", _product?.color ?? "D", _colorRange),
                      custSpace15Y,
                      _buildQualityRatingCard(
                          "CLARITY", _product?.clarity ?? "VS1", _clarityRange),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                          child: _buildQualityRatingCard(
                              "CUT", _product?.cut ?? "Excellent", _cutRange)),
                      const SizedBox(width: 15),
                      Expanded(
                          child: _buildQualityRatingCard(
                              "COLOR", _product?.color ?? "D", _colorRange)),
                      const SizedBox(width: 15),
                      Expanded(
                          child: _buildQualityRatingCard("CLARITY",
                              _product?.clarity ?? "VS1", _clarityRange)),
                    ],
                  );
          },
        ),
        custSpace30Y,
        _buildDiamondProportionsSection(),
      ],
    );
  }

  Widget _buildDiamondProportionsSection() {
    if (_product == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "DIAMOND PROPORTIONS",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _darkBlue,
              letterSpacing: 1,
            ),
          ),
          custSpace20Y,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Diamond Diagram
              Expanded(
                flex: 2,
                child: Container(
                  height: 200,
                  alignment: Alignment.center,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.diamond_outlined,
                        size: 120,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
                      ),
                      /* Image.network(
                        "https://www.diamonds.pro/wp-content/uploads/2021/03/diamond-diagram.png",
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.diamond_outlined,
                          size: 120,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.3),
                        ),
                      ), */
                      // Labels for measurements could be added here
                    ],
                  ),
                ),
              ),
              // Measurements
              Expanded(
                flex: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 380;
                    return isMobile
                        ? Column(
                            children: [
                              // First column of measurements
                              _buildMeasurementsGrid(),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First column of measurements
                              Expanded(child: _buildMeasurementsGrid()),
                              const SizedBox(width: 16),
                              // Second column of measurements
                              Expanded(
                                  child: _buildSecondaryMeasurementsGrid()),
                            ],
                          );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMeasurementRow("Table",
            "${_product?.tablePercentage?.toStringAsFixed(1) ?? 'N/A'}%"),
        _buildMeasurementRow(
            "Depth", "${_product?.depth?.toStringAsFixed(1) ?? 'N/A'}%"),
        _buildMeasurementRow("Crown Angle",
            "${_product?.crownAngle?.toStringAsFixed(1) ?? 'N/A'}°"),
        _buildMeasurementRow("Crown Height",
            "${_product?.crownHeight?.toStringAsFixed(1) ?? 'N/A'}%"),
        _buildMeasurementRow("Pavilion Angle",
            "${_product?.pavilionAngle?.toStringAsFixed(1) ?? 'N/A'}°"),
        _buildMeasurementRow("Pavilion Depth",
            "${_product?.pavilionDepth?.toStringAsFixed(1) ?? 'N/A'}%"),
      ],
    );
  }

  Widget _buildSecondaryMeasurementsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMeasurementRow(
            "Length", "${_product?.length?.toStringAsFixed(2) ?? 'N/A'} mm"),
        _buildMeasurementRow(
            "Width", "${_product?.width?.toStringAsFixed(2) ?? 'N/A'} mm"),
        _buildMeasurementRow(
            "Height", "${_product?.height?.toStringAsFixed(2) ?? 'N/A'} mm"),
        _buildMeasurementRow(
            "L/W Ratio", "${_product?.ratio?.toStringAsFixed(2) ?? 'N/A'}"),
        _buildMeasurementRow("Girdle", _product?.girdle ?? "N/A"),
        _buildMeasurementRow("Culet", _product?.culet ?? "N/A"),
      ],
    );
  }

  Widget _buildMeasurementRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _darkBlue,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: _darkBlue.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityRatingCard(
      String title, String value, List<String> range) {
    // Calculate rating position (0-1)
    double rating = 0;

    if (range.contains(value)) {
      // For clarity and cut, higher index is better
      if (title == "CUT") {
        rating = range.indexOf(value) / (range.length - 1);
      }
      // For color (D-Z), lower index is better
      else if (title == "COLOR") {
        rating = 1 - (range.indexOf(value) / (range.length - 1));
      }
      // For clarity (I3 to FL), higher index is better
      else if (title == "CLARITY") {
        rating = range.indexOf(value) / (range.length - 1);
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: _borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _darkBlue.withOpacity(0.7),
              letterSpacing: 1,
            ),
          ),
          custSpace8Y,
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: _darkBlue,
            ),
          ),
          custSpace15Y,
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Flexible(
                    flex: (rating * 100).toInt(),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.7),
                            Theme.of(context).colorScheme.primary,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 100 - (rating * 100).toInt(),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
          custSpace10Y,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title == "COLOR" ? "Best" : "Poor",
                style: TextStyle(
                  fontSize: 12,
                  color: _darkBlue.withOpacity(0.6),
                ),
              ),
              Text(
                title == "COLOR" ? "Poor" : "Best",
                style: TextStyle(
                  fontSize: 12,
                  color: _darkBlue.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color get _borderColor => Colors.grey.shade300;
}

class _HalfClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width / 2, size.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

class ZoomViewWithLens extends StatelessWidget {
  final String imagePath;
  final GlobalKey imageKey;
  final Offset pointerOffset;
  final double zoomScale;
  final double zoomWindowSize;

  const ZoomViewWithLens({
    super.key,
    required this.imagePath,
    required this.imageKey,
    required this.pointerOffset,
    this.zoomScale = 2.5,
    this.zoomWindowSize = 300,
  });

  @override
  Widget build(BuildContext context) {
    final box = imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return const SizedBox();

    final imageSize = box.size;

    final zoomWindowPosition = Container(
      width: zoomWindowSize,
      height: zoomWindowSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF800020), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
        color: Colors.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: -pointerOffset.dx * zoomScale + zoomWindowSize / 2,
            top: -pointerOffset.dy * zoomScale + zoomWindowSize / 2,
            child: Image.network(
              imagePath,
              width: imageSize.width * zoomScale,
              height: imageSize.height * zoomScale,
              fit: BoxFit.contain,
              loadingBuilder: (c, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF800020),
                      ),
                    ),
              errorBuilder: (c, e, st) => const Center(
                child: Icon(
                  Icons.error,
                  color: Color(0xFF800020),
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return zoomWindowPosition;
  }
}
