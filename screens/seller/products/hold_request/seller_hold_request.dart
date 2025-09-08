import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../bloc/seller_hold_management_bloc/seller_hold_bloc.dart';
import '../../../../bloc/seller_hold_management_bloc/seller_hold_event.dart';
import '../../../../bloc/seller_hold_management_bloc/seller_hold_state.dart';
import '../../../admin/products/widget/pagination_widget.dart';

class SellerHoldRequestScreen extends StatefulWidget {
  static const String routeName = '/seller/hold-products';

  const SellerHoldRequestScreen({super.key});

  @override
  State<SellerHoldRequestScreen> createState() =>
      _SellerHoldRequestScreenState();
}

class _SellerHoldRequestScreenState extends State<SellerHoldRequestScreen> {
  final TextEditingController _searchController = TextEditingController();
  String selectedStatus = 'pending';
  int itemsPerPage = 20;
  int _currentPage = 0;
  Timer? _debounce;

  late HoldRequestBloc _holdRequestBloc;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _holdRequestBloc = HoldRequestBloc();
    _fetchData();
  }

  void _fetchData() {
    _holdRequestBloc.add(
      FetchHoldRequests(
        skip: _currentPage * itemsPerPage,
        limit: itemsPerPage,
        status: selectedStatus,
        search: _searchController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    final theme = Theme.of(context);
    return BlocProvider(
      create: (_) => _holdRequestBloc,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFC),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Diamond Hold Requests',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<HoldRequestBloc, HoldRequestState>(
              builder: (context, state) {
                  if (state is HoldRequestLoaded) {
                    final total = state.pendingCount + state.approvedCount + state.rejectedCount;
                    return Row(
                      children: [
                        buildSummaryCard('Total Requests', '$total', Icons.event_note),
                        buildSummaryCard('Pending', '${state.pendingCount}', Icons.schedule),
                        buildSummaryCard('Approved', '${state.approvedCount}', Icons.check_circle),
                        buildSummaryCard('Rejected', '${state.rejectedCount}', Icons.cancel),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        buildSummaryCard('Total Requests', '0', Icons.event_note),
                        buildSummaryCard('Pending', '0', Icons.schedule),
                        buildSummaryCard('Approved', '0', Icons.check_circle),
                        buildSummaryCard('Rejected', '0', Icons.cancel),
                      ],
                    );
                  }
                }
              ),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 20),
              _buildDataTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSummaryCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xfffee4e2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))
              ],
            )
          ],
        ),
      ),
    );
  }

  String _getRemainingTimeString(DateTime? holdExpiresAt) {
    if (holdExpiresAt == null) return "N/A";

    final now = DateTime.now();
    final remaining = holdExpiresAt.difference(now);

    if (remaining.isNegative) {
      return "Expired";
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;

    return '${hours}h ${minutes}m ${seconds}s';
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Stone_Id',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              prefixIcon: const Icon(Icons.search),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (_) {
              if (_debounce?.isActive ?? false) _debounce!.cancel();
              _debounce = Timer(const Duration(milliseconds: 400), () {
                setState(() {
                  _currentPage = 0;
                });
                _fetchData();
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedStatus,
              hint: const Text("Filter by Status"),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              icon: const Icon(Icons.keyboard_arrow_down),
              isExpanded: true,
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: ['All Status', 'Pending', 'Approved', 'Rejected']
                  .map((status) => DropdownMenuItem(
                        value: status.toLowerCase(),
                        child: Text(status),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedStatus = value.toLowerCase();
                    _currentPage = 0;
                  });
                  _fetchData();
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable() {
    return Expanded(
      child: BlocBuilder<HoldRequestBloc, HoldRequestState>(
        builder: (context, state) {
          if (state is HoldRequestLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HoldRequestLoaded) {
            if (state.holdRequests.isEmpty) {
              return const Center(
                child: Text(
                  'No hold requests found.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              );
            }
            final filtered = state.holdRequests.where((request) {
              final search = _searchController.text.toLowerCase();
              final productName = request.product.stockNumber.toLowerCase();
              return search.isEmpty || productName.contains(search);
            }).toList();

            return Column(
              children: [
                Expanded(
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
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minWidth:
                                  MediaQuery.of(context).size.width * 0.9),
                          child: DataTable(
                            dataRowColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            headingRowColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor),
                            headingTextStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            columns: const [
                              DataColumn(label: Text('Stone ID')),
                              DataColumn(label: Text('Diamond Details')),
                              DataColumn(label: Text('Customer Info')),
                              DataColumn(label: Text('Request Date')),
                              DataColumn(label: Text('Hold Duration')),
                              DataColumn(label: Text('Remaining Time')),
                              DataColumn(label: Text('Status')),
                              DataColumn(label: Text('Actions')),
                              DataColumn(label: Text('Extend Time')),
                            ],
                            rows: state.holdRequests.map((request) {
                              print(request.holdExpiresAt);
                              final status = request.status;
                              final product = request.product;
                              final customer = request.sellerId;

                              Color bgColor;
                              Color txtColor;

                              if (status == 'approved') {
                                bgColor = const Color(0xffd1fadf);
                                txtColor = const Color(0xff027a48);
                              } else if (status == 'rejected') {
                                bgColor = const Color(0xfffee4e2);
                                txtColor = const Color(0xffb42318);
                              } else {
                                bgColor = const Color(0xfffff6d4);
                                txtColor = const Color(0xffb54708);
                              }

                              return DataRow(cells: [
                                DataCell(
                                    Text(request.product?.stockNumber ?? '--')),
                                DataCell(Text(
                                  request.product != null
                                      ? '${request.product?.carat ?? "--"}ct, ${request.product?.shape?.isNotEmpty == true ? request.product!.shape![0] : "--"}, ${request.product?.cut ?? "--"}, ${request.product?.clarity ?? "--"}, ${request.product?.color ?? "--"} Color'
                                      : '--',
                                )),
                                DataCell(Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(request.buyer_name),
                                    Text("${request.buyer_emailid}",
                                        style: const TextStyle(
                                            color: Colors.grey)),
                                  ],
                                )),
                                DataCell(Text(DateFormat('MMM d, yyyy')
                                    .format(request.createdAt))),
                                DataCell(Text(
                                    (request.holdDurationHours != null &&
                                            request.holdDurationHours > 0)
                                        ? '${request.holdDurationHours} hours'
                                        : 'N/A')),
                                DataCell(Text(_getRemainingTimeString(
                                    request.holdExpiresAt))),
                                DataCell(Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        status == 'Approved'
                                            ? Icons.check_circle
                                            : status == 'Rejected'
                                                ? Icons.cancel
                                                : Icons.circle,
                                        size: 14,
                                        color: txtColor,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        status,
                                        style: TextStyle(
                                          color: txtColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                                DataCell(Row(
                                  children: [
                                    if (status == 'pending')
                                      ElevatedButton(
                                        onPressed: () {
                                          _showTimeDurationPicker(
                                            context,
                                            "${request.id}",
                                            (selectedHours) {
                                              if (selectedHours != null) {
                                                _holdRequestBloc.add(
                                                  ApproveHoldRequest(
                                                    holdRequestId:
                                                        "${request.id}",
                                                    duration: selectedHours,
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff7f1d1d),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Approve'),
                                      ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: () {
                                        if (status == 'approved') {
                                          _holdRequestBloc.add(
                                              RejectHoldRequest(
                                                  holdRequestId: request.id));
                                        } else {
                                          _holdRequestBloc.add(
                                              RejectHoldRequest(
                                                  holdRequestId: request.id));
                                        }
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(
                                            color: Color(0xff7f1d1d)),
                                        foregroundColor:
                                            const Color(0xff7f1d1d),
                                      ),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                )),
                                DataCell(Row(children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    tooltip: 'Extend Duration',
                                    onPressed: () {
                                      _showTimeDurationPicker(
                                        context,
                                        request.id,
                                        (selectedHours) {
                                          if (selectedHours != null) {
                                            _holdRequestBloc.add(
                                              ExtendHoldDuration(
                                                holdRequestId: "${request.id}",
                                                duration: selectedHours,
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    },
                                  )
                                ])),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildPaginationControls(state.totalItems),
              ],
            );
          } else if (state is HoldRequestError) {
            return Center(child: Text("Error: ${state.message}"));
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildPaginationControls(totalItems) {
    return PaginationWidget(
      currentPage: _currentPage,
      totalItems: totalItems,
      itemsPerPage: itemsPerPage,
      onPageChanged: (page) {
        setState(() {
          _currentPage = page;
        });
        _fetchData();
      },
    );
  }

  void _showTimeDurationPicker(
    BuildContext context,
    String requestId,
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

// void _showTimeDurationPicker(BuildContext context, String requestId) {
//   int selectedHours = 0;
//   int selectedMinutes = 0;
//   int selectedSeconds = 0;
//
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.white,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//     ),
//     builder: (BuildContext context) {
//       return Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Select Hold Duration',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 _buildPicker(
//                   label: 'Hrs',
//                   max: 72,
//                   onChanged: (value) => selectedHours = value,
//                 ),
//                 _buildPicker(
//                   label: 'Min',
//                   max: 59,
//                   onChanged: (value) => selectedMinutes = value,
//                 ),
//                 _buildPicker(
//                   label: 'Sec',
//                   max: 59,
//                   onChanged: (value) => selectedSeconds = value,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 final int totalDurationInSeconds = (selectedHours * 3600) +
//                     (selectedMinutes * 60) +
//                     selectedSeconds;
//
//                 _holdRequestBloc.add(
//                   ApproveHoldRequest(
//                     holdRequestId: requestId,
//                     // durationInSeconds: totalDurationInSeconds,
//                   ),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 elevation: 2,
//                 side: const BorderSide(color: Color(0xff7f1d1d), width: 1.5),
//                 foregroundColor: const Color(0xff7f1d1d),
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text(
//                 'Confirm Duration',
//                 style: TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       );
//     },
//   );
// }
//
// Widget _buildPicker({
//   required String label,
//   required int max,
//   required Function(int) onChanged,
// }) {
//   return Expanded(
//     child: Column(
//       children: [
//         SizedBox(
//           height: 150,
//           child: CupertinoPicker(
//             scrollController: FixedExtentScrollController(initialItem: 0),
//             itemExtent: 36,
//             onSelectedItemChanged: onChanged,
//             children: List.generate(
//                 max + 1, (index) => Center(child: Text('$index'))),
//           ),
//         ),
//         Text(label),
//       ],
//     ),
//   );
// }
}
