import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/layout/pagination.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';

class FilterResult extends StatefulWidget {
  final ValueNotifier<Map<String, dynamic>> filterData;

  const FilterResult({
    super.key,
    required this.filterData,
  });

  @override
  State<FilterResult> createState() => _FilterResultState();
}

class _FilterResultState extends State<FilterResult> {

  int _currentPage = 1;
  final int _totalItems = 98;
  final int _itemsPerPage = 10;
  late final int _totalPages;

  @override
  void initState() {
    super.initState();
    _totalPages = (_totalItems / _itemsPerPage).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, dynamic>>(
      valueListenable: widget.filterData,
      builder: (context, data, _) {
        if (data.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: AppText(
                "No results found.",
                variant: TextVariant.bodyLarge,
                color: AppColors.neutral
              ),
            ),
          );
        }

        final startIndex = (_currentPage - 1) * _itemsPerPage;
        final endIndex = _currentPage * _itemsPerPage;
        final itemCount = endIndex > _totalItems ? _totalItems : endIndex;

        return ListView.separated(
          shrinkWrap: true,
          itemCount: (itemCount - startIndex) + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 16.0),
          itemBuilder: (_, index) { 
            if (index == itemCount - startIndex) {
              return Column(
                children: [
                  Pagination.simple(
                    theme: PaginationTheme.custom(
                      primaryColor: AppColors.accent, 
                      textColor: AppColors.accent, 
                      backgroundColor: AppColors.accentHover
                    ),
                    size: PaginationSize.small,
                    maxPages: 4,
                    currentPage: _currentPage,
                    totalPages: _totalPages,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                  ),
                  const SizedBox(height: 48.0),
                ],
              );
            }

            return _buildComicItem(startIndex + index);
          },
        );
      },
    );
  }

  Widget _buildComicItem(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          'https://m.media-amazon.com/images/I/81s8xJUzWGL._AC_UF894,1000_QL80_.jpg',
          width: 80,
          height: 120,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Title lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.bold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: AppColors.neutral,
              ),
              const SizedBox(height: 4.0),
              AppText(
                'AltTitle Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                variant: TextVariant.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                color: AppColors.neutral.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 8.0),
              AppText(
                'Description Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                variant: TextVariant.bodySmall,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                color: AppColors.neutral.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
