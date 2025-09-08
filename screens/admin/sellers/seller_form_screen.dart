import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_bloc.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_event.dart';
import 'package:jewellery_diamond/bloc/seller_management_bloc/seller_management_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/seller_model.dart';
import 'package:jewellery_diamond/widgets/cust_button.dart';
import 'package:jewellery_diamond/widgets/drag_drop_upload.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:jewellery_diamond/core/widgets/custom_snackbar.dart';

class SellerFormScreen extends StatefulWidget {
  final SellerModel? seller;

  const SellerFormScreen({
    Key? key,
    this.seller,
  }) : super(key: key);

  @override
  State<SellerFormScreen> createState() => _SellerFormScreenState();
}

class _SellerFormScreenState extends State<SellerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<UploadMultimageState> _uploadKey =
      GlobalKey<UploadMultimageState>();
  final GlobalKey<UploadSectionState> _uploadKeyLogo =
      GlobalKey<UploadSectionState>();

  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _streetAddressController =
      TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _businessDescriptionController =
      TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final List<TextEditingController> _certificationControllers = [];
  final List<Map<String, dynamic>> _verificationDocuments = [];

  // User data controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isVerified = false;
  bool _isUploading = false;

  List<Uint8List> _selectedImages = [];
  List<String> _imageNames = [];
  List<Uint8List> _selectedLogo = [];
  List<String> _logoNames = [];

  @override
  void initState() {
    super.initState();
    if (widget.seller != null) {
      _businessNameController.text = widget.seller!.businessName;
      _streetAddressController.text =
          widget.seller!.businessAddress['street'] ?? '';
      _cityController.text = widget.seller!.businessAddress['city'] ?? '';
      _stateController.text = widget.seller!.businessAddress['state'] ?? '';
      _countryController.text = widget.seller!.businessAddress['country'] ?? '';
      _postalCodeController.text =
          widget.seller!.businessAddress['postal_code'] ?? '';
      _contactPhoneController.text = widget.seller!.contactPhone;
      _businessDescriptionController.text = widget.seller!.businessDescription;
      _taxIdController.text = widget.seller!.taxId ?? '';

      // Initialize user data
      final fullName = widget.seller!.user['full_name'] ?? '';
      final nameParts = fullName.split(' ');
      _emailController.text = widget.seller!.user['email'] ?? '';
      _firstNameController.text = nameParts.isNotEmpty ? nameParts.first : '';
      _lastNameController.text =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      _phoneController.text = widget.seller!.user['phone'] ?? '';

      // Initialize certification controllers
      for (var cert in widget.seller!.certifications) {
        final controller = TextEditingController(text: cert);
        _certificationControllers.add(controller);
      }

      _verificationDocuments.addAll(widget.seller!.verificationDocuments);
      _imageNames = [];
      _logoNames = [];
    }
    // fillSampleDataInForm();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _contactPhoneController.dispose();
    _businessDescriptionController.dispose();
    _taxIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    for (var controller in _certificationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void fillSampleDataInForm() {
    _emailController.text = 'test@test.com';
    _passwordController.text = 'password';
    _firstNameController.text = 'John';
    _lastNameController.text = 'Doe';
    _phoneController.text = '1234567890';
    _businessNameController.text = 'Test Business';
    _businessDescriptionController.text = 'Test Business Description';
    _contactPhoneController.text = '1234567890';
    _taxIdController.text = '1234567890';
    _streetAddressController.text = '1234 Main St';
    _cityController.text = 'Anytown';
    _stateController.text = 'CA';
    _countryController.text = 'United States';
    _postalCodeController.text = '12345';
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final businessAddress = {
        'street': _streetAddressController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'country': _countryController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
      };

      final certifications = _certificationControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final userData = {
        'email': _emailController.text.trim(),
        'full_name':
            '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}',
        'phone': _phoneController.text.trim(),
        'role': 'seller',
        'is_active': true,
      };

      // Include password for new sellers or if password is being updated
      if (widget.seller == null) {
        userData['password'] = _passwordController.text.trim();
        print("Asd");
      } else if (_passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text.trim();
      }

      final sellerData = {
        'user_data': userData,
        'seller_data': {
          'business_name': _businessNameController.text.trim(),
          'business_address': businessAddress,
          'contact_phone': _contactPhoneController.text.trim(),
          'business_description': _businessDescriptionController.text.trim(),
          'certifications': certifications,
          'tax_id': _taxIdController.text.trim().isEmpty
              ? null
              : _taxIdController.text.trim(),
          'verification_documents': _verificationDocuments,
          'approval_status': widget.seller?.approvalStatus ?? null,
        },
      };

      // Add approval details if status is approved
      if (widget.seller?.approvalStatus == 'approved') {
        (sellerData['seller_data'] as Map<String, dynamic>).addAll({
          'approval_date': DateTime.now().toIso8601String(),
          'approved_by': widget.seller?.approvedBy,
        });
      }

      if (widget.seller != null) {
        context.read<SellerManagementBloc>().add(
              UpdateSeller(
                widget.seller!.id!,
                sellerData,
              ),
            );
      } else {
        context.read<SellerManagementBloc>().add(
              CreateSeller(
                sellerData,
              ),
            );
      }
    }
  }

  void _addCertificationField() {
    setState(() {
      _certificationControllers.add(TextEditingController());
    });
  }

  void _removeCertificationField(int index) {
    setState(() {
      _certificationControllers[index].dispose();
      _certificationControllers.removeAt(index);
    });
  }

  void _addVerificationDocument(String type, String url) {
    setState(() {
      _verificationDocuments.add({
        'type': type,
        'url': url,
        'verified': true,
      });
    });
  }

  void _removeVerificationDocument(int index) {
    setState(() {
      _verificationDocuments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 768;

    return BlocListener<SellerManagementBloc, SellerManagementState>(
      listener: (context, state) {
        if (state is SellerActionSuccess) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.green,
          );
          context.go(AppRoutes.adminSellers);
        } else if (state is SellerManagementError) {
          showCustomSnackBar(
            context: context,
            message: state.message,
            backgroundColor: Colors.red,
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
                                  // Left Column - User Info and Business Info
                                  Expanded(
                                    child: Column(
                                      children: [
                                        // User Information Section
                                        Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildSectionHeader(
                                                  icon: Icons.person,
                                                  title: 'User Information',
                                                  subtitle:
                                                      'Enter the seller\'s personal information',
                                                  primaryColor: primaryColor,
                                                ),
                                                const Divider(height: 32),
                                                TextFormField(
                                                  controller: _emailController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Email',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(
                                                        Icons.email_outlined),
                                                  ),
                                                  keyboardType: TextInputType
                                                      .emailAddress,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter an email';
                                                    }
                                                    if (!RegExp(
                                                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                        .hasMatch(value)) {
                                                      return 'Please enter a valid email';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                if (widget.seller != null) ...[
                                                  TextFormField(
                                                    controller:
                                                        _passwordController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText: 'New Password',
                                                      border:
                                                          OutlineInputBorder(),
                                                      prefixIcon: Icon(
                                                          Icons.lock_outline),
                                                    ),
                                                    obscureText: true,
                                                    validator: (value) {
                                                      if (value != null &&
                                                          value.isNotEmpty) {
                                                        if (value.length < 6) {
                                                          return 'Password must be at least 6 characters';
                                                        }
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  const SizedBox(height: 16),
                                                  TextFormField(
                                                    controller:
                                                        _confirmPasswordController,
                                                    decoration:
                                                        const InputDecoration(
                                                      labelText:
                                                          'Confirm New Password',
                                                      border:
                                                          OutlineInputBorder(),
                                                      prefixIcon: Icon(
                                                          Icons.lock_outline),
                                                    ),
                                                    obscureText: true,
                                                    validator: (value) {
                                                      if (_passwordController
                                                          .text.isNotEmpty) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please confirm your password';
                                                        }
                                                        if (value !=
                                                            _passwordController
                                                                .text) {
                                                          return 'Passwords do not match';
                                                        }
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                  const SizedBox(height: 16),
                                                ],
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _firstNameController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'First Name',
                                                          border:
                                                              OutlineInputBorder(),
                                                          prefixIcon: Icon(Icons
                                                              .person_outline),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter first name';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _lastNameController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Last Name',
                                                          border:
                                                              OutlineInputBorder(),
                                                          prefixIcon: Icon(Icons
                                                              .person_outline),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter last name';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                TextFormField(
                                                  controller: _phoneController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Phone Number',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(
                                                        Icons.phone_outlined),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.phone,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter a phone number';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        // Business Information Section
                                        Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildSectionHeader(
                                                  icon: Icons.business,
                                                  title: 'Business Information',
                                                  subtitle:
                                                      'Enter the business details',
                                                  primaryColor: primaryColor,
                                                ),
                                                const Divider(height: 32),
                                                TextFormField(
                                                  controller:
                                                      _businessNameController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Business Name',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(Icons
                                                        .business_outlined),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter business name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                TextFormField(
                                                  controller:
                                                      _businessDescriptionController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText:
                                                        'Business Description',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(Icons
                                                        .description_outlined),
                                                  ),
                                                  maxLines: 3,
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter business description';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _contactPhoneController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Business Phone',
                                                          border:
                                                              OutlineInputBorder(),
                                                          prefixIcon: Icon(Icons
                                                              .phone_outlined),
                                                        ),
                                                        keyboardType:
                                                            TextInputType.phone,
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter business phone';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _taxIdController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText: 'Tax ID',
                                                          border:
                                                              OutlineInputBorder(),
                                                          prefixIcon: Icon(Icons
                                                              .receipt_long_outlined),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Right Column - Address, Certifications, and Documents
                                  Expanded(
                                    child: Column(
                                      children: [
                                        // Business Address Section
                                        Card(
                                          child: Padding(
                                            padding: const EdgeInsets.all(24.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildSectionHeader(
                                                  icon: Icons.location_on,
                                                  title: 'Business Address',
                                                  subtitle:
                                                      'Enter the business address',
                                                  primaryColor: primaryColor,
                                                ),
                                                const Divider(height: 32),
                                                TextFormField(
                                                  controller:
                                                      _streetAddressController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Street Address',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(Icons
                                                        .location_on_outlined),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter street address';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _cityController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText: 'City',
                                                          border:
                                                              OutlineInputBorder(),
                                                          prefixIcon: Icon(Icons
                                                              .location_city_outlined),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter city';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _stateController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText: 'State',
                                                          border:
                                                              OutlineInputBorder(),
                                                          prefixIcon: Icon(Icons
                                                              .map_outlined),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter state';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _countryController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText: 'Country',
                                                          border:
                                                              OutlineInputBorder(),
                                                          prefixIcon: Icon(Icons
                                                              .public_outlined),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter country';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _postalCodeController,
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Postal Code',
                                                          border:
                                                              OutlineInputBorder(),
                                                          prefixIcon: Icon(Icons
                                                              .numbers_outlined),
                                                        ),
                                                        validator: (value) {
                                                          if (value == null ||
                                                              value.isEmpty) {
                                                            return 'Please enter postal code';
                                                          }
                                                          return null;
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  // User Information Section
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader(
                                            icon: Icons.person,
                                            title: 'User Information',
                                            subtitle:
                                                'Enter the seller\'s personal information',
                                            primaryColor: primaryColor,
                                          ),
                                          const Divider(height: 32),
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
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter an email';
                                              }
                                              if (!RegExp(
                                                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                  .hasMatch(value)) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          if (widget.seller != null) ...[
                                            TextFormField(
                                              controller: _passwordController,
                                              decoration: const InputDecoration(
                                                labelText: 'New Password',
                                                border: OutlineInputBorder(),
                                                prefixIcon:
                                                    Icon(Icons.lock_outline),
                                              ),
                                              obscureText: true,
                                              validator: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  if (value.length < 6) {
                                                    return 'Password must be at least 6 characters';
                                                  }
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              controller:
                                                  _confirmPasswordController,
                                              decoration: const InputDecoration(
                                                labelText:
                                                    'Confirm New Password',
                                                border: OutlineInputBorder(),
                                                prefixIcon:
                                                    Icon(Icons.lock_outline),
                                              ),
                                              obscureText: true,
                                              validator: (value) {
                                                if (_passwordController
                                                    .text.isNotEmpty) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Please confirm your password';
                                                  }
                                                  if (value !=
                                                      _passwordController
                                                          .text) {
                                                    return 'Passwords do not match';
                                                  }
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                          Row(
                                            children: [
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _firstNameController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'First Name',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(
                                                        Icons.person_outline),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter first name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: TextFormField(
                                                  controller:
                                                      _lastNameController,
                                                  decoration:
                                                      const InputDecoration(
                                                    labelText: 'Last Name',
                                                    border:
                                                        OutlineInputBorder(),
                                                    prefixIcon: Icon(
                                                        Icons.person_outline),
                                                  ),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return 'Please enter last name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _phoneController,
                                            decoration: const InputDecoration(
                                              labelText: 'Phone Number',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.phone_outlined),
                                            ),
                                            keyboardType: TextInputType.phone,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter a phone number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Business Information Section
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader(
                                            icon: Icons.business,
                                            title: 'Business Information',
                                            subtitle:
                                                'Enter the business details',
                                            primaryColor: primaryColor,
                                          ),
                                          const Divider(height: 32),
                                          TextFormField(
                                            controller: _businessNameController,
                                            decoration: const InputDecoration(
                                              labelText: 'Business Name',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.business_outlined),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter business name';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller:
                                                _businessDescriptionController,
                                            decoration: const InputDecoration(
                                              labelText: 'Business Description',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(
                                                  Icons.description_outlined),
                                            ),
                                            maxLines: 3,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter business description';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _contactPhoneController,
                                            decoration: const InputDecoration(
                                              labelText: 'Business Phone',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.phone_outlined),
                                            ),
                                            keyboardType: TextInputType.phone,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter business phone';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _taxIdController,
                                            decoration: const InputDecoration(
                                              labelText: 'Tax ID',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(
                                                  Icons.receipt_long_outlined),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Business Address Section
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader(
                                            icon: Icons.location_on,
                                            title: 'Business Address',
                                            subtitle:
                                                'Enter the business address',
                                            primaryColor: primaryColor,
                                          ),
                                          const Divider(height: 32),
                                          TextFormField(
                                            controller:
                                                _streetAddressController,
                                            decoration: const InputDecoration(
                                              labelText: 'Street Address',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(
                                                  Icons.location_on_outlined),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter street address';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _cityController,
                                            decoration: const InputDecoration(
                                              labelText: 'City',
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(
                                                  Icons.location_city_outlined),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter city';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _stateController,
                                            decoration: const InputDecoration(
                                              labelText: 'State',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.map_outlined),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter state';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _countryController,
                                            decoration: const InputDecoration(
                                              labelText: 'Country',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.public_outlined),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter country';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _postalCodeController,
                                            decoration: const InputDecoration(
                                              labelText: 'Postal Code',
                                              border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.numbers_outlined),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter postal code';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Certifications Section
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader(
                                            icon: Icons.verified,
                                            title: 'Certifications',
                                            subtitle:
                                                'Add seller certifications',
                                            primaryColor: primaryColor,
                                          ),
                                          const Divider(height: 32),
                                          ..._certificationControllers
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final controller = entry.value;
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: TextFormField(
                                                      controller: controller,
                                                      decoration:
                                                          const InputDecoration(
                                                        labelText:
                                                            'Certification',
                                                        border:
                                                            OutlineInputBorder(),
                                                        prefixIcon: Icon(Icons
                                                            .verified_outlined),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.remove_circle),
                                                    onPressed: () =>
                                                        _removeCertificationField(
                                                            index),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                          ElevatedButton.icon(
                                            onPressed: _addCertificationField,
                                            icon: const Icon(Icons.add),
                                            label:
                                                const Text('Add Certification'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  // Verification Documents Section
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader(
                                            icon: Icons.description,
                                            title: 'Verification Documents',
                                            subtitle:
                                                'Upload verification documents',
                                            primaryColor: primaryColor,
                                          ),
                                          const Divider(height: 32),
                                          ..._verificationDocuments
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            final index = entry.key;
                                            final doc = entry.value;
                                            return ListTile(
                                              leading: const Icon(
                                                  Icons.description_outlined),
                                              title: Text(
                                                  doc['type'] ?? 'Document'),
                                              subtitle: Text(doc['url'] ?? ''),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () =>
                                                    _removeVerificationDocument(
                                                        index),
                                              ),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
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
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
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
              widget.seller != null ? 'Edit Seller' : 'Create Seller',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.seller != null
                  ? 'Edit seller information'
                  : 'Create a new seller',
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
}
