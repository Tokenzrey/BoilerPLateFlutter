import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 72, color: Colors.deepOrange.shade400),
                  const SizedBox(height: 16),
                  AppText('Page Not Found',
                      color: Colors.deepOrange,
                      variant: TextVariant.headlineLarge),
                  const SizedBox(height: 12),
                  AppText(
                      'Sorry, the page you are looking for doesn\'t exist or has been moved.',
                      textAlign: TextAlign.center,
                      variant: TextVariant.bodyMedium),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home_filled),
                    label:
                        AppText('Back to Home', variant: TextVariant.bodyLarge),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
