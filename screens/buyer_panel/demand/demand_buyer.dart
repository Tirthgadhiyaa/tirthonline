// lib/screens/buyer_panel/demand/demand_buyer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'widgets/demand_form_screen.dart';
import 'widgets/demand_list_screen.dart';

class DemandUser extends StatefulWidget {
  static const String routeName = '/user-demand';

  const DemandUser({super.key});

  @override
  State<DemandUser> createState() => _DemandUserState();
}

class _DemandUserState extends State<DemandUser>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _headerAnimation;
  bool _showForm = false;

  // Mock data for demands
  final List<Map<String, dynamic>> _demands = [
    {
      'id': 'DM-001',
      'date': '2023-06-15',
      'shape': 'Round',
      'carat': '1.0-1.5',
      'color': 'D-F',
      'clarity': 'VS1-VVS2',
      'status': 'Active',
      'matches': 12,
    },
    {
      'id': 'DM-002',
      'date': '2023-06-20',
      'shape': 'Princess',
      'carat': '0.8-1.2',
      'color': 'G-H',
      'clarity': 'SI1-VS2',
      'status': 'Active',
      'matches': 8,
    },
    {
      'id': 'DM-003',
      'date': '2023-07-05',
      'shape': 'Oval',
      'carat': '1.5-2.0',
      'color': 'E-G',
      'clarity': 'VS2-SI1',
      'status': 'Fulfilled',
      'matches': 5,
    },
    {
      'id': 'DM-004',
      'date': '2023-07-12',
      'shape': 'Emerald',
      'carat': '2.0-3.0',
      'color': 'D-E',
      'clarity': 'VVS1-VVS2',
      'status': 'Active',
      'matches': 3,
    },
    {
      'id': 'DM-005',
      'date': '2023-08-01',
      'shape': 'Cushion',
      'carat': '1.2-1.8',
      'color': 'F-H',
      'clarity': 'VS1-VS2',
      'status': 'Expired',
      'matches': 0,
    },
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Create animations
    _headerAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Animated Header
          FadeTransition(
            opacity: _headerAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.2),
                end: Offset.zero,
              ).animate(_headerAnimation),
              child: _buildHeader(theme),
            ),
          ),

          // Action Bar
          FadeTransition(
            opacity: _headerAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.1),
                end: Offset.zero,
              ).animate(_headerAnimation),
              child: _buildActionBar(theme),
            ),
          ),

          // Main Content - Either Form or List
          Expanded(
            child: _showForm
                ? DemandFormScreen(
                    onCancel: () => setState(() => _showForm = false),
                    onSubmit: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                              'Demand request submitted successfully!'),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                      setState(() => _showForm = false);
                    },
                  )
                : DemandListScreen(demands: _demands),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              FontAwesomeIcons.fileLines,
              color: theme.colorScheme.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Demand',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Request specific diamonds for your needs',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildStatsSummary(theme),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStatItem(
            icon: FontAwesomeIcons.fileCircleCheck,
            value: _demands
                .where((d) => d['status'] == 'Active')
                .length
                .toString(),
            label: 'Active',
            theme: theme,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: FontAwesomeIcons.gem,
            value: _demands
                .fold<int>(0, (sum, d) => sum + (d['matches'] as int))
                .toString(),
            label: 'Matches',
            theme: theme,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: FontAwesomeIcons.check,
            value: _demands
                .where((d) => d['status'] == 'Fulfilled')
                .length
                .toString(),
            label: 'Fulfilled',
            theme: theme,
            valueColor: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: valueColor ?? theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildActionBar(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _showForm ? 'Create New Demand' : 'Your Demand Requests',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          FilledButton.icon(
            onPressed: () {
              setState(() {
                _showForm = !_showForm;
              });
            },
            icon: Icon(_showForm ? Icons.list : Icons.add),
            label: Text(_showForm ? "View Demands" : "Create Demand"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
