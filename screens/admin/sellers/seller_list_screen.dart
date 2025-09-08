// lib/screens/admin/sellers/seller_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_bloc.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_event.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/seller_model.dart';
import 'package:jewellery_diamond/widgets/cust_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jewellery_diamond/screens/admin/products/widget/pagination_widget.dart';
import 'package:jewellery_diamond/screens/admin/sellers/widgets/seller_table_widget.dart';

class SellerListScreen extends StatefulWidget {
  static const String routeName = '/admin/sellers';

  const SellerListScreen({Key? key}) : super(key: key);

  @override
  State<SellerListScreen> createState() => _SellerListScreenState();
}

class _SellerListScreenState extends State<SellerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String _sortBy = 'created_at';
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadSellers();
  }

  void _loadSellers() {
    context.read<SellerManagementBloc>().add(
          FetchSellers(
            page: _currentPage,
            limit: _itemsPerPage,
            search: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
            sortBy: _sortBy,
            approvalStatus: _selectedStatus,
          ),
        );
  }

  void _handleApproval(String sellerId, bool approve, {String? reason}) {
    if (approve) {
      context.read<SellerManagementBloc>().add(ApproveSeller(sellerId));
    } else {
      if (reason == null || reason.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please provide a reason for rejection'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      context.read<SellerManagementBloc>().add(RejectSeller(sellerId, reason));
    }
  }

  void _handleDelete(String sellerId) {
    context.read<SellerManagementBloc>().add(DeleteSeller(sellerId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<SellerManagementBloc, SellerManagementState>(
      listener: (context, state) {
        if (state is SellerActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _loadSellers();
        } else if (state is SellerManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(colorScheme),
            const SizedBox(height: 24),
            _buildFilters(colorScheme),
            const SizedBox(height: 24),
            Expanded(
              child: BlocBuilder<SellerManagementBloc, SellerManagementState>(
                builder: (context, state) {
                  if (state is SellerManagementLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is SellersLoaded) {
                    return Column(
                      children: [
                        Expanded(
                          child: SellerTable(
                            sellers: state.sellers,
                            onApprove: (seller) =>
                                _handleApproval(seller.id!, true),
                            onReject: (seller, reason) => _handleApproval(
                                seller.id!, false,
                                reason: reason),
                            onDelete: (seller) => _handleDelete(seller.userId),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PaginationWidget(
                          currentPage: _currentPage,
                          totalItems: state.totalItems,
                          itemsPerPage: _itemsPerPage,
                          onPageChanged: (page) {
                            setState(() {
                              _currentPage = page;
                            });
                            _loadSellers();
                          },
                        ),
                      ],
                    );
                  } else if (state is SellerManagementError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline,
                              size: 60, color: Colors.red.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${state.message}',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadSellers,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('No sellers found'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seller Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage all registered sellers in the system',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        CustButton(
          onPressed: () {
            context.go('${AppRoutes.adminSellers}/create');
          },
          icon: const Icon(Icons.add),
          child: const Text('Add New Seller'),
        ),
      ],
    );
  }

  Widget _buildFilters(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Expanded(
            flex: 3,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by company name or address...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _loadSellers();
                  }
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('All')),
                DropdownMenuItem(value: 'approved', child: Text('Approved')),
                DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                _loadSellers();
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              value: _sortBy,
              decoration: InputDecoration(
                labelText: 'Sort By',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'created_at', child: Text('Date Created')),
                DropdownMenuItem(
                    value: 'company_name', child: Text('Company Name')),
                DropdownMenuItem(value: 'rating', child: Text('Rating')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                _loadSellers();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showApproveDialog(SellerModel seller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Seller'),
        content:
            Text('Are you sure you want to approve ${seller.businessName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleApproval(seller.id!, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(SellerModel seller) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Seller'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to reject ${seller.businessName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a reason for rejection'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              Navigator.pop(context);
              _handleApproval(seller.id!, false,
                  reason: reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}
