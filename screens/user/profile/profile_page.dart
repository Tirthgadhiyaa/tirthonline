import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_bloc.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_event.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/core/layout/base_layout.dart';
import 'package:jewellery_diamond/models/user_model.dart';
import 'package:jewellery_diamond/utils/shared_preference.dart';
import 'package:jewellery_diamond/screens/user/profile/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = '/user/profiles';
  final Map<String, dynamic>? userData;
  final bool landingpage;

  const ProfilePage(this.landingpage, {super.key, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? currentUserData;

  // TextEditingControllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneController;
  late TextEditingController referralCodeController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController countryController;
  late TextEditingController codeController;
  late TextEditingController businessNameController;
  late TextEditingController companyController;
  late TextEditingController descriptionController;
  late TextEditingController taxIdController;

  @override
  void initState() {
    super.initState();
    currentUserData =
        widget.userData ?? SharedPreferencesHelper.instance.userData?.toJson();

    if (currentUserData?['role'] == 'buyer') {
      context.read<AuthBloc>().add(GetProfileRequested());
    }

    _initControllers();
  }

  void _initControllers() {
    UserModel? user = currentUserData is UserModel
        ? currentUserData as UserModel
        : UserModel.fromJson(currentUserData ?? {});

    firstNameController =
        TextEditingController(text: user.fullName.split(' ').first);
    lastNameController = TextEditingController(
        text: user.fullName.split(' ').length > 1
            ? user.fullName.split(' ').sublist(1).join(' ')
            : '');
    phoneController = TextEditingController(text: user.phone ?? '');

    // Buyer Info
    referralCodeController =
        TextEditingController(text: user.buyerInfo?.referralCode ?? '');

    // Address
    final address = user.buyerInfo?.address;
    addressController = TextEditingController(text: address?.street ?? '');
    cityController = TextEditingController(text: address?.city ?? '');
    stateController = TextEditingController(text: address?.state ?? '');
    countryController = TextEditingController(text: address?.country ?? '');
    codeController = TextEditingController(text: address?.postalCode ?? '');

    // Business Info
    final business = user.buyerInfo?.businessInfo;
    businessNameController = TextEditingController(text: business?.name ?? '');
    companyController = TextEditingController(text: business?.name ?? '');
    descriptionController = TextEditingController(text: business?.description ?? '');
    taxIdController = TextEditingController(text: business?.gstNumber ?? '');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    referralCodeController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    codeController.dispose();
    businessNameController.dispose();
    companyController.dispose();
    descriptionController.dispose();
    taxIdController.dispose();
    super.dispose();
  }

  Widget _space() => const SizedBox(height: 20);

  @override
  Widget build(BuildContext context) {
    Widget content = BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is BuyerProfileFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is AuthSuccess) {
          SharedPreferencesHelper.instance.clearToken();
          SharedPreferencesHelper.instance.clearUser();
          context.goNamed(AppRouteNames.home);
        }
      },
      builder: (context, state) {
        if (state is BuyerProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is BuyerProfileSuccess) {
          currentUserData = state.userData.toJson();
          _initControllers(); // Update controllers
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 40 : 16,
                  vertical: 24,
                ),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isDesktop ? 1200 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMinimalistHeader(context, state),
                        _space(),
                        if (isDesktop)
                          _buildDesktopLayout(context)
                        else
                          _buildMobileLayout(context),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return widget.landingpage ? BaseLayout(body: content) : content;
  }

  Widget _buildMinimalistHeader(BuildContext context, AuthState state) {
    final name = currentUserData?['full_name'] ?? 'Profile';
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.0,
            color: Color(0xFF333333),
          ),
        ),
        TextButton.icon(
          onPressed: state is AuthLoading
              ? null
              : () {
            context.read<AuthBloc>().add(LogoutRequested());
          },
          icon: state is AuthLoading
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary),
            ),
          )
              : const Icon(Icons.logout_rounded, size: 18),
          label: Text(
            state is AuthLoading ? 'Logging out...' : 'Logout',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: _buildMinimalistProfileCard(context)),
        const SizedBox(width: 30),
        Expanded(flex: 7, child: _buildExpandedProfileDetails(context)),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildMinimalistProfileCard(context),
        _space(),
        _buildExpandedProfileDetails(context),
      ],
    );
  }

  Widget _buildMinimalistProfileCard(BuildContext context) {
    final name = currentUserData?['full_name'] ?? 'User';
    final email = currentUserData?['email'] ?? 'No email provided';
    final role = currentUserData?['role'] ?? 'buyer';

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            child: Center(
              child: Icon(
                Icons.person_outline_rounded,
                size: 50,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          _space(),
          Text(name,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333))),
          const SizedBox(height: 6),
          Text(email, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          _space(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1,
              ),
            ),
            child: Text(
              role.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedProfileDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Personal Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          _space(),
          _buildLuxuryTextField("First Name", firstNameController,
              Icons.person_outline, Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField("Last Name", lastNameController,
              Icons.person_outline, Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField("Mobile Number", phoneController, Icons.phone,
              Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField("Referral Code", referralCodeController,
              Icons.card_giftcard, Theme.of(context).colorScheme.primary,
              readOnly: true),
          _space(),
          const Text('Address Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          _space(),
          _buildLuxuryTextField(
              "Address", addressController, Icons.location_on, Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField(
              "City", cityController, Icons.location_city, Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField(
              "State", stateController, Icons.map, Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField(
              "Country", countryController, Icons.public, Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField(
              "Zip / Postal Code", codeController, Icons.markunread_mailbox, Theme.of(context).colorScheme.primary),
          _space(),
          const Text('Business Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          _space(),
          _buildLuxuryTextField("Business Name", businessNameController,
              Icons.business, Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField("Company", companyController, Icons.business_center,
              Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField("Description", descriptionController, Icons.description,
              Theme.of(context).colorScheme.primary),
          _space(),
          _buildLuxuryTextField("Tax ID", taxIdController, Icons.confirmation_number,
              Theme.of(context).colorScheme.primary),
          _space(),
          _buildMinimalistActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildMinimalistActionButtons(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfilePage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          child: const Text('Edit Profile',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Change Password',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, letterSpacing: 0.5)),
        ),
      ],
    );
  }

  Widget _buildLuxuryTextField(
      String label, TextEditingController controller, IconData icon, Color color,
      {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: color),
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade700),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
    );
  }
}