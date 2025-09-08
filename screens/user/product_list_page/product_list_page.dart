import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/bloc/product_bloc/product_bloc.dart';
import 'package:jewellery_diamond/bloc/product_bloc/product_event.dart';
import 'package:jewellery_diamond/bloc/product_bloc/product_state.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_bloc.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_event.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_state.dart';
import 'package:jewellery_diamond/core/layout/base_layout.dart';
import 'package:jewellery_diamond/models/product_response_model.dart';
import 'package:jewellery_diamond/screens/admin/products/widget/pagination_widget.dart';
import 'package:jewellery_diamond/utils/product_adapter.dart';

import 'widgets/filter_panel_widget.dart';
import 'widgets/diamond_filter_panel_widget.dart';
import 'widgets/product_grid_widget.dart';

class DiamondListPage extends StatefulWidget {
  static const String routeName = '/product-list';
  final Map<String, List<String>>? initialFilters;
  final String? type;
  final bool? newArrivals;

  const DiamondListPage({
    super.key,
    this.initialFilters,
    this.type,
    this.newArrivals,
  });

  @override
  DiamondListPageState createState() => DiamondListPageState();
}

class DiamondListPageState extends State<DiamondListPage> {
  final ScrollController _scrollController = ScrollController();
  String sortOption = 'None';
  Map<String, List<String>> selectedFilters = {};
  late bool isNewArrivals;
  bool isDiamond = false;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedType;
  String? selectedShape;
  int currentPage = 1;

  int itemsPerPage = 20;

  @override
  void initState() {
    super.initState();

    selectedFilters = widget.initialFilters ?? {};
    isNewArrivals = widget.newArrivals ?? false;
    isDiamond = widget.type == 'Diamond';
    selectedType = widget.initialFilters?['Type']?.first;
    selectedSubCategory = widget.initialFilters?['SubCategory']?.first;

    // Set initial category filter if provided
    if (selectedFilters['Category']?.isNotEmpty ?? false) {
      selectedCategory = selectedFilters['Category']!.first;
    }

    // Set initial shape filter if provided
    if (selectedFilters['Shape']?.isNotEmpty ?? false) {
      selectedShape = selectedFilters['Shape']!.first;
    }

    _fetchProducts();
  }

  @override
  void didUpdateWidget(DiamondListPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if any relevant parameters have changed
    if (widget.initialFilters != oldWidget.initialFilters ||
        widget.type != oldWidget.type ||
        widget.newArrivals != oldWidget.newArrivals) {
      // Update the state with new values
      setState(() {
        // Ensure we're working with a properly typed Map
        selectedFilters = Map<String, List<String>>.from(
          widget.initialFilters?.map((key, value) =>
              MapEntry(
                key,
                value is List
                    ? List<String>.from(value)
                    : [value.toString()],
              )) ??
              {},
        );
        isNewArrivals = widget.newArrivals ?? false;
        isDiamond = widget.type == 'Diamond';

        // Reset all selected values when filters are cleared
        if (selectedFilters.isEmpty) {
          selectedCategory = null;
          selectedSubCategory = null;
          selectedType = null;
          selectedShape = null;
        } else {
          selectedShape = selectedFilters['Shape']?.first;
          selectedSubCategory = selectedFilters['SubCategory']?.first;
          selectedType = selectedFilters['Type']?.first;

          // Update category filter if provided
          if (selectedFilters['Category']?.isNotEmpty ?? false) {
            selectedCategory = selectedFilters['Category']!.first;
          }

          // Update shape filter if provided
          if (selectedFilters['Shape']?.isNotEmpty ?? false) {
            selectedShape = selectedFilters['Shape']!.first;
          }
        }
      });

      // Fetch products with new parameters
      _fetchProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _fetchProducts() {
    double? minPrice;
    double? maxPrice;
    String? category = selectedCategory ?? selectedFilters['Category']?.first;
    String? subcategory =
        selectedSubCategory ?? selectedFilters['SubCategory']?.first;
    String? type = selectedType ?? selectedFilters['Type']?.first;
    String? metal;
    String? goldPurity;
    String? shape = selectedShape ?? selectedFilters['Shape']?.first;

    if (selectedFilters['Price']?.isNotEmpty ?? false) {
      final priceRange = selectedFilters['Price']!.first.split('-');
      if (priceRange.length == 2) {
        minPrice = double.tryParse(priceRange[0]);
        maxPrice = double.tryParse(priceRange[1]);
      }
    }

    if (isDiamond) {
      // Use DiamondBloc for diamond products
      context.read<DiamondBloc>().add(
        FetchPublicDiamondProducts(
          skip: (currentPage - 1) * itemsPerPage,
          limit: itemsPerPage,
          search: null,
          category: category,
          minPrice: minPrice,
          maxPrice: maxPrice,
          status: 'Active',
          filters: {
            if (shape != null) 'Shape': [shape],
            if (selectedFilters['Color']?.isNotEmpty ?? false)
              'Color': selectedFilters['Color']!,
            if (selectedFilters['Clarity']?.isNotEmpty ?? false)
              'Clarity': selectedFilters['Clarity']!,
            if (selectedFilters['Cut']?.isNotEmpty ?? false)
              'Cut': selectedFilters['Cut']!,
            if (selectedFilters['Polish']?.isNotEmpty ?? false)
              'Polish': selectedFilters['Polish']!,
            if (selectedFilters['Symmetry']?.isNotEmpty ?? false)
              'Symmetry': selectedFilters['Symmetry']!,
            if (selectedFilters['Carat']?.isNotEmpty ?? false)
              'Carat': selectedFilters['Carat']!
                  .first
                  .split('-')
                  .map((e) => e.trim())
                  .toList(),
          },
        ),
      );
    } else {
      // Use ProductBloc for regular products
      context.read<ProductBloc>().add(
        FetchProducts(
          category: category,
          subcategory: subcategory,
          minPrice: minPrice,
          maxPrice: maxPrice,
          type: type,
          sortBy: _getSortBy(),
          sortOrder: _getSortOrder(),
          page: 1,
          newArrivals: isNewArrivals,
          limit: 20,
        ),
      );
    }
  }

  void _changePage(int page) {
    final productState = context
        .read<ProductBloc>()
        .state;
    if (productState is ProductLoaded) {
      if (page < 1 || page > productState.totalPages) return;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      double? minPrice;
      double? maxPrice;
      String? category;
      String? subcategory;
      String? shape;
      String? metal;
      String? goldPurity;
      String? type;

      for (var entry in selectedFilters.entries) {
        switch (entry.key) {
          case 'Price':
            if (entry.value.isNotEmpty) {
              final priceRange = entry.value.first;
              if (priceRange == 'Below ₹10,000') {
                maxPrice = 10000;
              } else if (priceRange == '₹10,000 - ₹20,000') {
                minPrice = 10000;
                maxPrice = 20000;
              } else if (priceRange == '₹50,000 and Above') {
                minPrice = 50000;
              }
            }
            break;
          case 'Type':
            if (entry.value.isNotEmpty) {
              type = entry.value.first.toLowerCase();
            }
            break;
          case 'Metal':
            if (entry.value.isNotEmpty) {
              metal = entry.value.first;
            }
            break;
          case 'Gold Purity':
            if (entry.value.isNotEmpty) {
              goldPurity = entry.value.first;
            }
            break;
          case 'Shape':
            if (entry.value.isNotEmpty) {
              shape = entry.value.first;
            }
            break;
        }
      }

      // update selected filters
      selectedFilters = {
        'Price': [
          if (minPrice != null && maxPrice != null)
            '₹$minPrice - ₹$maxPrice'
          else
            if (minPrice != null)
              'Above ₹$minPrice'
            else
              if (maxPrice != null)
                'Below ₹$maxPrice'
              else
                'No Filter'
        ],
        'Type': [type ?? ''],
        'SubCategory': [subcategory ?? ''],
        'Shape': [shape ?? ''],
        'Metal': [metal ?? ''],
        'Gold Purity': [goldPurity ?? ''],
      };

      // Use the ChangeProductPage event instead
      context.read<ProductBloc>().add(ChangeProductPage(
        page: page,
        filters: selectedFilters,
        // Pass current filters
        sortBy: _getSortBy(),
        sortOrder: _getSortOrder(),
        type: type,
      ));
    }
  }

  String? _getSortBy() {
    switch (sortOption) {
      case 'priceLowHigh':
      case 'priceHighLow':
        return 'price';
      case 'caratLowHigh':
      case 'caratHighLow':
        return 'carat';
      default:
        return null;
    }
  }

  int? _getSortOrder() {
    switch (sortOption) {
      case 'priceLowHigh':
      case 'caratLowHigh':
        return 1;
      case 'priceHighLow':
      case 'caratHighLow':
        return -1;
      default:
        return null;
    }
  }

  void _handleFilterChanged(Map<String, List<String>> filters) {
    setState(() {
      // Ensure we're working with a properly typed Map
      selectedFilters = Map<String, List<String>>.from(
        filters.map((key, value) =>
            MapEntry(
              key,
              value is List ? List<String>.from(value) : [value.toString()],
            )),
      );

      // Reset category and subcategory when filters are cleared
      if (filters.isEmpty) {
        selectedCategory = null;
        selectedSubCategory = null;
        selectedType = null;
        selectedShape = null;
      } else {
        // Update selected values from filters
        selectedCategory = filters['Category']?.first;
        selectedSubCategory = filters['SubCategory']?.first;
        selectedType = filters['Type']?.first;
        selectedShape = filters['Shape']?.first;
      }
    });

    _fetchProducts();
  }

  Widget _buildPaginationControls() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is! ProductLoaded) {
          return Container();
        }

        final currentPage = state.currentPage;
        final totalPages = state.totalPages;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.first_page),
              onPressed: currentPage > 1 ? () => _changePage(1) : null,
              tooltip: 'First Page',
            ),
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed:
              currentPage > 1 ? () => _changePage(currentPage - 1) : null,
              tooltip: 'Previous Page',
            ),
            const SizedBox(width: 8),
            _buildPageIndicators(currentPage, totalPages),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: currentPage < totalPages
                  ? () => _changePage(currentPage + 1)
                  : null,
              tooltip: 'Next Page',
            ),
            IconButton(
              icon: const Icon(Icons.last_page),
              onPressed: currentPage < totalPages
                  ? () => _changePage(totalPages)
                  : null,
              tooltip: 'Last Page',
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageIndicators(int currentPage, int totalPages) {
    const maxVisiblePages = 5;
    List<Widget> pageWidgets = [];

    int startPage = 1;
    int endPage = totalPages;

    if (totalPages > maxVisiblePages) {
      startPage = (currentPage - (maxVisiblePages ~/ 2))
          .clamp(1, totalPages - maxVisiblePages + 1);
      endPage = startPage + maxVisiblePages - 1;
    }

    for (int i = startPage; i <= endPage; i++) {
      pageWidgets.add(
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () => _changePage(i),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: i == currentPage
                    ? Theme
                    .of(context)
                    .colorScheme
                    .primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary,
                ),
              ),
              child: Text(
                '$i',
                style: TextStyle(
                  color: i == currentPage
                      ? Colors.white
                      : Theme
                      .of(context)
                      .colorScheme
                      .primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(children: pageWidgets);
  }

  Widget _buildFilterPanel() {
    if (isDiamond) {
      return DiamondFilterPanel(
        onFilterChanged: _handleFilterChanged,
        initialFilters: selectedFilters,
        filterOptions: const {
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
          'Color': [
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
            'N',
            'Fancy'
          ],
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
          'Cut': ['Excellent', 'Very Good', 'Good', 'Fair'],
          'Polish': ['Excellent', 'Very Good', 'Good', 'Fair'],
          'Symmetry': ['Excellent', 'Very Good', 'Good', 'Fair'],
        },
      );
    } else {
      return FilterPanel(
        onFilterChanged: _handleFilterChanged,
        initialFilters: selectedFilters,
        filterOptions: const {
          'Price': ['Below ₹10,000', '₹10,000 - ₹20,000', '₹50,000 and Above'],
          'Type': ['Earrings', 'Rings', 'Pendants'],
          'Metal': ['Gold', 'Platinum', 'Rose Gold'],
          'Gender': ['Women', 'Men', 'Kids', "Unisex"],
          'Gold Purity': ['18k', '14k', '22k'],
          'Occassion': [
            'Occassion',
            'Weekend',
            'Romance',
            "Workwear",
            "Festive",
            "Tritiya"
          ],
        },
      );
    }
  }

  Widget _buildProductRecommendationGrid(Product product) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'You may also like',
            style: Theme
                .of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              fontWeight: FontWeight.w300,
            ),
          ),
          Divider(
            color: Theme
                .of(context)
                .colorScheme
                .primary
                .withOpacity(0.5),
            height: 50,
          ),
          SizedBox(
            height: 350,
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoaded) {
                  final productsToShow = state.featuredProducts.products
                      .where((p) => p.id != product.id)
                      .toList();

                  return ProductGrid(
                    products: ProductAdapter.toUiProducts(productsToShow),
                    isHorzontal: true,
                    wishlistProducts: const [],
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }

  double getResponsiveHorizontalPadding(double screenWidth) {
    if (screenWidth > 1600) return 200.0;
    if (screenWidth > 1200) return 50.0;
    if (screenWidth > 800) return 40.0;
    return 20.0;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isLargeScreen = screenWidth > 800;

    return BaseLayout(
      actions: isLargeScreen
          ? null
          : [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) =>
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery
                            .of(context)
                            .viewInsets
                            .bottom),
                    child: _buildFilterPanel(),
                  ),
            );
          },
        ),
      ],
      body: SingleChildScrollView(
        controller: _scrollController,
        child: isLargeScreen
            ? LayoutBuilder(
          builder: (context, constraints) {
            // Calculate responsive padding based on screen width
            final screenWidth = constraints.maxWidth;
            final horizontalPadding =
            getResponsiveHorizontalPadding(screenWidth);

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDiamond ? horizontalPadding : 20,
                vertical: 40,
              ),
              child: Column(
                children: [
                  if (isDiamond)
                    DiamondFilterPanel(
                      onFilterChanged: _handleFilterChanged,
                      initialFilters: selectedFilters,
                      filterOptions: const {
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
                        'Color': [
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
                          'N',
                          'Fancy'
                        ],
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
                        'Cut': ['Excellent', 'Very Good', 'Good', 'Fair'],
                        'Polish': [
                          'Excellent',
                          'Very Good',
                          'Good',
                          'Fair'
                        ],
                        'Symmetry': [
                          'Excellent',
                          'Very Good',
                          'Good',
                          'Fair'
                        ],
                      },
                    ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isDiamond)
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme
                                  .of(context)
                                  .colorScheme
                                  .scrim
                                  .withOpacity(0.03),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: _buildFilterPanel(),
                          ),
                        ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          margin:
                          EdgeInsets.only(left: isDiamond ? 0 : 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Color(0xFF0B2545).withOpacity(0.03),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  if (isDiamond)
                                    BlocBuilder<DiamondBloc,
                                        DiamondState>(
                                      builder: (context, state) {
                                        if (state is DiamondLoaded) {
                                          return Text(
                                            'Showing ${state.diamonds
                                                .length} Diamonds',
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                              color: Theme
                                                  .of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          );
                                        }
                                        return const Text('Loading...');
                                      },
                                    )
                                  else
                                    BlocBuilder<ProductBloc,
                                        ProductState>(
                                      builder: (context, state) {
                                        if (state is ProductLoaded) {
                                          final skip =
                                              (state.currentPage - 1) *
                                                  10;
                                          return Text(
                                            'Showing ${skip + 1} to ${skip +
                                                state.products
                                                    .length} of ${state
                                                .totalProducts} Products',
                                            style: Theme
                                                .of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                              color: Theme
                                                  .of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          );
                                        }
                                        return const Text('Loading...');
                                      },
                                    ),
                                  if (!isDiamond)
                                    Row(
                                      children: [
                                        const Text(
                                          'Sort by :',
                                          style: TextStyle(
                                              fontWeight:
                                              FontWeight.bold),
                                        ),
                                        const SizedBox(width: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                            BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: DropdownButton<String>(
                                            value: sortOption.isEmpty
                                                ? 'None'
                                                : sortOption,
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 10,
                                              vertical: 7,
                                            ),
                                            isDense: true,
                                            underline: Container(),
                                            focusColor: Colors.white,
                                            onChanged: (value) {
                                              setState(() {
                                                sortOption = value!;
                                              });
                                              context
                                                  .read<ProductBloc>()
                                                  .add(
                                                FetchProducts(
                                                  sortBy:
                                                  _getSortBy(),
                                                  sortOrder:
                                                  _getSortOrder(),
                                                  page: 1,
                                                ),
                                              );
                                            },
                                            items: const [
                                              DropdownMenuItem(
                                                value: 'None',
                                                child: Text('None',
                                                    style: TextStyle(
                                                        fontSize: 14)),
                                              ),
                                              DropdownMenuItem(
                                                value: 'priceLowHigh',
                                                child: Text(
                                                    'Price: Low to High'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'priceHighLow',
                                                child: Text(
                                                    'Price: High to Low'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'caratLowHigh',
                                                child: Text(
                                                    'Carat: Low to High'),
                                              ),
                                              DropdownMenuItem(
                                                value: 'caratHighLow',
                                                child: Text(
                                                    'Carat: High to Low'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              if (isDiamond)
                                BlocBuilder<DiamondBloc, DiamondState>(
                                  builder: (context, state) {
                                    if (state is DiamondLoading) {
                                      return const Center(
                                          child:
                                          CircularProgressIndicator());
                                    } else if (state is DiamondFailure) {
                                      return Center(
                                          child: Text(
                                              "Error: ${state.error}"));
                                    } else if (state is DiamondLoaded) {
                                      return Column(
                                        children: [
                                          ProductGrid(
                                            isDiamond: true,
                                            products: state.diamonds,
                                            wishlistProducts: const [],
                                          ),
                                          SizedBox(height: 25,),
                                          PaginationWidget(
                                              currentPage: state.currentPage,
                                              totalItems: state.totalitems??0,
                                              itemsPerPage: itemsPerPage,
                                              onPageChanged: (newPage) {
                                                print('Page changed to: $newPage'); // Debug
                                                setState(() {
                                                  currentPage = newPage;
                                                });
                                                _fetchProducts();
                                              },)
                                        ],
                                      );
                                    }
                                    return Container();
                                  },
                                )
                              else
                                BlocBuilder<ProductBloc, ProductState>(
                                  builder: (context, state) {
                                    if (state is ProductLoading) {
                                      return const Center(
                                          child:
                                          CircularProgressIndicator());
                                    } else if (state is ProductError) {
                                      return Center(
                                          child: Text(
                                              "Error: ${state.message}"));
                                    } else if (state is ProductLoaded) {
                                      return Column(
                                        children: [
                                          ProductGrid(
                                            isDiamond: false,
                                            products: ProductAdapter
                                                .toUiProducts(
                                                state.products),
                                            wishlistProducts: const [],
                                          ),
                                          const SizedBox(height: 24),
                                          _buildPaginationControls(),
                                        ],
                                      );
                                    }
                                    return Container();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        )
            : Column(
          children: [
            if (isDiamond)
              DiamondFilterPanel(
                onFilterChanged: _handleFilterChanged,
                initialFilters: selectedFilters,
                filterOptions: const {
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
                  'Color': [
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
                    'N',
                    'Fancy'
                  ],
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
                  'Cut': ['Excellent', 'Very Good', 'Good', 'Fair'],
                  'Polish': ['Excellent', 'Very Good', 'Good', 'Fair'],
                  'Symmetry': ['Excellent', 'Very Good', 'Good', 'Fair'],
                },
              ),
            if (isDiamond)
              BlocBuilder<DiamondBloc, DiamondState>(
                builder: (context, state) {
                  if (state is DiamondLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  } else if (state is DiamondFailure) {
                    return Center(child: Text("Error: ${state.error}"));
                  } else if (state is DiamondLoaded) {
                    return Column(
                      children: [
                        ProductGrid(
                          isDiamond: true,
                          products: state.diamonds,
                          wishlistProducts: const [],
                        ),
                        SizedBox(height: 25,),
                        PaginationWidget(
                          currentPage: state.currentPage,
                          totalItems: state.totalitems??0,
                          itemsPerPage: itemsPerPage,
                          onPageChanged: (newPage) {
                            print('Page changed to: $newPage'); // Debug
                            setState(() {
                              currentPage = newPage;
                            });
                            _fetchProducts();
                          },)
                      ],
                    );

                  }
                  return Container();
                },
              )
            else
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(
                        child: CircularProgressIndicator());
                  } else if (state is ProductError) {
                    return Center(child: Text("Error: ${state.message}"));
                  } else if (state is ProductLoaded) {
                    return ProductGrid(
                      isDiamond: false,
                      products:
                      ProductAdapter.toUiProducts(state.products),
                      wishlistProducts: const [],
                    );
                  }
                  return Container();
                },
              ),
            if (!isDiamond)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: _buildPaginationControls(),
              ),
          ],
        ),
      ),
    );
  }
}
