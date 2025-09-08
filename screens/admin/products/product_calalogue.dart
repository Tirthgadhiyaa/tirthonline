import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_bloc.dart';
import 'package:jewellery_diamond/bloc/diamondproduct_bloc/diamond_event.dart';
import 'package:jewellery_diamond/screens/admin/products/widget/pagination_widget.dart';
import 'package:jewellery_diamond/screens/user/product_list_page/widgets/diamond_filter_panel_widget.dart';
import 'package:jewellery_diamond/widgets/cust_button.dart';
import 'dart:html' as html;
import '../../../bloc/diamondproduct_bloc/diamond_state.dart';
import '../../../constant/admin_routes.dart';
import '../../../models/diamond_product_model.dart';
import '../../../widgets/responsive_ui.dart';
import 'package:intl/intl.dart';
import 'package:jewellery_diamond/core/widgets/custom_snackbar.dart';

class ProductCatalogScreen extends StatefulWidget {
  static const String routeName = '/productform';

  const ProductCatalogScreen({super.key});

  @override
  ProductCatalogScreenState createState() => ProductCatalogScreenState();
}

class ProductCatalogScreenState extends State<ProductCatalogScreen> {
  final ScrollController _scrollController = ScrollController();

  bool isGridView = true;
  String currentTab = "Diamonds";
  String sortBy = "Latest";
  int currentPage = 1;
  Set<int> selectedIndices = {};
  List<String> selectedIds = [];
  int itemsPerPage = 20;
  String? selectedCategory;
  String? selectedPriceRange;
  String? selectedStatus;
  String? selectedDateAdded;
  TextEditingController searchController = TextEditingController();
  Map<String, List<String>> selectedFilters = {};
  bool isFilterPanelOpen = false;

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
  Map<String, DiamondProduct> selectedDiamonds = {};

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
    context.read<DiamondBloc>().add(FetchDiamondProducts());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _applyFilters(Map<String, List<String>> filters) {
    print("-------$selectedFilters");
    setState(() {
      selectedFilters = Map<String, List<String>>.from(filters);
    });
    _fetchFilteredProducts();
  }

  Map<String, dynamic> filterParams = {};

  void _fetchFilteredProducts() {
    // Create a map of filter parameters

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

    // Add pagination parameters
    filterParams['skip'] = (currentPage - 1) * itemsPerPage;
    filterParams['limit'] = itemsPerPage;
    print("Current page: $currentPage");
    print("Skip: ${(currentPage - 1) * itemsPerPage}, Limit: $itemsPerPage");

    // Dispatch the event with all filter parameters
    context.read<DiamondBloc>().add(FilterDiamondProducts(
          filterParams: filterParams,
        ));
  }

  static const _headerPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 24);

  static const _headerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
    ),
    boxShadow: [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 4,
        offset: Offset(0, 2),
      ),
    ],
  );

  Widget _buildHeaderSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatCard('Pieces', '$totalPieces'),
          const SizedBox(width: 16),
          _buildStatCard('Carats', totalCarats.toStringAsFixed(2)),
          const SizedBox(width: 16),
          _buildStatCard('Avg Pr/Ct', avgPricePerCarat.toStringAsFixed(2)),
          const SizedBox(width: 16),
          _buildStatCard('Total Amount', '\$${totalAmount.toStringAsFixed(2)}',
              valueColor: Colors.green),
        ],
      ),
    );
  }

  // Widget _buildHeaderSection() {
  //   return Container(
  //     padding: _headerPadding,
  //     decoration: _headerDecoration,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SingleChildScrollView(
  //           scrollDirection: Axis.horizontal,
  //           child: Row(
  //             children: [
  //               _buildStatCard('Pieces', '$totalPieces'),
  //               const SizedBox(width: 16),
  //               _buildStatCard('Carats', totalCarats.toStringAsFixed(2)),
  //               const SizedBox(width: 16),
  //               _buildStatCard(
  //                   'Avg Pr/Ct', avgPricePerCarat.toStringAsFixed(2)),
  //               const SizedBox(width: 16),
  //               _buildStatCard(
  //                   'Total Amount', '\$${totalAmount.toStringAsFixed(2)}',
  //                   valueColor: Colors.green),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildStatCard(String label, String value,
      {Color valueColor = Colors.blue}) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        '$label: $value',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: valueColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DiamondBloc, DiamondState>(
      listener: (context, state) {
        if (state is DiamondDeleteSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          context.read<DiamondBloc>().add(FetchDiamondProducts());
        } else if (state is DiamondFailure) {
          showCustomSnackBar(
            context: context,
            message: state.error,
            backgroundColor: Colors.red,
          );
        } else if (state is AdminProductExportSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          context.read<DiamondBloc>().add(FetchDiamondProducts());
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Product Catalog',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Manage your product catalog here',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  CustButton(
                    onPressed: () {
                      GoRouter.of(context).go(AppRoutes.productForm);
                    },
                    icon: const Icon(Icons.add),
                    child: const Text("Add New Product"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
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
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextField(
                          controller: searchController,
                          decoration: const InputDecoration(
                            hintText: 'Search products...',
                            prefixIcon: Icon(Icons.search, color: Colors.grey),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onChanged: (value) {
                            // Debounce search to avoid too many API calls
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              if (mounted) {
                                _fetchFilteredProducts();
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildFilterDropdown(
                      "Category",
                      ["All", "Diamond", "Jewelry"],
                      selectedCategory,
                      (value) {
                        setState(() => selectedCategory = value);
                        _fetchFilteredProducts();
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildFilterDropdown(
                      "Price Range",
                      [
                        "All",
                        "Under \$2,000",
                        "\$2,000-\$5,000",
                        "Over \$5,000"
                      ],
                      selectedPriceRange,
                      (value) {
                        setState(() => selectedPriceRange = value);
                        _fetchFilteredProducts();
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildFilterDropdown(
                      "Status",
                      ["All", "Active", "Hold", "Sold", "Inactive"],
                      selectedStatus,
                      (value) {
                        setState(() => selectedStatus = value);
                        _fetchFilteredProducts();
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildFilterDropdown(
                      "Date Added",
                      ["All", "Today", "This Week", "This Month"],
                      selectedDateAdded,
                      (value) {
                        setState(() => selectedDateAdded = value);
                        _fetchFilteredProducts();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (currentTab == "Diamonds")
                DiamondFilterPanel(
                  filterOptions: filterOptions,
                  onFilterChanged: _applyFilters,
                  initialFilters: selectedFilters,
                ),
              if (currentTab == "Diamonds")
                BlocBuilder<DiamondBloc, DiamondState>(
                  builder: (context, state) {
                    if (state is DiamondLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is DiamondFailure) {
                      return Center(child: Text("Error: $state"));
                    } else if (state is DiamondLoaded) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: state.diamonds.isEmpty
                            ? Center(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.search_off_rounded,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No products found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Try adjusting your filters or search criteria',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Listener(
                                onPointerSignal: (event) {
                                  if (event is PointerScrollEvent &&
                                      event.scrollDelta.dy != 0) {
                                    if (event.kind == PointerDeviceKind.mouse &&
                                        RawKeyboard.instance.keysPressed
                                            .contains(
                                                LogicalKeyboardKey.shiftLeft)) {
                                      _scrollController.jumpTo(
                                        _scrollController.position.pixels +
                                            event.scrollDelta.dy,
                                      );
                                    }
                                  }
                                },
                                child: GestureDetector(
                                  onHorizontalDragUpdate: (details) {
                                    _scrollController.jumpTo(
                                      _scrollController.position.pixels -
                                          details.primaryDelta!,
                                    );
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 20),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Diamond List',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                  ),
                                            ),
                                            const Spacer(),
                                            Row(
                                              children: [
                                                _buildHeaderSection(),
                                                const SizedBox(width: 24),
                                                OutlinedButton.icon(
                                                  onPressed: () {
                                                    context
                                                        .read<DiamondBloc>()
                                                        .add(
                                                            ExportAdminProductsToExcel(
                                                          filterParams:
                                                              filterParams,
                                                        ));
                                                  },
                                                  icon: const Icon(
                                                      Icons.download_outlined,
                                                      size: 16),
                                                  label: const Text(
                                                      "Export to Excel"),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 24,
                                                        vertical: 16),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    side: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        controller: _scrollController,
                                        child: Theme(
                                          data: Theme.of(context).copyWith(
                                            dividerTheme: DividerThemeData(
                                              color: Colors.grey.shade300,
                                              space: 0,
                                              thickness: 1,
                                              indent: 0,
                                              endIndent: 0,
                                            ),
                                          ),
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.85,
                                            ),
                                            child: DataTable(
                                              dataRowColor:
                                                  MaterialStateProperty.all<
                                                      Color>(Colors.white),
                                              headingRowColor:
                                                  MaterialStateProperty
                                                      .resolveWith(
                                                (states) => Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                              dividerThickness: 0.0,
                                              headingRowHeight:
                                                  Device.mobile(context)
                                                      ? 50
                                                      : 60,
                                              dataRowHeight:
                                                  Device.mobile(context)
                                                      ? 40
                                                      : 40,
                                              headingTextStyle: TextStyle(
                                                fontSize: Device.mobile(context)
                                                    ? 13
                                                    : Device.tablet(context)
                                                        ? 14
                                                        : 15,
                                                fontWeight: FontWeight.w900,
                                                color: Colors.white,
                                              ),
                                              dataTextStyle: TextStyle(
                                                fontSize: Device.mobile(context)
                                                    ? 12
                                                    : Device.tablet(context)
                                                        ? 13
                                                        : 14,
                                                color: Colors.black,
                                              ),
                                              columnSpacing:
                                                  Device.desktop(context)
                                                      ? 20
                                                      : Device.tablet(context)
                                                          ? 30
                                                          : 20,
                                              columns: const [
                                                DataColumn(label: Text('')),
                                                DataColumn(
                                                    label: Text('Actions')),
                                                DataColumn(
                                                    label: Text('Status')),
                                                DataColumn(label: Text('')),
                                                DataColumn(
                                                    label:
                                                        Text('Stock Number')),
                                                DataColumn(
                                                    label: Text('Shape')),
                                                DataColumn(
                                                    label: Text('Carat')),
                                                DataColumn(
                                                    label: Text('Color')),
                                                DataColumn(
                                                    label: Text('Clarity')),
                                                DataColumn(label: Text('Cut')),
                                                DataColumn(
                                                    label: Text('Price')),
                                                DataColumn(label: Text('Lab')),
                                                DataColumn(
                                                    label: Text('Certificate')),
                                                DataColumn(
                                                    label: Text('Location')),
                                              ],
                                              rows: state.diamonds
                                                  .asMap()
                                                  .entries
                                                  .map((entry) {
                                                int index = entry.key;
                                                var diamond = entry.value;
                                                return DataRow(
                                                  color: MaterialStateColor
                                                      .resolveWith(
                                                    (states) => index.isOdd
                                                        ? const Color(
                                                            0xFFFAF3F3)
                                                        : Colors.white,
                                                  ),
                                                  cells: [
                                                    DataCell(
                                                      Checkbox(
                                                        value: selectedIds
                                                            .contains(
                                                                diamond.id),
                                                        onChanged:
                                                            (bool? value) {
                                                          setState(() {
                                                            if (value == true) {
                                                              selectedIds.add(
                                                                  diamond.id ??
                                                                      '');
                                                              selectedDiamonds[
                                                                      diamond.id ??
                                                                          ""] =
                                                                  diamond;
                                                            } else {
                                                              selectedDiamonds
                                                                  .remove(
                                                                      diamond
                                                                          .id);
                                                              selectedIds.remove(
                                                                  diamond.id ??
                                                                      '');
                                                            }
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () {
                                                              GoRouter.of(context).go(
                                                                  AppRoutes
                                                                      .productForm,
                                                                  extra:
                                                                      diamond);
                                                            },
                                                            icon: const Icon(
                                                                CupertinoIcons
                                                                    .pencil_circle),
                                                            tooltip: 'Edit',
                                                          ),
                                                          IconButton(
                                                            onPressed: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) =>
                                                                        AlertDialog(
                                                                  title: const Text(
                                                                      'Delete Product'),
                                                                  content:
                                                                      const Text(
                                                                          'Are you sure you want to delete this product? This action cannot be undone.'),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed:
                                                                          () =>
                                                                              Navigator.pop(context),
                                                                      child: const Text(
                                                                          'Cancel'),
                                                                    ),
                                                                    TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        context
                                                                            .read<DiamondBloc>()
                                                                            .add(DeleteDiamondProduct(productId: diamond.id!));
                                                                      },
                                                                      child: const Text(
                                                                          'Delete'),
                                                                      style: TextButton
                                                                          .styleFrom(
                                                                        foregroundColor:
                                                                            Colors.red,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                            icon: const Icon(
                                                                CupertinoIcons
                                                                    .delete,
                                                                color:
                                                                    Colors.red),
                                                            tooltip: 'Delete',
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: _getStatusColor(
                                                              diamond.status ??
                                                                  "Active"),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        child: Text(
                                                          diamond.status ??
                                                              "Active",
                                                          style: TextStyle(
                                                            color: _getStatusTextColor(
                                                                diamond.status ??
                                                                    "Active"),
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          if (diamond.images !=
                                                                  null &&
                                                              diamond.images!
                                                                  .isNotEmpty)
                                                            Tooltip(
                                                              message:
                                                                  'View Image',
                                                              child: IconButton(
                                                                icon: Icon(
                                                                    Icons.image,
                                                                    color: Colors
                                                                        .blue),
                                                                onPressed: () {
                                                                  for (final imageUrl
                                                                      in diamond
                                                                          .images!) {
                                                                    html.window.open(
                                                                        imageUrl,
                                                                        '_blank');
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          if (diamond.video_url !=
                                                                  null &&
                                                              diamond.video_url!
                                                                  .isNotEmpty)
                                                            Tooltip(
                                                              message:
                                                                  'Watch Video',
                                                              child: IconButton(
                                                                icon: Icon(
                                                                    Icons
                                                                        .videocam,
                                                                    color: Colors
                                                                        .red),
                                                                onPressed: () {
                                                                  html.window.open(
                                                                      diamond
                                                                          .video_url!
                                                                          .first,
                                                                      '_blank');
                                                                },
                                                              ),
                                                            ),
                                                          if (diamond.certificate_url !=
                                                                  null &&
                                                              diamond
                                                                  .certificate_url!
                                                                  .isNotEmpty)
                                                            Tooltip(
                                                              message:
                                                                  'View Certificate',
                                                              child: IconButton(
                                                                icon: Icon(
                                                                    Icons
                                                                        .picture_as_pdf,
                                                                    color: Colors
                                                                        .green),
                                                                onPressed: () {
                                                                  html.window.open(
                                                                      diamond
                                                                          .certificate_url!
                                                                          .first,
                                                                      '_blank');
                                                                },
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    DataCell(Text(
                                                        diamond.stockNumber)),
                                                    DataCell(Text(diamond.shape
                                                            ?.join(', ') ??
                                                        'N/A')),
                                                    DataCell(Text(diamond.carat
                                                            ?.toStringAsFixed(
                                                                2) ??
                                                        'N/A')),
                                                    DataCell(Text(
                                                        diamond.color ??
                                                            'N/A')),
                                                    DataCell(Text(
                                                        diamond.clarity ??
                                                            'N/A')),
                                                    DataCell(Text(
                                                        diamond.cut ?? 'N/A')),
                                                    DataCell(Text(diamond
                                                                .price !=
                                                            null
                                                        ? '\$${diamond.price}'
                                                        : 'N/A')),
                                                    DataCell(Text(diamond
                                                            .certificateLab ??
                                                        'N/A')),
                                                    DataCell(Text(diamond
                                                            .certificateNumber ??
                                                        'N/A')),
                                                    DataCell(Text(
                                                        diamond.location ??
                                                            'N/A')),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      BlocBuilder<DiamondBloc, DiamondState>(
                                        builder: (context, state) {
                                          if (state is DiamondLoaded) {
                                            return PaginationWidget(
                                              currentPage: currentPage,
                                              totalItems: state.totalitems!,
                                              itemsPerPage: itemsPerPage,
                                              onPageChanged: (newPage) {
                                                setState(() {
                                                  print("---$newPage");
                                                  currentPage = newPage;
                                                  _fetchFilteredProducts();
                                                });
                                              },
                                            );
                                          }
                                          return Container();
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      );
                    }
                    return Container();
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTab(String title, bool isActive) {
    return InkWell(
      onTap: () {
        setState(() {
          currentTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(String title, List<String> items,
      String? selectedValue, Function(String?) onChanged) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(title),
          value: selectedValue,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green.shade200;
      case 'hold':
        return Colors.amber.shade200;
      case 'sold':
        return Colors.blue.shade200;
      case 'inactive':
        return Colors.red.shade200;
      default:
        return Theme.of(context).colorScheme.primary.withOpacity(0.5);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.black54;
      case 'hold':
        return Colors.black87;
      case 'sold':
        return Colors.black54;
      case 'inactive':
        return Colors.black54;
      default:
        return Colors.black54;
    }
  }
}
