import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import '../../../../models/product_response_model.dart';
import '../../../../models/diamond_product_model.dart';
import '../../../../widgets/responsive_ui.dart';
import '../../../admin/products/widget/pagination_widget.dart';
import 'product_card_widget.dart';
import '../../../../utils/shared_preference.dart';

class ProductGrid extends StatefulWidget {
  final List<dynamic> products;
  final List<String> wishlistProducts;
  final bool? isHorzontal;
  final bool? isDiamond;

  const ProductGrid({
    super.key,
    required this.products,
    this.isHorzontal = false,
    required this.wishlistProducts,
    this.isDiamond = false,
  });

  @override
  State<ProductGrid> createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  final ScrollController _scrollController = ScrollController();
  int _hoverIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
      return const Center(child: Text('No products match your filters.'));
    }
    if (widget.isDiamond == true) {
      return _buildDiamondDataTable(context);
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 1300
            ? 5
            : constraints.maxWidth > 1000
                ? 4
                : constraints.maxWidth > 700
                    ? 3
                    : 2;
        return widget.isHorzontal ?? false
            ? _buildHorizontalList(context, crossAxisCount)
            : _buildGrid(context, crossAxisCount, crossAxisCount);
      },
    );
  }

  void onAddToCart() {}

  void onAddToWishlist() {
    if (widget.wishlistProducts.contains(widget.products[0].name)) {
      widget.wishlistProducts.remove(widget.products[0].name);
      return;
    }
    widget.wishlistProducts.add(widget.products[0].name ?? '');
  }

  Widget _buildDiamondDataTable(BuildContext context) {
    final isMobile = Device.mobile(context);
    final isTablet = Device.tablet(context);
    final isDesktop = Device.desktop(context);

    return IntrinsicHeight(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Scrollbar(
          child: ScrollConfiguration(
            behavior: const ScrollBehavior().copyWith(scrollbars: false),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Diamond List',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                ),
                // Sticky header wrapper
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
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
                        maxHeight: MediaQuery.of(context).size.height * 0.7,
                      ),
                      child: SingleChildScrollView(
                        child: DataTable(
                          dataRowColor:
                              WidgetStateProperty.all<Color>(Colors.white),
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
                          columns: const [
                            DataColumn(
                              label: Text('Shape', textAlign: TextAlign.left),
                            ),
                            DataColumn(
                              label: Text('Carat', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label: Text('Color', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label:
                                  Text('Clarity', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label: Text('Cut', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label:
                                  Text('Polish', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label:
                                  Text('Symmetry', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label: Text('Lab', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label: Text('Table', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label: Text('Depth', textAlign: TextAlign.center),
                            ),
                            DataColumn(
                              label: Text('Amount', textAlign: TextAlign.right),
                            ),
                          ],
                          rows: widget.products.map((product) {
                            if (product is! DiamondProduct) {
                              return DataRow(
                                cells: List.generate(
                                    11, (index) => const DataCell(Text('—'))),
                              );
                            }

                            final diamond = product;
                            final index = widget.products.indexOf(product);

                            return DataRow(
                              onSelectChanged: (selected) {
                                // Only allow navigation if user is logged in
                                final isLoggedIn =
                                    SharedPreferencesHelper.instance.token !=
                                        null;
                                if (!isLoggedIn) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: const Text(
                                          'Please login to view diamond details.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                if (selected == true) {
                                  context.goNamed(
                                    AppRouteNames.productDetail,
                                    pathParameters: {
                                      'id': diamond.id.toString()
                                    },
                                  );
                                }
                              },
                              color: MaterialStateColor.resolveWith((states) {
                                return  index.isOdd
                                    ? const Color(
                                    0xFFFAF3F3)
                                    : Colors.white;
                              }),
                              cells: [
                                _buildDataCell(diamond.shape?.join(', ') ?? '—',
                                    align: TextAlign.left),
                                _buildDataCell(
                                    '${diamond.carat?.toStringAsFixed(2) ?? '—'} ct',
                                    align: TextAlign.center),
                                _buildDataCell(diamond.color ?? '—',
                                    align: TextAlign.center),
                                _buildDataCell(diamond.clarity ?? '—',
                                    align: TextAlign.center),
                                _buildDataCell(diamond.cut ?? '—',
                                    align: TextAlign.center),
                                _buildDataCell(diamond.polish ?? '—',
                                    align: TextAlign.center),
                                _buildDataCell(diamond.symmetry ?? '—',
                                    align: TextAlign.center),
                                _buildDataCell(diamond.certificateLab ?? 'NONE',
                                    align: TextAlign.center),
                                _buildDataCell(
                                    '${diamond.tablePercentage?.toStringAsFixed(2) ?? '—'} %',
                                    align: TextAlign.center),
                                _buildDataCell(
                                    '${diamond.depth?.toStringAsFixed(2) ?? '—'} %',
                                    align: TextAlign.center),
                                DataCell(
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: InkWell(
                                      onTap: () {
                                        // Navigate to login page
                                        if (SharedPreferencesHelper
                                                .instance.token !=
                                            null) {
                                          context.goNamed(
                                              AppRouteNames.userDashboard);
                                        } else {
                                          context.goNamed(AppRouteNames.login);
                                        }
                                      },
                                      child: Text(
                                        SharedPreferencesHelper
                                                    .instance.token !=
                                                null
                                            ? "Go to Dashboard"
                                            : "Login for Price",
                                        style: TextStyle(

                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DataCell _buildDataCell(String value, {TextAlign align = TextAlign.right}) {
    return DataCell(
      Align(
        alignment: align == TextAlign.right
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          textAlign: align,
        ),
      ),
    );
  }

  Widget _buildHorizontalList(BuildContext context, int index) {
    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: widget.products.length,
      itemBuilder: (context, index) {
        final product = widget.products[index];
        if (product is! Product) return const SizedBox.shrink();

        return InkWell(
          onTap: () {
            context.goNamed(
              AppRouteNames.productDetail,
              pathParameters: {'id': product.id.toString()},
            );
          },
          splashColor: Colors.transparent,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          child: Container(
            width: 270,
            margin: const EdgeInsets.only(right: 16),
            child: ProductCard(
              product: product,
              onAddToCart: onAddToCart,
              onAddToWishlist: onAddToWishlist,
              wishList: widget.wishlistProducts,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrid(BuildContext context, int index, int crossAxisCount) {
    return GridView.builder(
      itemCount: widget.products.length,
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final product = widget.products[index];
        if (product is! Product) return const SizedBox.shrink();

        return InkWell(
          onTap: () {
            context.goNamed(
              AppRouteNames.productDetail,
              pathParameters: {'id': product.id.toString()},
            );
          },
          splashColor: Colors.transparent,
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          child: ProductCard(
            product: product,
            onAddToCart: onAddToCart,
            onAddToWishlist: onAddToWishlist,
            wishList: widget.wishlistProducts,
          ),
        );
      },
    );
  }
}
