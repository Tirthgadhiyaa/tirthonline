// lib/screens/admin/sellers/seller_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_bloc.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_event.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/seller_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class SellerDetailScreen extends StatefulWidget {
  final String sellerId;

  const SellerDetailScreen({Key? key, required this.sellerId})
      : super(key: key);

  @override
  State<SellerDetailScreen> createState() => _SellerDetailScreenState();
}

class _SellerDetailScreenState extends State<SellerDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadSellerDetails();
  }

  void _loadSellerDetails() {
    context.read<SellerManagementBloc>().add(FetchSellerById(widget.sellerId));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocConsumer<SellerManagementBloc, SellerManagementState>(
          listener: (context, state) {
            if (state is SellerActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
              _loadSellerDetails();
            } else if (state is SellerManagementError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is SellerManagementLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SellerDetailLoaded) {
              return _buildSellerDetails(state.seller, colorScheme);
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
                      onPressed: _loadSellerDetails,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('Seller not found'));
          },
        ),
      ),
    );
  }

  Widget _buildSellerDetails(SellerModel seller, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(seller, colorScheme),
        const SizedBox(height: 24),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildSellerInfo(seller, colorScheme),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildSellerActions(seller, colorScheme),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(SellerModel seller, ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                context.go(AppRoutes.adminSellers);
              },
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.businessName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: seller.approvalStatus == 'approved'
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: seller.approvalStatus == 'approved'
                              ? Colors.green.shade300
                              : Colors.orange.shade300,
                        ),
                      ),
                      child: Text(
                        seller.approvalStatus == 'approved'
                            ? 'Verified'
                            : 'Pending Verification',
                        style: TextStyle(
                          color: seller.approvalStatus == 'approved'
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Joined: ${DateFormat('MMMM d, y').format(seller.createdAt)}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                context.go('${AppRoutes.adminSellers}/${seller.id}/edit');
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(width: 12),
            if (seller.approvalStatus != 'approved')
              ElevatedButton.icon(
                onPressed: () {
                  _showApproveDialog(seller);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Approve'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            if (seller.approvalStatus != 'approved') const SizedBox(width: 12),
            if (seller.approvalStatus != 'approved')
              ElevatedButton.icon(
                onPressed: () {
                  _showRejectDialog(seller);
                },
                icon: const Icon(Icons.cancel),
                label: const Text('Reject'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSellerInfo(SellerModel seller, ColorScheme colorScheme) {
    final address = seller.businessAddress;
    final formattedAddress = [
      address['street'],
      address['city'],
      address['state'],
      address['country'],
      address['postal_code']
    ].where((part) => part != null && part.isNotEmpty).join(', ');

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seller Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            icon: FontAwesomeIcons.building,
            title: 'Business Name',
            value: seller.businessName,
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: FontAwesomeIcons.locationDot,
            title: 'Business Address',
            value: formattedAddress,
          ),
          if (seller.taxId != null) ...[
            const Divider(height: 32),
            _buildInfoRow(
              icon: FontAwesomeIcons.idCard,
              title: 'Tax ID',
              value: seller.taxId!,
            ),
          ],
          if (seller.businessDescription.isNotEmpty) ...[
            const Divider(height: 32),
            _buildInfoRow(
              icon: FontAwesomeIcons.circleInfo,
              title: 'Business Description',
              value: seller.businessDescription,
              isMultiLine: true,
            ),
          ],
          const Divider(height: 32),
          _buildInfoRow(
            icon: FontAwesomeIcons.star,
            title: 'Rating',
            value: '${seller.rating} / 5.0',
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: FontAwesomeIcons.userCheck,
            title: 'Verification Status',
            value: seller.approvalStatus == 'approved'
                ? 'Verified'
                : 'Pending Verification',
            valueColor: seller.approvalStatus == 'approved'
                ? Colors.green
                : Colors.orange,
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: FontAwesomeIcons.calendar,
            title: 'Created At',
            value: DateFormat('MMMM d, y').format(seller.createdAt),
          ),
          const Divider(height: 32),
          _buildInfoRow(
            icon: FontAwesomeIcons.clockRotateLeft,
            title: 'Last Updated',
            value: DateFormat('MMMM d, y').format(seller.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Color? valueColor,
    bool isMultiLine = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSellerActions(SellerModel seller, ColorScheme colorScheme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              _buildActionButton(
                icon: Icons.edit,
                label: 'Edit Seller',
                color: Colors.blue,
                onPressed: () {
                  context.go('${AppRoutes.adminSellers}/${seller.id}/edit');
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.shopping_bag,
                label: 'View Products',
                color: Colors.purple,
                onPressed: () {
                  // Navigate to seller products
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                icon: Icons.analytics,
                label: 'View Analytics',
                color: Colors.teal,
                onPressed: () {
                  // Navigate to seller analytics
                },
              ),
              if (seller.approvalStatus != 'approved') ...[
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.check_circle,
                  label: 'Approve Seller',
                  color: Colors.green,
                  onPressed: () {
                    _showApproveDialog(seller);
                  },
                ),
                const SizedBox(height: 12),
                _buildActionButton(
                  icon: Icons.cancel,
                  label: 'Reject Seller',
                  color: Colors.red,
                  onPressed: () {
                    _showRejectDialog(seller);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 24),
              _buildStatItem(
                icon: FontAwesomeIcons.gem,
                label: 'Total Products',
                value: '0',
              ),
              const SizedBox(height: 16),
              _buildStatItem(
                icon: FontAwesomeIcons.bagShopping,
                label: 'Total Orders',
                value: '0',
              ),
              const SizedBox(height: 16),
              _buildStatItem(
                icon: FontAwesomeIcons.moneyBill,
                label: 'Total Revenue',
                value: '\$0.00',
              ),
              const SizedBox(height: 16),
              _buildStatItem(
                icon: FontAwesomeIcons.star,
                label: 'Average Rating',
                value: '${seller.rating} / 5.0',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: Colors.grey.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
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
              context
                  .read<SellerManagementBloc>()
                  .add(ApproveSeller(seller.id!));
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
              context.read<SellerManagementBloc>().add(
                    RejectSeller(seller.id!, reasonController.text.trim()),
                  );
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
