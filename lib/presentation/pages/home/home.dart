import 'dart:async';
import 'package:boilerplate/core/widgets/components/overlay/drawer.dart';
import 'package:boilerplate/core/widgets/navbar/navigation.dart';
import 'package:boilerplate/data/local/models/chapter_hot_model.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:boilerplate/presentation/store/home/home_store.dart';
import 'package:boilerplate/presentation/store/settings/settings_store.dart';
import 'package:boilerplate/utils/hoc/check_auth.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/display/comic_card.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/overlay/refresh_trigger.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _mainScrollController = ScrollController();
  final Map<String, ScrollController> _horizontalControllers = {
    'followedComics': ScrollController(),
    'readingHistory': ScrollController(),
    'mostRecent': ScrollController(),
    'popularNew': ScrollController(),
  };

  int _selectedRecentTab = 0;
  int _selectedPopularTab = 0;
  bool _isHotSelected = true;

  final DataRepository _dataRepository = DataRepository();

  final Map<String, bool> _isLoading = {
    'followedComics': false,
    'readingHistory': false,
    'mostRecent_0': false,
    'mostRecent_1': false,
    'mostRecent_2': false,
    'popularNew_0': false,
    'popularNew_1': false,
    'popularNew_2': false,
  };

  final Map<String, bool> _hasMoreData = {
    'followedComics': true,
    'readingHistory': true,
    'mostRecent_0': true,
    'mostRecent_1': true,
    'mostRecent_2': true,
    'popularNew_0': true,
    'popularNew_1': true,
    'popularNew_2': true,
  };

  final Map<String, int> _currentPages = {
    'followedComics': 0,
    'readingHistory': 0,
    'mostRecent_0': 0,
    'mostRecent_1': 0,
    'mostRecent_2': 0,
    'popularNew_0': 0,
    'popularNew_1': 0,
    'popularNew_2': 0,
  };

  final GlobalKey<RefreshTriggerState> _refreshTriggerKey = GlobalKey();
  final List<String> _timePeriodTabs = ['7d', '1m', '3m'];

  late final SettingsStore _settingsStore;
  late final HomeStore _homeStore;

  SettingsEntity? currentSettings;
  bool settingsLoaded = false;
  bool _isRefreshing = false;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeStores();
    _setupScrollListeners();
    _loadInitialData();
  }

  void _initializeStores() {
    _settingsStore = getIt<SettingsStore>();
    _homeStore = getIt<HomeStore>();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isInitialLoading = true;
    });

    await _fetchAndApplySettings();
    await _fetchHomeData();
    _dataRepository.initializeData();
    _loadInitialSections();

    setState(() {
      _isInitialLoading = false;
    });
  }

  Future<void> _fetchAndApplySettings() async {
    await _settingsStore.getSettings();
    currentSettings = _settingsStore.settings;
    settingsLoaded = true;
    setState(() {});
  }

  Future<void> _fetchHomeData() async {
    try {
      // Fetch trending comics for top sections
      await _homeStore.fetchTrendingWithSettings();

      if (_homeStore.hasTopData) {
        _updateMostRecentFromStore();
        _updatePopularNewFromStore();
      }

      // Fetch latest chapters for updates section
      await _homeStore.fetchLatestChaptersWithSettings();

      setState(() {});
    } catch (e, stackTrace) {
      debugPrint('Error fetching home data: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  void _updateMostRecentFromStore() {
    final topFollowMap = _homeStore.topFollowComicsMap;

    _dataRepository.clearSection('mostRecent_0');
    _dataRepository.clearSection('mostRecent_1');
    _dataRepository.clearSection('mostRecent_2');

    _dataRepository.setMostRecentData(topFollowMap[TopPeriod.seven] ?? [],
        period: 0);
    _dataRepository.setMostRecentData(topFollowMap[TopPeriod.thirty] ?? [],
        period: 1);
    _dataRepository.setMostRecentData(topFollowMap[TopPeriod.ninety] ?? [],
        period: 2);
  }

  void _updatePopularNewFromStore() {
    final topFollowNewMap = _homeStore.topFollowNewComicsMap;

    _dataRepository.clearSection('popularNew_0');
    _dataRepository.clearSection('popularNew_1');
    _dataRepository.clearSection('popularNew_2');

    _dataRepository.setPopularNewData(topFollowNewMap[TopPeriod.seven] ?? [],
        period: 0);
    _dataRepository.setPopularNewData(topFollowNewMap[TopPeriod.thirty] ?? [],
        period: 1);
    _dataRepository.setPopularNewData(topFollowNewMap[TopPeriod.ninety] ?? [],
        period: 2);
  }

  void _setupScrollListeners() {
    _mainScrollController.addListener(() {
      if (_mainScrollController.position.pixels >=
          _mainScrollController.position.maxScrollExtent - 200) {
        // Load more chapters when scrolling near the bottom of the main scroll view
        _homeStore.loadMoreChapters(_isHotSelected);
      }
    });

    _horizontalControllers.forEach((key, controller) {
      controller.addListener(() {
        if (controller.position.pixels >=
            controller.position.maxScrollExtent - 100) {
          String dataKey = key;

          if (key == 'mostRecent') {
            dataKey = 'mostRecent_$_selectedRecentTab';
          } else if (key == 'popularNew') {
            dataKey = 'popularNew_$_selectedPopularTab';
          }

          _loadMoreData(dataKey);
        }
      });
    });
  }

  void _loadInitialSections() {
    _loadMoreData('followedComics');
    _loadMoreData('readingHistory');
    _loadMoreData('mostRecent_$_selectedRecentTab');
    _loadMoreData('popularNew_$_selectedPopularTab');
  }

  void _loadMoreData(String section) {
    if (_isLoading[section] == true || _hasMoreData[section] == false) {
      return;
    }

    setState(() {
      _isLoading[section] = true;
    });

    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      _loadSectionData(section, section);
      setState(() {
        _isLoading[section] = false;
      });
    });
  }

  void _loadSectionData(String section, String actualSection) {
    final pageSize = 5;
    final page = _currentPages[section] ?? 0;
    final startIndex = page * pageSize;
    final sourceList = _dataRepository.getData(actualSection);

    if (startIndex >= sourceList.length) {
      setState(() {
        _hasMoreData[section] = false;
      });
      return;
    }

    final itemsToAdd = sourceList.sublist(
      startIndex,
      startIndex + pageSize > sourceList.length
          ? sourceList.length
          : startIndex + pageSize,
    );

    String visualSection = section;
    if (section.startsWith('mostRecent_')) {
      visualSection = 'mostRecent';
    } else if (section.startsWith('popularNew_')) {
      visualSection = 'popularNew';
    }

    setState(() {
      _dataRepository.addVisibleItems(visualSection, itemsToAdd);
      _currentPages[section] = page + 1;
    });
  }

  Future<void> _refreshContent() async {
    if (_isRefreshing) return;

    _isRefreshing = true;

    setState(() {
      _dataRepository.clearVisibleData();
      _currentPages.forEach((key, _) {
        _currentPages[key] = 0;
        _hasMoreData[key] = true;
        _isLoading[key] = false;
      });
    });

    try {
      // Reset pagination in homeStore when refreshing
      _homeStore.resetChaptersPagination();

      await _fetchAndApplySettings();
      await _fetchHomeData();
      _loadInitialSections();

      await Future.delayed(const Duration(milliseconds: 300));
    } finally {
      _isRefreshing = false;
    }

    return Future.value();
  }

  void _onRecentTabSelected(int index) {
    setState(() {
      _dataRepository.clearVisibleSection('mostRecent');

      _selectedRecentTab = index;

      _currentPages['mostRecent_$index'] = 0;
      _hasMoreData['mostRecent_$index'] = true;
      _isLoading['mostRecent_$index'] = false;

      _loadMoreData('mostRecent_$index');
    });
  }

  void _onPopularTabSelected(int index) {
    setState(() {
      _dataRepository.clearVisibleSection('popularNew');

      _selectedPopularTab = index;

      _currentPages['popularNew_$index'] = 0;
      _hasMoreData['popularNew_$index'] = true;
      _isLoading['popularNew_$index'] = false;

      _loadMoreData('popularNew_$index');
    });
  }

  void _navigateToLogin() {
    context.go('/login');
  }

  @override
  void dispose() {
    _disposeScrollControllers();
    super.dispose();
  }

  void _disposeScrollControllers() {
    _mainScrollController.dispose();
    for (var controller in _horizontalControllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading || !settingsLoaded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 20),
              AppText(
                "Loading your content...",
                variant: TextVariant.bodyLarge,
                color: AppColors.neutral[400]!,
              )
            ],
          ),
        ),
      );
    }

    return ScaffoldWithNavBar(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: RefreshTrigger(
          key: _refreshTriggerKey,
          minExtent: 200,
          maxExtent: 400,
          onRefresh: _refreshContent,
          child: _isRefreshing
              ? Center(child: _buildCenteredLoadingIndicator("Refreshing..."))
              : SingleChildScrollView(
                  controller: _mainScrollController,
                  padding: const EdgeInsets.symmetric(vertical: 64.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFollowedComicsSection(),
                      const SizedBox(height: 24),
                      _buildReadingHistorySection(),
                      const SizedBox(height: 24),
                      _buildMostRecentPopularSection(),
                      const SizedBox(height: 24),
                      _buildPopularNewComicsSection(),
                      const SizedBox(height: 24),
                      _buildUpdatesSection(),
                      Observer(
                        builder: (_) {
                          final isLoading = _isHotSelected
                              ? _homeStore.isHotChaptersLoading
                              : _homeStore.isNewChaptersLoading;
                          final hasMoreData = _isHotSelected
                              ? _homeStore.hasMoreHotChapters
                              : _homeStore.hasMoreNewChapters;

                          if (isLoading && hasMoreData) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(
                                child: _buildSmallLoadingIndicator(
                                    "Loading more updates..."),
                              ),
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFollowedComicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Followed Comics'),
        SizedBox(
          height: 270,
          child: AuthWidget(
            noAuthBuilder: (context) => _buildLoginPrompt(),
            child: _buildFollowedComicsContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginPrompt() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_outline,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16.0),
          AppText(
            'Track Your Favorite Comics',
            variant: TextVariant.titleLarge,
            color: AppColors.cardForeground,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8.0),
          AppText(
            'Sign in to see your followed comics and keep track of what you\'re reading',
            variant: TextVariant.bodyMedium,
            color: AppColors.mutedForeground,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          Button(
            text: 'Sign In',
            variant: ButtonVariant.primary,
            size: ButtonSize.large,
            colors: ButtonColors(
              background: AppColors.primary,
              text: AppColors.primaryForeground,
            ),
            onPressed: _navigateToLogin,
            leftIcon: Icons.login,
          ),
        ],
      ),
    );
  }

  Widget _buildFollowedComicsContent() {
    final comics = _dataRepository.getVisibleData('followedComics');
    final isLoading = _isLoading['followedComics'] == true;
    final controller = _horizontalControllers['followedComics']!;
    final hasComics = comics.isNotEmpty;

    return isLoading && !hasComics
        ? _buildCenteredLoadingIndicator("Loading followed comics...")
        : _buildHorizontalComicList(
            comics: comics,
            controller: controller,
            isLoading: isLoading,
            section: 'followedComics',
            cardBuilder: _buildFollowedComicCard,
            action: Button(
              text: 'View All',
              variant: ButtonVariant.text,
              size: ButtonSize.small,
              colors: ButtonColors(text: AppColors.blue[400]),
              onPressed: () {},
            ),
          );
  }

  Widget _buildReadingHistorySection() {
    final comics = _dataRepository.getVisibleData('readingHistory');
    final isLoading = _isLoading['readingHistory'] == true;
    final controller = _horizontalControllers['readingHistory']!;
    final hasComics = comics.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Reading History'),
        SizedBox(
          height: 250,
          child: isLoading && !hasComics
              ? _buildCenteredLoadingIndicator("Loading reading history...")
              : _buildHorizontalComicList(
                  comics: comics,
                  controller: controller,
                  isLoading: isLoading,
                  section: 'readingHistory',
                  cardBuilder: _buildHistoryComicCard,
                ),
        ),
      ],
    );
  }

  Widget _buildMostRecentPopularSection() {
    final comics = _dataRepository.getVisibleData('mostRecent');
    final isLoading = _isLoading['mostRecent_$_selectedRecentTab'] == true;
    final controller = _horizontalControllers['mostRecent']!;
    final hasComics = comics.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Most Recent Popular'),
        _buildTabSelector(
          tabs: _timePeriodTabs,
          selectedIndex: _selectedRecentTab,
          onSelected: _onRecentTabSelected,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: isLoading && !hasComics
              ? _buildCenteredLoadingIndicator("Loading most recent comics...")
              : _buildHorizontalComicList(
                  comics: comics,
                  controller: controller,
                  isLoading: isLoading,
                  section: 'mostRecent_$_selectedRecentTab',
                  cardBuilder: _buildRankedComicCard,
                ),
        ),
      ],
    );
  }

  Widget _buildPopularNewComicsSection() {
    final comics = _dataRepository.getVisibleData('popularNew');
    final isLoading = _isLoading['popularNew_$_selectedPopularTab'] == true;
    final controller = _horizontalControllers['popularNew']!;
    final hasComics = comics.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Popular New Comics'),
        _buildTabSelector(
          tabs: _timePeriodTabs,
          selectedIndex: _selectedPopularTab,
          onSelected: _onPopularTabSelected,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: isLoading && !hasComics
              ? _buildCenteredLoadingIndicator("Loading popular new comics...")
              : _buildHorizontalComicList(
                  comics: comics,
                  controller: controller,
                  isLoading: isLoading,
                  section: 'popularNew_$_selectedPopularTab',
                  cardBuilder: _buildRankedComicCard,
                ),
        ),
      ],
    );
  }

  Widget _buildUpdatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              const Expanded(
                child: AppText(
                  'Updates',
                  variant: TextVariant.titleLarge,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _buildUpdatesToggle(),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Observer(
            builder: (_) {
              final isLoading = _isHotSelected
                  ? _homeStore.isHotChaptersLoading
                  : _homeStore.isNewChaptersLoading;
              final hasError = _homeStore.hasChaptersError;
              final chapters = _isHotSelected
                  ? _homeStore.hotChapters
                  : _homeStore.newChapters;
              final hasMoreData = _isHotSelected
                  ? _homeStore.hasMoreHotChapters
                  : _homeStore.hasMoreNewChapters;

              if (isLoading && chapters.isEmpty) {
                return _buildCenteredLoadingIndicator(_isHotSelected
                    ? "Loading hot chapters..."
                    : "Loading new chapters...");
              } else if (hasError) {
                return _buildEmptyState(_homeStore.chaptersErrorMessage ??
                    "Error loading chapters");
              } else if (chapters.isEmpty) {
                return _buildEmptyState("No updates available");
              } else {
                return _buildUpdateGrid(chapters, isLoading, hasMoreData);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateGrid(
      List<ChapterResponseModel> chapters, bool isLoading, bool hasMoreData) {
    return Column(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.6,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            return _buildChapterCard(chapters[index], index);
          },
        ),
        if (isLoading && chapters.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _buildSmallLoadingIndicator("Loading more updates..."),
          ),
        if (!hasMoreData && chapters.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                "No more updates",
                style: TextStyle(
                  color: AppColors.neutral[500],
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {Widget? action}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              title,
              variant: TextVariant.titleLarge,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      height: 200,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 48, color: AppColors.neutral[600]),
          const SizedBox(height: 16),
          AppText(
            message,
            variant: TextVariant.bodyLarge,
            color: AppColors.neutral[500],
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector({
    required List<String> tabs,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          tabs.length,
          (index) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelected(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedIndex == index
                      ? AppColors.blue
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selectedIndex == index
                        ? AppColors.blue
                        : AppColors.neutral[600]!,
                    width: 1,
                  ),
                ),
                child: AppText(
                  tabs[index],
                  variant: TextVariant.labelMedium,
                  color: selectedIndex == index
                      ? AppColors.neutral[50]
                      : AppColors.neutral[400],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUpdatesToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildToggleOption(
          isSelected: _isHotSelected,
          title: 'Hot',
          icon: Icons.local_fire_department,
          color: AppColors.red,
          onTap: () => _toggleUpdateFilter(true),
        ),
        const SizedBox(width: 4),
        _buildToggleOption(
          isSelected: !_isHotSelected,
          title: 'New',
          icon: Icons.auto_awesome,
          color: AppColors.blue,
          onTap: () => _toggleUpdateFilter(false),
        ),
        IconButton(
          icon:
              Icon(Icons.filter_list, color: AppColors.neutral[400], size: 20),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          onPressed: () => _showContentPreferences(),
        ),
      ],
    );
  }

  Widget _buildToggleOption({
    required bool isSelected,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? color : AppColors.neutral[400],
            ),
            const SizedBox(width: 4),
            AppText(
              title,
              variant: TextVariant.labelMedium,
              color: isSelected ? color : AppColors.neutral[400],
            ),
          ],
        ),
      ),
    );
  }

  void _toggleUpdateFilter(bool isHot) {
    setState(() {
      if (_isHotSelected != isHot) {
        _isHotSelected = isHot;
      }
    });
  }

  void _showContentPreferences() {
    showSheet(
      context: context,
      draggable: false,
      builder: (sheetContext) => _buildSheetContent(
        context,
        'Content Preferences',
        'Customize your reading experience',
        Icons.tune,
        AppColors.primary,
      ),
    );
  }

  Widget _buildHorizontalComicList({
    required List<Map<String, dynamic>> comics,
    required ScrollController controller,
    required bool isLoading,
    required String section,
    required Widget Function(Map<String, dynamic>, int) cardBuilder,
    Widget? action,
  }) {
    return Stack(
      children: [
        comics.isEmpty
            ? _buildEmptyState("No comics available")
            : ListView.builder(
                controller: controller,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: comics.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: cardBuilder(comics[index], index),
                  );
                },
              ),
        if (isLoading && comics.isNotEmpty)
          Positioned.fill(
            child: _buildOverlayLoadingIndicator(),
          ),
        Positioned(
          left: 5,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildScrollButton(
              icon: Icons.chevron_left,
              onPressed: () => _scrollHorizontalList(controller, comics, false),
            ),
          ),
        ),
        Positioned(
          right: 5,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildScrollButton(
              icon: Icons.chevron_right,
              onPressed: () => _scrollHorizontalList(controller, comics, true),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverlayLoadingIndicator() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.neutral[900]!.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                strokeWidth: 3,
              ),
              SizedBox(height: 8),
              AppText(
                "Loading",
                variant: TextVariant.labelSmall,
                color: AppColors.neutral[300]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCenteredLoadingIndicator(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          AppText(
            message,
            variant: TextVariant.bodyMedium,
            color: AppColors.neutral[400]!,
          ),
        ],
      ),
    );
  }

  Widget _buildSmallLoadingIndicator(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeWidth: 2,
          ),
        ),
        SizedBox(width: 8),
        AppText(
          message,
          variant: TextVariant.labelMedium,
          color: AppColors.neutral[400]!,
        ),
      ],
    );
  }

  void _scrollHorizontalList(ScrollController controller,
      List<Map<String, dynamic>> comics, bool forward) {
    if (comics.isEmpty) return;

    final currentOffset = controller.offset;
    final scrollAmount = MediaQuery.of(context).size.width * 0.5;
    final targetOffset = forward
        ? (currentOffset + scrollAmount)
        : (currentOffset - scrollAmount);

    controller.animateTo(
      targetOffset.clamp(0, controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildScrollButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.neutral[800]!.withValues(alpha: 0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral[300]!.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildFollowedComicCard(Map<String, dynamic> comic, int index) {
    return ComicCard(
      title: comic['title'] as String,
      imageUrl: "https://meo.comick.pictures/${comic['cover']}",
      chapter: comic['chapter'] as String,
      updated: comic['time'] as String,
      scanlator: (comic['scanlator'] ?? 'Unknown') as String,
      likes: (comic['count'] ?? '0').toString(),
      countryCodeUrl: comic['language'] == 'en'
          ? 'assets/flags/us.png'
          : 'assets/flags/jp.png',
      isBookmarked: true,
      showBookmark: false,
      showLike: true,
      showCountryFlag: true,
      showUpdated: true,
      showScanlator: false,
      onTap: () => context.go('/comicDetail/${comic['slug']}'),
      style: ComicCardStyle.light().copyWith(
        width: 170,
        height: 270,
        imageHeight: 180,
      ),
    );
  }

  Widget _buildHistoryComicCard(Map<String, dynamic> comic, int index) {
    return ComicCard(
      title: comic['title'] as String,
      imageUrl: "https://meo.comick.pictures/${comic['cover']}",
      chapter: comic['chapter'] as String,
      updated: comic['time'] as String,
      scanlator: '',
      likes: (comic['count'] ?? '0').toString(),
      countryCodeUrl: '',
      showBookmark: false,
      showCountryFlag: false,
      showUpdated: false,
      showLike: false,
      showScanlator: false,
      onTap: () => context.go('/comicDetail/${comic['slug']}'),
      style: ComicCardStyle.light().copyWith(
        width: 170,
        height: 270,
        imageHeight: 180,
      ),
    );
  }

  Widget _buildRankedComicCard(Map<String, dynamic> comic, int index) {
    return Stack(
      children: [
        ComicCard(
          title: comic['title'] as String,
          imageUrl: "https://meo.comick.pictures/${comic['cover']}",
          chapter: comic['chapter'] as String,
          updated: (comic['time'] ?? '') as String,
          scanlator: '',
          likes: (comic['count'] ?? '0').toString(),
          countryCodeUrl: '',
          onlyTitle: true,
          showBookmark: false,
          showCountryFlag: false,
          showUpdated: false,
          showLike: true,
          showScanlator: false,
          onTap: () => context.go('/comicDetail/${comic['slug']}'),
          style: ComicCardStyle.light().copyWith(
            width: 170,
            height: 250,
            imageHeight: 180,
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getRankColor(index + 1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText(
                '${index + 1}',
                variant: TextVariant.labelMedium,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChapterCard(ChapterResponseModel chapter, int index) {
    final comic = chapter.mdComics;
    if (comic == null) return Container();

    String coverUrl = '';
    if (comic.mdCovers != null &&
        comic.mdCovers!.isNotEmpty &&
        comic.mdCovers!.first.b2key != null) {
      coverUrl = "https://meo.comick.pictures/${comic.mdCovers!.first.b2key}";
    } else if (comic.coverUrl != null && comic.coverUrl!.isNotEmpty) {
      coverUrl = comic.coverUrl!;
    }

    // Format chapter number
    String chapterNumber = 'Ch. ';
    if (chapter.chap != null && chapter.chap!.isNotEmpty) {
      chapterNumber += chapter.chap!;
    } else {
      chapterNumber += '?';
    }

    // Format time
    String timeAgo = 'New';
    if (chapter.createdAt != null && chapter.createdAt!.isNotEmpty) {
      final DateTime createdDate = DateTime.parse(chapter.createdAt!);
      final DateTime now = DateTime.now();
      final Duration difference = now.difference(createdDate);

      if (difference.inMinutes < 60) {
        timeAgo = '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        timeAgo = '${difference.inHours}h ago';
      } else {
        timeAgo = '${difference.inDays}d ago';
      }
    }

    return LayoutBuilder(builder: (context, constraints) {
      final double cardWidth = constraints.maxWidth;
      final double cardHeight = constraints.maxHeight;
      final double imageHeight = cardHeight * 0.64;

      return ComicCard(
        title: comic.title ?? 'Unknown Title',
        imageUrl: coverUrl,
        chapter: chapterNumber,
        updated: timeAgo,
        scanlator: chapter.groupName?.isNotEmpty == true
            ? chapter.groupName!.first
            : 'Unknown',
        likes: (chapter.upCount ?? 0).toString(),
        countryCodeUrl: chapter.lang == 'en'
            ? 'assets/flags/us.png'
            : 'assets/flags/jp.png',
        showBookmark: false,
        showCountryFlag: true,
        showUpdated: true,
        showLike: true,
        showScanlator: true,
        onTap: () => context.go('/comicDetail/${comic.slug}'),
        style: ComicCardStyle.light().copyWith(
          width: cardWidth,
          height: cardHeight,
          imageHeight: imageHeight,
        ),
      );
    });
  }

  Widget _buildSheetContent(BuildContext parentContext, String title,
      String description, IconData icon, Color color) {
    return SettingsSheet(
      currentSettings: currentSettings,
      onSettingsChanged: _applySettings,
    );
  }

  void _applySettings(SettingsEntity newSettings) async {
    setState(() => _isRefreshing = true);

    await _settingsStore.saveOrUpdateSettings(newSettings);
    await _settingsStore.getSettings();
    currentSettings = _settingsStore.settings;

    _homeStore.resetChaptersPagination();

    if (mounted) {
      closeSheet(context);
      await _refreshContent();
    }

    setState(() => _isRefreshing = false);
  }

  Color _getRankColor(int rank) {
    switch (rank % 5) {
      case 0:
        return AppColors.violet[700]!;
      case 1:
        return AppColors.red[700]!;
      case 2:
        return AppColors.green[700]!;
      case 3:
        return AppColors.orange[700]!;
      case 4:
        return AppColors.blue[700]!;
      default:
        return AppColors.neutral[700]!;
    }
  }
}

class DataRepository {
  final Map<String, List<Map<String, dynamic>>> _allComics = {
    'followedComics': [],
    'readingHistory': [],
    'mostRecent_0': [],
    'mostRecent_1': [],
    'mostRecent_2': [],
    'popularNew_0': [],
    'popularNew_1': [],
    'popularNew_2': [],
  };

  final Map<String, List<Map<String, dynamic>>> _visibleComics = {
    'followedComics': [],
    'readingHistory': [],
    'mostRecent': [],
    'popularNew': [],
  };

  void initializeData() {}

  void setRankingsData(List<dynamic> apiRankList) {
    if (apiRankList.isEmpty) return;

    _allComics['rankingData'] = List<Map<String, dynamic>>.from(
      apiRankList.map((e) {
        final map = e.toJson();
        return _mapToComicData(map);
      }),
    );
  }

  void setMostRecentData(List<dynamic> topFollowComicsList, {int period = 0}) {
    if (topFollowComicsList.isEmpty) return;

    List<Map<String, dynamic>> mappedData = List<Map<String, dynamic>>.from(
      topFollowComicsList.map((e) {
        final map = e is Map ? e : e.toJson();
        return _mapToComicData(map, startRank: 1);
      }),
    );

    _allComics['mostRecent_$period'] = mappedData;
  }

  void setPopularNewData(List<dynamic> topFollowNewComicsList,
      {int period = 0}) {
    if (topFollowNewComicsList.isEmpty) return;

    List<Map<String, dynamic>> mappedData = List<Map<String, dynamic>>.from(
      topFollowNewComicsList.map((e) {
        final map = e is Map ? e : e.toJson();
        return _mapToComicData(map, startRank: 1);
      }),
    );

    _allComics['popularNew_$period'] = mappedData;
  }

  void clearSection(String section) {
    if (_allComics.containsKey(section)) {
      _allComics[section] = [];
    }
  }

  Map<String, dynamic> _mapToComicData(Map<String, dynamic> map,
      {int startRank = 0}) {
    return {
      'title': map['title'] ?? 'Unknown Title',
      'cover': map['md_covers'] != null && map['md_covers'].isNotEmpty
          ? map['md_covers'][0].b2key
          : '',
      'slug': map['slug'] ?? '',
      'chapter': map['last_chapter']?.toString() ?? 'Ch.1',
      'time': map['created_at'] ?? '1d ago',
      'scanlator': map['scanlator'] ?? 'Unknown',
      'likes': map['likes']?.toString() ?? '0',
      'count': map['count']?.toString() ?? '0',
      'language': map['language'] ?? 'en',
      'rank': map['rank'] ?? startRank,
    };
  }

  List<Map<String, dynamic>> getData(String section) {
    return _allComics[section] ?? [];
  }

  List<Map<String, dynamic>> getVisibleData(String section) {
    return _visibleComics[section] ?? [];
  }

  void addVisibleItems(String section, List<Map<String, dynamic>> items) {
    _visibleComics[section] = _visibleComics[section] ?? [];
    _visibleComics[section]!.addAll(items);
  }

  void clearVisibleData() {
    _visibleComics.forEach((key, _) {
      _visibleComics[key] = [];
    });
  }

  void clearVisibleSection(String section) {
    _visibleComics[section] = [];
  }

  void debugLogVisibleData() {
    _visibleComics.forEach((key, value) {
      debugPrint('  $key: ${value.length} items');
    });
  }
}

class SettingsSheet extends StatefulWidget {
  final SettingsEntity? currentSettings;
  final Function(SettingsEntity) onSettingsChanged;

  const SettingsSheet({
    super.key,
    required this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late _SettingsEditModel editingSettings;
  bool _isSubmitting = false;

  final List<Map<String, String>> contentTypeOptions = [
    {
      'value': 'manga',
      'label': 'Manga',
      'description': 'are comics originating from Japan',
    },
    {
      'value': 'manhwa',
      'label': 'Manhwa',
      'description':
          'are the general Korean term for comics and print cartoons. Outside Korea, the term usually refers to South Korean comics.',
    },
    {
      'value': 'manhua',
      'label': 'Manhua',
      'description': 'is Chinese-language comics produced in China and Taiwan.',
    },
  ];

  final List<Map<String, dynamic>> demographicOptions = [
    {
      'value': 'male',
      'label': 'Male (Shounen + Seinen)',
      'description': '',
    },
    {
      'value': 'female',
      'label': 'Female (Shoujo + Josei)',
      'description': '',
    },
    {
      'value': 'none',
      'label': 'None (Not Set)',
      'description':
          'Comics that have not been updated with information yet. It should be "ON" for those who don\'t want to miss any good comics.',
    },
  ];

  final List<Map<String, String>> matureContentOptions = [
    {
      'value': 'mature',
      'label': 'Mature Content',
      'description':
          'These comics may have content or themes not appropriate for all audiences such as such as some nudity, sexual content, and other mature topics.',
    },
    {
      'value': 'horror_gore',
      'label': 'Frequent Horror and Gore',
      'description': 'Content that feature extreme horror or gore.',
    },
    {
      'value': 'adult',
      'label': 'Adult Only Content',
      'description':
          'Tick this box if you are okay seeing comics that contain sexual content that is explicit or graphic and is intended for adults only. By ticking this box you affirm that you are at least eighteen years old.',
    },
  ];

  @override
  void initState() {
    super.initState();
    final current = widget.currentSettings ??
        const SettingsEntity(
          id: "none",
          contentTypes: ['manga', 'manhwa', 'manhua'],
          demographic: 'male',
          matureContent: [],
        );

    editingSettings = _SettingsEditModel(
      contentTypes: List<String>.from(current.contentTypes),
      demographic: current.demographic,
      matureContent: List<String>.from(current.matureContent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.neutral[900],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildContentTypeSection(),
                    const SizedBox(height: 24),
                    _buildDemographicSection(),
                    const SizedBox(height: 24),
                    _buildMatureContentSection(),
                    const SizedBox(height: 24),
                    _buildApplyButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Manga/Manhwa/Manhua',
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        ...contentTypeOptions.map((option) => _buildCheckboxOption(
              option: option,
              isSelected:
                  editingSettings.contentTypes.contains(option['value']),
              onToggle: (selected) {
                setState(() {
                  if (selected) {
                    editingSettings.contentTypes.add(option['value']!);
                  } else {
                    editingSettings.contentTypes.remove(option['value']);
                  }
                });
              },
            )),
      ],
    );
  }

  Widget _buildDemographicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Genders (Demographic)',
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        ...demographicOptions.map((option) => _buildRadioOption(
              option: option,
              isSelected: editingSettings.demographic == option['value'],
              onSelect: () {
                setState(() {
                  editingSettings.demographic = option['value'] as String;
                });
              },
            )),
      ],
    );
  }

  Widget _buildMatureContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Mature Content',
          variant: TextVariant.titleLarge,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        const SizedBox(height: 16),
        ...matureContentOptions.map((option) => _buildCheckboxOption(
              option: option,
              isSelected:
                  editingSettings.matureContent.contains(option['value']),
              onToggle: (selected) {
                setState(() {
                  if (selected) {
                    editingSettings.matureContent.add(option['value']!);
                  } else {
                    editingSettings.matureContent.remove(option['value']);
                  }
                });
              },
            )),
      ],
    );
  }

  Widget _buildCheckboxOption({
    required Map<String, String> option,
    required bool isSelected,
    required Function(bool) onToggle,
  }) {
    return InkWell(
      onTap: () => onToggle(!isSelected),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => onToggle(value ?? false),
              activeColor: AppColors.blue[400],
              checkColor: Colors.white,
              side: BorderSide(
                color: AppColors.neutral[600]!,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    option['label']!,
                    variant: TextVariant.bodyLarge,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  if (option['description']!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AppText(
                      option['description']!,
                      variant: TextVariant.bodySmall,
                      color: AppColors.neutral[400]!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioOption({
    required Map<String, dynamic> option,
    required bool isSelected,
    required VoidCallback onSelect,
  }) {
    return InkWell(
      onTap: onSelect,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color:
                    isSelected ? AppColors.blue[400]! : AppColors.neutral[600]!,
                width: 2,
              ),
            ),
            child: Center(
              child: isSelected
                  ? Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.blue[400],
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    option['label'] as String,
                    variant: TextVariant.bodyLarge,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  if ((option['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: 4),
                    AppText(
                      option['description'] as String,
                      variant: TextVariant.bodySmall,
                      color: AppColors.neutral[400]!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _applySettings,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
      ),
      child: _isSubmitting
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 8),
                Text('Applying...'),
              ],
            )
          : const Text('Apply Preferences'),
    );
  }

  void _applySettings() {
    setState(() {
      _isSubmitting = true;
    });

    final updatedSettings = SettingsEntity(
      id: widget.currentSettings?.id ?? DateTime.now().toIso8601String(),
      contentTypes: editingSettings.contentTypes,
      demographic: editingSettings.demographic,
      matureContent: editingSettings.matureContent,
    );

    widget.onSettingsChanged(updatedSettings);
  }
}

class _SettingsEditModel {
  List<String> contentTypes;
  String demographic;
  List<String> matureContent;

  _SettingsEditModel({
    required this.contentTypes,
    required this.demographic,
    required this.matureContent,
  });
}
