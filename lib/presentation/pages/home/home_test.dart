import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controllers for horizontal scrolling
  final ScrollController _followedComicsController = ScrollController();
  final ScrollController _readingHistoryController = ScrollController();
  final ScrollController _mostRecentController = ScrollController();
  final ScrollController _popularNewController = ScrollController();

  // Selected tab indices
  int _selectedRecentTab = 0;
  int _selectedPopularTab = 0;
  bool _isHotSelected = true; // For Updates section

  // Mock data for comics
  final List<Map<String, dynamic>> _followedComics = [
    {
      'title': 'Pick Me Up',
      'cover': 'assets/covers/cover1.jpg',
      'chapter': 'Current 101',
      'time': '30 minutes ago',
      'language': 'en',
    },
    {
      'title': 'I Became an S-Rank',
      'cover': 'assets/covers/cover2.jpg',
      'chapter': 'Continue 2',
      'time': '1 hours ago',
      'language': 'en',
    },
    {
      'title': 'Urban Legend',
      'cover': 'assets/covers/cover3.jpg',
      'chapter': 'Current 71',
      'time': '15 hours ago',
      'language': 'en',
    },
    {
      'title': 'The Saintess',
      'cover': 'assets/covers/cover4.jpg',
      'chapter': 'Current 43',
      'time': '16 hours ago',
      'language': 'en',
    },
    {
      'title': 'Thunder Storm',
      'cover': 'assets/covers/cover5.jpg',
      'chapter': 'Current 52',
      'time': '18 hours ago',
      'language': 'en',
    },
  ];

  final List<Map<String, dynamic>> _readingHistory = [
    {
      'title': 'Nano Machine',
      'cover': 'assets/covers/cover6.jpg',
      'chapter': 'Chapter 143',
      'time': '2 days ago',
    },
    {
      'title': 'Stealth Master',
      'cover': 'assets/covers/cover7.jpg',
      'chapter': 'Chapter 87',
      'time': '3 days ago',
    },
    {
      'title': 'The Divine',
      'cover': 'assets/covers/cover8.jpg',
      'chapter': 'Chapter 65',
      'time': '5 days ago',
    },
    {
      'title': 'Blade of Wind',
      'cover': 'assets/covers/cover9.jpg',
      'chapter': 'Chapter 29',
      'time': '1 week ago',
    },
  ];

  // Tabs for Most Recent Popular
  final List<String> _recentTabs = ['7d', '1m', '3m'];

  // Popular comics for each tab period
  final Map<int, List<Map<String, dynamic>>> _mostRecentComics = {
    0: [
      // 7d
      {
        'rank': 1,
        'title': 'The Divine Power',
        'cover': 'assets/covers/cover10.jpg',
        'chapter': 'Chapter 82',
      },
      {
        'rank': 2,
        'title': 'Magic Hunter',
        'cover': 'assets/covers/cover11.jpg',
        'chapter': 'Chapter 57',
      },
      {
        'rank': 3,
        'title': 'Red Halo Mask',
        'cover': 'assets/covers/cover12.jpg',
        'chapter': 'Chapter 38',
      },
      {
        'rank': 4,
        'title': 'Bit-Blade Shadow',
        'cover': 'assets/covers/cover13.jpg',
        'chapter': 'Chapter 149',
      },
    ],
    1: [
      // 1m
      {
        'rank': 1,
        'title': 'Shadow Assassin',
        'cover': 'assets/covers/cover14.jpg',
        'chapter': 'Chapter 73',
      },
      {
        'rank': 2,
        'title': 'Magic Academy',
        'cover': 'assets/covers/cover15.jpg',
        'chapter': 'Chapter 42',
      },
      {
        'rank': 3,
        'title': 'Phoenix Rising',
        'cover': 'assets/covers/cover16.jpg',
        'chapter': 'Chapter 118',
      },
      {
        'rank': 4,
        'title': 'Dragon Knight',
        'cover': 'assets/covers/cover17.jpg',
        'chapter': 'Chapter 61',
      },
    ],
    2: [
      // 3m
      {
        'rank': 1,
        'title': 'Eternal Sword',
        'cover': 'assets/covers/cover18.jpg',
        'chapter': 'Chapter 95',
      },
      {
        'rank': 2,
        'title': 'Winter Crown',
        'cover': 'assets/covers/cover19.jpg',
        'chapter': 'Chapter 56',
      },
      {
        'rank': 3,
        'title': 'Mystic Scholar',
        'cover': 'assets/covers/cover20.jpg',
        'chapter': 'Chapter 77',
      },
      {
        'rank': 4,
        'title': 'Blood Contract',
        'cover': 'assets/covers/cover21.jpg',
        'chapter': 'Chapter 33',
      },
    ],
  };

  // Popular New Comics data
  final Map<int, List<Map<String, dynamic>>> _popularNewComics = {
    0: [
      // 7d
      {
        'rank': 1,
        'title': 'Divine Blade',
        'cover': 'assets/covers/cover22.jpg',
        'chapter': 'Chapter 12',
      },
      {
        'rank': 2,
        'title': 'Storm Walker',
        'cover': 'assets/covers/cover23.jpg',
        'chapter': 'Chapter 8',
      },
      {
        'rank': 3,
        'title': 'Black Aura',
        'cover': 'assets/covers/cover24.jpg',
        'chapter': 'Chapter 5',
      },
      {
        'rank': 4,
        'title': 'A Promised Land',
        'cover': 'assets/covers/cover25.jpg',
        'chapter': 'Chapter 7',
      },
    ],
    1: [
      // 1m
      {
        'rank': 1,
        'title': 'Midnight Sun',
        'cover': 'assets/covers/cover26.jpg',
        'chapter': 'Chapter 15',
      },
      {
        'rank': 2,
        'title': 'Crimson Tide',
        'cover': 'assets/covers/cover27.jpg',
        'chapter': 'Chapter 11',
      },
      {
        'rank': 3,
        'title': 'Ghost Walker',
        'cover': 'assets/covers/cover28.jpg',
        'chapter': 'Chapter 9',
      },
      {
        'rank': 4,
        'title': 'Azure Knight',
        'cover': 'assets/covers/cover29.jpg',
        'chapter': 'Chapter 17',
      },
    ],
    2: [
      // 3m
      {
        'rank': 1,
        'title': 'Golden Crown',
        'cover': 'assets/covers/cover30.jpg',
        'chapter': 'Chapter 25',
      },
      {
        'rank': 2,
        'title': 'Silver Fang',
        'cover': 'assets/covers/cover31.jpg',
        'chapter': 'Chapter 19',
      },
      {
        'rank': 3,
        'title': 'Iron Will',
        'cover': 'assets/covers/cover32.jpg',
        'chapter': 'Chapter 22',
      },
      {
        'rank': 4,
        'title': 'Copper Heart',
        'cover': 'assets/covers/cover33.jpg',
        'chapter': 'Chapter 14',
      },
    ],
  };

  // Updates section data
  final Map<String, List<Map<String, dynamic>>> _updatesComics = {
    'hot': [
      {
        'title': 'The Infinite Mage',
        'cover': 'assets/covers/update1.jpg',
        'chapter': 'Chapter 103',
        'time': '15 hours ago',
        'likes': 1054,
        'language': 'en',
      },
      {
        'title': 'The 100th Regression of the Max-Level Player',
        'cover': 'assets/covers/update2.jpg',
        'chapter': 'Chapter 57',
        'time': '15 hours ago',
        'likes': 832,
        'language': 'en',
      },
      {
        'title': 'The Fragrant Flower Blooms with Dignity',
        'cover': 'assets/covers/update3.jpg',
        'chapter': 'Chapter 152',
        'time': '23 minutes ago',
        'likes': 549,
        'language': 'en',
      },
      {
        'title': 'Wind Breaker',
        'cover': 'assets/covers/update4.jpg',
        'chapter': 'Chapter 180',
        'time': '5 hours ago',
        'likes': 746,
        'language': 'en',
      },
      {
        'title': 'Art S-class Adventurer',
        'cover': 'assets/covers/update5.jpg',
        'chapter': 'Chapter 12',
        'time': '10 hours ago',
        'likes': 371,
        'language': 'en',
      },
      {
        'title': 'My Avatar\'s Path to Greatness',
        'cover': 'assets/covers/update6.jpg',
        'chapter': 'Chapter 41',
        'time': '16 hours ago',
        'likes': 612,
        'language': 'en',
      },
    ],
    'new': [
      {
        'title': 'Mystic Journey',
        'cover': 'assets/covers/update7.jpg',
        'chapter': 'Chapter 1',
        'time': '5 hours ago',
        'likes': 328,
        'language': 'en',
      },
      {
        'title': 'Dragon\'s Dream',
        'cover': 'assets/covers/update8.jpg',
        'chapter': 'Chapter 2',
        'time': '8 hours ago',
        'likes': 156,
        'language': 'en',
      },
      {
        'title': 'Midnight Tales',
        'cover': 'assets/covers/update9.jpg',
        'chapter': 'Chapter 3',
        'time': '12 hours ago',
        'likes': 219,
        'language': 'en',
      },
      {
        'title': 'Rising Hero',
        'cover': 'assets/covers/update10.jpg',
        'chapter': 'Chapter 4',
        'time': '15 hours ago',
        'likes': 145,
        'language': 'en',
      },
    ],
  };

  @override
  void dispose() {
    _followedComicsController.dispose();
    _readingHistoryController.dispose();
    _mostRecentController.dispose();
    _popularNewController.dispose();
    super.dispose();
  }

  void _scrollLeft(ScrollController controller) {
    final double currentOffset = controller.offset;
    final double scrollAmount = MediaQuery.of(context).size.width * 0.8;
    controller.animateTo(
      currentOffset - scrollAmount,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight(ScrollController controller) {
    final double currentOffset = controller.offset;
    final double scrollAmount = MediaQuery.of(context).size.width * 0.8;
    controller.animateTo(
      currentOffset + scrollAmount,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
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
            ],
          ),
        ),
      ),
    );
  }

  // 1. New Chapters from Followed Comics Section
  Widget _buildFollowedComicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Use Expanded to prevent overflow
              Expanded(
                child: const AppText(
                  'New Chapters from Followed Comics',
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8), // Add spacing between title and button
              Button(
                text: 'View All',
                variant: ButtonVariant.text,
                size: ButtonSize.small,
                colors: ButtonColors(
                  text: AppColors.blue[400],
                ),
                onPressed: () {
                  // Navigation to view all followed comics
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230, // Adjust based on your design
          child: Stack(
            children: [
              ListView.builder(
                controller: _followedComicsController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _followedComics.length,
                itemBuilder: (context, index) {
                  final comic = _followedComics[index];
                  return _buildMediumComicCard(comic);
                },
              ),
              // Left scroll button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildScrollButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _scrollLeft(_followedComicsController),
                  ),
                ),
              ),
              // Right scroll button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildScrollButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _scrollRight(_followedComicsController),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Reading History Section
  Widget _buildReadingHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Use Expanded to prevent overflow
              Expanded(
                child: const AppText(
                  'Reading History',
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180, // Smaller height for compact cards
          child: Stack(
            children: [
              ListView.builder(
                controller: _readingHistoryController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: _readingHistory.length,
                itemBuilder: (context, index) {
                  final comic = _readingHistory[index];
                  return _buildCompactComicCard(comic);
                },
              ),
              // Left scroll button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildScrollButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _scrollLeft(_readingHistoryController),
                  ),
                ),
              ),
              // Right scroll button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildScrollButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _scrollRight(_readingHistoryController),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Most Recent Popular Section
  Widget _buildMostRecentPopularSection() {
    List<Map<String, dynamic>> currentComics =
        _mostRecentComics[_selectedRecentTab] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Use Expanded to prevent overflow
              Expanded(
                child: const AppText(
                  'Most Recent Popular',
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8), // Add spacing between title and button
              Button(
                text: 'View All',
                variant: ButtonVariant.text,
                size: ButtonSize.small,
                colors: ButtonColors(
                  text: AppColors.blue[400],
                ),
                onPressed: () {
                  // Navigation to most recent popular
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          // Make tabs scrollable to avoid overflow
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: List.generate(
              _recentTabs.length,
              (index) => _buildTabButton(
                label: _recentTabs[index],
                isSelected: _selectedRecentTab == index,
                onTap: () {
                  setState(() {
                    _selectedRecentTab = index;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230, // Adjust based on your design
          child: Stack(
            children: [
              ListView.builder(
                controller: _mostRecentController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: currentComics.length,
                itemBuilder: (context, index) {
                  final comic = currentComics[index];
                  return _buildRankedComicCard(comic);
                },
              ),
              // Left scroll button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildScrollButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _scrollLeft(_mostRecentController),
                  ),
                ),
              ),
              // Right scroll button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildScrollButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _scrollRight(_mostRecentController),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Popular New Comics Section
  Widget _buildPopularNewComicsSection() {
    List<Map<String, dynamic>> currentComics =
        _popularNewComics[_selectedPopularTab] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Use Expanded to prevent overflow
              Expanded(
                child: const AppText(
                  'Popular New Comics',
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8), // Add spacing between title and button
              Button(
                text: 'View All',
                variant: ButtonVariant.text,
                size: ButtonSize.small,
                colors: ButtonColors(
                  text: AppColors.blue[400],
                ),
                onPressed: () {
                  // Navigation to popular new comics
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          // Make tabs scrollable to avoid overflow
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: List.generate(
              _recentTabs.length,
              (index) => _buildTabButton(
                label: _recentTabs[index],
                isSelected: _selectedPopularTab == index,
                onTap: () {
                  setState(() {
                    _selectedPopularTab = index;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 230, // Adjust based on your design
          child: Stack(
            children: [
              ListView.builder(
                controller: _popularNewController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: currentComics.length,
                itemBuilder: (context, index) {
                  final comic = currentComics[index];
                  return _buildRankedComicCard(comic);
                },
              ),
              // Left scroll button
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildScrollButton(
                    icon: Icons.chevron_left,
                    onPressed: () => _scrollLeft(_popularNewController),
                  ),
                ),
              ),
              // Right scroll button
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _buildScrollButton(
                    icon: Icons.chevron_right,
                    onPressed: () => _scrollRight(_popularNewController),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Updates Section
  Widget _buildUpdatesSection() {
    final currentComics = _updatesComics[_isHotSelected ? 'hot' : 'new'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Use Expanded for the title
              Expanded(
                child: const AppText(
                  'Updates',
                  variant: TextVariant.titleMedium,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Wrap these in a Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isHotSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isHotSelected
                            ? AppColors.red.withValues(alpha:0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // Prevent horizontal overflow
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            size: 16,
                            color: _isHotSelected
                                ? AppColors.red
                                : AppColors.neutral[400],
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            'Hot',
                            variant: TextVariant.labelMedium,
                            color: _isHotSelected
                                ? AppColors.red
                                : AppColors.neutral[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4), // Reduce spacing
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isHotSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: !_isHotSelected
                            ? AppColors.blue.withValues(alpha:0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.min, // Prevent horizontal overflow
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: !_isHotSelected
                                ? AppColors.blue
                                : AppColors.neutral[400],
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            'New',
                            variant: TextVariant.labelMedium,
                            color: !_isHotSelected
                                ? AppColors.blue
                                : AppColors.neutral[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.filter_list,
                        color: AppColors.neutral[400], size: 20),
                    padding: const EdgeInsets.all(4), // Smaller padding
                    constraints: const BoxConstraints(), // Remove constraints
                    onPressed: () {
                      // Navigate to filter settings
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52, // Adjusted ratio to provide more height
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: currentComics.length,
            itemBuilder: (context, index) {
              final comic = currentComics[index];
              return _buildUpdateComicCard(comic);
            },
          ),
        ),
      ],
    );
  } // Helper Widgets

  // Medium-sized comic card for followed comics
  Widget _buildMediumComicCard(Map<String, dynamic> comic) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: Image.asset(
                      comic['cover'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.neutral[800],
                          child: Center(
                            child: Icon(Icons.image_not_supported,
                                color: AppColors.neutral[400]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (comic['language'] != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha:0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        comic['language'] == 'en' ? '🇬🇧' : '🌐',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          AppText(
            comic['title'],
            variant: TextVariant.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[100],
          ),
          const SizedBox(height: 2),
          AppText(
            comic['time'],
            variant: TextVariant.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[400],
          ),
          const SizedBox(height: 2),
          AppText(
            comic['chapter'],
            variant: TextVariant.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[300],
          ),
        ],
      ),
    );
  }

  // Compact comic card for reading history
  Widget _buildCompactComicCard(Map<String, dynamic> comic) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: Image.asset(
                  comic['cover'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.neutral[800],
                      child: Center(
                        child: Icon(Icons.image_not_supported,
                            color: AppColors.neutral[400]),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          AppText(
            comic['title'],
            variant: TextVariant.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[100],
          ),
          AppText(
            comic['chapter'],
            variant: TextVariant.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[300],
          ),
        ],
      ),
    );
  }

  // Ranked comic card for popular sections
  Widget _buildRankedComicCard(Map<String, dynamic> comic) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AspectRatio(
                    aspectRatio: 2 / 3,
                    child: Image.asset(
                      comic['cover'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.neutral[800],
                          child: Center(
                            child: Icon(Icons.image_not_supported,
                                color: AppColors.neutral[400]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getRankColor(comic['rank']),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppText(
                        '${comic['rank']}',
                        variant: TextVariant.labelMedium,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral[50],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          AppText(
            comic['title'],
            variant: TextVariant.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[100],
          ),
          const SizedBox(height: 2),
          AppText(
            comic['chapter'],
            variant: TextVariant.labelMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[300],
          ),
        ],
      ),
    );
  }

  // Update comic card for the grid
  Widget _buildUpdateComicCard(Map<String, dynamic> comic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Use AspectRatio for consistent sizing
        AspectRatio(
          aspectRatio: 2 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  comic['cover'],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.neutral[800],
                      child: Center(
                        child: Icon(Icons.image_not_supported,
                            color: AppColors.neutral[400]),
                      ),
                    );
                  },
                ),
              ),
              if (comic['language'] != null)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.background.withValues(alpha:0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      comic['language'] == 'en' ? '🇬🇧' : '🌐',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 3), // Minimum spacing
        SizedBox(
          height: 36, // Slightly reduced height for title
          child: AppText(
            comic['title'],
            variant: TextVariant.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[100],
          ),
        ),
        SizedBox(
          height: 16, // Reduced height for chapter and likes row
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AppText(
                  comic['chapter'],
                  variant: TextVariant.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: AppColors.neutral[300],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite, size: 12, color: AppColors.neutral[400]),
                  const SizedBox(width: 2), // Minimal spacing
                  AppText(
                    '${comic['likes']}',
                    variant: TextVariant.labelSmall,
                    color: AppColors.neutral[400],
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 14, // Reduced height for time
          child: AppText(
            comic['time'],
            variant: TextVariant.labelSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            color: AppColors.neutral[500],
          ),
        ),
      ],
    );
  }

  // Tab button for time periods
  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.blue : AppColors.neutral[600]!,
              width: 1,
            ),
          ),
          child: AppText(
            label,
            variant: TextVariant.labelMedium,
            color: isSelected ? AppColors.neutral[50] : AppColors.neutral[400],
          ),
        ),
      ),
    );
  }

  // Scroll button
  Widget _buildScrollButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.neutral[800]!.withValues(alpha:0.8),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, color: AppColors.neutral[50], size: 20),
        onPressed: onPressed,
      ),
    );
  }

  // Helper function to get rank color
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.red[700]!;
      case 2:
        return AppColors.orange[700]!;
      case 3:
        return AppColors.orange[600]!;
      default:
        return AppColors.neutral[600]!;
    }
  }
}
