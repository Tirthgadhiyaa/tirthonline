import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:jewellery_diamond/bloc/orders_bloc/orders_state.dart';
import 'package:jewellery_diamond/widgets/cust_button.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';

import '../../../bloc/diamondproduct_bloc/diamond_event.dart';
import '../../../bloc/orders_bloc/orders_bloc.dart';
import '../../../bloc/orders_bloc/orders_event.dart';
import '../../../models/orders_response_model.dart';
import '../../../services/api/orders_service.dart';
import '../../../widgets/sized_box_widget.dart';
import '../products/widget/pagination_widget.dart';

// // BLoC Pattern Implementation
// // Events
// abstract class OrderEvent {}
//
// class FetchOrders extends OrderEvent {}
//
// class FilterOrders extends OrderEvent {
//   final String? keyword;
//   final DateTimeRange? dateRange;
//   final String? status;
//
//   FilterOrders({this.keyword, this.dateRange, this.status});
// }
//
// // States
// abstract class OrderState {}
//
// class OrderInitial extends OrderState {}
//
// class OrderLoading extends OrderState {}
//
// class OrderLoaded extends OrderState {
//   final List<Order> orders;
//   final Map<String, int> statusCounts;
//   final Map<String, double> statusPercentChanges;
//
//   OrderLoaded(this.orders, this.statusCounts, this.statusPercentChanges);
// }
//
// class OrderError extends OrderState {
//   final String message;
//   OrderError(this.message);
// }
//
// // BLoC
// class OrderBloc extends Bloc<OrderEvent, OrderState> {
//   OrderBloc() : super(OrderInitial()) {
//     on<FetchOrders>(_onFetchOrders);
//     on<FilterOrders>(_onFilterOrders);
//   }
//
//   Future<void> _onFetchOrders(
//       FetchOrders event, Emitter<OrderState> emit) async {
//     emit(OrderLoading());
//     try {
//       // Normally you would fetch data from a repository here
//       final orders = _getDummyOrders();
//       final statusCounts = _getStatusCounts(orders);
//       final statusPercentChanges = _getStatusPercentChanges();
//
//       emit(OrderLoaded(orders, statusCounts, statusPercentChanges));
//     } catch (e) {
//       emit(OrderError("Failed to load orders: $e"));
//     }
//   }
//
//   Future<void> _onFilterOrders(
//       FilterOrders event, Emitter<OrderState> emit) async {
//     emit(OrderLoading());
//     try {
//       final allOrders = _getDummyOrders();
//
//       // Apply filters
//       final filteredOrders = allOrders.where((order) {
//         bool matches = true;
//
//         if (event.keyword != null && event.keyword!.isNotEmpty) {
//           matches = matches &&
//               (order.orderId
//                       .toLowerCase()
//                       .contains(event.keyword!.toLowerCase()) ||
//                   order.customerName
//                       .toLowerCase()
//                       .contains(event.keyword!.toLowerCase()));
//         }
//
//         if (event.dateRange != null) {
//           matches = matches &&
//               order.date.isAfter(event.dateRange!.start) &&
//               order.date
//                   .isBefore(event.dateRange!.end.add(const Duration(days: 1)));
//         }
//
//         if (event.status != null && event.status!.isNotEmpty) {
//           matches = matches && order.status == event.status;
//         }
//
//         return matches;
//       }).toList();
//
//       final statusCounts = _getStatusCounts(filteredOrders);
//       final statusPercentChanges = _getStatusPercentChanges();
//
//       emit(OrderLoaded(filteredOrders, statusCounts, statusPercentChanges));
//     } catch (e) {
//       emit(OrderError("Failed to filter orders: $e"));
//     }
//   }
//
//   Map<String, int> _getStatusCounts(List<Order> orders) {
//     return {
//       'total': orders.length,
//       'processing': orders.where((o) => o.status == 'Processing').length,
//       'shipped': orders.where((o) => o.status == 'Shipped').length,
//       'cancelled': orders.where((o) => o.status == 'Cancelled').length,
//     };
//   }
//
//   Map<String, double> _getStatusPercentChanges() {
//     // In a real app, this would compare with previous data
//     return {
//       'total': 12.5,
//       'processing': 5.2,
//       'shipped': 18.7,
//       'cancelled': -2.3,
//     };
//   }
//
//   List<Order> _getDummyOrders() {
//     return [
//       Order(
//         orderId: 'ORD-2024-001',
//         customerName: 'John Smith',
//         date: DateTime(2024, 1, 15),
//         status: 'Processing',
//         amount: 299.99,
//         customerInstructions: 'Please gift wrap the items',
//         productionNotes: 'Customer requested express shipping',
//       ),
//       Order(
//         orderId: 'ORD-2024-002',
//         customerName: 'Emma Wilson',
//         date: DateTime(2024, 1, 14),
//         status: 'In Production',
//         amount: 549.99,
//         customerInstructions: 'Custom color: Navy Blue',
//         productionNotes: 'Materials in stock, production started',
//       ),
//       Order(
//         orderId: 'ORD-2024-003',
//         customerName: 'Michael Brown',
//         date: DateTime(2024, 1, 14),
//         status: 'Shipped',
//         amount: 189.99,
//         customerInstructions: 'Handle with care',
//         productionNotes: 'Shipped via FedEx',
//       ),
//       Order(
//         orderId: 'ORD-2024-004',
//         customerName: 'Sarah Davis',
//         date: DateTime(2024, 1, 13),
//         status: 'Delivered',
//         amount: 459.99,
//         customerInstructions: 'Leave at front door',
//         productionNotes: 'Delivered on time',
//       ),
//       Order(
//         orderId: 'ORD-2024-005',
//         customerName: 'James Wilson',
//         date: DateTime(2024, 1, 13),
//         status: 'Cancelled',
//         amount: 699.99,
//         customerInstructions: 'Custom size requested',
//         productionNotes: 'Cancelled due to stock unavailability',
//       ),
//     ];
//   }
// }
//
// // Models
// class Order {
//   final String orderId;
//   final String customerName;
//   final DateTime date;
//   final String status;
//   final double amount;
//   final String customerInstructions;
//   final String productionNotes;
//
//   Order({
//     required this.orderId,
//     required this.customerName,
//     required this.date,
//     required this.status,
//     required this.amount,
//     required this.customerInstructions,
//     required this.productionNotes,
//   });
// }

// UI Implementation
class OrderManagementScreen extends StatefulWidget {
  static const String routeName = '/odermanagement';

  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  DateTimeRange? _selectedDateRange;
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _fetchOrdersProducts();
  }

  void _fetchOrdersProducts() {
    int skip = (currentPage - 1) * itemsPerPage;
    context
        .read<OrdersBloc>()
        .add(FetchAdminOrders(limit: itemsPerPage, skip: skip,search:_searchController.text,selectedDateRange: _selectedDateRange));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrdersBloc, OrdersState>(
      listener: (context, state) {
        if (state is OrderStatusUpdatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order status updated successfully')),
          );
          _fetchOrdersProducts();
        } else if (state is OrdersError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update order status')),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrdersError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is OrdersLoaded) {
              return _buildOrdersContent(context, state);
            }
            return const Center(child: Text('Something went wrong.'));
          },
        ),
      ),
    );
  }

  Widget _buildOrdersContent(BuildContext context, OrdersLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildStatusCards(state),
        const SizedBox(height: 24),
        _buildFiltersRow(),
        const SizedBox(height: 16),
        _buildOrdersTable(state),
        const SizedBox(height: 16),
        BlocBuilder<OrdersBloc, OrdersState>(
          builder: (context, state) {
            if (state is OrdersLoaded) {
              return PaginationWidget(
                currentPage: currentPage,
                totalItems: state.total!,
                itemsPerPage: itemsPerPage,
                onPageChanged: (newPage) {
                  setState(() {
                    print("---$newPage");
                    currentPage = newPage;
                    _fetchOrdersProducts();
                  });
                },
              );
            }
            return Container();
          },
        ),
        // _buildPagination(state),
      ],
    );
  }

  Widget _buildStatusCards(OrdersLoaded state) {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 700;
      final cardWidth = isSmallScreen
          ? constraints.maxWidth
          : (constraints.maxWidth / 4) - 20;

      return Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _buildStatusCard(
            title: 'Total Orders',
            count: 0,
            percentChange: 0,
            width: cardWidth,
            bgColor: Colors.blue.shade50,
            icon: Icons.shopping_cart,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
          _buildStatusCard(
            title: 'Processing Orders',
            count: 0,
            percentChange: 0,
            width: cardWidth,
            bgColor: Colors.orange.shade50,
            icon: Icons.hourglass_bottom,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
          _buildStatusCard(
            title: 'Shipped Orders',
            count: 0,
            percentChange: 0,
            width: cardWidth,
            bgColor: Colors.green.shade50,
            icon: Icons.local_shipping,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
          _buildStatusCard(
            title: 'Cancelled Orders',
            count: 0,
            percentChange: 0,
            width: cardWidth,
            bgColor: Colors.red.shade50,
            icon: Icons.cancel,
            iconColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      );
    });
  }

  Widget _buildFiltersRow() {
    return LayoutBuilder(builder: (context, constraints) {
      final isSmallScreen = constraints.maxWidth < 700;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: isSmallScreen ? constraints.maxWidth : 300,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search orders...',
                    prefixIcon:
                        const Icon(Icons.search, color: Colors.grey, size: 16),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onChanged: (value) {

                    Future.delayed(const Duration(milliseconds: 500),
                            () {
                          if (mounted) {
                            _fetchOrdersProducts();
                          }
                        });
                  },
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustButton(
                    onPressed: () async {
                      final initialDateRange = DateTimeRange(
                        start:
                            DateTime.now().subtract(const Duration(days: 30)),
                        end: DateTime.now(),
                      );

                      final result = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange:
                            _selectedDateRange ?? initialDateRange,
                      );

                      if (result != null) {
                        setState(() {
                          _selectedDateRange = result;
                          _fetchOrdersProducts();
                        });
                      }
                    },
                    icon: const Icon(Icons.calendar_today, size: 16),
                    isOutlined: true,
                    child: const Text('Date Range'),
                  ),
                  // const SizedBox(width: 12),
                  // CustButton(
                  //   onPressed: () {},
                  //   icon: const Icon(Icons.filter_list, size: 16),
                  //   isOutlined: true,
                  //   child: const Text('Filter'),
                  // ),
                ],
              ),
            ],
          ),
          CustButton(
            onPressed: () {},
            icon: const Icon(Icons.download, size: 16),
            child: const Text('Export'),
          ),
        ],
      );
    });
  }

  Widget _buildOrdersTable(OrdersLoaded state) {
    // Calculate pagination
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage > state.orders.length
        ? state.orders.length
        : startIndex + itemsPerPage;

    final displayedOrders = state.orders.sublist(
        startIndex < state.orders.length ? startIndex : 0,
        endIndex < state.orders.length ? endIndex : state.orders.length);

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 700;

          if (isSmallScreen) {
            return _buildOrderCardsList(displayedOrders);
          } else {
            return _buildOrdersDataTable(displayedOrders);
          }
        },
      ),
    );
  }

  Widget _buildOrdersDataTable(List<Order> orders) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && event.scrollDelta.dy != 0) {
          if (event.kind == PointerDeviceKind.mouse &&
              RawKeyboard.instance.keysPressed
                  .contains(LogicalKeyboardKey.shiftLeft)) {
            _scrollController.jumpTo(
              _scrollController.position.pixels + event.scrollDelta.dy,
            );
          }
        }
      },
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _scrollController.jumpTo(
            _scrollController.position.pixels - details.primaryDelta!,
          );
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
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
                minWidth: MediaQuery.of(context).size.width * 0.85,
              ),
              child: DataTable(
                dataRowColor: MaterialStateProperty.all<Color>(Colors.white),
                headingRowColor: MaterialStateProperty.resolveWith(
                  (states) => Theme.of(context).colorScheme.primary,
                ),
                dividerThickness: 0.0,
                headingRowHeight: Device.mobile(context) ? 50 : 60,
                dataRowHeight: Device.mobile(context) ? 40 : 50,
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
                columnSpacing: Device.desktop(context)
                    ? 20
                    : Device.tablet(context)
                        ? 30
                        : 20,
                showCheckboxColumn: false,
                columns: const [
                  DataColumn(
                    label: Text('STOCK ID'),
                  ),
                  DataColumn(
                    label: Text('CUSTOMER'),
                  ),
                  DataColumn(
                    label: Text('DATE'),
                  ),
                  DataColumn(
                    label: Text('STATUS'),
                  ),
                  DataColumn(
                    label: Text('AMOUNT'),
                  ),
                ],
                rows: orders.asMap().entries.map((entry) {
                  int index = entry.key;
                  Order order = entry.value;
                  return DataRow(
                    color: MaterialStateColor.resolveWith(
                      (states) =>
                          index.isOdd ? const Color(0xFFFAF3F3) : Colors.white,
                    ),
                    cells: [
                      DataCell(Text(
                        order.items != null &&
                                order.items!.isNotEmpty &&
                                order.items![0].product != null
                            ? order.items![0].product!.stockNumber ?? ""
                            : "",
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      )),
                      DataCell(Text(order.shippingAddress?.name ?? "")),
                      DataCell(Text(DateFormat('yyyy-MM-dd')
                          .format(DateTime.parse(order.createdAt ?? "")))),
                      DataCell(_buildStatusBadge(order.status ?? "")),
                      DataCell(Text(
                        '\$${order.totalAmount?.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      )),
                    ],
                    onSelectChanged: (selected){
                      if (selected == true) {
                         _showOrderDetailsDialog(context, order);
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, Order order) {
    String selectedStatus = order.status ?? 'pending';
    bool isUpdating = false;

     showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) => Dialog(
              insetPadding: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 750),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Order Details',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall!
                                .copyWith(color: Colors.grey.shade600)),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Order ID: #${order.orderNumber}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(width: 12),
                            _buildStatusBadge(order.status ?? ''),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Date of Order  •  '
                          '${DateFormat('yyyy-MM-dd').format(DateTime.parse(order.createdAt ?? ''))}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Summary',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(fontWeight: FontWeight.w600)),
                              const Divider(thickness: 1.2, height: 28),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Customer info
                                  Expanded(
                                    child: _buildInfoTable(
                                      header: 'Customer Information',
                                      rows: {
                                        'Name':
                                            order.shippingAddress?.name ?? '—',
                                        'Email':
                                            order.shippingAddress?.name ?? '—',
                                        'Shipping Address':
                                            order.shippingAddress?.street ??
                                                '—',
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 40),

                                  Expanded(
                                    child: _buildInfoTable(
                                      header: 'Product details',
                                      rows: {
                                        'Product name':
                                            order.items?[0].product?.name ??
                                                '—',
                                        'Code': order.items?[0].product
                                                ?.stockNumber ??
                                            '—',
                                        'Quantity':
                                            '${order.items?[0].quantity ?? 0}',
                                        'Price':
                                            '₹${order.items?[0].product?.price?.toStringAsFixed(0) ?? '0'}',
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildInfoTable(
                                header: 'Order Total',
                                rows: {
                                  'Subtotal':
                                      '₹${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                                  'Shipping Cost':
                                      '₹${order.shippingCost?.toStringAsFixed(0) ?? '0'}',
                                  'Total Amount Paid':
                                      '₹${order.totalAmount?.toStringAsFixed(0) ?? '0'}',
                                },
                              ),
                              const SizedBox(height: 32),
                              _buildOrderTimeline(order.status ?? ''),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(6),
                            color: Colors.white,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _actionHeader('Change Order Status'),
                                  _actionHeader('Update'),
                                  _actionHeader('Cancel Order'),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<String>(
                                          isExpanded: true,
                                          value: selectedStatus,
                                          items: [
                                            'pending',
                                            'processing',
                                            'shipped',
                                            'delivered',
                                            'cancelled'
                                          ]
                                              .map((e) => DropdownMenuItem(
                                                    value: e,
                                                    child: Text(
                                                      e[0].toUpperCase() +
                                                          e.substring(1),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ))
                                              .toList(),
                                          onChanged: (value) {
                                            setState(() {
                                              selectedStatus = value ?? "";
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  _actionButton(
                                    label: ' Update',
                                    color: const Color(0xff511845),
                                    onTap: isUpdating
                                        ? null
                                        : () async {
                                            setState(() {
                                              isUpdating = true;
                                            });
                                            try {
                                              context.read<OrdersBloc>().add(
                                                  UpdateOrderStatus(
                                                      newStatus: selectedStatus,
                                                      orderId: order.id ?? ""));
                                              // ScaffoldMessenger.of(context)
                                              //     .showSnackBar(
                                              //   SnackBar(
                                              //       content: Text(
                                              //           'Order status updated successfully')),
                                              // );
                                              Navigator.of(context).pop();
                                              // _fetchOrdersProducts();
                                            } catch (e) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                    content: Text(
                                                        'Failed to update status: $e')),
                                              );
                                              setState(() {
                                                isUpdating = false;
                                              });
                                              Navigator.of(context).pop();
                                            }
                                          },
                                  ),
                                  _actionButton(
                                    label: 'Cancel Order',
                                    color: Colors.red,
                                    onTap: isUpdating
                                        ? null
                                        : () async {
                                      setState(() {
                                        isUpdating = true;
                                      });
                                      try {
                                        context.read<OrdersBloc>().add(
                                            UpdateOrderStatus(
                                                newStatus:"cancelled",
                                                orderId: order.id ?? ""));
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Order status cancelled successfully')),
                                        );
                                        Navigator.of(context).pop();
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Failed to update status: $e')),
                                        );
                                        setState(() {
                                          isUpdating = false;
                                        });
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildInfoTable({
    required String header,
    required Map<String, String> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(header,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 12),
        ...rows.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 110,
                  child: Text(e.key,
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                ),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionHeader(String title) => Expanded(
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            border: Border(
              right: BorderSide(color: Colors.grey.shade300),
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ),
      );

  Widget _actionButton({
    required String label,
    IconData? icon,
    required Color color,
    required Future<void> Function()? onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 40,
            color: color,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                ],
                Text(label,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );

  Widget _buildStatusBadge(String status) {
    final Map<String, Color> map = {
      'pending': Colors.amber,
      'processing': Colors.orange,
      'shipped': Colors.deepPurple,
      'delivered': Colors.green,
      'cancelled': Colors.red,
    };
    final Color bg =
        (map[status.toLowerCase()] ?? Colors.grey).withOpacity(.15);
    final Color fg = map[status.toLowerCase()] ?? Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status[0].toUpperCase() + status.substring(1),
        style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildOrderTimeline(String status) {
    final stages = ['pending', 'processing', 'shipped', 'delivered'];
    final currentIndex = stages.indexOf(status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Order Progress', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: List.generate(stages.length * 2 - 1, (i) {
            if (i % 2 == 1) {
              // connector line
              return Expanded(
                child: Container(
                  height: 4,
                  color: i ~/ 2 < currentIndex ? Colors.green : Colors.grey.shade300,
                ),
              );
            } else {
              int index = i ~/ 2;
              bool isActive = index <= currentIndex;
              Color color;
              switch (stages[index]) {
                case 'pending':
                  color = Colors.brown;
                  break;
                case 'processing':
                  color = Colors.orange;
                  break;
                case 'shipped':
                  color = Colors.blue;
                  break;
                case 'delivered':
                  color = Colors.green;
                  break;
                default:
                  color = Colors.grey;
              }

              return Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isActive ? color : Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(Icons.check,
                          size: 12, color: isActive ? Colors.white : Colors.transparent),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stages[index][0].toUpperCase() + stages[index].substring(1),
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? color : Colors.grey,
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }
          }),
        ),
      ],
    );
  }

  Widget _buildOrderCardsList(List<Order> orders) {
    return ListView.separated(
      itemCount: orders.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final order = orders[index];
        return InkWell(
          onTap: () => {},
          child: Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.orderNumber ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      _buildStatusBadge(order.status ?? ""),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(order.shippingAddress?.name ?? ""),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(DateFormat('yyyy-MM-dd')
                          .format(DateTime.parse(order.createdAt ?? ""))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.attach_money,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '\$${order.totalAmount?.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        onPressed: () {
                          _showOrderDetailsDialog(context, order);
                        },
                        color: Colors.grey.shade700,
                        splashRadius: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () {},
                        color: Colors.grey.shade700,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusCard({
    required String title,
    required int count,
    required double percentChange,
    required double width,
    required Color bgColor,
    required IconData icon,
    required Color iconColor,
  }) {
    final isPositive = percentChange >= 0;

    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Icon(icon, color: iconColor),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Row(
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isPositive ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      Text(
                        '${isPositive ? '+' : ''}${percentChange.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



}
// Widget _buildStatusBadge(String status) {
//   Color bgColor;
//   Color textColor;
//
//   switch (status) {
//     case 'pending':
//       bgColor = Colors.amber.shade100;
//       textColor = Colors.amber.shade800;
//       break;
//     case 'Processing':
//       bgColor = Colors.orange.shade100;
//       textColor = Colors.orange.shade800;
//       break;
//     case 'In Production':
//       bgColor = Colors.purple.shade100;
//       textColor = Colors.purple.shade800;
//       break;
//     case 'shipped':
//       bgColor = Colors.green.shade100;
//       textColor = Colors.green.shade800;
//       break;
//     case 'Delivered':
//       bgColor = Colors.blue.shade100;
//       textColor = Colors.blue.shade800;
//       break;
//     case 'cancelled':
//       bgColor = Colors.red.shade100;
//       textColor = Colors.red.shade800;
//       break;
//     default:
//       bgColor = Colors.grey.shade100;
//       textColor = Colors.grey.shade800;
//   }
//
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//     decoration: BoxDecoration(
//       color: bgColor,
//       borderRadius: BorderRadius.circular(12),
//     ),
//     child: Text(
//       status,
//       style: TextStyle(
//         color: textColor,
//         fontSize: 12,
//         fontWeight: FontWeight.w500,
//       ),
//     ),
//   );
// }

// Widget _buildOrdersDataTable(List<Order> orders) {
//   return SingleChildScrollView(
//     child: DataTable(
//       columnSpacing: 16,
//       showCheckboxColumn: false,
//       headingRowColor: WidgetStateProperty.all(
//           Theme.of(context).colorScheme.primary.withOpacity(0.0)),
//       columns: const [
//         DataColumn(
//           label: Text(
//             'ORDER ID',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           ),
//         ),
//         DataColumn(
//           label: Text(
//             'CUSTOMER',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           ),
//         ),
//         DataColumn(
//           label: Text(
//             'DATE',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           ),
//         ),
//         DataColumn(
//           label: Text(
//             'STATUS',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           ),
//         ),
//         DataColumn(
//           label: Text(
//             'AMOUNT',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           ),
//         ),
//         DataColumn(
//           label: Text(
//             'ACTIONS',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
//           ),
//         ),
//       ],
//       rows: orders.map((order) {
//         return DataRow(
//           cells: [
//             DataCell(Text(
//               order.orderId,
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             )),
//             DataCell(Text(order.customerName)),
//             DataCell(Text(DateFormat('yyyy-MM-dd').format(order.date))),
//             DataCell(_buildStatusBadge(order.status)),
//             DataCell(Text(
//               '\$${order.amount.toStringAsFixed(2)}',
//               style: const TextStyle(fontWeight: FontWeight.w500),
//             )),
//             DataCell(Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.edit_outlined, size: 20),
//                   onPressed: () {},
//                   color: Colors.grey.shade700,
//                   splashRadius: 20,
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline, size: 20),
//                   onPressed: () {},
//                   color: Colors.grey.shade700,
//                   splashRadius: 20,
//                 ),
//               ],
//             )),
//           ],
//           onSelectChanged: (selected) {
//             if (selected == true) {
//               _showOrderDetails(order);
//             }
//           },
//         );
//       }).toList(),
//     ),
//   );
// }

// void _showOrderDetails(Order order) {
//   // showModalBottomSheet(
//   //   context: context,
//   //   isScrollControlled: true,
//   //   builder: (context) {
//   //     return DraggableScrollableSheet(
//   //       initialChildSize: 0.6,
//   //       maxChildSize: 0.9,
//   //       minChildSize: 0.5,
//   //       expand: false,
//   //       builder: (context, scrollController) {
//   //         return Container(
//   //           padding: const EdgeInsets.all(16),
//   //           child: ListView(
//   //             bloc: scrollController,
//   //             children: [
//   //               Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Text(
//   //                     'Order Details',
//   //                     style: Theme.of(context).textTheme.titleLarge,
//   //                   ),
//   //                   IconButton(
//   //                     icon: const Icon(Icons.close),
//   //                     onPressed: () => Navigator.pop(context),
//   //                   ),
//   //                 ],
//   //               ),
//   //               const SizedBox(height: 16),
//   //               Card(
//   //                 elevation: 0,
//   //                 color: Colors.grey.shade50,
//   //                 child: Padding(
//   //                   padding: const EdgeInsets.all(16.0),
//   //                   child: Column(
//   //                     crossAxisAlignment: CrossAxisAlignment.start,
//   //                     children: [
//   //                       _buildDetailRow('Order ID:', order.orderId),
//   //                       _buildDetailRow('Customer:', order.customerName),
//   //                       _buildDetailRow('Date:',
//   //                           DateFormat('yyyy-MM-dd').format(order.date)),
//   //                       _buildDetailRow('Status:', order.status,
//   //                           isStatus: true),
//   //                       _buildDetailRow('Amount:',
//   //                           '\$${order.amount.toStringAsFixed(2)}'),
//   //                     ],
//   //                   ),
//   //                 ),
//   //               ),
//   //               const SizedBox(height: 24),
//   //               Text(
//   //                 'Customer Instructions:',
//   //                 style: Theme.of(context).textTheme.titleMedium,
//   //               ),
//   //               const SizedBox(height: 8),
//   //               Container(
//   //                 padding: const EdgeInsets.all(16),
//   //                 decoration: const BoxDecoration(
//   //                   border: Border(
//   //                     left: BorderSide(color: Colors.blue, width: 3),
//   //                   ),
//   //                 ),
//   //                 child: Text(order.customerInstructions),
//   //               ),
//   //               const SizedBox(height: 24),
//   //               Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //                 children: [
//   //                   Text(
//   //                     'Production Notes:',
//   //                     style: Theme.of(context).textTheme.titleMedium,
//   //                   ),
//   //                   TextButton.icon(
//   //                     onPressed: () {
//   //                       // Add note functionality
//   //                       Navigator.pop(context);
//   //                     },
//   //                     icon: const Icon(Icons.add, size: 18),
//   //                     label: const Text('Add Note'),
//   //                   )
//   //                 ],
//   //               ),
//   //               const SizedBox(height: 8),
//   //               Container(
//   //                 padding: const EdgeInsets.all(16),
//   //                 decoration: const BoxDecoration(
//   //                   border: Border(
//   //                     left: BorderSide(color: Colors.blue, width: 3),
//   //                   ),
//   //                 ),
//   //                 child: Text(order.productionNotes),
//   //               ),
//   //             ],
//   //           ),
//   //         );
//   //       },
//   //     );
//   //   },
//   // );
// }

//
// Widget _buildOrderTimeline(String status) {
//   final stages = ['pending', 'processing', 'shipped', 'delivered'];
//   final colors = {
//     'pending': Colors.brown,
//     'processing': Colors.orange,
//     'shipped': Colors.deepPurple,
//     'delivered': Colors.green,
//   };
//   final current = stages.indexOf(status.toLowerCase());
//
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const SizedBox(height: 8),
//       SizedBox(
//         height: 60,
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             final timelineWidth = constraints.maxWidth;
//
//             return Stack(
//               children: [
//
//                 Positioned(
//                   left: 6,
//                   right: 6,
//                   top: 28,
//                   child: Container(height: 4, color: Colors.grey.shade300),
//                 ),
//
//                 if (current >= 0)
//                   Positioned(
//                     left: 6,
//                     top: 28,
//                     width: (timelineWidth - 12) *
//                         (current / (stages.length - 1)),
//                     child: Container(
//                       height: 4,
//                       color: colors[stages[current]] ?? Colors.blue,
//                     ),
//                   ),
//
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: List.generate(stages.length, (i) {
//                     final isActive = i <= current;
//                     final color = isActive ? colors[stages[i]]! : Colors.grey;
//
//                     return Column(
//                       children: [
//                         Text(
//                           stages[i][0].toUpperCase() + stages[i].substring(1),
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: color,
//                             fontWeight: isActive
//                                 ? FontWeight.w600
//                                 : FontWeight.normal,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Icon(Icons.arrow_drop_down, size: 20, color: color),
//                       ],
//                     );
//                   }),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     ],
//   );
// }