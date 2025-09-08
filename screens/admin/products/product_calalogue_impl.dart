// import 'package:flutter/cupertino.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jewellery_diamond/bloc/product_bloc/product_bloc.dart';
// import 'package:jewellery_diamond/bloc/product_bloc/product_event.dart';
// import 'package:jewellery_diamond/bloc/product_bloc/product_state.dart';
// import 'package:jewellery_diamond/models/product_response_model.dart';
// import 'package:jewellery_diamond/services/product_service.dart';
// import 'package:jewellery_diamond/widgets/cust_button.dart';
// import 'package:jewellery_diamond/widgets/responsive_ui.dart';
// import '../addproduct/add_product.dart';

// class ProductCatalogScreen extends StatefulWidget {
//   static const String routeName = '/productform';
//   const ProductCatalogScreen({super.key});

//   @override
//   ProductCatalogScreenState createState() => ProductCatalogScreenState();
// }

// class ProductCatalogScreenState extends State<ProductCatalogScreen> {
//   final ScrollController _scrollController = ScrollController();
//   final ProductService _productService = ProductService();

//   bool isGridView = true;
//   String currentTab = "Diamonds";
//   String sortBy = "Latest";
//   int currentPage = 1;
//   int totalPages = 10;
//   String? selectedCategory;
//   String? selectedPriceRange;
//   String? selectedStatus;
//   String? selectedDateAdded;
//   TextEditingController searchController = TextEditingController();
//   int skip = 0;
//   int limit = 10;
//   bool isLoadingMore = false;

//   @override
//   void initState() {
//     super.initState();
//     context.read<ProductBloc>().add(FetchProducts(
//           category: currentTab,
//           skip: skip,
//           limit: limit,
//         ));
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200) {
//       if (!isLoadingMore) {
//         _loadMoreProducts();
//       }
//     }
//   }

//   void _loadMoreProducts() {
//     if (context.read<ProductBloc>().state is ProductLoaded) {
//       final currentState = context.read<ProductBloc>().state as ProductLoaded;
//       if (currentState.hasMore) {
//         setState(() {
//           skip += limit;
//           isLoadingMore = true;
//         });
//         context.read<ProductBloc>().add(LoadMoreProducts(
//               skip: skip,
//               limit: limit,
//             ));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       controller: _scrollController,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Title and breadcrumb
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Product ',
//                   style: TextStyle(
//                     fontSize: 21,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   // Category tabs
//                   Row(
//                     children: [
//                       _buildCategoryTab("Diamonds", currentTab == "Diamonds"),
//                       const SizedBox(width: 10),
//                       const Spacer(),
//                       CustButton(
//                         onPressed: () {
//                           _showAddProductDialog();
//                         },
//                         icon: const Icon(Icons.add),
//                         child: const Text("Add New Product"),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Search and filters
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Container(
//                           height: 40,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(4),
//                             border: Border.all(color: Colors.grey.shade300),
//                           ),
//                           child: TextField(
//                             controller: searchController,
//                             decoration: const InputDecoration(
//                               hintText: 'Search products...',
//                               prefixIcon:
//                                   Icon(Icons.search, color: Colors.grey),
//                               border: InputBorder.none,
//                               contentPadding: EdgeInsets.symmetric(vertical: 8),
//                             ),
//                             onChanged: (value) {
//                               setState(() {
//                                 skip = 0;
//                               });
//                               context.read<ProductBloc>().add(FetchProducts(
//                                     category: currentTab,
//                                     search: value,
//                                     skip: skip,
//                                     limit: limit,
//                                   ));
//                             },
//                           ),
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       _buildFilterDropdown(
//                         "Category",
//                         ["All", "Diamonds", "Jewelry"],
//                         selectedCategory,
//                         (value) {
//                           setState(() {
//                             selectedCategory = value;
//                             skip = 0;
//                           });
//                           context.read<ProductBloc>().add(FetchProducts(
//                                 category: value,
//                                 skip: skip,
//                                 limit: limit,
//                               ));
//                         },
//                       ),
//                       const SizedBox(width: 12),
//                       _buildFilterDropdown(
//                         "Price Range",
//                         [
//                           "All",
//                           "Under \$2,000",
//                           "\$2,000-\$5,000",
//                           "Over \$5,000"
//                         ],
//                         selectedPriceRange,
//                         (value) {
//                           setState(() {
//                             selectedPriceRange = value;
//                             skip = 0;
//                           });
//                           // Add price range filter logic
//                         },
//                       ),
//                       const SizedBox(width: 12),
//                       _buildFilterDropdown(
//                         "Status",
//                         ["All", "In Stock", "Low Stock", "Out of Stock"],
//                         selectedStatus,
//                         (value) {
//                           setState(() {
//                             selectedStatus = value;
//                             skip = 0;
//                           });
//                           // Add status filter logic
//                         },
//                       ),
//                       const SizedBox(width: 12),
//                       _buildFilterDropdown(
//                         "Date Added",
//                         ["All", "Today", "This Week", "This Month"],
//                         selectedDateAdded,
//                         (value) {
//                           setState(() {
//                             selectedDateAdded = value;
//                             skip = 0;
//                           });
//                           // Add date filter logic
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 16),

//             // View toggles and sort
//             Row(
//               children: [
//                 Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(4),
//                   ),
//                   child: Row(
//                     children: [
//                       IconButton(
//                         icon: Icon(Icons.grid_view,
//                             color: isGridView
//                                 ? Theme.of(context).colorScheme.primary
//                                 : Colors.grey),
//                         onPressed: () => setState(() => isGridView = true),
//                         tooltip: "Grid View",
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.list,
//                             color: !isGridView
//                                 ? Theme.of(context).colorScheme.primary
//                                 : Colors.grey),
//                         onPressed: () => setState(() => isGridView = false),
//                         tooltip: "List View",
//                       ),
//                     ],
//                   ),
//                 ),
//                 const Spacer(),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey.shade300),
//                     borderRadius: BorderRadius.circular(4),
//                     color: Colors.white,
//                   ),
//                   child: DropdownButton<String>(
//                     underline: Container(),
//                     value: sortBy,
//                     items: [
//                       "Latest",
//                       "Price: Low to High",
//                       "Price: High to Low"
//                     ].map((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (value) {
//                       setState(() {
//                         sortBy = value!;
//                         skip = 0;
//                       });
//                       context.read<ProductBloc>().add(FetchProducts(
//                             category: currentTab,
//                             sortBy: value,
//                             sortOrder: value == "Price: Low to High" ? 1 : -1,
//                             skip: skip,
//                             limit: limit,
//                           ));
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Products grid or list
//             BlocBuilder<ProductBloc, ProductState>(
//               builder: (context, state) {
//                 if (state is ProductLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state is ProductError) {
//                   return Center(child: Text("Error: ${state.message}"));
//                 } else if (state is ProductLoaded) {
//                   final products = state.response.data.products;
//                   final total = state.response.data.total;

//                   return Column(
//                     children: [
//                       if (isGridView)
//                         GridView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           gridDelegate:
//                               SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: _getCrossAxisCount(context),
//                             childAspectRatio: 0.7,
//                             crossAxisSpacing: 16,
//                             mainAxisSpacing: 16,
//                           ),
//                           itemCount: products.length,
//                           itemBuilder: (context, index) {
//                             return _buildProductCard(products[index]);
//                           },
//                         )
//                       else
//                         ListView.builder(
//                           shrinkWrap: true,
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: products.length,
//                           itemBuilder: (context, index) {
//                             return _buildProductListItem(products[index]);
//                           },
//                         ),
//                       if (isLoadingMore)
//                         const Padding(
//                           padding: EdgeInsets.all(16.0),
//                           child: CircularProgressIndicator(),
//                         ),
//                       if (products.length < total)
//                         Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Center(
//                             child: Text(
//                               'Showing ${products.length} of $total products',
//                               style: TextStyle(
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 }
//                 return Container();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Calculate the appropriate height for the grid based on number of items and screen size
//   double _calculateGridHeight(int itemCount, BuildContext context) {
//     int crossAxisCount = _getCrossAxisCount(context);
//     int rowCount = (itemCount / crossAxisCount).ceil();
//     double itemHeight = MediaQuery.of(context).size.width /
//         crossAxisCount *
//         1.25; // Aspect ratio is 0.8
//     return rowCount * itemHeight;
//   }

//   // Calculate the appropriate height for the list based on number of items
//   double _calculateListHeight(int itemCount) {
//     return itemCount *
//         132.0; // Each list item is about 132 pixels high (120px + margin)
//   }

//   // Helper function to determine grid columns based on screen width
//   int _getCrossAxisCount(BuildContext context) {
//     double width = MediaQuery.of(context).size.width;
//     if (width > 1200) return 4;
//     if (width > 900) return 3;
//     if (width > 600) return 2;
//     return 1;
//   }

//   void _showAddProductDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Add New Product'),
//         content: Container(
//           width: 500,
//           child: const Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Product Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'SKU',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               SizedBox(height: 16),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Price',
//                   border: OutlineInputBorder(),
//                   prefixText: '\$',
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               // Add product logic
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Product added successfully')),
//               );
//             },
//             child: const Text('Add Product'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCategoryTab(String title, bool isActive) {
//     return InkWell(
//       onTap: () {
//         setState(() {
//           currentTab = title;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//         decoration: BoxDecoration(
//           color: isActive
//               ? Theme.of(context).colorScheme.primary
//               : Colors.transparent,
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color: isActive ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterDropdown(String title, List<String> items,
//       String? selectedValue, Function(String?) onChanged) {
//     return Container(
//       height: 40,
//       padding: const EdgeInsets.symmetric(horizontal: 12),
//       decoration: BoxDecoration(
//         color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
//         borderRadius: BorderRadius.circular(4),
//         // border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           hint: Text(title),
//           value: selectedValue,
//           icon: const Icon(Icons.keyboard_arrow_down),
//           items: items.map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: onChanged,
//         ),
//       ),
//     );
//   }

//   Widget _buildProductCard(Product product) {
//     return InkWell(
//       onTap: () {
//         _showProductDetailsDialog(product);
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Product image
//             Expanded(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius:
//                       const BorderRadius.vertical(top: Radius.circular(8)),
//                   color: Colors.grey.shade200,
//                   image: DecorationImage(
//                     image: NetworkImage(product.images.first),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),

//             // Product details
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name,
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Category: ${product.category}',
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '\$${product.price.toStringAsFixed(2)}',
//                     style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 18,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   _buildStatusBadge(product.stock > 10
//                       ? 'In Stock'
//                       : product.stock > 0
//                           ? 'Low Stock'
//                           : 'Out of Stock'),
//                   const SizedBox(height: 12),
//                   const Divider(),
//                   const SizedBox(height: 12),
//                   // Action buttons
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit_outlined, size: 20),
//                           onPressed: () => _showEditProductDialog(product),
//                           color: Colors.grey.shade600,
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                           tooltip: "Edit",
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.copy_outlined, size: 20),
//                           onPressed: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text('Product duplicated')),
//                             );
//                           },
//                           color: Colors.grey.shade600,
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                           tooltip: "Duplicate",
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete_outline, size: 20),
//                           onPressed: () =>
//                               _showDeleteConfirmationDialog(product),
//                           color: Colors.grey.shade600,
//                           padding: EdgeInsets.zero,
//                           constraints: const BoxConstraints(),
//                           tooltip: "Delete",
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProductListItem(Product product) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(8),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: InkWell(
//         onTap: () => _showProductDetailsDialog(product),
//         child: Row(
//           children: [
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 borderRadius:
//                     const BorderRadius.horizontal(left: Radius.circular(8)),
//                 color: Colors.grey.shade200,
//                 image: DecorationImage(
//                   image: NetworkImage(product.images.first),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             product.name,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Category: ${product.category}',
//                             style: TextStyle(
//                               color: Colors.grey.shade600,
//                               fontSize: 14,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           _buildStatusBadge(product.stock > 10
//                               ? 'In Stock'
//                               : product.stock > 0
//                                   ? 'Low Stock'
//                                   : 'Out of Stock'),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Text(
//                       '\$${product.price.toStringAsFixed(2)}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 18,
//                       ),
//                     ),
//                     const SizedBox(width: 20),
//                     Row(
//                       children: [
//                         IconButton(
//                           icon: const Icon(Icons.edit_outlined),
//                           onPressed: () => _showEditProductDialog(product),
//                           color: Colors.grey.shade600,
//                           tooltip: "Edit",
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.copy_outlined),
//                           onPressed: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text('Product duplicated')),
//                             );
//                           },
//                           color: Colors.grey.shade600,
//                           tooltip: "Duplicate",
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete_outline),
//                           onPressed: () =>
//                               _showDeleteConfirmationDialog(product),
//                           color: Colors.grey.shade600,
//                           tooltip: "Delete",
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showProductDetailsDialog(Product product) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Product Details'),
//         content: Container(
//           width: 500,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 height: 200,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   image: DecorationImage(
//                     image: NetworkImage(product.images.first),
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 product.name,
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 20,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Text('Category: ${product.category}'),
//               const SizedBox(height: 8),
//               Text(
//                 'Price: \$${product.price.toStringAsFixed(2)}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 18,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               _buildStatusBadge(product.stock > 10
//                   ? 'In Stock'
//                   : product.stock > 0
//                       ? 'Low Stock'
//                       : 'Out of Stock'),
//               const SizedBox(height: 16),
//               Text(
//                 'Description: ${product.description}',
//                 style: TextStyle(
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 'Stock: ${product.stock}',
//                 style: TextStyle(
//                   color: Colors.grey.shade700,
//                 ),
//               ),
//               if (product.specifications.diamond != null) ...[
//                 const SizedBox(height: 16),
//                 Text(
//                   'Diamond Specifications:',
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//                 Text('Carat: ${product.specifications.diamond.carat}'),
//                 Text('Cut: ${product.specifications.diamond.cut}'),
//                 Text('Color: ${product.specifications.diamond.color}'),
//                 Text('Clarity: ${product.specifications.diamond.clarity}'),
//               ],
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//           ElevatedButton(
//             onPressed: () => _showEditProductDialog(product),
//             child: const Text('Edit'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showEditProductDialog(Product product) {
//     final nameController = TextEditingController(text: product.name);
//     final priceController =
//         TextEditingController(text: product.price.toString());

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Edit Product'),
//         content: Container(
//           width: 500,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               TextField(
//                 controller: nameController,
//                 decoration: const InputDecoration(
//                   labelText: 'Product Name',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: priceController,
//                 decoration: const InputDecoration(
//                   labelText: 'Price',
//                   border: OutlineInputBorder(),
//                   prefixText: '\$',
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: product.stock > 10
//                     ? 'In Stock'
//                     : product.stock > 0
//                         ? 'Low Stock'
//                         : 'Out of Stock',
//                 decoration: const InputDecoration(
//                   labelText: 'Status',
//                   border: OutlineInputBorder(),
//                 ),
//                 items: ["In Stock", "Low Stock", "Out of Stock"]
//                     .map((status) => DropdownMenuItem(
//                           value: status,
//                           child: Text(status),
//                         ))
//                     .toList(),
//                 onChanged: (value) {},
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Product updated successfully')),
//               );
//             },
//             child: const Text('Save Changes'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               foregroundColor: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showDeleteConfirmationDialog(Product product) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Product'),
//         content: Text(
//             'Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('Product deleted')),
//               );
//             },
//             child: const Text('Delete'),
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.red,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBadge(String status) {
//     Color backgroundColor;
//     Color textColor = Colors.black54;

//     switch (status) {
//       case 'In Stock':
//         backgroundColor = Colors.green.shade200;
//         break;
//       case 'Low Stock':
//         backgroundColor = Colors.amber.shade200;
//         textColor = Colors.black87;
//         break;
//       case 'Out of Stock':
//         backgroundColor = Colors.red.shade200;
//         break;
//       default:
//         backgroundColor =
//             Theme.of(context).colorScheme.primary.withOpacity(0.5);
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         status,
//         style: TextStyle(
//           color: textColor,
//           fontSize: 12,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }
