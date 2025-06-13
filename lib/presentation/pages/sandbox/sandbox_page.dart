import 'package:boilerplate/presentation/pages/sandbox/animation_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/breadcrumb_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/button_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/circular_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/collapsible_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/pagination_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/colors_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/dialog_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/drawer_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/image_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/popover_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/refresh_trigger_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/toast_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/typography_sandbox.dart';
import 'package:boilerplate/presentation/pages/sandbox/form_sandbox.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A sandbox screen for showcasing and testing UI components.
///
/// This screen provides a central place to view and interact with all UI components
/// in the design system. It allows switching between different component types
/// and displays examples with various configurations.
class SandboxScreen extends StatefulWidget {
  const SandboxScreen({super.key});

  @override
  State<SandboxScreen> createState() => _SandboxScreenState();
}

class _SandboxScreenState extends State<SandboxScreen> {
  // State for currently selected component, default is Typography
  String _selectedComponent = 'Typography';

  // All available components to showcase
  final List<String> _components = [
    'Typography',
    'Color',
    'Button',
    'Image',
    'Animation',
    'Popover',
    'Dialog',
    'Toast',
    'Drawer',
    'Refresh Trigger',
    'App Form',
    'Circular Progress',
    'Breadcrumb',
    'Collapsible',
    'Pagination'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Component Sandbox'),
        actions: [
          // Dropdown for component selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              value: _selectedComponent,
              underline: const SizedBox(), // Remove underline
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: const Icon(Icons.arrow_drop_down),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedComponent = newValue;
                  });
                }
              },
              items: _components.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text('Back to Home'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  onPressed: () {
                    context.goNamed('home');
                  },
                ),
              ),
            ),
            Expanded(
              child: _buildSandboxContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the appropriate content based on selected component
  Widget _buildSandboxContent() {
    switch (_selectedComponent) {
      case 'Typography':
        return const TypographySandbox();
      case 'Color':
        return const ColorsSandbox();
      case 'Button':
        return const ButtonSandbox();
      case 'Image':
        return const ImageSandbox();
      case 'Animation':
        return const AnimationSandbox();
      case 'Popover':
        return const PopoverSandbox();
      case 'Dialog':
        return const DialogSandbox();
      case 'Toast':
        return const ToastSandbox();
      case 'Drawer':
        return const DrawerSandbox();
      case 'Refresh Trigger':
        return const RefreshTriggerSandbox();
      case 'App Form':
        return const FormSandbox();
      case 'Circular Progress':
        return const CircularProgressSandbox();
      case 'Breadcrumb':
        return const BreadcrumbSandbox();
      case 'Collapsible':
        return const CollapsibleSandbox();
      case 'Pagination':
        return const PaginationSandbox();
      default:
        return Center(
          child: Text('Component "$_selectedComponent" not implemented yet'),
        );
    }
  }
}
