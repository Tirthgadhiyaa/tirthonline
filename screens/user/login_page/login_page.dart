// lib/screens/user/login_page/login_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_bloc.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_event.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/cubit/navigation_bloc.dart';
import 'package:jewellery_diamond/gen/assets.gen.dart';

import '../../../constant/enum_constant.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = AppRoutes.login;
  final UserType userType;
  const LoginPage({this.userType = UserType.buyer, super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController(text: "seller@gmail.com");
  final TextEditingController passwordController = TextEditingController(text: "123");
  bool mouseHoverC = false;
  bool mouseHoverR = false;
  bool _obscurePassword = true;

  void _navigateUserBasedOnType() {
    final tempType = UserType.seller;
    switch (widget.userType) {
      case UserType.admin:
        context.goNamed(AppRouteNames.adminDashboard);
        break;
      case UserType.seller:
        context.goNamed(AppRouteNames.sellerDashboard);
        break;
      case UserType.buyer:
        context.goNamed(AppRouteNames.userDashboard);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get theme colors from the app's theme
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Login Successful!"),
              backgroundColor: Colors.green.shade800,
            ),
          );

          // Navigate to home page after successful login
          _navigateUserBasedOnType();
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${state.error}"),
              backgroundColor: Colors.red.shade800,
            ),
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
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: width > 1200 ? 1100 : width,
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Luxury branding
                            _buildLuxuryBranding(primary, secondary),

                            const SizedBox(height: 60),

                            // Login container with glass effect
                            Container(
                              width: width > 800 ? width * 0.7 : width * 0.9,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                                  child: Column(
                                    children: [
                                      Text(
                                        "LOGIN",
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
                                      const SizedBox(height: 40),

                                      // Login form
                                      width > 800
                                          ? _buildWideLoginForm(
                                              primary,
                                              secondary,
                                              onPrimary,
                                              surface,
                                              onSurface)
                                          : _buildNarrowLoginForm(
                                              primary,
                                              secondary,
                                              onPrimary,
                                              surface,
                                              onSurface),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),

                            // Footer text
                            Text(
                              "LAXMI JEWELS © 2023 | PRIVACY POLICY",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildLuxuryBranding(Color primary, Color secondary) {
    return Column(
      children: [
        // Diamond icon or logo
        Icon(
          Icons.diamond,
          size: 60,
          color: secondary,
        ),
        const SizedBox(height: 20),
        // Brand name
        const Text(
          "LAXMI JEWELS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w300,
            letterSpacing: 8,
          ),
        ),
        const SizedBox(height: 10),
        // Tagline
        Text(
          "LUXURY REDEFINED",
          style: TextStyle(
            color: secondary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildWideLoginForm(Color primary, Color secondary, Color onPrimary,
      Color surface, Color onSurface) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Login form
        Expanded(
          flex: 3,
          child: _buildLoginFields(primary, secondary, onPrimary),
        ),

        // Divider
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30),
          width: 1,
          height: 300,
          color: secondary.withOpacity(0.3),
        ),

        // Right side - Social login and create account
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSocialLogin(primary, secondary),
              const SizedBox(height: 40),
              _buildCreateAccount(primary, secondary, onPrimary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNarrowLoginForm(Color primary, Color secondary, Color onPrimary,
      Color surface, Color onSurface) {
    return Column(
      children: [
        _buildLoginFields(primary, secondary, onPrimary),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          height: 1,
          color: secondary.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(vertical: 20),
        ),
        _buildSocialLogin(primary, secondary),
        const SizedBox(height: 30),
        _buildCreateAccount(primary, secondary, onPrimary),
      ],
    );
  }

  Widget _buildLoginFields(Color primary, Color secondary, Color onPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "SIGN IN TO YOUR ACCOUNT",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 25),

        // Email field
        _buildLuxuryTextField(
          "EMAIL ADDRESS",
          emailController,
          Icons.email_outlined,
          secondary,
        ),
        const SizedBox(height: 20),

        // Password field
        _buildLuxuryTextField(
          "PASSWORD",
          passwordController,
          Icons.lock_outline,
          secondary,
          isPassword: true,
        ),

        // Forgot password
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              foregroundColor: secondary,
            ),
            child: Text(
              "Forgot Password?",
              style: TextStyle(
                fontSize: 12,
                color: secondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),

        const SizedBox(height: 25),

        // Sign in button
        _buildThemeButton(
          "SIGN IN",
          primary,
          secondary,
          onPrimary,
          onPressed: () {
            final email = emailController.text;
            final password = passwordController.text;
            context.read<AuthBloc>().add(
                  LoginRequested(
                    email: email,
                    password: password,
                    userType: widget.userType,
                  ),
                );
          },
        ),

        if (context.watch<AuthBloc>().state is AuthLoading)
          Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(secondary),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSocialLogin(Color primary, Color secondary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "OR CONTINUE WITH",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),

        // Social buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildSocialButton(Icons.g_mobiledata, "Google", primary),
            const SizedBox(width: 15),
            _buildSocialButton(Icons.facebook, "Facebook", primary),
            const SizedBox(width: 15),
            _buildSocialButton(Icons.apple, "Apple", primary),
          ],
        ),
      ],
    );
  }

  Widget _buildCreateAccount(Color primary, Color secondary, Color onPrimary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "NEW TO LAXMI JEWELS?",
          style: TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 20),

        // Create account button
        _buildOutlinedButton(
          "CREATE ACCOUNT",
          secondary,
          onPressed: () {
            context.read<NavigationBloc>().navigateTo(AppRoutes.register);
            context.pushNamed(AppRouteNames.register);
          },
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
          child: TextField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              border: InputBorder.none,
              prefixIcon: Icon(
                icon,
                color: accentColor.withOpacity(0.7),
                size: 18,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: accentColor.withOpacity(0.7),
                        size: 18,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
              hintText:
                  isPassword ? '••••••••' : 'Enter your ${label.toLowerCase()}',
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

  Widget _buildThemeButton(
    String text,
    Color primary,
    Color secondary,
    Color onPrimary, {
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => mouseHoverC = true),
      onExit: (_) => setState(() => mouseHoverC = false),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: mouseHoverC ? secondary : primary,
            borderRadius: BorderRadius.circular(4),
            boxShadow: mouseHoverC
                ? [
                    BoxShadow(
                      color: secondary.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: onPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(
    String text,
    Color accentColor, {
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      onEnter: (_) => setState(() => mouseHoverR = true),
      onExit: (_) => setState(() => mouseHoverR = false),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color:
                mouseHoverR ? accentColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: accentColor,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color accentColor) {
    return Tooltip(
      message: "Continue with $label",
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: accentColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: IconButton(
          icon: Icon(
            icon,
            color: accentColor,
            size: 20,
          ),
          onPressed: () {
            // Handle social login
          },
        ),
      ),
    );
  }
}
