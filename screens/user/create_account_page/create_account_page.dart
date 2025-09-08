// lib/screens/user/create_account_page/create_account_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_bloc.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_event.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/gen/assets.gen.dart';
import 'package:jewellery_diamond/core/widgets/custom_snackbar.dart';

import '../../../constant/enum_constant.dart';

class CreateAccountPage extends StatefulWidget {
  static const String routeName = '/Registered';
  final UserType userType;
  const CreateAccountPage({this.userType = UserType.buyer, super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController alternativemobileController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController referralCode = TextEditingController();
  // Address controllers
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController codeController = TextEditingController();

// Business information controllers
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController businessDescriptionController = TextEditingController();
  final TextEditingController businessPhoneController = TextEditingController();
  final TextEditingController businessTaxIdController = TextEditingController();


  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Dropdown values
  String? selectedGender;
  String? preferredDiamondCut;
  String? preferredMetalType;
  String? jewelleryStyle;

  bool showPassword = false;
  bool mouseHoverR = false;
  bool _isHoveredLogin = false;

  // Password strength
  String _passwordStrength = "No Password";
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    passwordController.removeListener(_updatePasswordStrength);
    super.dispose();
  }

  void _updatePasswordStrength() {
    final password = passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = "No Password";
        _passwordStrengthColor = Colors.grey;
      });
    } else if (password.length < 6) {
      setState(() {
        _passwordStrength = "Weak";
        _passwordStrengthColor = Colors.red;
      });
    } else if (password.length < 10) {
      setState(() {
        _passwordStrength = "Medium";
        _passwordStrengthColor = Colors.orange;
      });
    } else {
      setState(() {
        _passwordStrength = "Strong";
        _passwordStrengthColor = Colors.green;
      });
    }
  }

  // Validate form
  bool _validateForm() {
    if (!_formKey.currentState!.validate()) {
      return false;
    }

    if (selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your gender"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match"),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return BlocProvider(
      create: (context) => AuthBloc(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            showCustomSnackBar(
              context: context,
              message: state.message,
              backgroundColor: Colors.green.shade800,
            );

            // Navigate to home page after successful registration
            context.goNamed(AppRouteNames.home);
          } else if (state is AuthFailure) {
            showCustomSnackBar(
              context: context,
              message: "Error: ${state.error}",
              backgroundColor: Colors.red.shade800,
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    image: DecorationImage(
                      image: AssetImage(Assets.images.adminloginback.path),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.7),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 40),

                          // Branding
                          Icon(
                            Icons.diamond,
                            size: 50,
                            color: secondary,
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "LAXMI JEWELS",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "LUXURY REDEFINED",
                            style: TextStyle(
                              color: secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              letterSpacing: 3,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Title
                          Text(
                            widget.userType == UserType.seller
                                ? "CREATE SELLER ACCOUNT"
                                : "CREATE ACCOUNT",
                            style: TextStyle(
                              color: secondary,
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 40,
                            height: 1,
                            color: secondary,
                          ),

                          const SizedBox(height: 20),

                          // Form container
                          Container(
                            width: width > 800 ? 900 : width * 0.9,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: secondary.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: const EdgeInsets.all(30),
                                child: Form(
                                  key: _formKey,
                                  child: width > 800
                                      ? _buildHorizontalLayout(
                                          primary, secondary, onPrimary)
                                      : _buildVerticalLayout(
                                          primary, secondary, onPrimary),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Already have an account link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account?",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 10),
                              MouseRegion(
                                onEnter: (_) =>
                                    setState(() => _isHoveredLogin = true),
                                onExit: (_) =>
                                    setState(() => _isHoveredLogin = false),
                                child: GestureDetector(
                                  onTap: () {
                                    context.goNamed(AppRouteNames.login);
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "Sign In",
                                        style: TextStyle(
                                          color: secondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        height: 1,
                                        width: _isHoveredLogin ? 50 : 0,
                                        color: secondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          // Footer
                          Text(
                            "LAXMI JEWELS © 2023 | PRIVACY POLICY",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Modified/New Code
  Widget _buildHorizontalLayout(
      Color primary, Color secondary, Color onPrimary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column - Personal Information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PERSONAL INFORMATION",
                style: TextStyle(
                  color: secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 1,
                color: secondary.withOpacity(0.5),
              ),
              const SizedBox(height: 25),
              _buildLuxuryTextField(
                "FIRST NAME",
                firstNameController,
                Icons.person_outline,
                secondary,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              _buildLuxuryTextField(
                "LAST NAME",
                lastNameController,
                Icons.person_outline,
                secondary,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              _buildLuxuryDropdown(
                "GENDER",
                ['Male', 'Female', 'Other'],
                selectedGender,
                (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                secondary,
                isRequired: true,
              ),
              const SizedBox(height: 20),
              _buildLuxuryTextField(
                "MOBILE NUMBER",
                mobileController,
                Icons.phone_android,
                secondary,
                isRequired: true,
              ),
              const SizedBox(height: 40),
              Text(
                "PREFERENCES",
                style: TextStyle(
                  color: secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 1,
                color: secondary.withOpacity(0.5),
              ),
              const SizedBox(height: 25),
              _buildLuxuryDropdown(
                "PREFERRED DIAMOND CUT",
                ['Round', 'Princess', 'Emerald', 'Oval', 'Marquise'],
                preferredDiamondCut,
                (value) {
                  setState(() {
                    preferredDiamondCut = value;
                  });
                },
                secondary,
                isRequired: false,
              ),
              const SizedBox(height: 20),
              _buildLuxuryDropdown(
                "PREFERRED METAL TYPE",
                ['Gold', 'Silver', 'Platinum', 'Rose Gold'],
                preferredMetalType,
                (value) {
                  setState(() {
                    preferredMetalType = value;
                  });
                },
                secondary,
                isRequired: false,
              ),
              const SizedBox(height: 20),
              _buildLuxuryDropdown(
                "JEWELLERY STYLE",
                ['Classic', 'Vintage', 'Modern', 'Bohemian'],
                jewelleryStyle,
                (value) {
                  setState(() {
                    jewelleryStyle = value;
                  });
                },
                secondary,
                isRequired: false,
              ),
              const SizedBox(height: 20),

              // Business Information section
              Text(
                "BUSINESS INFORMATION",
                style: TextStyle(
                  color: secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(width: 40, height: 1, color: secondary.withOpacity(0.5)),
              const SizedBox(height: 25),
              _buildLuxuryTextField("BUSINESS NAME", businessNameController, Icons.business, secondary),
              const SizedBox(height: 15),
              _buildLuxuryTextField("DESCRIPTION", businessDescriptionController, Icons.description, secondary),
              const SizedBox(height: 15),
              _buildLuxuryTextField("PHONE NUMBER", businessPhoneController, Icons.phone, secondary),
              const SizedBox(height: 15),
              _buildLuxuryTextField("TAX ID", businessTaxIdController, Icons.badge, secondary),
              const SizedBox(height: 15),

            ],
          ),
        ),

        // Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          width: 1,
          height: 600, // Adjust height as needed
          color: secondary.withOpacity(0.3),
        ),

        // Right column - Preferences and Sign-in Information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sign-in Information section
              Text(
                "SIGN-IN INFORMATION",
                style: TextStyle(
                  color: secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 1,
                color: secondary.withOpacity(0.5),
              ),
              const SizedBox(height: 25),

              _buildLuxuryTextField(
                "EMAIL",
                emailController,
                Icons.email_outlined,
                secondary,
              ),
              const SizedBox(height: 20),

              _buildLuxuryTextField(
                "PASSWORD",
                passwordController,
                Icons.lock_outline,
                secondary,
                isPassword: !showPassword,
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Text(
                    "Password Strength: ",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  Text(
                    _passwordStrength,
                    style: TextStyle(
                      fontSize: 12,
                      color: _passwordStrengthColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _buildLuxuryTextField(
                "CONFIRM PASSWORD",
                confirmPasswordController,
                Icons.lock_outline,
                secondary,
                isPassword: !showPassword,
              ),
              const SizedBox(height: 15),

              // Show password checkbox
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: showPassword,
                      onChanged: (value) {
                        setState(() {
                          showPassword = value!;
                        });
                      },
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return secondary;
                        }
                        return Colors.white.withOpacity(0.2);
                      }),
                      checkColor: Colors.white,
                      side: BorderSide(color: secondary.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Show Password",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              _buildLuxuryTextField(
                "REFERRAL CODE (OPTIONAL)",
                referralCode,
                Icons.card_giftcard,
                secondary,
                isRequired: false,
              ),

              const SizedBox(height: 40),
              // Address section
              Text(
                "ADDRESS INFORMATION",
                style: TextStyle(
                  color: secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Container(width: 40, height: 1, color: secondary.withOpacity(0.5)),
              const SizedBox(height: 25),
              _buildLuxuryTextField("ADDRESS", addressController, Icons.location_on, secondary),
              const SizedBox(height: 15),
              _buildLuxuryTextField("CITY", cityController, Icons.location_city, secondary),
              const SizedBox(height: 15),
              _buildLuxuryTextField("STATE", stateController, Icons.map, secondary),
              const SizedBox(height: 15),
              _buildLuxuryTextField("COUNTRY", countryController, Icons.public, secondary),
              const SizedBox(height: 15),
              _buildLuxuryTextField("ZIP / POSTAL CODE", codeController, Icons.markunread_mailbox, secondary),
              const SizedBox(height: 40),
              // Create account button
              Center(
                child: _buildCreateAccountButton(primary, secondary, onPrimary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalLayout(Color primary, Color secondary, Color onPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information section
        Text(
          "PERSONAL INFORMATION",
          style: TextStyle(
            color: secondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 1,
          color: secondary.withOpacity(0.5),
        ),
        const SizedBox(height: 25),

        // Form fields in responsive layout
        _buildNarrowFormLayout(primary, secondary),

        const SizedBox(height: 40),

        // Sign-in Information section
        Text(
          "SIGN-IN INFORMATION",
          style: TextStyle(
            color: secondary,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: 40,
          height: 1,
          color: secondary.withOpacity(0.5),
        ),
        const SizedBox(height: 25),

        // Email and password fields
        _buildLuxuryTextField(
            "EMAIL", emailController, Icons.email_outlined, secondary),
        const SizedBox(height: 20),
        _buildLuxuryTextField(
          "PASSWORD",
          passwordController,
          Icons.lock_outline,
          secondary,
          isPassword: !showPassword,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              "Password Strength: ",
              style: TextStyle(
                fontSize: 12,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
            Text(
              _passwordStrength,
              style: TextStyle(
                fontSize: 12,
                color: _passwordStrengthColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildLuxuryTextField(
          "CONFIRM PASSWORD",
          confirmPasswordController,
          Icons.lock_outline,
          secondary,
          isPassword: !showPassword,
        ),
        const SizedBox(height: 15),

        // Show password checkbox
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: showPassword,
                onChanged: (value) {
                  setState(() {
                    showPassword = value!;
                  });
                },
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.selected)) {
                    return secondary;
                  }
                  return Colors.white.withOpacity(0.2);
                }),
                checkColor: Colors.white,
                side: BorderSide(color: secondary.withOpacity(0.5)),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Show Password",
              style: TextStyle(
                color: Colors.black.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        // Create account button
        Center(
          child: _buildCreateAccountButton(primary, secondary, onPrimary),
        ),
      ],
    );
  }

  // ... existing code ...

  Widget _buildNarrowFormLayout(Color primary, Color secondary) {
    return Column(
      children: [
        _buildLuxuryTextField(
          "FIRST NAME",
          firstNameController,
          Icons.person_outline,
          secondary,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildLuxuryTextField(
          "LAST NAME",
          lastNameController,
          Icons.person_outline,
          secondary,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildLuxuryDropdown(
          "GENDER",
          ['Male', 'Female', 'Other'],
          selectedGender,
          (value) {
            setState(() {
              selectedGender = value;
            });
          },
          secondary,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildLuxuryTextField(
          "MOBILE NUMBER",
          mobileController,
          Icons.phone_android,
          secondary,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildLuxuryTextField(
          "ALTERNATIVE MOBILE NUMBER",
          alternativemobileController,
          Icons.phone_android,
          secondary,
          isRequired: true,
        ),
        const SizedBox(height: 20),
        _buildLuxuryDropdown(
          "PREFERRED DIAMOND CUT",
          ['Round', 'Princess', 'Emerald', 'Oval', 'Marquise'],
          preferredDiamondCut,
          (value) {
            setState(() {
              preferredDiamondCut = value;
            });
          },
          secondary,
          isRequired: false,
        ),
        const SizedBox(height: 20),
        _buildLuxuryDropdown(
          "PREFERRED METAL TYPE",
          ['Gold', 'Silver', 'Platinum', 'Rose Gold'],
          preferredMetalType,
          (value) {
            setState(() {
              preferredMetalType = value;
            });
          },
          secondary,
          isRequired: false,
        ),
        const SizedBox(height: 20),
        _buildLuxuryDropdown(
          " JEWELLERY STYLE",
          ['Classic', 'Vintage', 'Modern', 'Bohemian'],
          jewelleryStyle,
          (value) {
            setState(() {
              jewelleryStyle = value;
            });
          },
          secondary,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildLuxuryTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    Color accentColor, {
    bool isPassword = false,
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: isPassword,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    if (label == "EMAIL" && !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    if (label == "MOBILE NUMBER" && value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  }
                : null,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                icon,
                color: accentColor,
                size: 18,
              ),
              hintText: 'Enter your ${label.toLowerCase()}',
              hintStyle: TextStyle(
                color: Colors.black.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLuxuryDropdown(
    String label,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
    Color accentColor, {
    bool isRequired = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.black.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            hint: Text(
              'Select ${label.toLowerCase()}',
              style: TextStyle(
                color: Colors.black.withOpacity(0.3),
                fontSize: 14,
              ),
            ),
            onChanged: onChanged,
            validator: isRequired
                ? (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  }
                : null,
            isExpanded: true,
            icon: Icon(
              Icons.arrow_drop_down,
              color: accentColor.withOpacity(0.7),
            ),
            decoration: const InputDecoration(
              isCollapsed: true,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildCreateAccountButton(
      Color primary, Color secondary, Color onPrimary) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return MouseRegion(
          onEnter: (_) => setState(() => mouseHoverR = true),
          onExit: (_) => setState(() => mouseHoverR = false),
          child: GestureDetector(
            onTap: state is AuthLoading
                ? null
                : () {
                    if (_validateForm()) {
                      final userData = {
                        'firstname': firstNameController.text,
                        'lastname' : lastNameController.text,
                        'email': emailController.text,
                        'password': passwordController.text,
                        'phone': mobileController.text,
                        'alternativephone': alternativemobileController.text,
                        'gender': selectedGender,
                        'preferred_diamond_cut': preferredDiamondCut,
                        'preferred_metal_type': preferredMetalType,
                        'jewellery_style': jewelleryStyle,
                        'referral_code':referralCode.text,
                        'address': addressController.text,
                        'city': cityController.text,
                        'state': stateController.text,
                        'country': countryController.text,
                        'zip_code': codeController.text,

                        // Business Information
                        'business_name': businessNameController.text,
                        'business_description': businessDescriptionController.text,
                        'business_phone': businessPhoneController.text,
                        'business_tax_id': businessTaxIdController.text,
                      };


                      context.read<AuthBloc>().add(
                            RegisterRequested(
                              firstname: userData['firstname']!,
                              lastname: userData['lastname']!,
                              email: userData['email']!,
                              password: userData['password']!,
                              phone: userData['phone']!,
                              alternativephone: userData['alternativephone']!,
                              role: widget.userType,
                              gender: userData['gender']!,
                              preferredDiamondCut:
                                  userData['preferred_diamond_cut'] ?? '',
                              preferredMetalType:
                                  userData['preferred_metal_type'] ?? '',
                              jewelleryStyle: userData['jewellery_style'] ?? '',
                              referralCode: userData['referral_code']??"",
                              // Address
                              address: userData['address'] ?? '',
                              city: userData['city'] ?? '',
                              state: userData['state'] ?? '',
                              country: userData['country'] ?? '',
                              zipCode: userData['zip_code'] ?? '',

                              // Business Information
                              businessName: userData['business_name'] ?? '',
                              businessDescription: userData['business_description'] ?? '',
                              businessPhone: userData['business_phone'] ?? '',
                              businessTaxId: userData['business_tax_id'] ?? '',
                            ),
                          );
                    }
                  },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
              decoration: BoxDecoration(
                color: mouseHoverR ? secondary : primary,
                borderRadius: BorderRadius.circular(4),
                boxShadow: mouseHoverR
                    ? [
                        BoxShadow(
                          color: secondary.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: state is AuthLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(
                        color: onPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
