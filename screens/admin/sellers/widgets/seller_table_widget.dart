import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/seller_model.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';
import 'package:intl/intl.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_bloc.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_event.dart';

import 'EditSellerDialog.dart';

class SellerTable extends StatefulWidget {
  final List<SellerModel> sellers;
  final Function(SellerModel) onApprove;
  final Function(SellerModel, String) onReject;
  final Function(SellerModel) onDelete;

  const SellerTable({
    super.key,
    required this.sellers,
    required this.onApprove,
    required this.onReject,
    required this.onDelete,
  });

  @override
  State<SellerTable> createState() => _SellerTableState();
}

class _SellerTableState extends State<SellerTable> {
  final ScrollController _scrollController = ScrollController();
  int _hoverIndex = -1;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sellers.isEmpty) {
      return const Center(child: Text('No sellers found.'));
    }

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
                    'Seller List',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                  ),
                ),
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
                          child: DataTable(
                            dataRowColor:
                                MaterialStateProperty.all<Color>(Colors.white),
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
                            columns: const [
                              DataColumn(label: Text('Business Name')),
                              DataColumn(label: Text('Owner')),
                              DataColumn(label: Text('Contact')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Rating')),
                              DataColumn(label: Text('Created At')),
                              DataColumn(label: Text('Actions')),
                            ],
                            rows: widget.sellers.asMap().entries.map((entry) {
                              int index = entry.key;
                              var seller = entry.value;

                              final address = seller.businessAddress;
                              final formattedAddress = [
                                address['street'],
                                address['city'],
                                address['state'],
                                address['country'],
                                address['postal_code']
                              ]
                                  .where(
                                      (part) => part != null && part.isNotEmpty)
                                  .join(', ');

                              return DataRow(
                                color: MaterialStateColor.resolveWith(
                                  (states) => index.isOdd
                                      ? const Color(0xFFFAF3F3)
                                      : Colors.white,
                                ),
                                cells: [
                                  DataCell(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          seller.businessName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Flexible(
                                          child: Text(
                                            formattedAddress,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            softWrap: false,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          seller.user['full_name'] ?? 'N/A',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          seller.user['email'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          seller.contactPhone,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          seller.user['phone'] ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            seller.approvalStatus == 'approved'
                                                ? Colors.green.shade100
                                                : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        seller.approvalStatus == 'approved'
                                            ? 'Approved'
                                            : 'Rejected',
                                        style: TextStyle(
                                          color: seller.approvalStatus ==
                                                  'approved'
                                              ? Colors.green.shade700
                                              : Colors.orange.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          seller.rating.toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Text(
                                      DateFormat('MMM d, y')
                                          .format(seller.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            // Navigate to edit seller page
                                            // context.pushNamed(
                                            //   AppRouteNames.adminSellerEdit,
                                            //   pathParameters: {
                                            //     'id': seller.id!
                                            //   },
                                            //   extra: seller,
                                            // );
                                            showDialog(
                                              context: context,
                                              builder: (context) => const EditSellerDialog(),
                                            );
                                          },
                                          tooltip: 'Edit',
                                        ),
                                        if (seller.approvalStatus ==
                                            'rejected') ...[
                                          IconButton(
                                            icon: const Icon(Icons.check_circle,
                                                color: Colors.green),
                                            onPressed: () {
                                              // Show approve confirmation dialog
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Approve Seller'),
                                                  content: Text(
                                                      'Are you sure you want to approve ${seller.businessName}?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        widget
                                                            .onApprove(seller);
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                      child:
                                                          const Text('Approve'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            tooltip: 'Approve',
                                          ),
                                        ] else ...[
                                          IconButton(
                                            icon: const Icon(Icons.cancel,
                                                color: Colors.red),
                                            onPressed: () {
                                              // Show reject confirmation dialog
                                              final TextEditingController
                                                  reasonController =
                                                  TextEditingController();
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title: const Text(
                                                      'Reject Seller'),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'Are you sure you want to reject ${seller.businessName}?'),
                                                      const SizedBox(
                                                          height: 16),
                                                      TextField(
                                                        controller:
                                                            reasonController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Reason for rejection',
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                        maxLines: 3,
                                                      ),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        if (reasonController
                                                            .text
                                                            .trim()
                                                            .isEmpty) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'Please provide a reason for rejection'),
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                          );
                                                          return;
                                                        }
                                                        Navigator.pop(context);
                                                        widget.onReject(
                                                            seller,
                                                            reasonController
                                                                .text
                                                                .trim());
                                                      },
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        foregroundColor:
                                                            Colors.white,
                                                      ),
                                                      child:
                                                          const Text('Reject'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            tooltip: 'Reject',
                                          ),
                                        ],
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () {
                                            // Show delete confirmation dialog
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title:
                                                    const Text('Delete Seller'),
                                                content: Text(
                                                    'Are you sure you want to delete ${seller.businessName}?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      widget.onDelete(seller);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.red,
                                                    ),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                          tooltip: 'Delete',
                                        ),
                                      ],
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
