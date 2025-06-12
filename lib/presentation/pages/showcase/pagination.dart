import 'package:boilerplate/core/widgets/components/layout/pagination.dart';
import 'package:flutter/material.dart';

class PaginationShowcasePage extends StatefulWidget {
  const PaginationShowcasePage({super.key});

  @override
  State<PaginationShowcasePage> createState() => _PaginationShowcasePageState();
}

class _PaginationShowcasePageState extends State<PaginationShowcasePage> {
  final Map<String, int> currentPages = {
    'basic': 1,
    'compact': 1,
    'large': 1,
    'vertical': 1,
    'iconOnly': 1,
    'custom': 1,
    'configured': 1,
  };

  void _setPage(String key, int page) {
    setState(() => currentPages[key] = page);
  }

  Widget _buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pagination Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSection(
              "Basic Pagination",
              Pagination(
                currentPage: currentPages['basic']!,
                totalPages: 5,
                onPageChanged: (p) => _setPage('basic', p),
              ),
            ),
            _buildSection(
              "Compact Pagination for Mobile",
              Pagination(
                currentPage: currentPages['compact']!,
                totalPages: 3,
                size: PaginationSize.small,
                showLabels: false,
                onPageChanged: (p) => _setPage('compact', p),
              ),
            ),
            _buildSection(
              "Large Pagination with Many Pages",
              Pagination(
                currentPage: currentPages['large']!,
                totalPages: 25,
                size: PaginationSize.large,
                maxPages: 7,
                onPageChanged: (p) => _setPage('large', p),
              ),
            ),
            _buildSection(
              "Vertical Pagination",
              Pagination(
                currentPage: currentPages['vertical']!,
                totalPages: 8,
                direction: Axis.vertical,
                onPageChanged: (p) => _setPage('vertical', p),
              ),
            ),
            _buildSection(
              "Icon-Only Pagination",
              Pagination(
                currentPage: currentPages['iconOnly']!,
                totalPages: 10,
                showLabels: false,
                onPageChanged: (p) => _setPage('iconOnly', p),
              ),
            ),
            _buildSection(
              "Custom Themed Pagination",
              Pagination(
                currentPage: currentPages['custom']!,
                totalPages: 12,
                onPageChanged: (p) => _setPage('custom', p),
                theme: PaginationTheme(
                  activeColor: Colors.purple,
                  activeBackgroundColor: Colors.purple.withValues(alpha: 0.1),
                  textColor: Colors.black,
                  disabledColor: Colors.grey,
                  borderColor: Colors.purpleAccent,
                  iconColor: Colors.purple,
                  ghostBackgroundColor: Colors.transparent,
                  ghostHoverColor: Colors.purple.withValues(alpha: 0.05),
                  textStyle: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            _buildSection(
              "Pagination with Custom Configuration",
              Pagination(
                currentPage: currentPages['configured']!,
                totalPages: 9,
                maxPages: 3,
                showSkipToFirstPage: false,
                showSkipToLastPage: false,
                showLabels: true,
                showTotalPages: true,
                onPageChanged: (p) => _setPage('configured', p),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

