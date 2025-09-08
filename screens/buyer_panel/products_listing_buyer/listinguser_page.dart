/* // lib/screens/user_panel/listinguser/listinguser_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jewellery_diamond/screens/buyer_panel/products_listing_buyer/widgets/buyer_product_grid_widget.dart';

import '../../../bloc/diamondproduct_bloc/diamond_bloc.dart';
import '../../../bloc/diamondproduct_bloc/diamond_state.dart';
import '../../../bloc/product_bloc/product_bloc.dart';
import '../../../bloc/product_bloc/product_event.dart';
import '../../../bloc/product_bloc/product_state.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../models/product_response_model.dart';
import '../../../utils/product_adapter.dart';
import '../../admin/products/widget/pagination_widget.dart';
import '../../user/product_list_page/widgets/diamond_filter_panel_widget.dart';

class ListinguserPage extends StatefulWidget {
  static const String routeName = '/user-listing';

  const ListinguserPage({super.key});

  @override
  State<ListinguserPage> createState() => _ListinguserPageState();
}

class _ListinguserPageState extends State<ListinguserPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  String sortOption = 'None';
  Map<String, List<String>> selectedFilters = {};
  late bool isNewArrivals;
  bool isDiamond = true;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedType;
  String? selectedShape;
  String sortBy = "Latest";
  int currentPage = 1;
  int itemsPerPage = 10;
  String? selectedPriceRange;
  String? selectedStatus;
  String? selectedDateAdded;
  TextEditingController searchController = TextEditingController();

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _filtersAnimation;
  late Animation<double> _contentAnimation;

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

  @override
  void initState() {
    super.initState();
    isNewArrivals = false;
    selectedType = ['Type']?.first;
    selectedSubCategory = ['SubCategory']?.first;

    // Set initial category filter if provided
    if (selectedFilters['Category']?.isNotEmpty ?? false) {
      selectedCategory = selectedFilters['Category']!.first;
    }

    // Set initial shape filter if provided
    if (selectedFilters['Shape']?.isNotEmpty ?? false) {
      selectedShape = selectedFilters['Shape']!.first;
    }

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create animations with different curves and delays
    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _filtersAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    );

    _contentAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    );

    // Start the animation
    _animationController.forward();

    _fetchProducts();
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
    Map<String, dynamic> filterParams = {};
    if (searchController.text.isNotEmpty) {
      filterParams['search'] = searchController.text;
    }
    if (selectedCategory != null && selectedCategory != 'All') {
      filterParams['category'] = selectedCategory;
    }
    if (selectedPriceRange != null && selectedPriceRange != 'All') {
      if (selectedPriceRange == 'Under ₹10,000') {
        filterParams['min_price'] = 0;
        filterParams['max_price'] = 10000;
      } else if (selectedPriceRange == '₹10,000 - ₹20,000') {
        filterParams['min_price'] = 10000;
        filterParams['max_price'] = 20000;
      } else if (selectedPriceRange == '₹50,000 and Above') {
        filterParams['min_price'] = 50000;
        filterParams['max_price'] = 10000000;
      }
    }
    if (selectedStatus != null && selectedStatus != 'All') {
      filterParams['status'] = selectedStatus;
    }
    if (selectedDateAdded != null && selectedDateAdded != 'All') {
      DateTime now = DateTime.now();
      if (selectedDateAdded == 'Today') {
        filterParams['dateFrom'] = now.toIso8601String().split('T').first;
      } else if (selectedDateAdded == 'This Week') {
        DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
        filterParams['dateFrom'] = weekStart.toIso8601String().split('T').first;
      } else if (selectedDateAdded == 'This Month') {
        filterParams['dateFrom'] =
            DateTime(now.year, now.month, 1).toIso8601String().split('T').first;
      }
    }
    if (selectedFilters.isNotEmpty) {
      selectedFilters.forEach((category, values) {
        if (values.isNotEmpty) {
          switch (category) {
            case 'Shape':
              filterParams['shape'] = values;
              break;
            case 'Carat':
              if (values.length == 1) {
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
    filterParams['skip'] = (currentPage - 1) * itemsPerPage;
    filterParams['limit'] = itemsPerPage;
    Map<String, List<String>> convertedFilters = {};
    filterParams.forEach((key, value) {
      if (value is List) {
        convertedFilters[key] = value.map((e) => e.toString()).toList();
      } else {
        convertedFilters[key] = [value.toString()];
      }
    });
    context.read<ProductBloc>().add(
          FetchProducts(
            page: currentPage,
            limit: itemsPerPage,
            search: searchController.text,
            category: selectedCategory,
            filters: convertedFilters,
            sortBy: sortBy,
            status: 'Active',
          ),
        );
  }

  void _fetchProducts() {
    Map<String, dynamic> filterParams = {};

    // Add search parameter
    if (searchController.text.isNotEmpty) {
      filterParams['search'] = searchController.text;
    }

    // Add category filter
    if (selectedCategory != null && selectedCategory != 'All') {
      filterParams['category'] = selectedCategory;
    }

    // Add price range filter with proper mapping
    if (selectedPriceRange != null && selectedPriceRange != 'All') {
      if (selectedPriceRange == 'Under ₹10,000') {
        filterParams['min_price'] = 0.0;
        filterParams['max_price'] = 10000.0;
      } else if (selectedPriceRange == '₹10,000 - ₹20,000') {
        filterParams['min_price'] = 10000.0;
        filterParams['max_price'] = 20000.0;
      } else if (selectedPriceRange == '₹50,000 and Above') {
        filterParams['min_price'] = 50000.0;
        filterParams['max_price'] = 10000000.0;
      }
    }

    // Add status filter
    if (selectedStatus != null && selectedStatus != 'All') {
      filterParams['status'] = selectedStatus;
    }

    // Add date added filter with proper format
    if (selectedDateAdded != null && selectedDateAdded != 'All') {
      DateTime now = DateTime.now();
      if (selectedDateAdded == 'Today') {
        filterParams['dateAdded'] = DateFormat('yyyy-MM-dd').format(now);
      } else if (selectedDateAdded == 'This Week') {
        DateTime weekStart = now.subtract(Duration(days: now.weekday - 1));
        filterParams['dateAdded'] = DateFormat('yyyy-MM-dd').format(weekStart);
      } else if (selectedDateAdded == 'This Month') {
        filterParams['dateAdded'] =
            DateFormat('yyyy-MM-dd').format(DateTime(now.year, now.month, 1));
      }
    }

    // Process diamond filter panel filters
    if (selectedFilters.isNotEmpty) {
      selectedFilters.forEach((category, values) {
        if (values.isNotEmpty) {
          switch (category) {
            case 'Shape':
              filterParams['shape'] = values;
              break;
            case 'Carat':
              if (values.length == 1) {
                final caratRange = values.first.split('-');
                if (caratRange.length == 2) {
                  filterParams['min_carat'] =
                      double.tryParse(caratRange[0]) ?? 0.0;
                  filterParams['max_carat'] =
                      double.tryParse(caratRange[1]) ?? 0.0;
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

    // Add pagination parameters
    filterParams['skip'] = (currentPage - 1) * itemsPerPage;
    filterParams['limit'] = itemsPerPage;

    // Add sorting parameter
    String apiSortBy = _mapSortByToApiValue(sortBy);
    int? sortOrder = _getSortOrderForValue(sortBy);

    // Dispatch the event with all parameters
    context.read<ProductBloc>().add(
          FetchProducts(
            skip: (currentPage - 1) * itemsPerPage,
            page: currentPage,
            limit: itemsPerPage,
            search: searchController.text,
            category: selectedCategory,
            minPrice: filterParams['min_price'] as double?,
            maxPrice: filterParams['max_price'] as double?,
            dateAdded: filterParams['dateAdded'] as String?,
            sortBy: apiSortBy,
            sortOrder: sortOrder,
            status: 'Active',
            filters: _convertToStringListMap(filterParams),
          ),
        );
  }

  // Helper method to map UI sort values to API values
  String _mapSortByToApiValue(String uiSortBy) {
    switch (uiSortBy) {
      case 'Price: Low to High':
        return 'price_asc';
      case 'Price: High to Low':
        return 'price_desc';
      case 'Name: A to Z':
        return 'name_asc';
      case 'Name: Z to A':
        return 'name_desc';
      default:
        return 'latest';
    }
  }

  // Helper method to get sort order
  int? _getSortOrderForValue(String uiSortBy) {
    switch (uiSortBy) {
      case 'Price: Low to High':
      case 'Name: A to Z':
        return 1;
      case 'Price: High to Low':
      case 'Name: Z to A':
        return -1;
      default:
        return null;
    }
  }

  // Helper method to convert filter parameters to the expected format
  Map<String, List<String>> _convertToStringListMap(
      Map<String, dynamic> params) {
    Map<String, List<String>> result = {};

    params.forEach((key, value) {
      if (value is List) {
        result[key] = value.map((e) => e.toString()).toList();
      } else if (value != null) {
        result[key] = [value.toString()];
      }
    });

    return result;
  }

  void _changePage(int page) {
    setState(() {
      currentPage = page;
    });
    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Header
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.2),
                  end: Offset.zero,
                ).animate(_headerAnimation),
                child: _buildHeader(theme),
              ),
            ),

            const SizedBox(height: 24),

            // Animated Filters
            // FadeTransition(
            //   opacity: _filtersAnimation,
            //   child: SlideTransition(
            //     position: Tween<Offset>(
            //       begin: const Offset(0, -0.1),
            //       end: Offset.zero,
            //     ).animate(_filtersAnimation),
            //     child: _buildSearchAndFilters(theme),
            //   ),
            // ),

            // const SizedBox(height: 24),

            // Animated Filter Panel
            FadeTransition(
              opacity: _filtersAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_filtersAnimation),
                child: DiamondFilterPanel(
                  filterOptions: filterOptions,
                  onFilterChanged: _applyFilters,
                  initialFilters: selectedFilters,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Animated Content
            FadeTransition(
              opacity: _contentAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(_contentAnimation),
                child: _buildProductContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.diamond_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Diamond Collection',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Explore our premium selection of diamonds',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildSearchAndFilters(theme)
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 1200;
        final isMediumScreen = constraints.maxWidth > 800;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.spaceBetween,
          children: [
            // Search field
            Container(
              width: isLargeScreen
                  ? 400
                  : isMediumScreen
                      ? 300
                      : 350,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: searchController,
                decoration: const InputDecoration(
                  hintText: 'Search diamonds...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                onChanged: (value) {
                  _fetchProducts();
                },
              ),
            ),

            // Sort dropdown
            Container(
              width: isLargeScreen ? 200 : constraints.maxWidth * 0.45,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: sortBy,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isExpanded: true,
                  items: [
                    'Latest',
                    'Price: Low to High',
                    'Price: High to Low',
                    'Name: A to Z',
                    'Name: Z to A',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      sortBy = value ?? 'Latest';
                    });
                    _fetchProducts();
                  },
                ),
              ),
            ),

            // Price range dropdown
            Container(
              width: isLargeScreen ? 200 : constraints.maxWidth * 0.45,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPriceRange,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isExpanded: true,
                  hint: const Text('Price Range '),
                  items: [
                    'All',
                    'Under ₹10,000',
                    '₹10,000 - ₹20,000',
                    '₹50,000 and Above',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriceRange = value;
                    });
                    _fetchProducts();
                  },
                ),
              ),
            ),

            // Date added dropdown
            Container(
              width: isLargeScreen ? 200 : constraints.maxWidth * 0.45,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedDateAdded,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  icon: const Icon(Icons.keyboard_arrow_down),
                  isExpanded: true,
                  hint: const Text('Date Added'),
                  items: [
                    'All',
                    'Today',
                    'This Week',
                    'This Month',
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDateAdded = value;
                    });
                    _fetchProducts();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductContent() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading diamonds...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          );
        } else if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _fetchProducts,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        } else if (state is ProductLoaded) {
          if (state.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.diamond_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Diamonds Found',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try adjusting your filters to find diamonds',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              BlocListener<DiamondBloc, DiamondState>(
                listener: (context, state) {
                  if (state is WishlistUpdateSuccess) {
                    showCustomSnackBar(
                      context: context,
                      message: state.message,
                      backgroundColor: Colors.green,
                    );
                    _fetchProducts();
                  }
                  if (state is CartUpdateSuccess) {
                    showCustomSnackBar(
                      context: context,
                      message: state.message,
                      backgroundColor: Colors.green,
                    );
                    _fetchProducts();
                  }
                  if (state is HoldUpdateSuccess) {
                    showCustomSnackBar(
                      context: context,
                      message: state.message,
                      backgroundColor: Colors.green,
                    );
                    _fetchProducts();
                  } else if (state is DiamondFailure) {
                    showCustomSnackBar(
                      context: context,
                      message: state.error,
                      backgroundColor: Colors.red,
                    );
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BuyerProductGrid(
                    isDiamond: isDiamond,
                    products: ProductAdapter.toUiProducts(state.products),
                    wishlistProducts: const [],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PaginationWidget(
                    currentPage: currentPage,
                    totalItems: state.totalProducts,
                    itemsPerPage: itemsPerPage,
                    onPageChanged: (newPage) {
                      _changePage(newPage);
                    },
                  ),
                ),
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
 */