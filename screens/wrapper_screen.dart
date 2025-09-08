import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_bloc.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_event.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_state.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/models/user_model.dart';

class WrapperScreen extends StatefulWidget {
  const WrapperScreen({super.key});

  @override
  State<WrapperScreen> createState() => _WrapperScreenState();
}

class _WrapperScreenState extends State<WrapperScreen> {
  @override
  void initState() {
    super.initState();
    // Request profile data when the screen initializes
    // context.read<AuthBloc>().add(GetProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthSuccess && state.userData != null) {
          final user = UserModel.fromJson(state.userData!);

          // Use post-frame callback to avoid navigation during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (user.role) {
              case 'admin':
                context.goNamed(AppRouteNames.adminDashboard);
                break;
              case 'seller':
                context.goNamed(AppRouteNames.sellerDashboard);
                break;
              default:
                context.goNamed(AppRouteNames.buyerDashboard);
                break;
            }
          });
        } else {
          print('state is AuthSuccess && state.userData != null');
          // If not authenticated or no user data, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goNamed(AppRouteNames.login);
          });
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
