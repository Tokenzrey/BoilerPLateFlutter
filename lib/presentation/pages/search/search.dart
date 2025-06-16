import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/navbar/navigation.dart';
import 'package:boilerplate/core/widgets/search/filter_result.dart';
import 'package:boilerplate/core/widgets/search/search_filter.dart';
import 'package:flutter/material.dart' hide showDialog;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  ValueNotifier<Map<String, dynamic>> filterData = ValueNotifier({});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavBar(
      backgroundColor: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Divider(
              height: 8, 
              thickness: 1, 
              color: AppColors.neutral,
            ),
            Expanded(
              child: FilterResult(filterData: filterData),
            ),
          ],
        ),
      )
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top:80.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            'Advanced Search',
            variant: TextVariant.titleLarge,
            color: AppColors.neutral,
          ),
          Button(
            onPressed: () {
              showDialog(
                context: context,
                barrierColor: AppColors.background.withValues(alpha: 0.5),
                fullScreen: true,
                animationType: DialogAnimationType.scale,
                builder: (context) => SearchFilter(
                  onApply: (Map<String, dynamic> filterResultJson) {
                    filterData.value = filterResultJson;
                  }
                ),
              );
            },
            text: 'Show Filter',
          ),
        ],
      ),
    );
  }
}