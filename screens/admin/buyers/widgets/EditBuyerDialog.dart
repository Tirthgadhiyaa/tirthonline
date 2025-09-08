import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jewellery_diamond/models/user_model.dart';

import '../../../../bloc/user_management_bloc/user_management_bloc.dart';
import '../../../../bloc/user_management_bloc/user_management_event.dart';
import '../../../../bloc/user_management_bloc/user_management_state.dart';

class EditBuyerDialog extends StatefulWidget {
  final UserModel? buyer;

  const EditBuyerDialog(this.buyer, {super.key});

  @override
  State<EditBuyerDialog> createState() => _EditBuyerDialogState();
}

class _EditBuyerDialogState extends State<EditBuyerDialog> {
  Map<String, dynamic>? referralData;
  bool isLoadingReferral = true;


  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController alternatePhoneController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final TextEditingController streetController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController businessDescController = TextEditingController();
  final TextEditingController businessPhoneController = TextEditingController();
  final TextEditingController taxIdController = TextEditingController();

  final TextEditingController diamondCutController = TextEditingController();
  final TextEditingController metalController = TextEditingController();
  final TextEditingController jewelleryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final buyer = widget.buyer;

    if (buyer != null) {
      // Basic info
      emailController.text = buyer.email;
      phoneController.text = buyer.phone ?? '';

      // Name split
      if ((buyer.fullName).isNotEmpty) {
        List<String> names = buyer.fullName.split(' ');
        firstNameController.text = names.first;
        if (names.length > 1) lastNameController.text = names.sublist(1).join(' ');
      }

      // Buyer Info
      final info = buyer.buyerInfo;
      if (info != null) {
        // Address
        streetController.text = info.address?.street ?? '';
        cityController.text = info.address?.city ?? '';
        stateController.text = info.address?.state ?? '';
        countryController.text = info.address?.country ?? '';
        postalCodeController.text = info.address?.postalCode ?? '';

        // Preferences
        diamondCutController.text = info.preferences?.diamondCut.join(', ') ?? '';
        metalController.text = info.preferences?.metalType.join(', ') ?? '';
        jewelleryController.text = info.preferences?.jewelryStyle.join(', ') ?? '';

        // Business Info
        businessNameController.text = info.businessInfo?.name ?? '';
        companyController.text = ''; // Not present in JSON? Keep empty or map accordingly
        businessDescController.text = info.businessInfo?.description ?? '';
        businessPhoneController.text = info.businessInfo?.phone ?? '';
        taxIdController.text = info.businessInfo?.gstNumber ?? '';
        if (buyer.referrer != null) {
          referralData = {
            'id': buyer.referrer!.id,
            'email': buyer.referrer!.email,
            'full_name': buyer.referrer!.fullName,
            'phone_number': buyer.referrer!.phone ?? '-',
          };
        }
        isLoadingReferral = false;
      }
    }


  }


  @override
  void dispose() {

    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    alternatePhoneController.dispose();
    genderController.dispose();

    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    postalCodeController.dispose();

    businessNameController.dispose();
    companyController.dispose();
    businessDescController.dispose();
    businessPhoneController.dispose();
    taxIdController.dispose();

    diamondCutController.dispose();
    metalController.dispose();
    jewelleryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state is ReferralDetailsLoaded) {
          setState(() {
            referralData = state.referralDetails;
            isLoadingReferral = false;
          });
        } else if (state is UserManagementError) {
          setState(() {
            referralData = null;
            isLoadingReferral = false;
          });
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        title: const Text(
          'Edit Buyer',
          style: TextStyle(
            color: Color(0xFF9B1C1C),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 1000,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column
                    Expanded(
                      child: _buildCard(
                        title: 'User Information',
                        subtitle: 'Enter the seller\'s personal information',
                        icon: Icons.person,
                        children: [
                          _textField(label: 'Email', icon: Icons.email, controller: emailController),
                          const SizedBox(height: 12),
                          _textField(label: 'Password', icon: Icons.lock, controller: passwordController),
                          const SizedBox(height: 12),
                          _textField(label: 'Confirm Password', icon: Icons.lock_outline, controller: confirmPasswordController),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _textField(label: 'First Name', icon: Icons.person, controller: firstNameController)),
                              const SizedBox(width: 8),
                              Expanded(child: _textField(label: 'Last Name', icon: Icons.person, controller: lastNameController)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _textField(label: 'Phone Number', icon: Icons.phone, controller: phoneController),
                          const SizedBox(height: 12),
                          _textField(label: 'Alternate Number', icon: Icons.phone_android, controller: alternatePhoneController),
                          const SizedBox(height: 12),
                          _textField(label: 'Gender', icon: Icons.wc, controller: genderController),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Column
                    Expanded(
                      child: Column(
                        children: [
                          _buildCard(
                            title: 'Referral Information',
                            subtitle: 'Details of the referring user',
                            icon: Icons.person_search,
                            children: [
                              if (isLoadingReferral)
                                const Center(child: CircularProgressIndicator())
                              else if (referralData != null)
                                ...[
                                  _infoRow('Referral ID', referralData!['id'] ?? '-'),
                                  const SizedBox(height: 8),
                                  _infoRow('Referral Email', referralData!['email'] ?? '-'),
                                  const SizedBox(height: 8),
                                  _infoRow('Referral Name', referralData!['full_name'] ?? '-'),
                                  const SizedBox(height: 8),
                                  _infoRow('Referral Phone', referralData!['phone_number'] ?? '-'),
                                ]
                              else
                                const Text("No referral data found."),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildCard(
                            title: 'Business Address',
                            subtitle: 'Enter the business address',
                            icon: Icons.location_on,
                            children: [
                              _textField(label: 'Street Address', icon: Icons.location_on, controller: streetController),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _textField(label: 'City', icon: Icons.location_city, controller: cityController)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _textField(label: 'State', icon: Icons.map, controller: stateController)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(child: _textField(label: 'Country', icon: Icons.public, controller: countryController)),
                                  const SizedBox(width: 8),
                                  Expanded(child: _textField(label: 'Postal Code', icon: Icons.confirmation_number, controller: postalCodeController)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Business Information
                _buildCard(
                  title: 'Business Information',
                  subtitle: 'Enter the business details',
                  icon: Icons.business,
                  children: [
                    _textField(label: 'Business Name', icon: Icons.apartment, controller: businessNameController),
                    const SizedBox(height: 12),
                    _textField(label: 'Company', icon: Icons.business_center, controller: companyController),
                    const SizedBox(height: 12),
                    _textField(label: 'Business Description', icon: Icons.description, controller: businessDescController),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _textField(label: 'Business Phone', icon: Icons.phone, controller: businessPhoneController)),
                        const SizedBox(width: 8),
                        Expanded(child: _textField(label: 'Tax ID', icon: Icons.receipt_long, controller: taxIdController)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Preferences
                _buildCard(
                  title: 'Preferences',
                  subtitle: 'Select seller preferences',
                  icon: Icons.favorite,
                  children: [
                    _textField(label: 'Preferred Diamond Cut', icon: Icons.diamond, controller: diamondCutController),
                    const SizedBox(height: 12),
                    _textField(label: 'Metal', icon: Icons.circle, controller: metalController),
                    const SizedBox(height: 12),
                    _textField(label: 'Jewellery', icon: Icons.watch, controller: jewelleryController),
                  ],
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: const Text('Cancel'),
          ),
          SizedBox(
            height: 40,
            child: TextButton(
              onPressed: () {
                // Prepare updated data
                final data = {
                  "email": emailController.text.trim(),
                  "password": passwordController.text.trim(),
                  "first_name": firstNameController.text.trim(),
                  "last_name": lastNameController.text.trim(),
                  "phone": phoneController.text.trim(),
                  "alternate_phone": alternatePhoneController.text.trim(),
                  "gender": genderController.text.trim(),
                  "address": {
                    "street": streetController.text.trim(),
                    "city": cityController.text.trim(),
                    "state": stateController.text.trim(),
                    "country": countryController.text.trim(),
                    "postal_code": postalCodeController.text.trim(),
                  }..removeWhere((key, value) => value == null || value.toString().isEmpty),
                  "business_info": {
                    "name": businessNameController.text.trim(),
                    "company": companyController.text.trim(),
                    "description": businessDescController.text.trim(),
                    "phone": businessPhoneController.text.trim(),
                    "gst_number": taxIdController.text.trim(),
                  }..removeWhere((key, value) => value == null || value.toString().isEmpty),
                  "preferences": {
                    "diamond_cut": diamondCutController.text.split(',').map((e) => e.trim()).toList(),
                    "metal_type": metalController.text.split(',').map((e) => e.trim()).toList(),
                    "jewelry_style": jewelleryController.text.split(',').map((e) => e.trim()).toList(),
                  }..removeWhere((key, value) => value == null || value.toString().isEmpty),
                }..removeWhere((key, value) => value == null || value.toString().isEmpty);

                context.read<UserManagementBloc>().add(UpdateUser(widget.buyer!.id, data));
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF9B1C1C),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF9B1C1C)),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ]),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _textField({required String label, required IconData icon, TextEditingController? controller}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(value),
        ),
      ],
    );
  }
}
