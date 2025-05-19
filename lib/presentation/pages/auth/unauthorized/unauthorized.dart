import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/routes/routes_config.dart';
import 'package:flutter/material.dart';

class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: AppText('Unauthorized',  variant: TextVariant.headlineMedium),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                AppText('Access Denied', color: Colors.redAccent, variant: TextVariant.titleLarge),
                const SizedBox(height: 8),
                AppText(
                    'You do not have permission to view this page.', variant: TextVariant.bodyMedium),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () =>
                      AppRouter.pushReplacement(context, RoutePaths.home),
                  icon: const Icon(Icons.home),
                  label: AppText('Go to Home',variant: TextVariant.bodyLarge),
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
    );
  }
}
