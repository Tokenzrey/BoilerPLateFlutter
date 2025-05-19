import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/presentation/pages/sandbox/animation_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/button_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/popover_sandbox.dart';
// import 'package:boilerplate/presentation/pages/sandbox/select_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/typography_sandbox.dart';
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        children: [
          const SizedBox(height: 200),
          const TypographyExamplePage(),
          const SizedBox(height: 200),
          const ButtonSandboxPage(),
          const SizedBox(height: 200),
          const PopoverSandbox(),
          const SizedBox(height: 200),
          // const SelectSandbox(),
          const SizedBox(height: 200),
          const SizedBox(height: 200),
          const SizedBox(height: 200),
          const AnimationSandboxPage(),
          const SizedBox(height: 200),
        ],
      ),
    );
  }
}
