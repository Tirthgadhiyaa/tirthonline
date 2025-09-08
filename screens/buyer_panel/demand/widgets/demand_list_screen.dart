// lib/screens/buyer_panel/demand/widgets/demand_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../../widgets/responsive_ui.dart';

class DemandListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> demands;

  const DemandListScreen({
    super.key,
    required this.demands,
  });

  @override
  State<DemandListScreen> createState() => _DemandListScreenState();
}

class _DemandListScreenState extends State<DemandListScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _tableAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create animations
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _tableAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(_tableAnimation),
        child: _buildDemandTable(theme),
      ),
    );
  }

  Widget _buildDemandTable(ThemeData theme) {
    final isMobile = Device.mobile(context);
    final isTablet = Device.tablet(context);
    final isDesktop = Device.desktop(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return SizedBox(
          width: availableWidth,
          height: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
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
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Shape')),
                        DataColumn(label: Text('Carat Range')),
                        DataColumn(label: Text('Color Range')),
                        DataColumn(label: Text('Clarity Range')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Matches')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: widget.demands.asMap().entries.map((entry) {
                        int index = entry.key;
                        var demand = entry.value;

                        return DataRow(
                          color: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.hovered)) {
                              return theme.colorScheme.primary
                                  .withOpacity(0.05);
                            }
                            return index.isEven
                                ? Colors.white
                                : Colors.grey.shade50;
                          }),
                          cells: [
                            DataCell(Text(demand['id'])),
                            DataCell(Text(demand['date'])),
                            DataCell(Text(demand['shape'])),
                            DataCell(Text(demand['carat'])),
                            DataCell(Text(demand['color'])),
                            DataCell(Text(demand['clarity'])),
                            DataCell(
                                _buildStatusBadge(demand['status'], theme)),
                            DataCell(Text(demand['matches'].toString())),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.visibility_outlined,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  tooltip: 'View Matches',
                                  onPressed: () {
                                    // View matches action
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: theme.colorScheme.secondary,
                                    size: 20,
                                  ),
                                  tooltip: 'Edit Demand',
                                  onPressed: () {
                                    // Edit demand action
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: theme.colorScheme.error,
                                    size: 20,
                                  ),
                                  tooltip: 'Delete Demand',
                                  onPressed: () {
                                    // Delete demand action
                                  },
                                ),
                              ],
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

  Widget _buildStatusBadge(String status, ThemeData theme) {
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'Active':
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'Fulfilled':
        backgroundColor = theme.colorScheme.primary.withOpacity(0.1);
        textColor = theme.colorScheme.primary;
        break;
      case 'Expired':
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }
}
