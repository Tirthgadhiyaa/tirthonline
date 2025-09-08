// This file will be a copy of seller_form_screen.dart, adapted for buyers (users).

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/user_management_bloc/user_management_bloc.dart';
import 'package:jewellery_diamond/bloc/user_management_bloc/user_management_event.dart';
import 'package:jewellery_diamond/bloc/user_management_bloc/user_management_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/user_model.dart';
import 'package:jewellery_diamond/widgets/cust_button.dart';

class BuyerFormScreen extends StatefulWidget {
  final UserModel? buyer;

  const BuyerFormScreen({Key? key, this.buyer}) : super(key: key);

  @override
  State<BuyerFormScreen> createState() => _BuyerFormScreenState();
}

class _BuyerFormScreenState extends State<BuyerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String _role = 'buyer';
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.buyer != null) {
      _fullNameController.text = widget.buyer!.fullName;
      _emailController.text = widget.buyer!.email;
      _phoneController.text = widget.buyer!.phone ?? '';
      _role = widget.buyer!.role;
      _isActive = widget.buyer!.isActive ?? true;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userData = {
        'full_name': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _role,
        'is_active': _isActive,
      };
      final data = {
        'user_data': userData,
      };
      if (widget.buyer == null) {
        userData['password'] = _passwordController.text.trim();
        context.read<UserManagementBloc>().add(CreateUser(data));
      } else {
        userData['password'] = _passwordController.text.trim();
        context
            .read<UserManagementBloc>()
            .add(UpdateUser(widget.buyer!.id, data));
      }
      context.go(AppRoutes.adminBuyers);
    }
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
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
              widget.buyer != null ? 'Edit Buyer' : 'Create Buyer',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.buyer != null
                  ? 'Edit buyer information'
                  : 'Create a new buyer',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;
    final isEdit = widget.buyer != null;

    return BlocListener<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state is UserActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: Colors.green),
          );
          context.go(AppRoutes.adminBuyers);
        } else if (state is UserManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      _buildHeader(theme.colorScheme),
                      const SizedBox(height: 24),
                      Form(
                        key: _formKey,
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Card(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionHeader(
                                              icon: Icons.person,
                                              title: 'User Information',
                                              subtitle: isEdit
                                                  ? 'Edit the buyer\'s information'
                                                  : 'Enter the buyer\'s information',
                                              primaryColor: primaryColor,
                                            ),
                                            const Divider(height: 32),
                                            TextFormField(
                                              controller: _fullNameController,
                                              decoration: const InputDecoration(
                                                labelText: 'Full Name',
                                                border: OutlineInputBorder(),
                                                prefixIcon:
                                                    Icon(Icons.person_outline),
                                              ),
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                      ? 'Enter full name'
                                                      : null,
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              controller: _emailController,
                                              decoration: const InputDecoration(
                                                labelText: 'Email',
                                                border: OutlineInputBorder(),
                                                prefixIcon:
                                                    Icon(Icons.email_outlined),
                                              ),
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              validator: (value) =>
                                                  value == null || value.isEmpty
                                                      ? 'Enter email'
                                                      : null,
                                            ),
                                            const SizedBox(height: 16),
                                              TextFormField(
                                                controller: _passwordController,
                                                decoration:
                                                    InputDecoration(
                                                  labelText: isEdit ? 'New Password' : 'Password',
                                                  border: const OutlineInputBorder(),
                                                  prefixIcon:
                                                      const Icon(Icons.lock_outline),
                                                ),
                                                obscureText: true,
                                                validator: (value) =>
                                                    value == null ||
                                                            value.isEmpty
                                                        ? 'Enter password'
                                                        : null,
                                              ),
                                              const SizedBox(height: 16),
                                            if(isEdit)
                                              TextFormField(
                                                controller: _confirmPasswordController,
                                                decoration:
                                                const InputDecoration(
                                                  labelText: 'Confirm New Password',
                                                  border: OutlineInputBorder(),
                                                  prefixIcon:
                                                  Icon(Icons.lock_outline),
                                                ),
                                                obscureText: true,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Enter Confirm New password';
                                                  }
                                                  if (value != _passwordController.text) {
                                                    return 'Password does not match';
                                                  }
                                                  return null;
                                                }
                                              ),
                                            if(isEdit)
                                              const SizedBox(height: 16),
                                            TextFormField(
                                              controller: _phoneController,
                                              decoration: const InputDecoration(
                                                labelText: 'Phone',
                                                border: OutlineInputBorder(),
                                                prefixIcon:
                                                    Icon(Icons.phone_outlined),
                                              ),
                                            ),
                                            // const SizedBox(height: 16),
                                            // DropdownButtonFormField<String>(
                                            //   value: _role,
                                            //   decoration: const InputDecoration(
                                            //     labelText: 'Role',
                                            //     border: OutlineInputBorder(),
                                            //   ),
                                            //   items: const [
                                            //     DropdownMenuItem(
                                            //         value: 'user',
                                            //         child: Text('User')),
                                            //     DropdownMenuItem(
                                            //         value: 'buyer',
                                            //         child: Text('Buyer')),
                                            //     DropdownMenuItem(
                                            //         value: 'admin',
                                            //         child: Text('Admin')),
                                            //   ],
                                            //   onChanged: (value) {
                                            //     setState(() {
                                            //       _role = value!;
                                            //     });
                                            //   },
                                            // ),
                                            const SizedBox(height: 16),
                                            SwitchListTile(
                                              value: _isActive,
                                              onChanged: (val) => setState(
                                                  () => _isActive = val),
                                              title: const Text('Active'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader(
                                        icon: Icons.person,
                                        title: 'User Information',
                                        subtitle: isEdit
                                            ? 'Edit the buyer\'s information'
                                            : 'Enter the buyer\'s information',
                                        primaryColor: primaryColor,
                                      ),
                                      const Divider(height: 32),
                                      TextFormField(
                                        controller: _fullNameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Full Name',
                                          border: OutlineInputBorder(),
                                          prefixIcon:
                                              Icon(Icons.person_outline),
                                        ),
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                                ? 'Enter full name'
                                                : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          border: OutlineInputBorder(),
                                          prefixIcon:
                                              Icon(Icons.email_outlined),
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        validator: (value) =>
                                            value == null || value.isEmpty
                                                ? 'Enter email'
                                                : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _passwordController,
                                        decoration:
                                        InputDecoration(
                                          labelText: isEdit ? 'New Password' : 'Password',
                                          border: const OutlineInputBorder(),
                                          prefixIcon:
                                          const Icon(Icons.lock_outline),
                                        ),
                                        obscureText: true,
                                        validator: (value) =>
                                        value == null ||
                                            value.isEmpty
                                            ? 'Enter password'
                                            : null,
                                      ),
                                      const SizedBox(height: 16),
                                      if(isEdit)
                                        TextFormField(
                                            controller: _confirmPasswordController,
                                            decoration:
                                            const InputDecoration(
                                              labelText: 'Confirm New Password',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                              Icon(Icons.lock_outline),
                                            ),
                                            obscureText: true,
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Enter Confirm New password';
                                              }
                                              if (value != _passwordController.text) {
                                                return 'Password does not match';
                                              }
                                              return null;
                                            }
                                        ),
                                      if(isEdit)
                                        const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _phoneController,
                                        decoration: const InputDecoration(
                                          labelText: 'Phone',
                                          border: OutlineInputBorder(),
                                          prefixIcon:
                                          Icon(Icons.phone_outlined),
                                        ),
                                      ),
                                      // const SizedBox(height: 16),
                                      // DropdownButtonFormField<String>(
                                      //   value: _role,
                                      //   decoration: const InputDecoration(
                                      //     labelText: 'Role',
                                      //     border: OutlineInputBorder(),
                                      //   ),
                                      //   items: const [
                                      //     DropdownMenuItem(
                                      //         value: 'buyer',
                                      //         child: Text('Buyer')),
                                      //     DropdownMenuItem(
                                      //       value: 'admin',
                                      //       child: Text('Admin'),
                                      //     ),
                                      //   ],
                                      //   onChanged: (value) {
                                      //     setState(() {
                                      //       _role = value!;
                                      //     });
                                      //   },
                                      // ),
                                      const SizedBox(height: 16),
                                      SwitchListTile(
                                        value: _isActive,
                                        onChanged: (val) =>
                                            setState(() => _isActive = val),
                                        title: const Text('Active'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48.0 : 16.0,
            vertical: 16.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustButton(
                onPressed: () => context.pop(),
                color: Colors.grey.shade200,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              CustButton(
                onPressed: _submitForm,
                child: Text(isEdit ? 'Update Buyer' : 'Create Buyer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
