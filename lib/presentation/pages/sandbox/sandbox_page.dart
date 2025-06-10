import 'package:boilerplate/core/widgets/components/breadcrumb/breadcrumb.dart';
import 'package:boilerplate/core/widgets/components/collapsible/collapsible.dart';
import 'package:boilerplate/core/widgets/components/progress/circular.dart';
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
          const SizedBox(height: 15),
          AppCircularProgress(showPercentage: true, center: AppText("Tes")),
          const SizedBox(height: 15),
          const AppCollapsible(
              children: [
                AppCollapsibleTrigger(
                  child: Text("Click to expand"),
                ),
                AppCollapsibleContent(
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                      child: AppExpandableText(
                        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua',
                        maxLines: 2,
                        expandText: 'Show More',
                        collapseText: 'Show Less',
                      ),
                      // child: Text('This content can be collapsed and expanded.'),
                  ),
                ),
              ],
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
