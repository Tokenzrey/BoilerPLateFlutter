import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileDetailsScreen extends StatelessWidget {
  const ProfileDetailsScreen({super.key, required String userId});

  @override
  Widget build(BuildContext context) {
    final id = GoRouterState.of(context).pathParameters['id'] ?? 'unknown';

    return Scaffold(
      appBar: AppBar(
        title: AppText(
          'Profile #\$id',
          variant: TextVariant.headlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Detail Information',
              variant: TextVariant.titleLarge,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),
            AppText(
              'User ID: \$id',
              variant: TextVariant.bodyMedium,
            ),
            const SizedBox(height: 8),
            AppText(
              'Name: User \$id',
              variant: TextVariant.bodyMedium,
            ),
            const SizedBox(height: 8),
            AppText(
              'Email: user\\$id@example.com',
              variant: TextVariant.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: AppText(
                'Back',
                variant: TextVariant.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
