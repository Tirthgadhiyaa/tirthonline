import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/bloc/auth_bloc/auth_bloc.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/utils/math_utils.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:js' as js;

import 'bloc/chat_bloc/chat_bloc.dart';
import 'bloc/diamondproduct_bloc/diamond_bloc.dart';
import 'bloc/orders_bloc/orders_bloc.dart';
import 'bloc/saved_search_bloc/saved_search_bloc.dart';
import 'bloc/seller_management_bloc/seller_management_bloc.dart';
import 'bloc/seller_product_bloc/seller_product_bloc.dart';
import 'bloc/user_management_bloc/user_management_bloc.dart';
import 'constant/app_theme.dart';
import 'cubit/navigation_bloc.dart';
import 'screens/admin/order/order_management.dart';
import 'utils/shared_preference.dart';
import 'bloc/product_bloc/product_bloc.dart';
import 'services/api/product_service.dart';
import 'services/context_provider.dart';

void main() async {
  // Set the URL strategy to path-based instead of hash-based
  setUrlStrategy(PathUrlStrategy());

  WidgetsFlutterBinding.ensureInitialized();
  await Future<void>.delayed(const Duration(milliseconds: 150))
      .then((val) async {
    await SharedPreferencesHelper.instance.loadSavedData();
    HttpOverrides.global = MyHttpOverrides();

    runApp(
      BlocProvider<ScreenSizeBloc>(
        create: (context) => ScreenSizeBloc(),
        child: const MainApp(),
      ),
    );
  });
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final AuthBloc authBloc;
  late final AppRouter appRouter;
  String? pendingRedirectPath;

  @override
  void initState() {
    super.initState();
    authBloc = AuthBloc();
    appRouter = AppRouter(authBloc: authBloc);

    // Check for redirect path immediately
    _checkForRedirectPath();

    // Handle redirect path after app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleRedirectPath();
    });

    // Delay the context setup to ensure the widget is fully built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = Screen.getAdjustedSize(context);
        context.read<ScreenSizeBloc>().add(UpdateScreenSize(size));
        // Set the context in the ContextProvider
        ContextProvider().setContext(context);
      }
    });
  }

  void _checkForRedirectPath() {
    try {
      // Check if there's a redirect path stored in sessionStorage
      final redirectPath = js.context
          .callMethod('eval', ['sessionStorage.getItem("redirectPath")']);

      print('Checking for redirect path...');
      if (redirectPath != null && redirectPath.toString().isNotEmpty) {
        print('Found redirect path: $redirectPath');
        pendingRedirectPath = redirectPath.toString();
        // Clear the stored path
        js.context
            .callMethod('eval', ['sessionStorage.removeItem("redirectPath")']);
        print('Cleared redirect path from sessionStorage');
      } else {
        print('No redirect path found in sessionStorage');
      }
    } catch (e) {
      // Ignore errors if running on non-web platforms
      print('Redirect path check error: $e');
    }
  }

  void _handleRedirectPath() {
    print('Handling redirect path...');
    if (pendingRedirectPath != null && mounted) {
      final path = pendingRedirectPath!;
      print('Navigating to: $path');
      pendingRedirectPath = null;

      // Use a small delay to ensure router is ready
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          try {
            print('Executing navigation to: $path');
            appRouter.router.go(path);
            print('Navigation completed');
          } catch (e) {
            print('Navigation error: $e');
          }
        } else {
          print('Widget not mounted during navigation');
        }
      });
    } else {
      print(
          'No pending redirect path or widget not mounted. pendingRedirectPath: $pendingRedirectPath, mounted: $mounted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => NavigationBloc()),
        BlocProvider(create: (context) => OrdersBloc()),
        BlocProvider(create: (context) => authBloc),
        BlocProvider(create: (context) => DiamondBloc()),
        BlocProvider(create: (context) => SellerProductBloc()),
        BlocProvider(create: (context) => SellerManagementBloc()),
        BlocProvider(create: (context) => ProductBloc(ProductService())),
        BlocProvider(create: (context) => UserManagementBloc()),
        BlocProvider(create: (context) => ChatBloc()),
        // Add other BlocProviders here if needed
      ],
      child: Builder(
        builder: (context) {
          // Set the context in the ContextProvider when it's available
          if (!ContextProvider().hasContext) {
            ContextProvider().setContext(context);
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              return BlocBuilder<NavigationBloc, String>(
                builder: (context, state) {
                  return MaterialApp.router(
                    routerConfig: appRouter.router,
                    debugShowCheckedModeBanner: false,
                    themeMode: ThemeMode.light,
                    theme: lightThemeData(),
                    darkTheme: darkThemeData(),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
