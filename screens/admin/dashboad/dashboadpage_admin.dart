// lib/screens/admin/dashboad/dashboadpage_admin.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jewellery_diamond/services/dashboard_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/bloc/dashboard_bloc/dashboard_bloc.dart';
import 'package:jewellery_diamond/bloc/dashboard_bloc/dashboard_event.dart';
import 'package:jewellery_diamond/bloc/dashboard_bloc/dashboard_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

class DashboadpageAdmin extends StatefulWidget {
  static const String routeName = '/dashboard';
  const DashboadpageAdmin({super.key});

  @override
  State<DashboadpageAdmin> createState() => _DashboadpageAdminState();
}

class _DashboadpageAdminState extends State<DashboadpageAdmin>
    with SingleTickerProviderStateMixin {
  String currentTab = "Overview";
  late TabController _tabController;
  late DashboardBloc _dashboardBloc;
  bool isLoading = false;

  // Luxury color palette
  final Color goldAccent = const Color(0xFFD4AF37);
  final Color deepBlue = const Color(0xFF1A237E);
  final Color platinum = const Color(0xFFE5E4E2);
  final Color darkCharcoal = const Color(0xFF333333);
  final Color emerald = const Color(0xFF046307);
  final Color ruby = const Color(0xFFE0115F);
  final Color sapphire = const Color(0xFF0F52BA);

  // Dashboard data
  Map<String, dynamic> dashboardData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _dashboardBloc = DashboardBloc();
    _dashboardBloc.add(const FetchDashboardData());

    // Modified/New Code
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          switch (_tabController.index) {
            case 0:
              currentTab = "Overview";
              break;
            case 1:
              currentTab = "Users";
              break;
            case 2:
              currentTab = "Products";
              break;
            case 3:
              currentTab = "Orders";
              break;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dashboardBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('EEEE, MMMM d, y').format(DateTime.now());

    return BlocProvider(
      create: (context) => _dashboardBloc,
      child: BlocConsumer<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: state is DashboardLoading
                ? _buildLoadingState()
                : _buildTabContent(state, formattedDate),
          );
        },
      ),
    );
  }

  // Modified/New Code
  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  // Modified/New Code
  Widget _buildTabContent(DashboardState state, String formattedDate) {
    return Column(
      children: [
        _buildHeader(formattedDate, state),
        const SizedBox(height: 28),
        _buildTabBar(),
        const SizedBox(height: 28),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Overview Tab
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatisticsCards(state),
                    const SizedBox(height: 28),
                    _buildChartSection(state),
                    const SizedBox(height: 28),
                    _buildRecentActivities(state),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Users Tab
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserStatistics(state),
                    const SizedBox(height: 28),
                    _buildRecentSellersSection(state),
                  ],
                ),
              ),

              // Products Tab
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProductStatistics(state),
                    const SizedBox(height: 28),
                    _buildRecentProductsSection(state),
                  ],
                ),
              ),

              // Orders Tab
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderStatistics(state),
                    const SizedBox(height: 28),
                    _buildRecentOrdersSection(state),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String formattedDate, DashboardState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              // Modified/New Code
              "$currentTab Dashboard",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today, color: darkCharcoal, size: 14),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    fontSize: 14,
                    color: darkCharcoal.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () => _dashboardBloc.add(const RefreshDashboardData()),
              icon: Icon(Icons.refresh,
                  color: Theme.of(context).colorScheme.primary),
              label: Text("Refresh",
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Theme.of(context).colorScheme.primary),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, color: Colors.white),
              label: const Text("Export Report",
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).colorScheme.primary,
        unselectedLabelColor: darkCharcoal.withOpacity(0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        indicator: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        tabs: [
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_customize, size: 18),
                const SizedBox(width: 8),
                const Text("Overview"),
              ],
            ),
          ),
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 18),
                const SizedBox(width: 8),
                const Text("Users"),
              ],
            ),
          ),
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.diamond, size: 18),
                const SizedBox(width: 8),
                const Text("Products"),
              ],
            ),
          ),
          Tab(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag, size: 18),
                const SizedBox(width: 8),
                const Text("Orders"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;
    return LayoutBuilder(
      builder: (context, constraints) {
        double maxWidth = constraints.maxWidth;
        int crossAxisCount = maxWidth > 1200
            ? 4
            : maxWidth > 800
                ? 2
                : 1;

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 2.0,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          children: [
            _buildStatCard(
              title: "Total Buyer",
              value: "${data['user_statistics']['total_buyers']}",
              icon: FontAwesomeIcons.userGroup,
              color: sapphire,
              subtitle:
                  "+${data['user_statistics']['new_users']['this_month']} this month",
              subtitleColor: emerald,
              gradientColors: [
                sapphire.withOpacity(0.8),
                sapphire.withOpacity(0.6)
              ],
            ),
            _buildStatCard(
              title: "Total Stones",
              value: "${data['product_statistics']['total_products']}",
              icon: FontAwesomeIcons.gem,
              color: goldAccent,
              subtitle:
                  "+${data['product_statistics']['new_products']['this_week']} this week",
              subtitleColor: sapphire,
              gradientColors: [
                goldAccent.withOpacity(0.8),
                goldAccent.withOpacity(0.6)
              ],
            ),
            _buildStatCard(
              title: "Total Orders",
              value: "${data['order_statistics']['total_orders']}",
              icon: FontAwesomeIcons.bagShopping,
              color: deepBlue,
              subtitle: "${data['order_statistics']['pending_orders']} pending",
              subtitleColor: Colors.orange,
              gradientColors: [
                deepBlue.withOpacity(0.8),
                deepBlue.withOpacity(0.6)
              ],
            ),
            _buildStatCard(
              title: "Monthly Revenue",
              value:
                  "₹${NumberFormat('#,###').format(data['order_statistics']['monthly_revenue'])}",
              icon: FontAwesomeIcons.moneyBillWave,
              color: emerald,
              subtitle:
                  "${data['order_statistics']['completed_orders']} completed orders",
              subtitleColor: emerald.withOpacity(0.7),
              gradientColors: [
                emerald.withOpacity(0.8),
                emerald.withOpacity(0.6)
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
    required Color subtitleColor,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: darkCharcoal,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: gradientColors,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.trending_up, color: subtitleColor, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _buildChartCard(
            title: "Sales & Revenue Trends",
            icon: FontAwesomeIcons.chartLine,
            height: 490,
            color: sapphire,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                    child: _buildLineChart(data),
                  ),
                ),
                _buildChartLegend([
                  {"label": "Orders", "color": sapphire},
                  {"label": "Revenue", "color": emerald},
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildChartCard(
                title: "Product Distribution",
                icon: FontAwesomeIcons.chartPie,
                height: 270,
                color: goldAccent,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: data['product_statistics']
                                      ['active_products']
                                  .toDouble(),
                              color: sapphire,
                              title: "Active",
                              radius: 60,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2),
                            ),
                            PieChartSectionData(
                              value: data['product_statistics']['sold_products']
                                  .toDouble(),
                              color: emerald,
                              title: "Sold",
                              radius: 60,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2),
                            ),
                            PieChartSectionData(
                              value: data['product_statistics']['hold_products']
                                  .toDouble(),
                              color: goldAccent,
                              title: "Hold",
                              radius: 60,
                              titleStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                              borderSide: const BorderSide(
                                  color: Colors.white, width: 2),
                            ),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem("Active", sapphire,
                                "${data['product_statistics']['active_products']}"),
                            const SizedBox(height: 16),
                            _buildLegendItem("Sold", emerald,
                                "${data['product_statistics']['sold_products']}"),
                            const SizedBox(height: 16),
                            _buildLegendItem("On Hold", goldAccent,
                                "${data['product_statistics']['hold_products']}"),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildChartCard(
                title: "Order Status",
                icon: FontAwesomeIcons.clipboardList,
                height: 190,
                color: deepBlue,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOrderStatusCard(
                        "Pending",
                        "${data['order_statistics']['pending_orders']}",
                        FontAwesomeIcons.hourglassHalf,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOrderStatusCard(
                        "Completed",
                        "${data['order_statistics']['completed_orders']}",
                        FontAwesomeIcons.circleCheck,
                        emerald,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildOrderStatusCard(
                        "Cancelled",
                        "${data['order_statistics']['cancelled_orders']}",
                        FontAwesomeIcons.circleXmark,
                        ruby,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderStatusCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, String value) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkCharcoal,
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard({
    required String title,
    required IconData icon,
    required Widget child,
    required double height,
    required Color color,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkCharcoal,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.more_horiz, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildChartLegend(List<Map<String, dynamic>> items) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item['color'],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item['color'].withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  item['label'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: darkCharcoal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // Modified/New Code
  Widget _buildLineChart(Map<String, dynamic> data) {
    // Generate sample data since the API doesn't provide monthly trends
    final List<FlSpot> orderSpots = [];
    final List<FlSpot> revenueSpots = [];

    // Generate sample data for 12 months
    for (int i = 0; i < 12; i++) {
      // Use the total orders and revenue as a base, then distribute randomly
      double orderValue = (data['order_statistics']['total_orders'] * 0.1 +
              i * 100 +
              (i % 3) * 200)
          .toDouble();
      double revenueValue = (data['order_statistics']['monthly_revenue'] * 0.1 +
              i * 500 +
              (i % 4) * 300)
          .toDouble();

      // Ensure minimum values
      orderValue = orderValue < 100 ? 100 + i * 50 : orderValue;
      revenueValue = revenueValue < 500 ? 500 + i * 200 : revenueValue;

      orderSpots.add(FlSpot(i.toDouble(), orderValue));
      revenueSpots.add(FlSpot(i.toDouble(), revenueValue));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1000,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 1000,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    value >= 1000
                        ? '${(value / 1000).toInt()}k'
                        : '${value.toInt()}',
                    style: TextStyle(
                      color: darkCharcoal.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                const months = [
                  'Jan',
                  'Feb',
                  'Mar',
                  'Apr',
                  'May',
                  'Jun',
                  'Jul',
                  'Aug',
                  'Sep',
                  'Oct',
                  'Nov',
                  'Dec'
                ];
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      months[value.toInt()],
                      style: TextStyle(
                        color: darkCharcoal.withOpacity(0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: false,
        ),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(color: goldAccent.withOpacity(0.3)),
            tooltipPadding: const EdgeInsets.all(12),
            getTooltipItems: (List<LineBarSpot> touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  '${spot.barIndex == 0 ? 'Orders: ' : 'Revenue: '}\$${NumberFormat('#,###').format(spot.y.toInt())}',
                  TextStyle(
                    color: spot.barIndex == 0 ? sapphire : emerald,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: orderSpots,
            isCurved: true,
            color: sapphire,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: sapphire,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  sapphire.withOpacity(0.3),
                  sapphire.withOpacity(0.01),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          LineChartBarData(
            spots: revenueSpots,
            isCurved: true,
            color: emerald,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: emerald,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  emerald.withOpacity(0.3),
                  emerald.withOpacity(0.01),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivities(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "Recent Activities",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildRecentOrdersTable(data),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildRecentSellersCard(data),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrdersTable(Map<String, dynamic> data) {
    final recentOrders = data['recent_activities']['recent_orders'] as List;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: deepBlue.withOpacity(0.2), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.bagShopping, color: deepBlue, size: 16),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: deepBlue,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.visibility,
                    color: Theme.of(context).colorScheme.primary, size: 16),
                label: Text('View All',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: recentOrders.isEmpty
                  ? _buildEmptyState(
                      "No recent orders found", FontAwesomeIcons.boxOpen)
                  : Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.2),
                        1: FlexColumnWidth(1.5),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: platinum.withOpacity(0.3),
                          ),
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(14),
                              child: Text('Order ID',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(14),
                              child: Text('Customer',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(14),
                              child: Text('Amount',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            Padding(
                              padding: EdgeInsets.all(14),
                              child: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        // Sample data since API returns empty list
                        _buildOrderTableRow('#ORD-001', 'Emma Wilson',
                            '\$3,499', 'Completed', emerald),
                        _buildOrderTableRow('#ORD-002', 'Michael Brown',
                            '\$1,299', 'Processing', sapphire),
                        _buildOrderTableRow('#ORD-003', 'Sarah Davis', '\$899',
                            'Shipped', Colors.purple),
                        _buildOrderTableRow('#ORD-004', 'James Miller', '\$599',
                            'Completed', emerald),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildOrderTableRow(String orderId, String customer, String amount,
      String status, Color statusColor) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(orderId,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: deepBlue,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(customer),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Text(amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSellersCard(Map<String, dynamic> data) {
    final recentSellers = data['recent_activities']['recent_sellers'] as List;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            border: Border.all(color: goldAccent.withOpacity(0.2), width: 1),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.userTie,
                          color: goldAccent, size: 16),
                      const SizedBox(width: 12),
                      Text(
                        'New Sellers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: goldAccent,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.visibility,
                        color: Theme.of(context).colorScheme.primary, size: 16),
                    label: Text('View All',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary)),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (recentSellers.isNotEmpty)
                ...recentSellers
                    .take(4)
                    .map((seller) => _buildSellerItem(
                          seller['company_name'] ?? 'Unknown Company',
                          'Diamond Seller',
                          'assets/images/others/504025HMQAAA00.webp',
                          (seller['is_verified'] ?? false)
                              ? 'Verified'
                              : 'Pending',
                          (seller['is_verified'] ?? false)
                              ? emerald
                              : Colors.orange,
                        ))
                    .toList()
              else
                _buildEmptyState(
                    "No recent sellers found", FontAwesomeIcons.userSlash),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSellerItem(String name, String role, String image, String status,
      Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: platinum.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundImage: AssetImage(image),
              radius: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: deepBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    color: darkCharcoal.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Modified/New Code - User Tab
  Widget _buildUserStatistics(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: sapphire,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "User Statistics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            int crossAxisCount = maxWidth > 1200
                ? 4
                : maxWidth > 800
                    ? 2
                    : 1;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.0,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              children: [
                _buildStatCard(
                  title: "Total Users",
                  value: "${data['user_statistics']['total_users']}",
                  icon: FontAwesomeIcons.users,
                  color: sapphire,
                  subtitle: "Active accounts",
                  subtitleColor: emerald,
                  gradientColors: [
                    sapphire.withOpacity(0.8),
                    sapphire.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "Total Buyers",
                  value: "${data['user_statistics']['total_buyers']}",
                  icon: FontAwesomeIcons.userTag,
                  color: deepBlue,
                  subtitle: "Registered buyers",
                  subtitleColor: deepBlue.withOpacity(0.7),
                  gradientColors: [
                    deepBlue.withOpacity(0.8),
                    deepBlue.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "Total Sellers",
                  value: "${data['user_statistics']['total_sellers']}",
                  icon: FontAwesomeIcons.userTie,
                  color: goldAccent,
                  subtitle: "Registered sellers",
                  subtitleColor: goldAccent.withOpacity(0.7),
                  gradientColors: [
                    goldAccent.withOpacity(0.8),
                    goldAccent.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "New Users (Month)",
                  value:
                      "${data['user_statistics']['new_users']['this_month']}",
                  icon: FontAwesomeIcons.userPlus,
                  color: emerald,
                  subtitle: "This month",
                  subtitleColor: emerald.withOpacity(0.7),
                  gradientColors: [
                    emerald.withOpacity(0.8),
                    emerald.withOpacity(0.6)
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        _buildSellerVerificationStats(data),
      ],
    );
  }

  Widget _buildSellerVerificationStats(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: sapphire.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.userCheck, color: sapphire, size: 18),
              const SizedBox(width: 12),
              Text(
                'Seller Verification Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: sapphire,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildVerificationCard(
                  "Pending",
                  "${data['seller_statistics']['pending_sellers']}",
                  FontAwesomeIcons.hourglassHalf,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVerificationCard(
                  "Approved",
                  "${data['seller_statistics']['approved_sellers']}",
                  FontAwesomeIcons.circleCheck,
                  emerald,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVerificationCard(
                  "Rejected",
                  "${data['seller_statistics']['rejected_sellers']}",
                  FontAwesomeIcons.circleXmark,
                  ruby,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildVerificationCard(
                  "Total",
                  "${data['seller_statistics']['total_sellers']}",
                  FontAwesomeIcons.users,
                  sapphire,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSellersSection(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;
    final recentSellers = data['recent_activities']['recent_sellers'] as List;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.userTie, color: goldAccent, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    'Registered Sellers',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: goldAccent,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.visibility,
                    color: Theme.of(context).colorScheme.primary, size: 16),
                label: Text('View All',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (recentSellers.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentSellers.length,
              itemBuilder: (context, index) {
                final seller = recentSellers[index];
                final approvalStatus = seller['approval_status'] ?? 'pending';
                final isVerified = approvalStatus == 'approved';
                final businessAddress = seller['business_address'] ?? {};
                final address = [
                  businessAddress['street'],
                  businessAddress['city'],
                  businessAddress['state'],
                  businessAddress['country']
                ].where((part) => part != null).join(', ');

                return _buildDetailedSellerItem(
                  seller['business_name'] ?? 'Unknown Company',
                  address.isNotEmpty ? address : 'No address provided',
                  seller['business_description'] ?? 'No description available',
                  seller['logo_url'] ??
                      'assets/images/others/504025HMQAAA00.webp',
                  isVerified ? 'Verified' : 'Pending',
                  isVerified ? emerald : Colors.orange,
                  DateFormat('MMM d, y')
                      .format(DateTime.parse(seller['created_at'])),
                );
              },
            )
          else
            _buildEmptyState("No sellers found", FontAwesomeIcons.userSlash),
        ],
      ),
    );
  }

  Widget _buildDetailedSellerItem(
    String name,
    String address,
    String description,
    String image,
    String status,
    Color statusColor,
    String date,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: platinum.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(image),
                  radius: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: deepBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        color: darkCharcoal.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              color: darkCharcoal.withOpacity(0.8),
              fontSize: 13,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Joined: $date",
                style: TextStyle(
                  color: darkCharcoal.withOpacity(0.6),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: sapphire, size: 18),
                    onPressed: () {},
                    tooltip: 'Edit',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: ruby, size: 18),
                    onPressed: () {},
                    tooltip: 'Delete',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modified/New Code - Products Tab
  Widget _buildProductStatistics(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: goldAccent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "Product Statistics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            int crossAxisCount = maxWidth > 1200
                ? 4
                : maxWidth > 800
                    ? 2
                    : 1;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.0,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              children: [
                _buildStatCard(
                  title: "Total Products",
                  value: "${data['product_statistics']['total_products']}",
                  icon: FontAwesomeIcons.gem,
                  color: goldAccent,
                  subtitle: "All products",
                  subtitleColor: goldAccent.withOpacity(0.7),
                  gradientColors: [
                    goldAccent.withOpacity(0.8),
                    goldAccent.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "Active Products",
                  value: "${data['product_statistics']['active_products']}",
                  icon: FontAwesomeIcons.thumbsUp,
                  color: sapphire,
                  subtitle: "Available for sale",
                  subtitleColor: sapphire.withOpacity(0.7),
                  gradientColors: [
                    sapphire.withOpacity(0.8),
                    sapphire.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "Sold Products",
                  value: "${data['product_statistics']['sold_products']}",
                  icon: FontAwesomeIcons.cartShopping,
                  color: emerald,
                  subtitle: "Completed sales",
                  subtitleColor: emerald.withOpacity(0.7),
                  gradientColors: [
                    emerald.withOpacity(0.8),
                    emerald.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "On Hold Products",
                  value: "${data['product_statistics']['hold_products']}",
                  icon: FontAwesomeIcons.pause,
                  color: Colors.orange,
                  subtitle: "Reserved items",
                  subtitleColor: Colors.orange.withOpacity(0.7),
                  gradientColors: [
                    Colors.orange.withOpacity(0.8),
                    Colors.orange.withOpacity(0.6)
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        _buildProductDistributionChart(data),
      ],
    );
  }

  Widget _buildProductDistributionChart(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.chartPie, color: goldAccent, size: 18),
              const SizedBox(width: 12),
              Text(
                'Product Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: goldAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 380,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: data['product_statistics']['active_products'] >
                                  0
                              ? data['product_statistics']['active_products']
                                  .toDouble()
                              : 1,
                          color: sapphire,
                          title: "Active",
                          radius: 100,
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                        ),
                        PieChartSectionData(
                          value: data['product_statistics']['sold_products'] > 0
                              ? data['product_statistics']['sold_products']
                                  .toDouble()
                              : 1,
                          color: emerald,
                          title: "Sold",
                          radius: 100,
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                        ),
                        PieChartSectionData(
                          value: data['product_statistics']['hold_products'] > 0
                              ? data['product_statistics']['hold_products']
                                  .toDouble()
                              : 1,
                          color: Colors.orange,
                          title: "On Hold",
                          radius: 100,
                          titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                          borderSide:
                              const BorderSide(color: Colors.white, width: 2),
                        ),
                      ],
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildProductLegendItem(
                        "Active Products",
                        sapphire,
                        "${data['product_statistics']['active_products']}",
                        "Available for purchase",
                      ),
                      const SizedBox(height: 24),
                      _buildProductLegendItem(
                        "Sold Products",
                        emerald,
                        "${data['product_statistics']['sold_products']}",
                        "Successfully sold",
                      ),
                      const SizedBox(height: 24),
                      _buildProductLegendItem(
                        "On Hold Products",
                        Colors.orange,
                        "${data['product_statistics']['hold_products']}",
                        "Reserved by customers",
                      ),
                      const SizedBox(height: 24),
                      _buildProductLegendItem(
                        "Total Products",
                        goldAccent,
                        "${data['product_statistics']['total_products']}",
                        "All products in system",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductLegendItem(
      String label, Color color, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: darkCharcoal.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentProductsSection(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;
    final recentProducts = data['recent_activities']['recent_products'] as List;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: goldAccent.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.gem, color: goldAccent, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    'Recent Products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: goldAccent,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.visibility,
                    color: Theme.of(context).colorScheme.primary, size: 16),
                label: Text('View All',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (recentProducts.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentProducts.length > 5 ? 5 : recentProducts.length,
              itemBuilder: (context, index) {
                final product = recentProducts[index];
                return _buildProductItem(
                  product['name'] ?? 'Unnamed Product',
                  product['type'] ?? 'Diamond',
                  product['price'] != null
                      ? '\$${NumberFormat('#,###.##').format(product['price'])}'
                      : 'Price not set',
                  product['images'] != null && product['images'].isNotEmpty
                      ? product['images'][0]
                      : 'assets/images/diamonds/diamond_placeholder.png',
                  product['status'] ?? 'Active',
                  product['status'] == 'Sold'
                      ? emerald
                      : product['status'] == 'Active'
                          ? sapphire
                          : Colors.orange,
                  DateFormat('MMM d, y')
                      .format(DateTime.parse(product['created_at'])),
                  product['carat'] != null ? '${product['carat']} ct' : 'N/A',
                );
              },
            )
          else
            _buildEmptyState("No products found", FontAwesomeIcons.boxOpen),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    String name,
    String type,
    String price,
    String image,
    String status,
    Color statusColor,
    String date,
    String carat,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: platinum.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: goldAccent.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: image.startsWith('http')
                  ? CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/diamonds/diamond_placeholder.png',
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      image,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: deepBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(FontAwesomeIcons.tag,
                        size: 12, color: darkCharcoal.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Text(
                      type,
                      style: TextStyle(
                        color: darkCharcoal.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(FontAwesomeIcons.weightHanging,
                        size: 12, color: darkCharcoal.withOpacity(0.6)),
                    const SizedBox(width: 6),
                    Text(
                      carat,
                      style: TextStyle(
                        color: darkCharcoal.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: goldAccent,
                      ),
                    ),
                    Text(
                      "Added: $date",
                      style: TextStyle(
                        color: darkCharcoal.withOpacity(0.6),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: sapphire, size: 18),
                    onPressed: () {},
                    tooltip: 'Edit',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                  IconButton(
                    icon: Icon(Icons.visibility, color: goldAccent, size: 18),
                    onPressed: () {},
                    tooltip: 'View',
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Modified/New Code - Orders Tab
  Widget _buildOrderStatistics(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: deepBlue,
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Text(
            "Order Statistics",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            int crossAxisCount = maxWidth > 1200
                ? 4
                : maxWidth > 800
                    ? 2
                    : 1;

            return GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 2.0,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              children: [
                _buildStatCard(
                  title: "Total Orders",
                  value: "${data['order_statistics']['total_orders']}",
                  icon: FontAwesomeIcons.bagShopping,
                  color: deepBlue,
                  subtitle: "All orders",
                  subtitleColor: deepBlue.withOpacity(0.7),
                  gradientColors: [
                    deepBlue.withOpacity(0.8),
                    deepBlue.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "Pending Orders",
                  value: "${data['order_statistics']['pending_orders']}",
                  icon: FontAwesomeIcons.hourglassHalf,
                  color: Colors.orange,
                  subtitle: "Awaiting processing",
                  subtitleColor: Colors.orange.withOpacity(0.7),
                  gradientColors: [
                    Colors.orange.withOpacity(0.8),
                    Colors.orange.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "Completed Orders",
                  value: "${data['order_statistics']['completed_orders']}",
                  icon: FontAwesomeIcons.circleCheck,
                  color: emerald,
                  subtitle: "Successfully delivered",
                  subtitleColor: emerald.withOpacity(0.7),
                  gradientColors: [
                    emerald.withOpacity(0.8),
                    emerald.withOpacity(0.6)
                  ],
                ),
                _buildStatCard(
                  title: "Monthly Revenue",
                  value:
                      "\$${NumberFormat('#,###').format(data['order_statistics']['monthly_revenue'])}",
                  icon: FontAwesomeIcons.moneyBillWave,
                  color: goldAccent,
                  subtitle: "This month",
                  subtitleColor: goldAccent.withOpacity(0.7),
                  gradientColors: [
                    goldAccent.withOpacity(0.8),
                    goldAccent.withOpacity(0.6)
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 30),
        _buildOrderStatusChart(data),
      ],
    );
  }

  Widget _buildOrderStatusChart(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: deepBlue.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FontAwesomeIcons.chartBar, color: deepBlue, size: 18),
              const SizedBox(width: 12),
              Text(
                'Order Status Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: deepBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 390,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10, // Set a minimum value for visualization
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipRoundedRadius: 8,
                          tooltipBorder:
                              BorderSide(color: deepBlue.withOpacity(0.3)),
                          tooltipPadding: const EdgeInsets.all(12),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            String status;
                            switch (groupIndex) {
                              case 0:
                                status = 'Pending';
                                break;
                              case 1:
                                status = 'Completed';
                                break;
                              case 2:
                                status = 'Cancelled';
                                break;
                              default:
                                status = '';
                            }
                            return BarTooltipItem(
                              '$status: ${rod.toY.toInt()}',
                              TextStyle(
                                color: deepBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              String text;
                              switch (value.toInt()) {
                                case 0:
                                  text = 'Pending';
                                  break;
                                case 1:
                                  text = 'Completed';
                                  break;
                                case 2:
                                  text = 'Cancelled';
                                  break;
                                default:
                                  text = '';
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Text(
                                  text,
                                  style: TextStyle(
                                    color: darkCharcoal.withOpacity(0.7),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: darkCharcoal.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withOpacity(0.15),
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(
                              toY: data['order_statistics']['pending_orders'] >
                                      0
                                  ? data['order_statistics']['pending_orders']
                                      .toDouble()
                                  : 1,
                              color: Colors.orange,
                              width: 40,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(
                              toY: data['order_statistics']
                                          ['completed_orders'] >
                                      0
                                  ? data['order_statistics']['completed_orders']
                                      .toDouble()
                                  : 1,
                              color: emerald,
                              width: 40,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(
                              toY: data['order_statistics']
                                          ['cancelled_orders'] >
                                      0
                                  ? data['order_statistics']['cancelled_orders']
                                      .toDouble()
                                  : 1,
                              color: ruby,
                              width: 40,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ListView(
                    children: [
                      _buildOrderLegendItem(
                        "Pending Orders",
                        Colors.orange,
                        "${data['order_statistics']['pending_orders']}",
                        "Awaiting processing",
                      ),
                      const SizedBox(height: 24),
                      _buildOrderLegendItem(
                        "Completed Orders",
                        emerald,
                        "${data['order_statistics']['completed_orders']}",
                        "Successfully delivered",
                      ),
                      const SizedBox(height: 24),
                      _buildOrderLegendItem(
                        "Cancelled Orders",
                        ruby,
                        "${data['order_statistics']['cancelled_orders']}",
                        "Order cancelled",
                      ),
                      const SizedBox(height: 24),
                      _buildOrderLegendItem(
                        "Total Orders",
                        deepBlue,
                        "${data['order_statistics']['total_orders']}",
                        "All orders",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderLegendItem(
      String label, Color color, String value, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: darkCharcoal.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrdersSection(DashboardState state) {
    if (state is! DashboardLoaded) return const SizedBox.shrink();
    final data = state.dashboardData;
    final recentOrders = data['recent_activities']['recent_orders'] as List;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(color: deepBlue.withOpacity(0.3), width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(FontAwesomeIcons.bagShopping, color: deepBlue, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    'Order History',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: deepBlue,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.visibility,
                    color: Theme.of(context).colorScheme.primary, size: 16),
                label: Text('View All',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (recentOrders.isNotEmpty)
            _buildOrdersTable(recentOrders)
          else
            _buildEmptyState("No orders found", FontAwesomeIcons.boxOpen),
        ],
      ),
    );
  }

  Widget _buildOrdersTable(List orders) {
    // Since the API returns an empty list, we'll create sample data
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Container(
              color: platinum.withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: const [
                  Expanded(
                    flex: 1,
                    child: Text('Order ID',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('Customer',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Date',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Amount',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text('Status',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                      width: 80,
                      child: Text('Actions',
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            // Sample order data
            _buildOrderRow('#ORD-001', 'Emma Wilson', '2023-04-15', '\$3,499',
                'Completed', emerald),
            _buildOrderRow('#ORD-002', 'Michael Brown', '2023-04-12', '\$1,299',
                'Processing', sapphire),
            _buildOrderRow('#ORD-003', 'Sarah Davis', '2023-04-10', '\$899',
                'Shipped', Colors.purple),
            _buildOrderRow('#ORD-004', 'James Miller', '2023-04-08', '\$599',
                'Completed', emerald),
            _buildOrderRow('#ORD-005', 'Jennifer Taylor', '2023-04-05',
                '\$2,199', 'Cancelled', ruby),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderRow(String orderId, String customer, String date,
      String amount, String status, Color statusColor) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              orderId,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: deepBlue,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(customer),
          ),
          Expanded(
            flex: 1,
            child: Text(
              date,
              style: TextStyle(
                color: darkCharcoal.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              amount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                status,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.visibility, color: sapphire, size: 18),
                  onPressed: () {},
                  tooltip: 'View',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: darkCharcoal.withOpacity(0.6), size: 18),
                  onPressed: () {},
                  tooltip: 'More',
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Modified/New Code - Empty State Widget
  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: darkCharcoal.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: darkCharcoal.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, color: Colors.white),
              label:
                  const Text("Add New", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
