import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_bloc.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_state.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_event.dart';
import 'package:jewellery_diamond/utils/shared_preference.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/models/user_model.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userData = SharedPreferencesHelper.instance.userData;
    final isAuthenticated = userData != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
              context.goNamed(AppRouteNames.home);
            },
          ),
        ],
      ),
      body: isAuthenticated
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(userData),
                  const SizedBox(height: 24),
                  _buildProfileSection(
                    title: 'Personal Information',
                    children: [
                      _buildInfoRow('Name', userData.fullName),
                      _buildInfoRow('Email', userData.email),
                      // Note: Phone number is not in the model, so we'll remove it for now
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildProfileSection(
                    title: 'Account Settings',
                    children: [
                      ListTile(
                        leading: const Icon(Icons.edit),
                        title: const Text('Edit Profile'),
                        onTap: () {
                          // Navigate to edit profile page
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Change Password'),
                        onTap: () {
                          // Navigate to change password page
                        },
                      ),
                    ],
                  ),
                  if (userData.role == 'admin' || userData.role == 'seller')
                    const SizedBox(height: 24),
                  if (userData.role == 'admin' || userData.role == 'seller')
                    _buildProfileSection(
                      title: 'Business Information',
                      children: const [
                        // Note: Business information is not in the model, so we'll show a message
                        Text('Business information not available'),
                      ],
                    ),
                ],
              ),
            )
          : const Center(
              child: Text('Please login to view profile'),
            ),
    );
  }

  Widget _buildProfileHeader(UserModel userData) {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userData.fullName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            userData.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _getRoleColor(userData.role),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              userData.role.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'seller':
        return Colors.blue;
      case 'buyer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
