import 'dart:async';
import 'package:boilerplate/core/widgets/components/overlay/drawer.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/domain/entity/user/setting.dart';
import 'package:boilerplate/presentation/store/settings/settings_store.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/display/comic_card.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/overlay/refresh_trigger.dart';
import 'package:boilerplate/presentation/pages/home/content_constant.dart';
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

  final Map<String, List<Map<String, dynamic>>> _allComics = {
    'followedComics': followedComics,
    'readingHistory': readingHistory,
    'mostRecent': [],
    'popularNew': [],
    'updatesHot': [],
    'updatesNew': [],
  };

  final Map<String, List<Map<String, dynamic>>> _visibleComics = {
    'followedComics': [],
    'readingHistory': [],
    'mostRecent': [],
    'popularNew': [],
    'updatesHot': [],
    'updatesNew': [],
  };

  final Map<String, bool> _isLoading = {
    'followedComics': false,
    'readingHistory': false,
    'mostRecent': false,
    'popularNew': false,
    'updatesHot': false,
    'updatesNew': false,
  };

  final Map<String, bool> _hasMoreData = {
    'followedComics': true,
    'readingHistory': true,
    'mostRecent': true,
    'popularNew': true,
    'updatesHot': true,
    'updatesNew': true,
  };

  final Map<String, int> _currentPages = {
    'followedComics': 0,
    'readingHistory': 0,
    'mostRecent': 0,
    'popularNew': 0,
    'updatesHot': 0,
    'updatesNew': 0,
  };

  final GlobalKey<RefreshTriggerState> _refreshTriggerKey = GlobalKey();

  final List<String> _timePeriodTabs = ['7d', '1m', '3m'];

  late final SettingsStore _settingsStore;
  SettingsEntity? currentSettings;
  bool settingsLoaded = false;
  bool settingsSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _settingsStore = getIt<SettingsStore>();
    _fetchAndApplySettings().then((_) {
      setState(() {});
    });

    _initializeData();
    _setupScrollListeners();
  }

  Future<void> _fetchAndApplySettings() async {
    await _settingsStore.getSettings();
    currentSettings = _settingsStore.settings;
    settingsLoaded = true;
  }

  void _initializeData() {
    for (int i = 0; i < _timePeriodTabs.length; i++) {
      _allComics['mostRecent_$i'] = mostRecentComics[i] ?? [];
    }

    for (int i = 0; i < _timePeriodTabs.length; i++) {
      _allComics['popularNew_$i'] = popularNewComics[i] ?? [];
    }

    _allComics['updatesHot'] = updatesComics['hot'] ?? [];
    _allComics['updatesNew'] = updatesComics['new'] ?? [];

    _loadMoreData('followedComics');
    _loadMoreData('readingHistory');
    _loadMoreData('mostRecent_$_selectedRecentTab');
    _loadMoreData('popularNew_$_selectedPopularTab');
    _loadMoreData(_isHotSelected ? 'updatesHot' : 'updatesNew');
  }

  void _setupScrollListeners() {
    _mainScrollController.addListener(() {
      if (_mainScrollController.position.pixels >=
          _mainScrollController.position.maxScrollExtent - 200) {
        _loadMoreData(_isHotSelected ? 'updatesHot' : 'updatesNew');
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

  void _loadMoreData(String section) {
    if (_isLoading[section] == true || _hasMoreData[section] == false) {
      return;
    }

    setState(() {
      _isLoading[section] = true;
    });

    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final pageSize = 5;
      final page = _currentPages[section] ?? 0;
      final startIndex = page * pageSize;
      final sourceList = _allComics[section] ?? [];

      if (startIndex >= sourceList.length) {
        setState(() {
          _hasMoreData[section] = false;
          _isLoading[section] = false;
        });
        return;
      }

      final itemsToAdd = sourceList.sublist(
        startIndex,
        startIndex + pageSize > sourceList.length
            ? sourceList.length
            : startIndex + pageSize,
      );

      setState(() {
        _visibleComics[section] = _visibleComics[section] ?? [];
        _visibleComics[section]!.addAll(itemsToAdd);
        _currentPages[section] = page + 1;
        _isLoading[section] = false;
      });
    });
  }

  Future<void> _refreshContent() async {
    setState(() {
      _visibleComics.forEach((key, _) {
        _visibleComics[key] = [];
        _currentPages[key] = 0;
        _hasMoreData[key] = true;
      });
    });

    _initializeData();

    await Future.delayed(const Duration(seconds: 1));
    return;
  }

  @override
  void dispose() {
    _mainScrollController.dispose();
    for (var controller in _horizontalControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!settingsLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildSandboxFab(),
      body: SafeArea(
        child: RefreshTrigger(
          key: _refreshTriggerKey,
          minExtent: 200,
          maxExtent: 400,
          onRefresh: _refreshContent,
          child: SingleChildScrollView(
            controller: _mainScrollController,
            padding: const EdgeInsets.only(bottom: 24.0),
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
                if (_isLoading[_isHotSelected ? 'updatesHot' : 'updatesNew'] ==
                    true)
                  _buildLoadingIndicator(),
              ],
            ),
          ),
        ),
      ),
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

  Widget _buildFollowedComicsSection() {
    final comics = _visibleComics['followedComics'] ?? [];
    final isLoading = _isLoading['followedComics'] == true;
    final controller = _horizontalControllers['followedComics']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Followed Comics',
          action: Button(
            text: 'View All',
            variant: ButtonVariant.text,
            size: ButtonSize.small,
            colors: ButtonColors(text: AppColors.blue[400]),
            onPressed: () {},
          ),
        ),
        SizedBox(
          height: 270,
          child: _buildHorizontalComicList(
            comics: comics,
            controller: controller,
            isLoading: isLoading,
            cardBuilder: (comic) => _buildFollowedComicCard(comic),
          ),
        ),
      ],
    );
  }

  Widget _buildReadingHistorySection() {
    final comics = _visibleComics['readingHistory'] ?? [];
    final isLoading = _isLoading['readingHistory'] == true;
    final controller = _horizontalControllers['readingHistory']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Reading History'),
        SizedBox(
          height: 250,
          child: _buildHorizontalComicList(
            comics: comics,
            controller: controller,
            isLoading: isLoading,
            cardBuilder: (comic) => _buildHistoryComicCard(comic),
          ),
        ),
      ],
    );
  }

  Widget _buildMostRecentPopularSection() {
    final selectedKey = 'mostRecent_$_selectedRecentTab';
    final comics = _visibleComics[selectedKey] ?? [];
    final isLoading = _isLoading[selectedKey] == true;
    final controller = _horizontalControllers['mostRecent']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Most Recent Popular'),
        _buildTabSelector(
          tabs: _timePeriodTabs,
          selectedIndex: _selectedRecentTab,
          onSelected: (index) {
            setState(() {
              _selectedRecentTab = index;
              final newKey = 'mostRecent_$index';
              if ((_visibleComics[newKey] ?? []).isEmpty) {
                _loadMoreData(newKey);
              }
            });
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: _buildHorizontalComicList(
            comics: comics,
            controller: controller,
            isLoading: isLoading,
            cardBuilder: (comic) => _buildRankedComicCard(comic),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularNewComicsSection() {
    final selectedKey = 'popularNew_$_selectedPopularTab';
    final comics = _visibleComics[selectedKey] ?? [];
    final isLoading = _isLoading[selectedKey] == true;
    final controller = _horizontalControllers['popularNew']!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Popular New Comics'),
        _buildTabSelector(
          tabs: _timePeriodTabs,
          selectedIndex: _selectedPopularTab,
          onSelected: (index) {
            setState(() {
              _selectedPopularTab = index;
              final newKey = 'popularNew_$index';
              if ((_visibleComics[newKey] ?? []).isEmpty) {
                _loadMoreData(newKey);
              }
            });
          },
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: _buildHorizontalComicList(
            comics: comics,
            controller: controller,
            isLoading: isLoading,
            cardBuilder: (comic) => _buildRankedComicCard(comic),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdatesSection() {
    final selectedKey = _isHotSelected ? 'updatesHot' : 'updatesNew';
    final comics = _visibleComics[selectedKey] ?? [];

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
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: comics.length,
            itemBuilder: (context, index) {
              return _buildUpdateComicCard(comics[index]);
            },
          ),
        ),
      ],
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
        GestureDetector(
          onTap: () {
            setState(() {
              if (!_isHotSelected) {
                _isHotSelected = true;
                if ((_visibleComics['updatesHot'] ?? []).isEmpty) {
                  _loadMoreData('updatesHot');
                }
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _isHotSelected
                  ? AppColors.red.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color:
                      _isHotSelected ? AppColors.red : AppColors.neutral[400],
                ),
                const SizedBox(width: 4),
                AppText(
                  'Hot',
                  variant: TextVariant.labelMedium,
                  color:
                      _isHotSelected ? AppColors.red : AppColors.neutral[400],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () {
            setState(() {
              if (_isHotSelected) {
                _isHotSelected = false;
                if ((_visibleComics['updatesNew'] ?? []).isEmpty) {
                  _loadMoreData('updatesNew');
                }
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: !_isHotSelected
                  ? AppColors.blue.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 16,
                  color:
                      !_isHotSelected ? AppColors.blue : AppColors.neutral[400],
                ),
                const SizedBox(width: 4),
                AppText(
                  'New',
                  variant: TextVariant.labelMedium,
                  color:
                      !_isHotSelected ? AppColors.blue : AppColors.neutral[400],
                ),
              ],
            ),
          ),
        ),
        IconButton(
          icon:
              Icon(Icons.filter_list, color: AppColors.neutral[400], size: 20),
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(),
          onPressed: () {
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
          },
        ),
      ],
    );
  }

  Widget _buildHorizontalComicList({
    required List<Map<String, dynamic>> comics,
    required ScrollController controller,
    required bool isLoading,
    required Widget Function(Map<String, dynamic>) cardBuilder,
  }) {
    return Stack(
      children: [
        ListView.builder(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: comics.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 16),
              child: cardBuilder(comics[index]),
            );
          },
        ),
        if (isLoading)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.neutral[950]!.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          left: 5,
          top: 0,
          bottom: 0,
          child: Center(
            child: _buildScrollButton(
              icon: Icons.chevron_left,
              onPressed: () {
                final currentOffset = controller.offset;
                final scrollAmount = MediaQuery.of(context).size.width * 0.5;
                controller.animateTo(
                  (currentOffset - scrollAmount)
                      .clamp(0, controller.position.maxScrollExtent),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              },
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
              onPressed: () {
                final currentOffset = controller.offset;
                final scrollAmount = MediaQuery.of(context).size.width * 0.5;
                controller.animateTo(
                  (currentOffset + scrollAmount)
                      .clamp(0, controller.position.maxScrollExtent),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowedComicCard(Map<String, dynamic> comic) {
    return ComicCard(
      title: comic['title'] as String,
      imageUrl: comic['cover'] as String,
      chapter: comic['chapter'] as String,
      updated: comic['time'] as String,
      scanlator: (comic['scanlator'] ?? 'Unknown') as String,
      likes: (comic['likes'] ?? '0').toString(),
      countryCodeUrl: comic['language'] == 'en'
          ? 'assets/flags/us.png'
          : 'assets/flags/jp.png',
      isBookmarked: true,
      showBookmark: true,
      showLike: false,
      showCountryFlag: true,
      showUpdated: true,
      showScanlator: false,
      onTap: () {},
      style: ComicCardStyle.light().copyWith(
        width: 170,
        height: 270,
        imageHeight: 180,
      ),
    );
  }

  Widget _buildHistoryComicCard(Map<String, dynamic> comic) {
    return ComicCard(
      title: comic['title'] as String,
      imageUrl: comic['cover'] as String,
      chapter: comic['chapter'] as String,
      updated: comic['time'] as String,
      scanlator: '',
      likes: '',
      countryCodeUrl: '',
      showBookmark: false,
      showCountryFlag: false,
      showUpdated: false,
      showLike: false,
      showScanlator: false,
      onTap: () {},
      style: ComicCardStyle.light().copyWith(
        width: 170,
        height: 270,
        imageHeight: 180,
      ),
    );
  }

  Widget _buildRankedComicCard(Map<String, dynamic> comic) {
    return Stack(
      children: [
        ComicCard(
          title: comic['title'] as String,
          imageUrl: comic['cover'] as String,
          chapter: comic['chapter'] as String,
          updated: (comic['time'] ?? '') as String,
          scanlator: '',
          likes: (comic['likes'] ?? '0').toString(),
          countryCodeUrl: '',
          showBookmark: true,
          showCountryFlag: false,
          showUpdated: false,
          showLike: true,
          showScanlator: false,
          onTap: () {},
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
              color: _getRankColor(comic['rank'] as int),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: AppText(
                '${comic['rank']}',
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

  Widget _buildUpdateComicCard(Map<String, dynamic> comic) {
    return LayoutBuilder(builder: (context, constraints) {
      final double cardWidth = constraints.maxWidth;
      final double cardHeight = constraints.maxHeight;
      final double imageHeight = cardHeight * 0.64;

      return ComicCard(
        title: comic['title'] as String,
        imageUrl: comic['cover'] as String,
        chapter: comic['chapter'] as String,
        updated: comic['time'] as String,
        scanlator: (comic['scanlator'] ?? 'Unknown') as String,
        likes: (comic['likes'] ?? '0').toString(),
        countryCodeUrl: comic['language'] == 'en'
            ? 'assets/flags/us.png'
            : 'assets/flags/jp.png',
        showBookmark: true,
        showCountryFlag: true,
        showUpdated: true,
        showLike: true,
        showScanlator: true,
        onTap: () {},
        style: ComicCardStyle.light().copyWith(
          width: cardWidth,
          height: cardHeight,
          imageHeight: imageHeight,
        ),
      );
    });
  }

  Widget _buildScrollButton(
      {required IconData icon, required VoidCallback onPressed}) {
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

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildSandboxFab() {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/sandbox'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.primaryForeground,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      icon: const Icon(Icons.science_outlined),
      label: const AppText(
        'API Sandbox',
        variant: TextVariant.labelLarge,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSheetContent(BuildContext parentContext, String title,
      String description, IconData icon, Color color) {
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
        'description':
            'is Chinese-language comics produced in China and Taiwan.',
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

    final current = currentSettings ??
        const SettingsEntity(
          id: "none",
          contentTypes: ['manga', 'manhwa', 'manhua'],
          demographic: 'male',
          matureContent: [],
        );

    final editingSettings = _SettingsEditModel(
      contentTypes: List<String>.from(current.contentTypes),
      demographic: current.demographic,
      matureContent: List<String>.from(current.matureContent),
    );

    return StatefulBuilder(
      builder: (context, setState) {
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
                        // Content Type Section
                        const AppText(
                          'Manga/Manhwa/Manhua',
                          variant: TextVariant.titleLarge,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        ...contentTypeOptions.map((option) {
                          bool isSelected = editingSettings.contentTypes
                              .contains(option['value']);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  editingSettings.contentTypes
                                      .remove(option['value']);
                                } else {
                                  editingSettings.contentTypes
                                      .add(option['value']!);
                                }
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true &&
                                            !editingSettings.contentTypes
                                                .contains(option['value'])) {
                                          editingSettings.contentTypes
                                              .add(option['value']!);
                                        } else if (value == false) {
                                          editingSettings.contentTypes
                                              .remove(option['value']);
                                        }
                                      });
                                    },
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          option['label']!,
                                          variant: TextVariant.bodyLarge,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        if (option['description']!
                                            .isNotEmpty) ...[
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
                        }),

                        const SizedBox(height: 24),

                        // Demographic Section
                        const AppText(
                          'Genders (Demographic)',
                          variant: TextVariant.titleLarge,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        ...demographicOptions.map((option) {
                          bool isSelected =
                              editingSettings.demographic == option['value'];
                          return InkWell(
                            onTap: () {
                              setState(() {
                                editingSettings.demographic =
                                    option['value'] as String;
                              });
                            },
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
                                      color: isSelected
                                          ? AppColors.blue[400]!
                                          : AppColors.neutral[600]!,
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          option['label'] as String,
                                          variant: TextVariant.bodyLarge,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        if ((option['description'] as String)
                                            .isNotEmpty) ...[
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
                        }),

                        const SizedBox(height: 24),

                        // Mature Content Section
                        const AppText(
                          'Mature Content',
                          variant: TextVariant.titleLarge,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        ...matureContentOptions.map((option) {
                          bool isSelected = editingSettings.matureContent
                              .contains(option['value']);
                          return InkWell(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  editingSettings.matureContent
                                      .remove(option['value']);
                                } else {
                                  editingSettings.matureContent
                                      .add(option['value']!);
                                }
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Transform.scale(
                                  scale: 1.2,
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true &&
                                            !editingSettings.matureContent
                                                .contains(option['value'])) {
                                          editingSettings.matureContent
                                              .add(option['value']!);
                                        } else if (value == false) {
                                          editingSettings.matureContent
                                              .remove(option['value']);
                                        }
                                      });
                                    },
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AppText(
                                          option['label']!,
                                          variant: TextVariant.bodyLarge,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                        if (option['description']!
                                            .isNotEmpty) ...[
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
                        }),

                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () async {
                            final updatedSettings = SettingsEntity(
                              id: current.id == "none"
                                  ? DateTime.now().toIso8601String()
                                  : current.id,
                              contentTypes: editingSettings.contentTypes,
                              demographic: editingSettings.demographic,
                              matureContent: editingSettings.matureContent,
                            );
                            await _settingsStore
                                .saveOrUpdateSettings(updatedSettings);
                            await _settingsStore.getSettings();
                            currentSettings = _settingsStore.settings;
                            if (!parentContext.mounted) return;
                            closeSheet(parentContext);
                            setState(() {});
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Apply Preferences'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
