// This file will be a copy of seller_table_widget.dart, adapted for buyers (users).

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/user_model.dart';
import 'package:jewellery_diamond/screens/admin/buyers/widgets/EditBuyerDialog.dart';
import 'package:jewellery_diamond/widgets/responsive_ui.dart';

import '../../../../bloc/user_management_bloc/user_management_bloc.dart';

class BuyerTable extends StatefulWidget {
  final List<UserModel> buyers;
  final void Function(String userId)? onActivate;
  final void Function(String userId)? onDeactivate;
  final void Function(String userId)? onDelete;
  // TODO: Add onEdit, onDelete, etc. callbacks as needed

  const BuyerTable(
      {Key? key,
      required this.buyers,
      this.onActivate,
      this.onDeactivate,
      this.onDelete})
      : super(key: key);

  @override
  State<BuyerTable> createState() => _BuyerTableState();
}

class _BuyerTableState extends State<BuyerTable> {
  final ScrollController _scrollController = ScrollController();
  int _hoverIndex = -1;
@override
  void dispose() {
   _scrollController.dispose();
    // TODO: implement dispose
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    if (widget.buyers.isEmpty) {
      return const Center(child: Text('No buyers found.'));
    }

    return IntrinsicHeight(
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
                'Buyer List',
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
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
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
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Phone')),
                            DataColumn(label: Text('Role')),
                            DataColumn(label: Text('Status')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: widget.buyers.asMap().entries.map((entry) {
                            int index = entry.key;
                            var buyer = entry.value;
                            return DataRow(
                              color: MaterialStateColor.resolveWith(
                                (states) => index.isOdd
                                    ? const Color(0xFFFAF3F3)
                                    : Colors.white,
                              ),
                              cells: [
                                DataCell(Text(buyer.fullName)),
                                DataCell(Text(buyer.email)),
                                DataCell(Text(buyer.phone ?? '-')),
                                DataCell(Text(buyer.role)),
                                DataCell(
                                  buyer.isActive == null
                                      ? const Text('-')
                                      : buyer.isActive!
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.green.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Active',
                                                style: TextStyle(
                                                  color: Colors.green.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            )
                                          : Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                'Inactive',
                                                style: TextStyle(
                                                  color: Colors.orange.shade700,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
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
                                          showDialog(
                                            context: context,
                                            builder: (context) => BlocProvider(
                                              create: (_) => UserManagementBloc(),
                                              child: EditBuyerDialog(buyer),
                                            ),
                                          );
                                        },
                                        tooltip: 'Edit',
                                      ),
                                      if (buyer.isActive == false) ...[
                                        IconButton(
                                          icon: const Icon(Icons.check_circle,
                                              color: Colors.green),
                                          onPressed: widget.onActivate != null
                                              ? () => widget.onActivate!(buyer.id)
                                              : null,
                                          tooltip: 'Activate',
                                        ),
                                      ] else if (buyer.isActive == true) ...[
                                        IconButton(
                                          icon: const Icon(Icons.cancel,
                                              color: Colors.red),
                                          onPressed: widget.onDeactivate != null
                                              ? () => widget.onDeactivate!(buyer.id)
                                              : null,
                                          tooltip: 'Deactivate',
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
                                              title: const Text('Delete Buyer'),
                                              content: Text(
                                                  'Are you sure you want to delete ${buyer.fullName}?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    if (widget.onDelete != null) {
                                                      widget.onDelete!(buyer.id);
                                                    }
                                                  },
                                                  style: TextButton.styleFrom(
                                                    foregroundColor: Colors.red,
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
            ),
          ],
        ),
      ),
    );
  }
}
