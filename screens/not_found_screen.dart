import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jewellery_diamond/constant/admin_routes.dart';
import 'package:jewellery_diamond/widgets/sized_box_widget.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '404\nPage Not Found',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            custSpace40Y,
            const Text(
              'Oops! The page you are looking for does not exist.',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                context.goNamed(AppRouteNames.wrapper);
              },
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
