// lib/screens/user_panel/dashboard/dashboard_user.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:jewellery_diamond/bloc/user_dashboard_bloc/buyer_dashboard_bloc.dart';
import 'package:jewellery_diamond/bloc/user_dashboard_bloc/buyer_dashboard_event.dart';
import 'package:jewellery_diamond/bloc/user_dashboard_bloc/buyer_dashboard_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/diamond_product_model.dart';
import 'package:jewellery_diamond/screens/buyer_panel/dashboard/widgets/activity_timeline_widget.dart';
import 'package:jewellery_diamond/screens/buyer_panel/dashboard/widgets/cart_items_table_widget.dart';
import 'package:jewellery_diamond/screens/buyer_panel/dashboard/widgets/dashboard_card_widget.dart';
import 'package:jewellery_diamond/screens/buyer_panel/dashboard/widgets/offers_carousel_widget.dart';
import 'package:jewellery_diamond/screens/buyer_panel/dashboard/widgets/recommendations_widget.dart';
import 'package:jewellery_diamond/screens/buyer_panel/dashboard/widgets/welcome_header_widget.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';

import '../../../models/buyer_dashboard_model.dart';

class DashboardUser extends StatefulWidget {
  static const String routeName = '/user-dashboard';

  const DashboardUser({super.key});

  @override
  State<DashboardUser> createState() => _DashboardUserState();
}

class _DashboardUserState extends State<DashboardUser> {
  late UserDashboardBloc _dashboardBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _dashboardBloc = UserDashboardBloc();
    _dashboardBloc.add(const FetchUserDashboard(useDemo: true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToCart() {
    GoRouter.of(context).goNamed(AppRouteNames.userCart);
  }

  void _navigateToWishlist() {
    GoRouter.of(context).goNamed(AppRouteNames.userWishlist);
  }

  void _navigateToHoldStones() {
    GoRouter.of(context).goNamed(AppRouteNames.userHold);
  }

  void _navigateToOrders() {
    GoRouter.of(context).goNamed(AppRouteNames.userPurchaseGoods);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _dashboardBloc,
      child: BlocConsumer<UserDashboardBloc, UserDashboardState>(
        listener: (context, state) {
          if (state is UserDashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UserDashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is! UserDashboardLoaded) {
            return const Center(
              child: Text('No dashboard data available'),
            );
          }

          final dashboard = state.dashboard;
          final offers = state.offers;
          final activities = state.activities;
          final recommendations = state.recommendations;

          // Extract cart items
          List<DiamondProduct> diamondList = [];
          for (var item in dashboard.recentCartItems) {
            try {
              diamondList.add(DiamondProduct.fromJson(item['product']));
            } catch (e) {
              print('Error parsing diamond: $e');
            }
          }

          return RefreshIndicator(
            onRefresh: () async {
              _dashboardBloc.add(const RefreshUserDashboard(useDemo: true));
              return Future.delayed(const Duration(milliseconds: 500));
            },
            child: Scaffold(
              body: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome header
                      // WelcomeHeaderWidget(
                      //   userName: dashboard.userName,
                      //   formattedDate: DateFormat('EEEE, MMMM d, y')
                      //       .format(DateTime.now()),
                      // ),
                      // custSpace25Y,

                      // Offers carousel
                      OffersCarouselWidget(
                        offers: offers,
                        isLoading: state.isOffersLoading,
                      ),

                      custSpace25Y,

                      // Stats cards
                      _buildStatsCards(context, dashboard),

                      custSpace25Y,

                      // Two-column layout for desktop
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (constraints.maxWidth > 1000) {
                            // Desktop layout - two columns
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Left column - 65% width
                                Expanded(
                                  flex: 65,
                                  child: Column(
                                    children: [
                                      // Recent cart items
                                      CartItemsTableWidget(
                                        diamondList: diamondList,
                                        scrollController: _scrollController,
                                        onViewDetails: (diamond) {
                                          // Navigate to diamond details
                                        },
                                        onRemoveFromCart: (diamond) {
                                          // Remove from cart
                                        },
                                      ),

                                      custSpace25Y,

                                      // Recommendations
                                      RecommendationsWidget(
                                        recommendations: recommendations,
                                        isLoading:
                                            state.isRecommendationsLoading,
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(width: 24),

                                // Right column - 35% width
                                Expanded(
                                  flex: 35,
                                  child: Column(
                                    children: [
                                      // Recent activity timeline
                                      ActivityTimelineWidget(
                                        activities: activities,
                                        isLoading: state.isActivitiesLoading,
                                      ),

                                      custSpace25Y,

                                      // Market trends widget
                                      _buildMarketTrendsWidget(context),

                                      custSpace25Y,

                                      // Upcoming events widget
                                      // _buildUpcomingEventsWidget(context),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          } else {
                            // Mobile/tablet layout - single column
                            return Column(
                              children: [
                                // Recent cart items
                                CartItemsTableWidget(
                                  diamondList: diamondList,
                                  scrollController: _scrollController,
                                  onViewDetails: (diamond) {
                                    // Navigate to diamond details
                                  },
                                  onRemoveFromCart: (diamond) {
                                    // Remove from cart
                                  },
                                ),

                                custSpace25Y,

                                // Recent activity timeline
                                ActivityTimelineWidget(
                                  activities: activities,
                                  isLoading: state.isActivitiesLoading,
                                ),

                                custSpace25Y,

                                // Recommendations
                                RecommendationsWidget(
                                  recommendations: recommendations,
                                  isLoading: state.isRecommendationsLoading,
                                ),

                                custSpace25Y,

                                // Market trends widget
                                _buildMarketTrendsWidget(context),

                                custSpace25Y,

                                // Upcoming events widget
                                _buildUpcomingEventsWidget(context),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, UserDashboardModel dashboard) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        double cardWidth = (maxWidth / 2) - 20;

        if (maxWidth > 800) {
          cardWidth = (maxWidth / 4) - 20;
        } else if (maxWidth > 500) {
          cardWidth = (maxWidth / 2) - 20;
        } else {
          cardWidth = maxWidth - 20;
        }

        return Wrap(
          spacing: 26,
          runSpacing: 20,
          children: [
            DashboardCardWidget(
              title: "My Cart",
              value: "${dashboard.cartItemsCount}",
              subtitle: dashboard.cartItemsCount > 0
                  ? "Items waiting for checkout"
                  : "Your cart is empty",
              icon: Icons.shopping_cart,
              color: Theme.of(context).colorScheme.primary,
              width: cardWidth,
              onTap: _navigateToCart,
            ),
            DashboardCardWidget(
              title: "My Watchlist",
              value: "${dashboard.wishlistItemsCount}",
              subtitle: dashboard.wishlistItemsCount > 0
                  ? "Items in your watchlist"
                  : "Add items to watchlist",
              icon: Icons.favorite,
              color: Colors.redAccent,
              width: cardWidth,
              onTap: _navigateToWishlist,
            ),
            DashboardCardWidget(
              title: "Hold Stones",
              value: "${dashboard.holdedProductsCount}",
              subtitle: dashboard.holdedProductsCount > 0
                  ? "Stones on hold"
                  : "No stones on hold",
              icon: Icons.pause_circle_rounded,
              color: Colors.amber,
              width: cardWidth,
              onTap: _navigateToHoldStones,
            ),
            DashboardCardWidget(
              title: "Total Orders",
              value: "${dashboard.completedOrders}",
              subtitle: dashboard.pendingOrders > 0
                  ? "${dashboard.pendingOrders} pending orders"
                  : "All orders completed",
              icon: Icons.diamond,
              color: Colors.teal,
              width: cardWidth,
              onTap: _navigateToOrders,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMarketTrendsWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Diamond Market Trends',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Market trend items
          _buildTrendItem(
            context,
            title: 'Round Brilliant',
            change: '+2.3%',
            isUp: true,
          ),
          const Divider(),
          _buildTrendItem(
            context,
            title: 'Emerald Cut',
            change: '+1.8%',
            isUp: true,
          ),
          const Divider(),
          _buildTrendItem(
            context,
            title: 'Princess Cut',
            change: '-0.5%',
            isUp: false,
          ),
          const Divider(),
          _buildTrendItem(
            context,
            title: 'Cushion Cut',
            change: '+1.2%',
            isUp: true,
          ),

          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Navigate to market trends page
              },
              icon: const Icon(Icons.analytics),
              label: const Text('View Market Analysis'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendItem(
    BuildContext context, {
    required String title,
    required String change,
    required bool isUp,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Icon(
                isUp ? Icons.arrow_upward : Icons.arrow_downward,
                color: isUp ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isUp ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEventsWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.event,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Upcoming Events',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Event items
          _buildEventItem(
            context,
            title: 'Summer Collection Launch',
            date: 'June 15, 2023',
            location: 'Online Event',
          ),
          const SizedBox(height: 16),
          _buildEventItem(
            context,
            title: 'Diamond Masterclass',
            date: 'June 22, 2023',
            location: 'Virtual Workshop',
          ),
          const SizedBox(height: 16),
          _buildEventItem(
            context,
            title: 'Exclusive Preview: Bridal Collection',
            date: 'July 5, 2023',
            location: 'By Invitation Only',
          ),

          const SizedBox(height: 16),
          Center(
            child: TextButton.icon(
              onPressed: () {
                // Navigate to events page
              },
              icon: const Icon(Icons.calendar_today),
              label: const Text('View All Events'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(
    BuildContext context, {
    required String title,
    required String date,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
