import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/data/network/api/top_api_service.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/store/home/home_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

/// A sandbox screen for testing and exploring API capabilities
///
/// Last updated: 2025-06-13 20:24:51 UTC
/// Author: Tokenzrey
class ApiSandbox extends StatefulWidget {
  const ApiSandbox({super.key});

  @override
  State<ApiSandbox> createState() => _ApiSandboxState();
}

class _ApiSandboxState extends State<ApiSandbox>
    with SingleTickerProviderStateMixin {
  /// Store for managing API data state
  final HomeStore _store = getIt<HomeStore>();

  // API parameter state
  TopGender _selectedGender = TopGender.male;
  TopDay _selectedDay = TopDay.d180;
  TopType _selectedType = TopType.trending;
  final List<ComicType> _selectedComicTypes = [ComicType.manga];
  bool _acceptMatureContent = false;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page header
            _buildPageHeader(),

            const SizedBox(height: 16),

            // Parameter controls in a scrollable card
            _buildParameterControls(),

            const SizedBox(height: 20),

            // Fetch buttons row
            _buildActionButtons(),

            const SizedBox(height: 24),

            // Tab bar for different data views
            _buildTabBar(),

            const SizedBox(height: 12),

            // Content area
            Expanded(
              child: Observer(
                builder: (_) {
                  if (_store.isLoading) {
                    return _buildLoadingState();
                  }
                  if (_store.hasError) {
                    return _buildErrorState();
                  }
                  if (!_store.hasData) {
                    return _buildEmptyState();
                  }
                  return _buildTabContent();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the page header with title and subtitle
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'API Sandbox',
          variant: TextVariant.headlineMedium,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        const AppText(
          'Explore comic data with different parameters',
          variant: TextVariant.bodyLarge,
          color: AppColors.mutedForeground,
        ),
      ],
    );
  }

  /// Builds the parameters control card
  Widget _buildParameterControls() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 280),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('API Parameters'),
            const Divider(color: AppColors.border, height: 24),

            // Gender selector
            _buildParameterRow(
              'Gender',
              _buildGenderSelector(),
            ),

            // Time range selector
            _buildParameterRow(
              'Time Range',
              _buildTimeRangeSelector(),
            ),

            // Type selector
            _buildParameterRow(
              'Type',
              _buildTypeSelector(),
            ),

            // Comic types selector
            _buildComicTypesSelector(),

            // Mature content switch
            _buildParameterRow(
              'Accept Mature Content',
              Switch(
                value: _acceptMatureContent,
                onChanged: (v) => setState(() => _acceptMatureContent = v),
                activeColor: AppColors.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the gender selector segmented button
  Widget _buildGenderSelector() {
    return SegmentedButton<TopGender>(
      segments: const [
        ButtonSegment(
          value: TopGender.male,
          label: Text('Male'),
          icon: Icon(Icons.male, size: 18),
        ),
        ButtonSegment(
          value: TopGender.female,
          label: Text('Female'),
          icon: Icon(Icons.female, size: 18),
        ),
      ],
      selected: {_selectedGender},
      onSelectionChanged: (s) => setState(() => _selectedGender = s.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primary;
            }
            return AppColors.subtleBackground;
          },
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.primaryForeground;
            }
            return AppColors.cardForeground;
          },
        ),
      ),
    );
  }

  /// Builds the time range dropdown
  Widget _buildTimeRangeSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.subtleBackground,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TopDay>(
          value: _selectedDay,
          items: _buildTimeRangeItems(),
          onChanged: (v) => v != null ? setState(() => _selectedDay = v) : null,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: AppColors.card,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          style: const TextStyle(
            color: AppColors.cardForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Builds the content type dropdown
  Widget _buildTypeSelector() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.subtleBackground,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TopType>(
          value: _selectedType,
          items: _buildTypeItems(),
          onChanged: (v) =>
              v != null ? setState(() => _selectedType = v) : null,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          borderRadius: BorderRadius.circular(8),
          dropdownColor: AppColors.card,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          style: const TextStyle(
            color: AppColors.cardForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// Builds a section header with a title
  Widget _buildSectionHeader(String title) {
    return AppText(
      title,
      variant: TextVariant.titleLarge,
      color: AppColors.cardForeground,
      fontWeight: FontWeight.bold,
    );
  }

  /// Builds a parameter row with a label and input component
  Widget _buildParameterRow(String label, Widget control) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: AppText(
              label,
              variant: TextVariant.bodyLarge,
              fontWeight: FontWeight.w500,
              color: AppColors.cardForeground,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: control,
          ),
        ],
      ),
    );
  }

  /// Builds the comic types multi-selection component
  Widget _buildComicTypesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Comic Types',
          variant: TextVariant.bodyLarge,
          fontWeight: FontWeight.w500,
          color: AppColors.cardForeground,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ComicType.values.map((type) {
            final isSelected = _selectedComicTypes.contains(type);
            return FilterChip(
              label: AppText(
                _getComicTypeLabel(type),
                variant: TextVariant.labelMedium,
                color: isSelected
                    ? AppColors.primaryForeground
                    : AppColors.cardForeground,
              ),
              selected: isSelected,
              onSelected: (sel) => setState(() {
                if (sel) {
                  _selectedComicTypes.add(type);
                } else if (_selectedComicTypes.length > 1) {
                  _selectedComicTypes.remove(type);
                }
              }),
              backgroundColor: AppColors.subtleBackground,
              selectedColor: AppColors.primary,
              checkmarkColor: AppColors.primaryForeground,
              showCheckmark: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Builds dropdown items for time range selection
  List<DropdownMenuItem<TopDay>> _buildTimeRangeItems() {
    final labels = {
      TopDay.d180: '6 months',
      TopDay.d270: '9 months',
      TopDay.d360: '1 year',
      TopDay.d720: '2 years',
    };

    return TopDay.values.map((day) {
      return DropdownMenuItem(
        value: day,
        child: Text(labels[day] ?? ''),
      );
    }).toList();
  }

  /// Builds dropdown items for type selection
  List<DropdownMenuItem<TopType>> _buildTypeItems() {
    final labels = {
      TopType.trending: 'Trending',
      TopType.newFollow: 'New Follow',
      TopType.follow: 'Follow',
    };

    final icons = {
      TopType.trending: Icons.trending_up,
      TopType.newFollow: Icons.new_releases,
      TopType.follow: Icons.bookmark,
    };

    return TopType.values.map((type) {
      return DropdownMenuItem(
        value: type,
        child: Row(
          children: [
            Icon(icons[type], size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(labels[type] ?? ''),
          ],
        ),
      );
    }).toList();
  }

  /// Builds the action buttons for API fetching
  Widget _buildActionButtons() {
    final screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPadding = 20.0;
    const double spacing = 12.0;
    final buttonWidth = (screenWidth - horizontalPadding * 2 - spacing * 2) / 3;

    return Wrap(
      spacing: spacing,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildFetchButton(
          'Trending Manga',
          Icons.trending_up,
          _fetchTrendingManga,
          width: buttonWidth,
          color: AppColors.secondary,
        ),
        _buildFetchButton(
          'Popular (Female)',
          Icons.favorite,
          _fetchPopularForFemaleReaders,
          width: buttonWidth,
          color: AppColors.muted,
        ),
        _buildFetchButton(
          'Fetch Custom',
          Icons.search,
          _fetchDataWithCurrentParams,
          width: buttonWidth,
          color: AppColors.accent,
          isPrimary: true,
        ),
      ],
    );
  }

  /// Builds the tab bar for content sections
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.subtleBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.primary,
        ),
        labelColor: AppColors.primaryForeground,
        unselectedLabelColor: AppColors.foreground,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            icon: Icon(Icons.format_list_numbered),
            text: 'Rankings',
            iconMargin: EdgeInsets.only(bottom: 4),
            height: 56,
          ),
          Tab(
            icon: Icon(Icons.trending_up),
            text: 'Trending',
            iconMargin: EdgeInsets.only(bottom: 4),
            height: 56,
          ),
          Tab(
            icon: Icon(Icons.new_releases),
            text: 'News',
            iconMargin: EdgeInsets.only(bottom: 4),
            height: 56,
          ),
        ],
      ),
    );
  }

  /// Builds a single fetch button with consistent styling
  Widget _buildFetchButton(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    required double width,
    Color? color,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: color,
          foregroundColor:
              isPrimary ? AppColors.accentForeground : Colors.white,
          elevation: isPrimary ? 4 : 2,
          shadowColor: (color ?? AppColors.primary).withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the loading state display
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          const AppText(
            'Loading comic data...',
            variant: TextVariant.bodyLarge,
            color: AppColors.mutedForeground,
          ),
        ],
      ),
    );
  }

  /// Builds the error state display
  Widget _buildErrorState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppColors.destructive),
            const SizedBox(height: 20),
            AppText(
              'Error',
              variant: TextVariant.headlineSmall,
              color: AppColors.destructive,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            AppText(
              _store.errorMessage ?? 'Unknown error occurred',
              variant: TextVariant.bodyLarge,
              color: AppColors.foreground,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchDataWithCurrentParams,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the empty state display
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_download_outlined,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 24),
          const AppText(
            'No data fetched yet',
            variant: TextVariant.titleLarge,
            color: AppColors.foreground,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 12),
          const AppText(
            'Select parameters and tap one of the fetch buttons above',
            variant: TextVariant.bodyLarge,
            color: AppColors.mutedForeground,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          OutlinedButton.icon(
            onPressed: _fetchTrendingManga,
            icon: const Icon(Icons.trending_up),
            label: const Text('Fetch Trending Manga'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the tab content based on the selected tab
  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildRankingsTab(),
        _buildTrendingTab(),
        _buildNewsTab(),
      ],
    );
  }

  /// Builds the rankings tab content
  Widget _buildRankingsTab() {
    final rankings = _store.rankingList;
    if (rankings.isEmpty) {
      return _buildEmptyTabContent('No ranking data available');
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: rankings.length,
      itemBuilder: (context, i) {
        return _buildRankingItem(rankings[i], index: i);
      },
    );
  }

  /// Builds a single ranking item card
  Widget _buildRankingItem(dynamic rank, {required int index}) {
    final cover = rank.mdCovers.isNotEmpty ? rank.mdCovers.first : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 4, right: 4),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rank number badge
          Container(
            width: 32,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            alignment: Alignment.center,
            child: AppText(
              '${index + 1}',
              variant: TextVariant.titleSmall,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForeground,
            ),
          ),
          if (cover != null)
            _buildCoverImage(
              cover.b2key,
              width: 100,
              height: 140,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(0),
                bottomLeft: Radius.circular(0),
                topRight: Radius.circular(0),
                bottomRight: Radius.circular(0),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    rank.title,
                    variant: TextVariant.titleMedium,
                    fontWeight: FontWeight.bold,
                    color: AppColors.cardForeground,
                  ),
                  const SizedBox(height: 6),
                  AppText(
                    'Slug: ${rank.slug}',
                    variant: TextVariant.bodySmall,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppText(
                        'Rating: ',
                        variant: TextVariant.bodySmall,
                        color: AppColors.mutedForeground,
                      ),
                      _buildRatingBadge(rank.contentRating),
                    ],
                  ),
                  if (rank.lastChapter != null) ...[
                    const SizedBox(height: 4),
                    AppText(
                      'Last Chapter: ${rank.lastChapter}',
                      variant: TextVariant.bodySmall,
                      color: AppColors.mutedForeground,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildGenreChips(rank.genres),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the trending tab content
  Widget _buildTrendingTab() {
    final trending = _store.trendingList;
    if (trending.isEmpty) {
      return _buildEmptyTabContent('No trending data available');
    }

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      // Responsive grid: 2 columns on small screens, 3 on larger screens
      final crossAxisCount = width < 600 ? 2 : 3;

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: 0.6,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: trending.length,
        itemBuilder: (context, i) {
          return _buildTrendingItem(trending[i]);
        },
      );
    });
  }

  /// Builds a single trending item card
  Widget _buildTrendingItem(dynamic item) {
    final cover = item.mdCovers.isNotEmpty ? item.mdCovers.first : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (cover != null)
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCoverImage(
                    cover.b2key,
                    width: double.infinity,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  // Gradient overlay for better text visibility
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Trending badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.trending_up,
                            size: 14,
                            color: AppColors.accentForeground,
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            'Trending',
                            variant: TextVariant.labelSmall,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentForeground,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Expanded(
              child: Container(
                color: AppColors.subtleBackground,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.image_not_supported,
                  size: 48,
                  color: AppColors.mutedForeground,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item.title,
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.cardForeground,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AppText(
                      'ID: ${item.id}',
                      variant: TextVariant.bodySmall,
                      color: AppColors.mutedForeground,
                    ),
                    _buildRatingBadge(item.contentRating),
                  ],
                ),
                if (item.genres.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.tag,
                        size: 14,
                        color: AppColors.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: AppText(
                          item.genres.take(3).map((g) => '#$g').join(', '),
                          variant: TextVariant.bodySmall,
                          color: AppColors.mutedForeground,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the news tab content
  Widget _buildNewsTab() {
    final news = _store.newsList;
    if (news.isEmpty) {
      return _buildEmptyTabContent('No news data available');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: news.length,
      itemBuilder: (context, i) {
        return _buildNewsItem(news[i]);
      },
    );
  }

  /// Builds a single news item card
  Widget _buildNewsItem(dynamic item) {
    final cover = item.mdCovers.isNotEmpty ? item.mdCovers.first : null;
    final title =
        item.mdTitles.isNotEmpty ? item.mdTitles.first.title : item.title;

    // Format the createdAt date string if possible
    String formattedDate = item.createdAt;
    try {
      final date = DateTime.parse(item.createdAt);
      formattedDate =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      // Use raw date if parsing fails
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (cover != null)
            SizedBox(
              height: 200,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCoverImage(
                    cover.b2key,
                    width: double.infinity,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  // News badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.new_releases,
                            size: 16,
                            color: AppColors.accentForeground,
                          ),
                          const SizedBox(width: 6),
                          AppText(
                            'NEW',
                            variant: TextVariant.labelMedium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accentForeground,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppText(
                        title,
                        variant: TextVariant.headlineSmall,
                        fontWeight: FontWeight.bold,
                        color: AppColors.cardForeground,
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildRatingBadge(item.contentRating),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoRow(
                  Icons.library_books,
                  'Chapter',
                  '${item.lastChapter ?? "N/A"}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Created',
                  formattedDate,
                ),
                if (item.demographic != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.people,
                    'Demographic',
                    '${item.demographic}',
                  ),
                ],
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                _buildGenreChips(item.genres, size: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds an info row with icon, label and value
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        AppText(
          '$label:',
          variant: TextVariant.bodyMedium,
          color: AppColors.mutedForeground,
        ),
        const SizedBox(width: 8),
        AppText(
          value,
          variant: TextVariant.bodyMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.cardForeground,
        ),
      ],
    );
  }

  /// Builds an empty tab content with message
  Widget _buildEmptyTabContent(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox,
            size: 64,
            color: AppColors.mutedForeground.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          AppText(
            message,
            variant: TextVariant.titleMedium,
            color: AppColors.mutedForeground,
          ),
        ],
      ),
    );
  }

  /// Builds a collection of genre chips
  Widget _buildGenreChips(List<dynamic> genres, {double size = 11}) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children: genres.map((genre) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.subtleBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: AppText(
            '#$genre',
            variant: TextVariant.labelMedium,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedForeground,
          ),
        );
      }).toList(),
    );
  }

  /// Builds a content rating badge
  Widget _buildRatingBadge(String rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getRatingColor(rating),
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        rating,
        variant: TextVariant.labelMedium,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Builds a comic cover image with error handling
  Widget _buildCoverImage(
    String b2key, {
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        'https://comics.services.kiraku.id/uploads/cover/$b2key',
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: AppColors.subtleBackground,
          child: const Icon(Icons.broken_image,
              size: 40, color: AppColors.mutedForeground),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: width,
            height: height,
            color: AppColors.subtleBackground,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Gets the label for a comic type
  String _getComicTypeLabel(ComicType type) {
    switch (type) {
      case ComicType.manga:
        return 'Manga';
      case ComicType.manhwa:
        return 'Manhwa';
      case ComicType.manhua:
        return 'Manhua';
    }
  }

  /// Gets the appropriate color for content rating
  Color _getRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'safe':
        return AppColors.green[600]!;
      case 'suggestive':
        return AppColors.orange[600]!;
      case 'erotica':
        return AppColors.red[500]!;
      case 'pornographic':
        return AppColors.red[900]!;
      default:
        return AppColors.slate[500]!;
    }
  }

  /// Fetches trending manga
  Future<void> _fetchTrendingManga() async {
    await _store.fetchTrendingManga();
  }

  /// Fetches comics popular with female readers
  Future<void> _fetchPopularForFemaleReaders() async {
    await _store.fetchPopularForFemaleReaders();
  }

  /// Fetches comics with current parameter selections
  Future<void> _fetchDataWithCurrentParams() async {
    await _store.fetchCustom(
      gender: _selectedGender,
      day: _selectedDay,
      type: _selectedType,
      comicTypes: List.from(_selectedComicTypes),
      acceptMatureContent: _acceptMatureContent,
    );
  }
}
