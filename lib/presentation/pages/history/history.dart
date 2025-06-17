import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/navbar/navigation.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/history/history.dart';
import 'package:boilerplate/presentation/store/history/history_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  
  late final HistoryStore _historyStore;
  
  @override
  void initState() {
    super.initState();
    _historyStore = getIt<HistoryStore>();
    _historyStore.fetchRecentHistory();

    print(_historyStore.historyList);
  }
  
  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavBar(
      backgroundColor: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Observer(
          builder: (_) {
            final list = _historyStore.historyList;

            if (_historyStore.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (list.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: AppText(
                    "No recent history.",
                    variant: TextVariant.bodyLarge,
                    color: AppColors.neutral,
                  ),
                ),
              );
            }

            return Column(
              children: [
                Center(
                  child: AppText(
                    'Recent History',
                    variant: TextVariant.titleLarge,
                    color: AppColors.neutral,
                  ),
                ),
                const Divider(height: 8.0),
                ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    return _buildHistoryItem(item);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }


  Widget _buildHistoryItem(HistoryEntity item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.network(
          'https://m.media-amazon.com/images/I/81s8xJUzWGL._AC_UF894,1000_QL80_.jpg',
          width: 60,
          height: 100,
          fit: BoxFit.cover,
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                item.slug,
                variant: TextVariant.bodyLarge,
                fontWeight: FontWeight.bold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: AppColors.neutral,
              ),
              const SizedBox(height: 4.0),
              AppText(
                item.chap,
                variant: TextVariant.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                color: AppColors.neutral.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16.0),
        IconButton(
          onPressed: () => _historyStore.deleteHistory(item.hid), 
          icon: Icon(
            Icons.delete,
            color: AppColors.destructive,
          )
        )
      ],
    );
  }
}