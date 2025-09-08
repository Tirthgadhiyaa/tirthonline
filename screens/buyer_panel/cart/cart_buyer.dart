// lib/screens/user_panel/cart/cart_user.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';
import 'dart:math' as math;
import '../../../bloc/diamondproduct_bloc/diamond_bloc.dart';
import '../../../bloc/diamondproduct_bloc/diamond_event.dart';
import '../../../bloc/diamondproduct_bloc/diamond_state.dart';
import '../../../models/diamond_product_model.dart';
import '../../../services/razorpay_service_web.dart';
import 'package:jewellery_diamond/core/widgets/custom_snackbar.dart';
import 'package:js/js_util.dart'; // for allowInterop

class CartUser extends StatefulWidget {
  static const String routeName = '/user-cart';

  const CartUser({super.key});

  @override
  State<CartUser> createState() => _CartUserState();
}

class _CartUserState extends State<CartUser>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  List<String> selectedIds = [];
  Map<String, DiamondProduct> selectedDiamonds = {};
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _tableAnimation;

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

  // Common styles
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

  static const _headerPadding =
      EdgeInsets.symmetric(horizontal: 24, vertical: 24);

  Widget _buildStatCard(String label, String value,
      {Color valueColor = Colors.blue}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: _headerPadding,
      decoration: _headerDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'My Cart',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatCard('Pieces', '$totalPieces'),
                const SizedBox(width: 16),
                _buildStatCard('Carats', totalCarats.toStringAsFixed(2)),
                const SizedBox(width: 16),
                _buildStatCard(
                    'Avg Pr/Ct', avgPricePerCarat.toStringAsFixed(2)),
                const SizedBox(width: 16),
                _buildStatCard(
                    'Total Amount', '\$${totalAmount.toStringAsFixed(2)}',
                    valueColor: Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BlocBuilder<DiamondBloc, DiamondState>(builder: (context, state) {
                final hasCarts =
                    state is CartlistLoaded && state.cartlist.isNotEmpty;
                return OutlinedButton.icon(
                  onPressed: () {
                    if (hasCarts) {
                      context.read<DiamondBloc>().add(
                          ExportBuyerCartProductsToExcel(
                              productIds: selectedIds));
                    }
                  },
                  icon: const Icon(Icons.download_outlined, size: 16),
                  label: const Text("Export to Excel"),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                );
              }),
              // const SizedBox(width: 12),
              // OutlinedButton.icon(
              //   onPressed: () {
              //     if (selectedIds.isNotEmpty) {
              //       context.read<DiamondBloc>().add(AddToWishlist(selectedIds));
              //     }
              //   },
              //   icon: const Icon(Icons.bookmark_outline, size: 16),
              //   label: const Text("Add To Watchlist"),
              //   style: OutlinedButton.styleFrom(
              //     padding:
              //         const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(4),
              //     ),
              //     side:
              //         BorderSide(color: Theme.of(context).colorScheme.primary),
              //   ),
              // ),
            ],
          ),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  if (selectedIds.isNotEmpty) {
                    context
                        .read<DiamondBloc>()
                        .add(RemoveFromCart(selectedIds));
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text("Delete"),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  if (selectedIds.isNotEmpty) {
                    context.read<DiamondBloc>().add(AddToHold(selectedIds));
                  }
                },
                icon: const Icon(Icons.hourglass_empty, size: 16),
                label: const Text("Hold"),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () {
                  print("test");
                  if (selectedIds.isNotEmpty) {
                    final amountInPaise = (totalAmount * 100).toInt();

                    final options = RazorpayOptions(
                      key: 'rzp_test_MTcCVhlJKXbl6O',
                      amount: amountInPaise,
                      currency: 'INR',
                      name: 'Laxmi Software Technology',
                      description: 'Diamond Purchase',
                      handler: allowInterop((response) {
                        // Payment success
                        print(
                            "Razorpay Payment Success: ${response.toString()}");

                        // List<Map<String, dynamic>> orderProducts = selectedDiamonds.entries.map((entry) {
                        //   final diamond = entry.value;
                        //   return {
                        //     "product_id": diamond.id,
                        //     "price_per_unit": diamond.price,
                        //   };
                        // }).toList();
                        // context.read<DiamondBloc>().add(AddToOrders(orderProducts));

                        showCustomSnackBar(
                          context: context,
                          message: "Payment successful",
                          backgroundColor: Colors.green,
                        );
                      }),
                      prefill: {
                        "contact": "9999999999",
                        "email": "test@example.com",
                      },
                      theme: {"color": "#3399cc"},
                    );

                    final razorpay = Razorpay(options);

                    razorpay.on('payment.failed', allowInterop((response) {
                      print("Payment failed: $response");

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Payment Failed"),
                          content: Text(response['error']['description'] ??
                              'Unknown error'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }));

                    razorpay.open();
                  }
                  // if (selectedIds.isNotEmpty) {
                  //   List<Map<String, dynamic>> orderProducts =
                  //       selectedDiamonds.entries.map((entry) {
                  //     final diamond = entry.value;
                  //     return {
                  //       "product_id": diamond.id,
                  //       "price_per_unit": diamond.price,
                  //     };
                  //   }).toList();
                  //   context.read<DiamondBloc>().add(AddToOrders(orderProducts));
                  // }
                },
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text("Order"),
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();

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

  void _fetchProducts() {
    context.read<DiamondBloc>().add(FetchCart());
  }

  void _changePage(int page) {
    final diamondState = context.read<DiamondBloc>().state;
    if (diamondState is CartlistLoaded) {
      if (page < 1 || page > diamondState.totalPages) return;

      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      context.read<DiamondBloc>().add(ChangeCartPage(page: page));
    }
  }

  void _selectAll(List<DiamondProduct> diamonds) {
    setState(() {
      if (selectedIds.length == diamonds.length) {
        // If all are selected, deselect all
        selectedIds.clear();
        selectedDiamonds.clear();
      } else {
        // Otherwise, select all
        selectedIds = diamonds
            .map((d) => d.id ?? '')
            .where((id) => id.isNotEmpty)
            .toList();
        selectedDiamonds = {
          for (var diamond in diamonds)
            if (diamond.id != null) diamond.id!: diamond
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<DiamondBloc, DiamondState>(
      listener: (context, state) {
        if (state is CartRemoveSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          _fetchProducts();
        } else if (state is HoldUpdateSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          _fetchProducts();
        } else if (state is WishlistUpdateSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          _fetchProducts();
        } else if (state is OrdersUpdateSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          _fetchProducts();
        } else if (state is BuyerProductExportSuccess) {
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
      child: Scaffold(
        body: Column(
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

            // Action Bar
            FadeTransition(
              opacity: _headerAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(_headerAnimation),
                child: _buildActionBar(theme),
              ),
            ),

            // Main Content
            Expanded(
              child: FadeTransition(
                opacity: _tableAnimation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_tableAnimation),
                  child: BlocBuilder<DiamondBloc, DiamondState>(
                    builder: (context, state) {
                      if (state is DiamondLoading) {
                        return _buildLoadingState(theme);
                      } else if (state is DiamondFailure) {
                        return _buildErrorState(state.error, theme);
                      } else if (state is CartlistLoaded) {
                        return state.cartlist.isEmpty
                            ? _buildEmptyState(theme)
                            : _buildDiamondTable(state, theme);
                      }
                      return Container();
                    },
                  ),
                ),
              ),
            ),

            // Pagination
            BlocBuilder<DiamondBloc, DiamondState>(
              builder: (context, state) {
                if (state is CartlistLoaded && state.cartlist.isNotEmpty) {
                  return _buildPaginationControls(state, theme);
                }
                return const SizedBox.shrink();
              },
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Cart',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Diamonds ready for purchase',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildStatsSummary(theme),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(
            icon: Icons.diamond_outlined,
            value: totalPieces.toString(),
            label: 'Pieces',
            theme: theme,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.scale,
            value: totalCarats.toStringAsFixed(2),
            label: 'Carats',
            theme: theme,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: Icons.attach_money,
            value: '\$${totalAmount.toStringAsFixed(2)}',
            label: 'Total',
            theme: theme,
            valueColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: valueColor ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildActionBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: BlocBuilder<DiamondBloc, DiamondState>(
        builder: (context, state) {
          if (state is CartlistLoaded) {
            final hasItems = state.cartlist.isNotEmpty;
            final allSelected =
                hasItems && selectedIds.length == state.cartlist.length;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left side - Selection info
                Row(
                  children: [
                    // Select all checkbox
                    if (hasItems)
                      Row(
                        children: [
                          Checkbox(
                            value: allSelected,
                            onChanged: (value) => _selectAll(state.cartlist),
                            activeColor: theme.colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            allSelected ? 'Deselect All' : 'Select All',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: selectedIds.isNotEmpty
                                  ? theme.colorScheme.primary.withOpacity(0.1)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              selectedIds.isEmpty
                                  ? 'No items selected'
                                  : '${selectedIds.length} of ${state.cartlist.length} selected',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: selectedIds.isNotEmpty
                                    ? theme.colorScheme.primary
                                    : Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Right side - Action buttons
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: hasItems
                          ? () => context.read<DiamondBloc>().add(
                              ExportBuyerCartProductsToExcel(
                                  productIds: selectedIds.isEmpty
                                      ? state.cartlist
                                          .map((e) => e.id ?? '')
                                          .toList()
                                      : selectedIds))
                          : null,
                      icon: const Icon(Icons.download_outlined, size: 18),
                      label: const Text("Export"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: selectedIds.isNotEmpty
                          ? () => context
                              .read<DiamondBloc>()
                              .add(RemoveFromCart(selectedIds))
                          : null,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text("Delete"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: selectedIds.isNotEmpty
                          ? () => context
                              .read<DiamondBloc>()
                              .add(AddToHold(selectedIds))
                          : null,
                      icon: const Icon(Icons.hourglass_empty, size: 18),
                      label: const Text("Hold"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: selectedIds.isNotEmpty
                          ? () {
                              if (selectedIds.isNotEmpty) {
                                final amountInPaise =
                                    (totalAmount * 100).toInt();

                                final options = RazorpayOptions(
                                  key: 'rzp_test_MTcCVhlJKXbl6O',
                                  amount: amountInPaise,
                                  currency: 'INR',
                                  name: 'Laxmi Software Technology',
                                  description: 'Diamond Purchase',
                                  handler: allowInterop((response) {
                                    // Payment success
                                    print(
                                        "Razorpay Payment Success: ${response.toString()}");

                                    // List<Map<String, dynamic>> orderProducts = selectedDiamonds.entries.map((entry) {
                                    //   final diamond = entry.value;
                                    //   return {
                                    //     "product_id": diamond.id,
                                    //     "price_per_unit": diamond.price,
                                    //   };
                                    // }).toList();
                                    // context.read<DiamondBloc>().add(AddToOrders(orderProducts));

                                    showCustomSnackBar(
                                      context: context,
                                      message: "Payment successful",
                                      backgroundColor: Colors.green,
                                    );
                                  }),
                                  prefill: {
                                    "contact": "9999999999",
                                    "email": "test@example.com",
                                  },
                                  theme: {"color": "#3399cc"},
                                );

                                final razorpay = Razorpay(options);

                                razorpay.on('payment.failed',
                                    allowInterop((response) {
                                  print("Payment failed: $response");

                                  showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text("Payment Failed"),
                                      content: Text(response['error']
                                              ['description'] ??
                                          'Unknown error'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("OK"),
                                        ),
                                      ],
                                    ),
                                  );
                                }));

                                razorpay.open();
                              }
                              // List<Map<String, dynamic>> orderProducts =
                              //     selectedDiamonds.entries.map((entry) {
                              //   final diamond = entry.value;
                              //   return {
                              //     "product_id": diamond.id,
                              //     "price_per_unit": diamond.price,
                              //   };
                              // }).toList();
                              // context
                              //     .read<DiamondBloc>()
                              //     .add(AddToOrders(orderProducts));
                            }
                          : null,
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text("Confirm Order"),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
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
            'Loading your cart items...',
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
            onPressed: _fetchProducts,
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
              Icons.shopping_cart_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Your Cart is Empty',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add diamonds to your cart to proceed with purchase',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to diamond listing
            },
            icon: const Icon(Icons.diamond_outlined),
            label: const Text('Browse Diamonds'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiamondTable(CartlistLoaded state, ThemeData theme) {
    final isMobile = Device.mobile(context);
    final isTablet = Device.tablet(context);
    final isDesktop = Device.desktop(context);
    // Calculate available width for the table
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return Container(
          width: availableWidth,
          height: double.infinity,
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              // Make the table at least as wide as the available space
              width: math.max(availableWidth, 1200),
              child: Listener(
                onPointerSignal: (event) {
                  if (event is PointerScrollEvent &&
                      event.scrollDelta.dy != 0) {
                    if (event.kind == PointerDeviceKind.mouse &&
                        RawKeyboard.instance.keysPressed
                            .contains(LogicalKeyboardKey.shiftLeft)) {
                      _scrollController.jumpTo(
                        _scrollController.position.pixels +
                            event.scrollDelta.dy,
                      );
                    }
                  }
                },
                child: SingleChildScrollView(
                  controller: _scrollController,
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
                        DataColumn(label: Text('')),
                        DataColumn(
                            label: Flexible(
                                child: Text(
                          'Stock Number',
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(label: Text('Carat')),
                        DataColumn(label: Text('Price')),
                        DataColumn(label: Text('Shape')),
                        DataColumn(label: Text('Color')),
                        DataColumn(label: Text('Clarity')),
                        DataColumn(label: Text('Cut')),
                        DataColumn(label: Text('Polish')),
                        DataColumn(label: Text('Symmetry')),
                        DataColumn(label: Text('Fluorescence')),
                        DataColumn(
                            label: Flexible(
                                child: Text(
                          'Certificate Lab',
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(
                            label: Flexible(
                                child: Text(
                          'Certificate Number',
                          softWrap: true,
                          textAlign: TextAlign.center,
                        ))),
                        DataColumn(label: Text('Measurements')),
                      ],
                      rows: state.cartlist.asMap().entries.map((entry) {
                        int index = entry.key;
                        var diamond = entry.value;
                        final isSelected = selectedIds.contains(diamond.id);

                        return DataRow(
                          color: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return theme.colorScheme.primary
                                  .withOpacity(0.05);
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
                                      selectedIds.add(diamond.id ?? '');
                                      selectedDiamonds[diamond.id ?? ""] =
                                          diamond;
                                    } else {
                                      selectedDiamonds.remove(diamond.id);
                                      selectedIds.remove(diamond.id ?? '');
                                    }
                                  });
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor: theme.colorScheme.primary,
                              ),
                            ),
                            DataCell(Text(diamond.stockNumber ?? "")),
                            DataCell(Text(
                                diamond.carat?.toStringAsFixed(2) ?? 'N/A')),
                            DataCell(Text(diamond.price != null
                                ? '\$${diamond.price}'
                                : 'N/A')),
                            DataCell(Text(diamond.shape?.join(', ') ?? 'N/A')),
                            DataCell(Text(diamond.color ?? 'N/A')),
                            DataCell(Text(diamond.clarity ?? 'N/A')),
                            DataCell(Text(diamond.cut ?? 'N/A')),
                            DataCell(Text(diamond.polish ?? 'N/A')),
                            DataCell(Text(diamond.symmetry ?? 'N/A')),
                            DataCell(Text(diamond.fluorescence ?? 'N/A')),
                            DataCell(Text(diamond.certificateLab ?? 'N/A')),
                            DataCell(Text(diamond.certificateNumber ?? 'N/A')),
                            DataCell(Text(
                              '${diamond.length?.toStringAsFixed(2) ?? 'N/A'} × ${diamond.width?.toStringAsFixed(2) ?? 'N/A'} × ${diamond.height?.toStringAsFixed(2) ?? 'N/A'}',
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaginationControls(CartlistLoaded state, ThemeData theme) {
    final currentPage = state.currentPage;
    final totalPages = state.totalPages;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pagination
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: currentPage > 1 ? () => _changePage(1) : null,
                tooltip: 'First Page',
                color: theme.colorScheme.primary,
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed:
                    currentPage > 1 ? () => _changePage(currentPage - 1) : null,
                tooltip: 'Previous Page',
                color: theme.colorScheme.primary,
                iconSize: 20,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$currentPage of $totalPages',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: currentPage < totalPages
                    ? () => _changePage(currentPage + 1)
                    : null,
                tooltip: 'Next Page',
                color: theme.colorScheme.primary,
                iconSize: 20,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: currentPage < totalPages
                    ? () => _changePage(totalPages)
                    : null,
                tooltip: 'Last Page',
                color: theme.colorScheme.primary,
                iconSize: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
