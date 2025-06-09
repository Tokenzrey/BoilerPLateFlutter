import 'package:boilerplate/core/widgets/components/breadcrumb/breadcrumb.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/empty_app_bar_widget.dart';
import 'package:boilerplate/presentation/pages/sandbox/button_sandbox.dart';
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
          Center(
            child: Breadcrumb(
              // defaultnya arrow separator
              separator: Breadcrumb.slashSeparator,
                children: [
                  const AppText("slash-1"),
                  const AppText("slash-2")
                ]),
          ),
          const SizedBox(height: 15),
          Center(
            child: Breadcrumb(
              // defaultnya arrow separator
                children: [
                  const AppText("arrow-1"),
                  const AppText("arrow-2")
                ]),
          ),
        ],
      ),
    );
  }
}
