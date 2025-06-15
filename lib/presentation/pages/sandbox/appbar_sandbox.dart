import 'package:boilerplate/core/widgets/navbar/navigation.dart';
import 'package:flutter/material.dart';

class AppbarSandbox extends StatefulWidget {
  const AppbarSandbox({super.key});

  @override
  State<AppbarSandbox> createState() => _AppbarSandboxState();
}

class _AppbarSandboxState extends State<AppbarSandbox> {
  final ValueNotifier<bool> _navbarVisibleNotifier = ValueNotifier(true);

  @override
  void dispose() {
    _navbarVisibleNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavBar(
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 100, bottom: 90),
        itemCount: 30,
        separatorBuilder: (_, __) => const Divider(height: 0),
        itemBuilder: (context, i) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueGrey.shade200,
              child: Text('${i + 1}'),
            ),
            title: Text('Item ${i + 1}'),
            subtitle: const Text(
                'Scroll up/down to see navbar animation.\nTap anywhere to toggle TopNavbar.'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          );
        },
      ),
    );
  }
}
