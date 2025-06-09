import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
// import 'package:boilerplate/presentation/pages/sandbox/animation_sandbox.dart';
// import 'package:boilerplate/presentation/pages/sandbox/button_sandbox.dart';
// import 'package:boilerplate/presentation/pages/sandbox/popover_sandbox.dart';
// import 'package:boilerplate/presentation/pages/sandbox/select_sandbox.dart';
// import 'package:boilerplate/presentation/pages/sandbox/typography_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/comic_card_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/comic_search_sandbox.dart';
import 'package:flutter/material.dart';

class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: EmptyAppBar(),
      body: ListView(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComicCardSandboxPage()),
              );
            },
            child: const Text("Go to ComicCard Sandbox"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComicSearchSandboxPage()),
              );
            },
            child: const Text("Go to ComicSearch Sandbox"),
          ),
          // const SizedBox(height: 200),
          // const TypographyExamplePage(),
          // const SizedBox(height: 200),
          // const ButtonSandboxPage(),
          // const SizedBox(height: 200),
          // const PopoverSandbox(),
          // const SizedBox(height: 200),
          // const SelectSandbox(),
          // const SizedBox(height: 200),
          // const SizedBox(height: 200),
          // const AnimationSandboxPage(),
          // const SizedBox(height: 200),
        ],
      ),
    );
  }
}
