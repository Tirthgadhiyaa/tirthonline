import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';
import '../../../../bloc/diamondproduct_bloc/diamond_bloc.dart';
import '../../../../bloc/diamondproduct_bloc/diamond_event.dart';
import '../../../../models/product_response_model.dart';
import '../../../../models/diamond_product_model.dart';
import '../../../../widgets/responsive_ui.dart';
import '../../../../utils/shared_preference.dart';
import '../../../user/product_list_page/widgets/product_card_widget.dart';
import 'dart:html' as html;

class BuyerProductGrid extends StatefulWidget {
  final List<dynamic> products;
  final List<String> wishlistProducts;
  final bool? isHorzontal;
  final bool? isDiamond;

  const BuyerProductGrid({
    super.key,
    required this.products,
    this.isHorzontal = false,
    required this.wishlistProducts,
    this.isDiamond = false,
  });

  @override
  State<BuyerProductGrid> createState() => _BuyerProductGridState();
}

class _BuyerProductGridState extends State<BuyerProductGrid> {
  final ScrollController _scrollController = ScrollController();
  int _hoverIndex = -1;

  List<String> selectedIds = [];

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
    return LayoutBuilder(
      builder: (context, constraints) {
        return IntrinsicHeight(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Scrollbar(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior().copyWith(scrollbars: false),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Diamond List',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                              ),
                            ),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  icon: const Icon(
                                    Icons.bookmark_outline,
                                    size: 16,
                                  ),
                                  onPressed: () {
                                    if (selectedIds.isNotEmpty) {
                                      context
                                          .read<DiamondBloc>()
                                          .add(AddToWishlist(selectedIds));
                                    }
                                  },
                                  label: const Text('Add To Watchlist'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                custSpace8X,
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.hourglass_empty,
                                      size: 16),
                                  onPressed: () {
                                    _showTimeDurationPicker(context,(selectedHours) {
                                      if(selectedHours != null)
                                        {
                                          context
                                              .read<DiamondBloc>()
                                              .add(AddToHold(selectedIds));
                                        }

                                    },);

                                  },
                                  label: const Text('Hold'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                custSpace8X,
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.shopping_cart_outlined,
                                      size: 16),
                                  onPressed: () {
                                    if (selectedIds.isNotEmpty) {
                                      context
                                          .read<DiamondBloc>()
                                          .add(AddToCart(selectedIds));
                                    }
                                  },
                                  label: const Text('Add to Cart'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  // style: OutlinedButton.styleFrom(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 24, vertical: 16),
                                  //   shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(4),
                                  //   ),
                                  // ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: ClipRRect(
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
                            child: Listener(
                              onPointerSignal: (event) {
                                if (event is PointerScrollEvent &&
                                    event.scrollDelta.dy != 0) {
                                  if (event.kind == PointerDeviceKind.mouse &&
                                      RawKeyboard.instance.keysPressed.contains(
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
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  physics: const NeverScrollableScrollPhysics(),
                                  controller: _scrollController,
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minWidth: constraints.maxWidth,
                                    ),
                                    child: DataTable(
                                      dataRowColor:
                                          WidgetStateProperty.all<Color>(
                                              Colors.white),
                                      headingRowColor:
                                          WidgetStateProperty.all<Color>(
                                              Theme.of(context)
                                                  .colorScheme
                                                  .primary),
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
                                        DataColumn(label: Text('')),
                                        DataColumn(label: Text('')),
                                        DataColumn(
                                          label: Text('Stock Id',
                                              textAlign: TextAlign.left),
                                        ),
                                        DataColumn(
                                          label: Text('Carat',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Price',
                                              textAlign: TextAlign.right),
                                        ),
                                        DataColumn(
                                          label: Text('Color',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Clarity',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Cut',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Polish',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Symmetry',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Lab',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Table',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Depth',
                                              textAlign: TextAlign.center),
                                        ),
                                        DataColumn(
                                          label: Text('Shape',
                                              textAlign: TextAlign.center),
                                        ),
                                      ],
                                      rows: widget.products.map((product) {
                                        final diamond = product;
                                        final index =
                                            widget.products.indexOf(product);
                                        return DataRow(
                                          onSelectChanged: (selected) {
                                            if (selected == true) {
                                              context.goNamed(
                                                AppRouteNames.productDetail,
                                                pathParameters: {
                                                  'id': diamond.id.toString()
                                                },
                                              );
                                            }
                                          },
                                          color: MaterialStateColor.resolveWith(
                                              (states) {
                                            if (_hoverIndex == index) {
                                              return Colors.grey.shade100;
                                            }
                                            return index.isEven
                                                ? Colors.white
                                                : Colors.grey.shade50;
                                          }),
                                          cells: [
                                            DataCell(
                                              Checkbox(
                                                value: selectedIds
                                                    .contains(diamond.id),
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    if (value == true) {
                                                      selectedIds.add(
                                                          diamond.id ?? '');
                                                    } else {
                                                      selectedIds.remove(
                                                          diamond.id ?? '');
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            DataCell(
                                              Row(
                                                children: [
                                                  if (diamond.images != null &&
                                                      diamond
                                                          .images!.isNotEmpty)
                                                    Tooltip(
                                                      message: 'View Image',
                                                      child: IconButton(
                                                        icon: Icon(Icons.image,
                                                            color: Colors.blue),
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
                                                  if (diamond.videoUrl !=
                                                          null &&
                                                      diamond
                                                          .videoUrl!.isNotEmpty)
                                                    Tooltip(
                                                      message: 'Watch Video',
                                                      child: IconButton(
                                                        icon: Icon(
                                                            Icons.videocam,
                                                            color: Colors.red),
                                                        onPressed: () {
                                                          html.window.open(
                                                              diamond.videoUrl!
                                                                  .first,
                                                              '_blank');
                                                        },
                                                      ),
                                                    ),
                                                  if (diamond.certificateUrl !=
                                                          null &&
                                                      diamond.certificateUrl!
                                                          .isNotEmpty)
                                                    Tooltip(
                                                      message:
                                                          'View Certificate',
                                                      child: IconButton(
                                                        icon: Icon(
                                                            Icons
                                                                .picture_as_pdf,
                                                            color:
                                                                Colors.green),
                                                        onPressed: () {
                                                          html.window.open(
                                                              diamond
                                                                  .certificateUrl!
                                                                  .first,
                                                              '_blank');
                                                        },
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            _buildDataCell(
                                                diamond.stockNumber ?? '—',
                                                align: TextAlign.left),
                                            _buildDataCell(
                                                '${diamond.carat?.toStringAsFixed(2) ?? '—'} ct',
                                                align: TextAlign.center),
                                            _buildDataCell(
                                                '${diamond.price?.toStringAsFixed(2) ?? '—'}',
                                                align: TextAlign.center),
                                            _buildDataCell(diamond.color ?? '—',
                                                align: TextAlign.center),
                                            _buildDataCell(
                                                diamond.clarity ?? '—',
                                                align: TextAlign.center),
                                            _buildDataCell(diamond.cut ?? '—',
                                                align: TextAlign.center),
                                            _buildDataCell(
                                                diamond.polish ?? '—',
                                                align: TextAlign.center),
                                            _buildDataCell(
                                                diamond.symmetry ?? '—',
                                                align: TextAlign.center),
                                            _buildDataCell(
                                                diamond.certificateLab ??
                                                    'NONE',
                                                align: TextAlign.center),
                                            _buildDataCell(
                                                '${diamond.tablePercentage?.toStringAsFixed(2) ?? '—'} %',
                                                align: TextAlign.center),
                                            _buildDataCell(
                                                '${diamond.depth?.toStringAsFixed(2) ?? '—'} %',
                                                align: TextAlign.center),
                                            _buildDataCell(
                                                '${diamond.shape?.join(",") ?? '—'}',
                                                align: TextAlign.center),
                                          ],
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
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
          ),
        );
      },
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

  void _showTimeDurationPicker(
      BuildContext context,
      void Function(int selectedHours) onConfirm,
      ) {
    int selectedHours = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Hold Duration (Hours)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPicker(
                    label: 'Hrs',
                    max: 72,
                    onChanged: (value) => selectedHours = value,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm(selectedHours);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 2,
                  side: const BorderSide(color: Color(0xff7f1d1d), width: 1.5),
                  foregroundColor: const Color(0xff7f1d1d),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Confirm Duration',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPicker({
    required String label,
    required int max,
    required Function(int) onChanged,
  }) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: 0),
              itemExtent: 36,
              onSelectedItemChanged: onChanged,
              children: List.generate(
                max + 1,
                    (index) => Center(child: Text('$index')),
              ),
            ),
          ),
          Text(label),
        ],
      ),
    );
  }
}
