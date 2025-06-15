import 'package:boilerplate/presentation/pages/profile/profile_tab.dart';
import 'package:boilerplate/presentation/pages/profile/setting_tab.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/utils/routes/routes.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Widget> _tabViews = const [
    KeepAlivePage(child: ProfileTab()),
    KeepAlivePage(child: SettingsTab()),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _currentIndex = _tabController.index;
      });
      _pageController.animateToPage(
        _tabController.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/home'),
          tooltip: 'Back to Home',
        ),
        title: const AppText(
          'Profile Settings',
          variant: TextVariant.headlineSmall,
          color: Colors.white,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.neutral.shade800,
                  width: 1.0,
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                _buildTab(0, Icons.person, 'Profile'),
                _buildTab(1, Icons.settings, 'Settings'),
              ],
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.neutral.shade400,
              dividerColor: Colors.transparent,
            ),
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) {
          if (_currentIndex != index) {
            setState(() {
              _currentIndex = index;
              _tabController.animateTo(index, duration: Duration.zero);
            });
          }
        },
        children: _tabViews,
      ),
    );
  }

  Widget _buildTab(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return Tab(
      height: 48,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primary : AppColors.neutral.shade400,
            size: 20,
          ),
          const SizedBox(width: 8),
          AppText(
            label,
            variant: TextVariant.labelLarge,
            color: isSelected ? AppColors.primary : AppColors.neutral.shade400,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ],
      ),
    );
  }
}

/// Wrapper to keep tab pages alive when switching tabs
class KeepAlivePage extends StatefulWidget {
  final Widget child;

  const KeepAlivePage({super.key, required this.child});

  @override
  State<KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
