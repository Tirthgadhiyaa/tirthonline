// This file will be a copy of seller_list_screen.dart, adapted for buyers (users).
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/user_model.dart';
import 'package:jewellery_diamond/widgets/cust_button.dart';
import 'package:jewellery_diamond/screens/admin/buyers/widgets/buyer_table_widget.dart';
import 'package:jewellery_diamond/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:jewellery_diamond/bloc/user_management_bloc/user_management_event.dart';
import 'package:jewellery_diamond/bloc/user_management_bloc/user_management_state.dart';
import 'package:jewellery_diamond/core/widgets/custom_snackbar.dart';
import 'package:jewellery_diamond/screens/admin/products/widget/pagination_widget.dart';

class BuyerListScreen extends StatefulWidget {
  static const String routeName = '/admin/buyers';

  const BuyerListScreen({Key? key}) : super(key: key);

  @override
  State<BuyerListScreen> createState() => _BuyerListScreenState();
}

class _BuyerListScreenState extends State<BuyerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;
  String _sortBy = 'created_at';
  int _currentPage = 1;
  int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadBuyers();
  }

  void _loadBuyers() {
    context.read<UserManagementBloc>().add(
          FetchUsers(
            skip: (_currentPage - 1) * _itemsPerPage,
            limit: _itemsPerPage,
            search: _searchController.text.isNotEmpty
                ? _searchController.text
                : null,
            sortBy: _sortBy,
            isActive: _selectedStatus == 'Active'
                ? true
                : _selectedStatus == 'Inactive'
                    ? false
                    : null,
            role: 'buyer',
          ),
        );
  }

  void _activateUser(String userId) {
    context.read<UserManagementBloc>().add(ActivateUser(userId));
  }

  void _deactivateUser(String userId) {
    context.read<UserManagementBloc>().add(DeactivateUser(userId));
  }

  void _deleteUser(String userId) {
    context.read<UserManagementBloc>().add(DeleteUser(userId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state is UserActionSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          _loadBuyers();
        } else if (state is UserManagementError) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.red,
          );
        }
      },
      builder: (context, state) {
        List<UserModel> buyers = [];
        if (state is UsersLoaded) {
          buyers = state.users;
        }
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(colorScheme),
              const SizedBox(height: 24),
              _buildFilters(colorScheme),
              const SizedBox(height: 24),
              Expanded(
                child: state is UserManagementLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                      child: Column(
                          children: [
                            BuyerTable(
                              buyers: buyers,
                              onActivate: _activateUser,
                              onDeactivate: _deactivateUser,
                              onDelete: _deleteUser,
                            ),
                            if (state is UsersLoaded) ...[
                              const SizedBox(height: 16),
                              PaginationWidget(
                                currentPage: _currentPage,
                                totalItems: state.totalItems,
                                itemsPerPage: _itemsPerPage,
                                onPageChanged: (page) {
                                  setState(() {
                                    _currentPage = page;
                                  });
                                  _loadBuyers();
                                },
                              ),
                            ],
                          ],
                        ),
                    ),
              ),
            ],
          ),
        );
      },
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
              'Buyer Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage all registered buyers in the system',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        // CustButton(
        //   onPressed: () {
        //     context.go('${AppRoutes.adminBuyers}/create');
        //   },
        //   icon: const Icon(Icons.add),
        //   child: const Text('Add New Buyer'),
        // ),
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
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    _loadBuyers();
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
                DropdownMenuItem(value: 'Active', child: Text('Active')),
                DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                _loadBuyers();
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
                DropdownMenuItem(value: 'full_name', child: Text('Name')),
                DropdownMenuItem(value: 'email', child: Text('Email')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                });
                _loadBuyers();
              },
            ),
          ),
        ],
      ),
    );
  }
}
