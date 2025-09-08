// lib/screens/seller/products/seller_product_catalog.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'package:jewellery_diamond/bloc/seller_product_bloc/seller_product_bloc.dart';
import 'package:jewellery_diamond/bloc/seller_product_bloc/seller_product_event.dart';
import 'package:jewellery_diamond/bloc/seller_product_bloc/seller_product_state.dart';
import 'package:jewellery_diamond/screens/admin/products/widget/pagination_widget.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';
import 'package:intl/intl.dart';
import 'package:jewellery_diamond/screens/user/product_list_page/widgets/diamond_filter_panel_widget.dart';
import 'package:jewellery_diamond/widgets/under_construction_widget.dart';
import 'package:jewellery_diamond/core/widgets/custom_snackbar.dart';
import 'dart:html' as html;

import '../../../constant/admin_routes.dart';
import '../../../models/diamond_product_model.dart';

class SellerProductCatalogScreen extends StatefulWidget {
  static const String routeName = '/seller/products';

  const SellerProductCatalogScreen({super.key});

  @override
  SellerProductCatalogScreenState createState() =>
      SellerProductCatalogScreenState();
}

class SellerProductCatalogScreenState extends State<SellerProductCatalogScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  bool isGridView = true;
  String currentTab = "Diamond";
  String sortBy = "Latest";
  int currentPage = 1;

  int itemsPerPage = 20;
  String? selectedCategory;
  String? selectedPriceRange;
  String? selectedStatus;
  String? selectedDataFilter;
  String? selectedDateAdded;
  TextEditingController searchController = TextEditingController();
  Map<String, List<String>> selectedFilters = {};
  bool isFilterPanelOpen = false;
  bool isDiamondFilterVisible = true;
  Set<int> selectedIndices = {};
  List<String> selectedIds = [];

  Map<String, DiamondProduct> selectedDiamonds = {};

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _tableAnimation;

  // Map of filter options
  final Map<String, List<String>> filterOptions = {
    'Shape': [
      'Round',
      'Princess',
      'Cushion',
      'Oval',
      'Emerald',
      'Pear',
      'Marquise',
      'Radiant',
      'Heart',
      'Asscher'
    ],
    'Carat': ['0.5', '1.0', '1.5', '2.0', '3.0'],
    'Color': ['D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'Fancy'],
    'Clarity': [
      'FL',
      'IF',
      'VVS1',
      'VVS2',
      'VS1',
      'VS2',
      'SI1',
      'SI2',
      'I1',
      'I2'
    ],
    'Cut': ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor'],
    'Polish': ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor'],
    'Symmetry': ['Excellent', 'Very Good', 'Good', 'Fair', 'Poor'],
    'Lab': ['GIA', 'IGI', 'HRD', 'Other'],
  };

  // Stats calculations
  int get totalPieces => selectedDiamonds.length;
  double get totalCarats => selectedDiamonds.values
      .fold(0.0, (sum, diamond) => sum + (diamond.carat ?? 0.0));
  double get totalAmount => selectedDiamonds.values
      .fold(0.0, (sum, diamond) => sum + (diamond.price ?? 0.0));

  double get avgPricePerCarat {
    final carats = totalCarats;
    if (carats == 0) return 0.0;
    return totalAmount / carats;
  }

  @override
  void initState() {
    super.initState();
    isGridView = currentTab != "Diamond"; // Set grid view based on tab
    _fetchFilteredProducts();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create animations
    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _tableAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _applyFilters(Map<String, List<String>> filters) {
    setState(() {
      selectedFilters = Map<String, List<String>>.from(filters);
    });
    _fetchFilteredProducts();
  }

  void _fetchFilteredProducts() {
    // Create a map of filter parameters
    Map<String, dynamic> filterParams = {};

    // Add search parameter if search text is not empty
    if (searchController.text.isNotEmpty) {
      filterParams['search'] = searchController.text;
    }

    // Add category filter if selected
    if (selectedCategory != null && selectedCategory != 'All') {
      filterParams['category'] = selectedCategory;
    }

    // Add price range filter if selected
    if (selectedPriceRange != null && selectedPriceRange != 'All') {
      if (selectedPriceRange == 'Under \$2,000') {
        filterParams['min_price'] = 0;
        filterParams['max_price'] = 2000;
      } else if (selectedPriceRange == '\$2,000-\$5,000') {
        filterParams['min_price'] = 2000;
        filterParams['max_price'] = 5000;
      } else if (selectedPriceRange == 'Over \$5,000') {
        filterParams['min_price'] = 5000;
        filterParams['max_price'] = 1000000; // A high value to represent "over"
      }
    }

    // Add status filter if selected
    if (selectedStatus != null && selectedStatus != 'All') {
      filterParams['status'] = selectedStatus;
    }

    if (selectedDataFilter != null) {
      filterParams['scope'] = selectedDataFilter;
    }

    // Add date added filter if selected
    if (selectedDateAdded != null && selectedDateAdded != 'All') {
      DateTime now = DateTime.now();
      if (selectedDateAdded == 'Today') {
        filterParams['dateFrom'] = DateFormat('yyyy-MM-dd').format(now);
      } else if (selectedDateAdded == 'This Week') {
        DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
        filterParams['dateFrom'] = DateFormat('yyyy-MM-dd').format(weekStart);
      } else if (selectedDateAdded == 'This Month') {
        filterParams['dateFrom'] =
            DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
      }
    }

    // Add diamond filter panel filters
    if (selectedFilters.isNotEmpty) {
      // Process each filter category
      selectedFilters.forEach((category, values) {
        if (values.isNotEmpty) {
          switch (category) {
            case 'Shape':
              filterParams['shape'] = values;
              break;
            case 'Carat':
              if (values.length == 1) {
                // Parse the carat range string (e.g., "0.50-1.00")
                final caratRange = values.first.split('-');
                if (caratRange.length == 2) {
                  final minCarat = double.tryParse(caratRange[0]) ?? 0.0;
                  final maxCarat = double.tryParse(caratRange[1]) ?? 0.0;
                  if (minCarat > 0 || maxCarat > 0) {
                    filterParams['min_carat'] = minCarat;
                    filterParams['max_carat'] = maxCarat;
                  }
                }
              }
              break;
            case 'Color':
              filterParams['color'] = values;
              break;
            case 'Clarity':
              filterParams['clarity'] = values;
              break;
            case 'Cut':
              filterParams['cut'] = values;
              break;
            case 'Polish':
              filterParams['polish'] = values;
              break;
            case 'Symmetry':
              filterParams['symmetry'] = values;
              break;
            case 'Lab':
              filterParams['certificate_lab'] = values;
              break;
          }
        }
      });
    }

    // Convert filterParams to Map<String, List<String>>
    Map<String, List<String>> convertedFilters = {};
    filterParams.forEach((key, value) {
      if (value is List) {
        convertedFilters[key] = value.map((e) => e.toString()).toList();
      } else {
        convertedFilters[key] = [value.toString()];
      }
    });
    // Dispatch the event with all filter parameters
    context.read<SellerProductBloc>().add(
          FetchSellerProducts(
            page: currentPage,
            limit: itemsPerPage,
            search: searchController.text,
            category: currentTab,
            filters: convertedFilters,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SellerProductBloc, SellerProductState>(
      listener: (context, state) {
        if (state is SellerProductDeleteSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          _fetchFilteredProducts();
        } else if (state is SellerProductError) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.red,
          );
        } else if (state is SellerProductExportSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          _fetchFilteredProducts();
        } else if (state is SellerProductLoaded) {
          // Synchronize current page with state
          if (state.currentPage != currentPage) {
            setState(() {
              currentPage = state.currentPage;
            });
          }
        }
      },
      child: Scaffold(
        body: Column(
          children: [
            // Fixed Header Section
            // Compact Header with Title and Stats
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(_headerAnimation),
                child: _buildCompactHeader(Theme.of(context)),
              ),
            ),

            // Center View
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Top Filter Bar with Category Tabs and Search
                    FadeTransition(
                      opacity: _headerAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, -0.1),
                          end: Offset.zero,
                        ).animate(_headerAnimation),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: _buildTopFilterBar(Theme.of(context)),
                        ),
                      ),
                    ),

                    // Diamond Filter Panel (Collapsible)
                    if (isDiamondFilterVisible && currentTab == "Diamond")
                      FadeTransition(
                        opacity: _headerAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.1),
                            end: Offset.zero,
                          ).animate(_headerAnimation),
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: DiamondFilterPanel(
                              filterOptions: filterOptions,
                              onFilterChanged: _applyFilters,
                              initialFilters: selectedFilters,
                            ),
                          ),
                        ),
                      ),
                    //  Main Content
                    FadeTransition(
                      opacity: _tableAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(_tableAnimation),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 16),
                              _buildMainContent(),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fixed Pagination Footer
            BlocBuilder<SellerProductBloc, SellerProductState>(
              builder: (context, state) {
                if (state is SellerProductLoaded) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade200),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isSmallScreen = constraints.maxWidth < 600;
                        if (isSmallScreen) {
                          // Stack vertically on small screens
                          return Column(
                            children: [
                              // Top row: Items per page and total count
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Items per page selector
                                  Row(
                                    children: [
                                      Text(
                                        'Items per page:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      DropdownButton<int>(
                                        value: itemsPerPage,
                                        items:
                                            [10, 20, 50, 100].map((int value) {
                                          return DropdownMenuItem<int>(
                                            value: value,
                                            child: Text(
                                              value.toString(),
                                              style:
                                                  const TextStyle(fontSize: 11),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (int? newValue) {
                                          if (newValue != null) {
                                            setState(() {
                                              itemsPerPage = newValue;
                                              currentPage =
                                                  1; // Reset to first page
                                            });
                                            _fetchFilteredProducts();
                                          }
                                        },
                                        isDense: true,
                                        underline: const SizedBox(),
                                      ),
                                    ],
                                  ),
                                  // Total items count
                                  Text(
                                    'Total: ${state.totalItems} items',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Bottom row: Pagination controls
                              PaginationWidget(
                                currentPage: currentPage,
                                totalItems: state.totalItems,
                                itemsPerPage: itemsPerPage,
                                onPageChanged: (newPage) {
                                  print('Page changed to: $newPage'); // Debug
                                  setState(() {
                                    currentPage = newPage;
                                  });
                                  _fetchFilteredProducts();
                                },
                              ),
                            ],
                          );
                        }

                        // Horizontal layout for larger screens
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Items per page selector
                            Row(
                              children: [
                                Text(
                                  'Items per page:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                DropdownButton<int>(
                                  value: itemsPerPage,
                                  items: [10, 20, 50, 100].map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text(
                                        value.toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (int? newValue) {
                                    if (newValue != null) {
                                      setState(() {
                                        itemsPerPage = newValue;
                                        currentPage = 1; // Reset to first page
                                      });
                                      _fetchFilteredProducts();
                                    }
                                  },
                                  isDense: true,
                                  underline: const SizedBox(),
                                ),
                              ],
                            ),

                            // Pagination controls
                            PaginationWidget(
                              currentPage: currentPage,
                              totalItems: state.totalItems,
                              itemsPerPage: itemsPerPage,
                              onPageChanged: (newPage) {
                                print('Page changed to: $newPage'); // Debug
                                setState(() {
                                  currentPage = newPage;
                                });
                                _fetchFilteredProducts();
                              },
                            ),

                            // Total items count
                            Text(
                              'Total: ${state.totalItems} items',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 1200;
          final isMediumScreen = constraints.maxWidth > 800;
          final isSmallScreen = constraints.maxWidth > 600;

          // For very small screens, stack vertically
          if (!isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title section
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.diamond_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Products',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Manage your product catalog',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Stats section
                _buildCompactStatsSummary(theme),
                const SizedBox(height: 12),
                // Search field only
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      _fetchFilteredProducts();
                    },
                  ),
                ),
              ],
            );
          }

          // For small to medium screens, use horizontal layout with limited elements
          return Row(
            children: [
              // Left section - Title and subtitle
              Expanded(
                flex: isLargeScreen ? 2 : 1,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.diamond_outlined,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'My Products',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isMediumScreen)
                            Text(
                              'Manage your product catalog',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // search and filters
              Expanded(
                flex: isLargeScreen ? 3 : 2,
                child: Row(
                  children: [
                    // Search field
                    Expanded(
                      flex: 3,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: Icon(Icons.search, size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            isDense: true,
                          ),
                          onChanged: (value) {
                            _fetchFilteredProducts();
                          },
                        ),
                      ),
                    ),

                    if (isMediumScreen) ...[
                      const SizedBox(width: 12),

                      // Sort dropdown
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDataFilter,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 18),
                              isExpanded: true,
                              isDense: true,
                              hint: const Text('Data Filter',
                                  style: TextStyle(fontSize: 12)),
                              items: [
                                'own',
                                'all',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {

                                  selectedDataFilter = value?.toLowerCase() ?? 'all';
                                  print(selectedDataFilter);
                                });
                                _fetchFilteredProducts();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (isLargeScreen) ...[
                      const SizedBox(width: 16),

                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: sortBy,
                              padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 18),
                              isExpanded: true,
                              isDense: true,
                              hint: const Text('Sort',
                                  style: TextStyle(fontSize: 12)),
                              items: [
                                'Latest',
                                'Price: Low to High',
                                'Price: High to Low',
                                'Name: A to Z',
                                'Name: Z to A',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  sortBy = value ?? 'Latest';
                                });
                                _fetchFilteredProducts();
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Status dropdown
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedStatus,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 20),
                              isExpanded: true,
                              isDense: true,
                              hint: const Text('Status',
                                  style: TextStyle(fontSize: 13)),
                              items: [
                                'All',
                                'Active',
                                'Hold',
                                'Sold',
                                'Inactive',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedStatus = value;
                                });
                                _fetchFilteredProducts();
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Date added dropdown
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedDateAdded,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              icon: const Icon(Icons.keyboard_arrow_down,
                                  size: 20),
                              isExpanded: true,
                              isDense: true,
                              hint: const Text('Date Added',
                                  style: TextStyle(fontSize: 13)),
                              items: [
                                'All',
                                'Today',
                                'This Week',
                                'This Month',
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedDateAdded = value;
                                });
                                _fetchFilteredProducts();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (isMediumScreen) ...[
                const SizedBox(width: 16),
                // Right section - Stats summary
                _buildCompactStatsSummary(theme),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildCompactStatsSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCompactStatItem(
            label: 'Pieces',
            value: totalPieces.toString(),
            theme: theme,
          ),
          _buildCompactDivider(),
          _buildCompactStatItem(
            label: 'Carats',
            value: totalCarats.toStringAsFixed(2),
            theme: theme,
          ),
          _buildCompactDivider(),
          _buildCompactStatItem(
            label: 'Total',
            value: '\$${totalAmount.toStringAsFixed(2)}',
            theme: theme,
            valueColor: Colors.green.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem({
    required String label,
    required String value,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: valueColor ?? theme.colorScheme.primary,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactDivider() {
    return Container(
      height: 24,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 6),
    );
  }

  Widget _buildTopFilterBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 16, bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 1200;
          final isMediumScreen = constraints.maxWidth > 800;
          final isSmallScreen = constraints.maxWidth > 600;

          // For very small screens, stack vertically
          if (!isSmallScreen) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tabs
                Row(
                  children: [
                    Expanded(
                      child:
                          _buildCategoryTab("Diamond", currentTab == "Diamond"),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          _buildCategoryTab("Jewelry", currentTab == "Jewelry"),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Export button
                BlocBuilder<SellerProductBloc, SellerProductState>(
                  builder: (context, state) {
                    final hasProducts = state is SellerProductLoaded &&
                        state.products.isNotEmpty;

                    return SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: hasProducts
                            ? () {
                                if (state is SellerProductLoaded) {
                                  context.read<SellerProductBloc>().add(
                                      ExportSellerProductsToExcel(
                                          productIds: selectedIds.isEmpty
                                              ? state.products
                                                  .map((e) => e.id ?? '')
                                                  .where((id) => id.isNotEmpty)
                                                  .toList()
                                              : selectedIds));
                                }
                              }
                            : null,
                        icon: const Icon(Icons.download_outlined, size: 18),
                        label: const Text("Export to Excel"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          }

          // For larger screens, use horizontal layout
          return Row(
            children: [
              // Category tabs
              _buildCategoryTab("Diamond", currentTab == "Diamond"),
              const SizedBox(width: 16),
              _buildCategoryTab("Jewelry", currentTab == "Jewelry"),

              const Spacer(),

              // Export button
              BlocBuilder<SellerProductBloc, SellerProductState>(
                builder: (context, state) {
                  final hasProducts =
                      state is SellerProductLoaded && state.products.isNotEmpty;

                  return OutlinedButton.icon(
                    onPressed: hasProducts
                        ? () {
                            if (state is SellerProductLoaded) {
                              context.read<SellerProductBloc>().add(
                                  ExportSellerProductsToExcel(
                                      productIds: selectedIds.isEmpty
                                          ? state.products
                                              .map((e) => e.id ?? '')
                                              .where((id) => id.isNotEmpty)
                                              .toList()
                                          : selectedIds));
                            }
                          }
                        : null,
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: const Text("Export to Excel"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab(String title, bool isActive) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return InkWell(
          onTap: () {
            setState(() {
              currentTab = title;
              isGridView = title != "Diamond"; // Update grid view based on tab
            });
            _fetchFilteredProducts();
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 6 : 8,
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: isSmallScreen ? 12 : 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContent() {
    if (currentTab != "Diamond") {
      return const UnderConstructionWidget();
    }
    return BlocBuilder<SellerProductBloc, SellerProductState>(
      builder: (context, state) {
        if (state is SellerProductLoading) {
          return _buildLoadingState(Theme.of(context));
        } else if (state is SellerProductError) {
          return _buildErrorState(state.message, Theme.of(context));
        } else if (state is SellerProductLoaded) {
          if (state.products.isEmpty) {
            return _buildEmptyState(Theme.of(context));
          }
          return _buildDiamondTable(state, Theme.of(context));
        }
        return Container();
      },
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: theme.colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your products...',
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _fetchFilteredProducts,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Products Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products to your inventory or try different filters',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to add product page
            },
            icon: const Icon(Icons.add),
            label: const Text('Add New Product'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondTable(SellerProductLoaded state, ThemeData theme) {
    final isMobile = Device.mobile(context);
    final isTablet = Device.tablet(context);
    final isDesktop = Device.desktop(context);
    // Table Content - No fixed height, natural flow
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final isLargeScreen = availableWidth > 1200;
        final isMediumScreen = availableWidth > 800;
        final isSmallScreen = availableWidth > 600;

        return Container(
          width: availableWidth,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              // Make the table responsive to screen size
              width: isLargeScreen
                  ? math.max(availableWidth, 1400)
                  : isMediumScreen
                      ? math.max(availableWidth, 1000)
                      : math.max(availableWidth, 800),
              child: Theme(
                data: Theme.of(context).copyWith(
                  dividerTheme: DividerThemeData(
                    color: Colors.grey.shade200,
                    space: 0,
                    thickness: 1,
                    indent: 0,
                    endIndent: 0,
                  ),
                ),
                child: DataTable(
                  dataRowColor: WidgetStateProperty.all<Color>(Colors.white),
                  headingRowColor: WidgetStateProperty.all<Color>(
                      Theme.of(context).colorScheme.primary),
                  dividerThickness: 0.0,
                  headingRowHeight: 40,
                  columnSpacing: isDesktop
                      ? 50
                      : isTablet
                          ? 30
                          : 20,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  showCheckboxColumn: false,
                  columns: [
                    DataColumn(
                      label: Row(
                        children: [
                          Checkbox(
                            value:
                                selectedIds.length == state.products.length &&
                                    state.products.isNotEmpty,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  // Select all
                                  selectedIds = state.products
                                      .map((product) => product.id ?? '')
                                      .where((id) => id.isNotEmpty)
                                      .toList();
                                  selectedDiamonds = {
                                    for (var product in state.products)
                                      if (product.id != null)
                                        product.id!: product
                                  };
                                } else {
                                  // Deselect all
                                  selectedIds.clear();
                                  selectedDiamonds.clear();
                                }
                              });
                            },
                            fillColor: MaterialStateProperty.resolveWith(
                              (states) => Colors.white,
                            ),
                            checkColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const DataColumn(label: Text('Media')),
                    const DataColumn(label: Text('Stock Number')),
                    const DataColumn(label: Text('Shape')),
                    const DataColumn(label: Text('Carat')),
                    const DataColumn(label: Text('Color')),
                    const DataColumn(label: Text('Clarity')),
                    // Show cut, polish, symmetry only on medium screens and larger
                    if (isMediumScreen) ...[
                      const DataColumn(label: Text('Cut')),
                      const DataColumn(label: Text('Polish')),
                      const DataColumn(label: Text('Symmetry')),
                    ],
                    const DataColumn(label: Text('Lab')),
                    const DataColumn(label: Text('Price')),
                    const DataColumn(label: Text('Status')),
                    const DataColumn(label: Text('Actions')),
                  ],
                  rows: state.products.asMap().entries.map((entry) {
                    int index = entry.key;
                    var product = entry.value;
                    final isSelected = selectedIds.contains(product.id);
                    final hasImage =
                        product.images != null && product.images!.isNotEmpty;
                    final hasVideo = product.video_url != null &&
                        product.video_url!.isNotEmpty;
                    final hasCerti = product.certificate_url != null &&
                        product.certificate_url!.isNotEmpty;
                    var diamond = entry.value;
                    return DataRow(
                      color: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.hovered)) {
                          return theme.colorScheme.primary.withOpacity(0.05);
                        }
                        if (isSelected) {
                          return theme.colorScheme.primary.withOpacity(0.1);
                        }
                        return index.isEven
                            ? Colors.white
                            : Colors.grey.shade50;
                      }),
                      cells: [
                        DataCell(
                          Checkbox(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedIds.add(product.id ?? '');
                                  selectedDiamonds[product.id ?? ""] = product;
                                } else {
                                  selectedDiamonds.remove(product.id);
                                  selectedIds.remove(product.id ?? '');
                                }
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            activeColor: theme.colorScheme.primary,
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Tooltip(
                                message: hasImage
                                    ? 'View Image'
                                    : 'Image Unavailble',
                                child: IconButton(
                                  icon: Icon(
                                    hasImage
                                        ? Icons.image
                                        : Icons.image_not_supported_outlined,
                                    color: hasImage ? Colors.blue : Colors.grey,
                                    size: 20,
                                  ),
                                  onPressed: hasImage
                                      ? () {
                                          for (final imageUrl
                                              in product.images!) {
                                            html.window
                                                .open(imageUrl, '_blank');
                                          }
                                        }
                                      : null,
                                  padding: const EdgeInsets.all(5),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                              Tooltip(
                                message: hasVideo
                                    ? 'Watch Video'
                                    : 'Video Unavailble',
                                child: IconButton(
                                  icon: Icon(
                                      hasVideo
                                          ? Icons.videocam
                                          : Icons.videocam_off_outlined,
                                      color:
                                          hasVideo ? Colors.red : Colors.grey,
                                      size: 20),
                                  onPressed: hasVideo
                                      ? () {
                                          html.window.open(
                                              product.video_url!.first,
                                              '_blank');
                                        }
                                      : null,
                                  padding: const EdgeInsets.all(5),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                              Tooltip(
                                message: hasCerti
                                    ? 'View Certificate'
                                    : 'Certificate Unavailble',
                                child: IconButton(
                                  icon: Icon(
                                      hasCerti
                                          ? Icons.picture_as_pdf
                                          : Icons.not_interested_rounded,
                                      color:
                                          hasCerti ? Colors.green : Colors.grey,
                                      size: 20),
                                  onPressed: hasCerti
                                      ? () {
                                          html.window.open(
                                              product.certificate_url!.first,
                                              '_blank');
                                        }
                                      : null,
                                  padding: const EdgeInsets.all(5),
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(product.stockNumber ?? "N/A")),
                        DataCell(Text(product.shape?.join(', ') ?? 'N/A')),
                        DataCell(
                            Text(product.carat?.toStringAsFixed(2) ?? 'N/A')),
                        DataCell(Text(product.color ?? 'N/A')),
                        DataCell(Text(product.clarity ?? 'N/A')),
                        // Show cut, polish, symmetry only on medium screens and larger
                        if (isMediumScreen) ...[
                          DataCell(Text(product.cut ?? 'N/A')),
                          DataCell(Text(product.polish ?? 'N/A')),
                          DataCell(Text(product.symmetry ?? 'N/A')),
                        ],
                        DataCell(Text(product.certificateLab ?? 'N/A')),
                        DataCell(
                          Text(
                            product.price != null
                                ? '\$${product.price}'
                                : 'N/A',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(product.status ?? ''),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.status ?? 'N/A',
                              style: TextStyle(
                                color:
                                    _getStatusTextColor(product.status ?? ''),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                                onPressed: () {
                                  GoRouter.of(context).go(
                                      AppRoutes
                                          .sellerProductForm,
                                      extra:
                                      diamond);
                                },
                                tooltip: 'Edit',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                                onPressed: () {
                                  if (product.id != null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this product?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              context
                                                  .read<SellerProductBloc>()
                                                  .add(
                                                    DeleteSellerProduct(
                                                        productId: product.id!),
                                                  );
                                            },
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                tooltip: 'Delete',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade100;
      case 'hold':
        return Colors.amber.shade100;
      case 'sold':
        return Colors.blue.shade100;
      case 'inactive':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade800;
      case 'hold':
        return Colors.amber.shade800;
      case 'sold':
        return Colors.blue.shade800;
      case 'inactive':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade800;
    }
  }
}
