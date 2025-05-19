import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/utils/routes/routes_config.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy user list
    final users = List.generate(5, (index) => 'User ${index + 1}');

    return Scaffold(
      appBar: AppBar(
          title: AppText('Profiles', variant: TextVariant.headlineMedium)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final name = users[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: AppText(
              name,
              variant: TextVariant.bodyLarge,
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => AppRouter.navigateTo(
                context, RoutePaths.profileDetails,
                params: {'id': '${index + 1}'}),
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: users.length,
      ),
    );
  }
}
