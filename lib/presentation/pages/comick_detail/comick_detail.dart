import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/layout/collapsible.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
import 'package:boilerplate/core/widgets/components/overlay/overlay.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart' hide showDialog;
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/image.dart';
import 'package:boilerplate/core/widgets/components/layout/pagination.dart';

class ComicDetailScreen extends StatefulWidget {
  final String comicId;

  const ComicDetailScreen({
    super.key,
    required this.comicId,
  });

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  bool _isFollowing = false;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _tags = [
    'Action',
    'Fantasy',
    'Overpowered',
    'Magic',
    'Reincarnation',
    'Martial Arts',
    'Magic System',
    'Dungeons',
    'Strong Male Lead',
    'Adventure',
    'Returned Player'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleFollow() {
    setState(() {
      _isFollowing = !_isFollowing;
    });
  }

  void _startReading(int chap) {
    debugPrint('Start reading...');
    debugPrint(widget.comicId);
    context.goNamed('comic-content', pathParameters: {
        'slug': widget.comicId,
        'hid': widget.comicId,
        'chap': chap.toString(),
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            _buildDescriptionSection(),
            const SizedBox(height: 20),
            _buildMoreInfoSection(),
            const SizedBox(height: 22),
            _buildTagsSection(),
            const SizedBox(height: 22),
            const ChaptersSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.subtleBackground,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white),
            onPressed: () => context.push('/home'),
            tooltip: "Back",
            splashRadius: 22,
          ),
          const Spacer(),
          const AppText(
            'Comic Details',
            color: Colors.white,
            variant: TextVariant.titleLarge,
            fontWeight: FontWeight.w700,
            maxLines: 1,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CoverImage(),
        const SizedBox(width: 18),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'The Sword God From the Destroyed World',
                variant: TextVariant.headlineLarge,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              const AppText(
                'Alternative titles: 세계가 멸망한 검신',
                variant: TextVariant.bodySmall,
                color: Color(0xFFB0B8C5),
              ),
              const SizedBox(height: 12),
              _buildActionButtons(),
              const SizedBox(height: 14),
              _buildStatsRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Button(
          text: 'Start Reading',
          leftIcon: Icons.play_arrow,
          variant: ButtonVariant.primary,
          shape: ButtonShape.fullRounded,
          layout: const ButtonLayout(
            padding: EdgeInsets.symmetric(vertical: 12),
            borderRadius: BorderRadius.all(Radius.circular(24)),
            expanded: true,
          ),
          onPressed: () => _startReading(1),
        ),
        const SizedBox(height: 10),
        Button(
          text: _isFollowing ? 'Following' : 'Follow',
          leftIcon: _isFollowing ? Icons.bookmark : Icons.bookmark_border,
          variant: ButtonVariant.neutral,
          shape: ButtonShape.fullRounded,
          layout: const ButtonLayout(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
            borderRadius: BorderRadius.all(Radius.circular(22)),
            expanded: true,
          ),
          onPressed: _toggleFollow,
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        const Icon(Icons.star_rounded, color: Color(0xFFFEAD1A), size: 20),
        const SizedBox(width: 4),
        const AppText(
          '4.73',
          variant: TextVariant.bodyMedium,
          color: Colors.white,
        ),
        const SizedBox(width: 14),
        const Icon(Icons.visibility_rounded,
            color: Color(0xFFB0B8C5), size: 20),
        const SizedBox(width: 4),
        const AppText(
          '51,941',
          variant: TextVariant.bodyMedium,
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      color: AppColors.subtleBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Description',
              variant: TextVariant.headlineMedium,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 10),
            AppExpandableText(
              text: "The world was destroyed, consumed by death and despair. "
                  "And in the midst of it all, one man fought to the bitter end — the Sword God, fallen. "
                  "But then, as if guided by fate, a door to another world opened. This time... it was faith — a world he hadn't yet explored.",
              maxLines: 3,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
              expandText: 'Read more',
              collapseText: 'Read less',
              initialExpanded: false,
              theme: const CollapsibleTheme(
                animationDuration: Duration(milliseconds: 300),
                animationCurve: Curves.easeInOutCubic,
                textButtonStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              expandCollapsePrefix:
                  const Icon(Icons.expand_more, color: Colors.white, size: 18),
              expandCollapseSuffix: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreInfoSection() {
    final moreInfo = [
      {'label': 'Author', 'value': '정지훈'},
      {'label': 'Status', 'value': 'Ongoing'},
      {'label': 'Genres', 'value': 'Fantasy, Action'},
      {'label': 'Type', 'value': 'Webtoon'},
      {'label': 'Source', 'value': 'Kakao Webtoon'},
      {'label': 'Published', 'value': '2024'},
    ];

    return Card(
      color: AppColors.subtleBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3.4,
            crossAxisSpacing: 14,
            mainAxisSpacing: 6,
          ),
          itemCount: moreInfo.length,
          itemBuilder: (context, index) {
            final item = moreInfo[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  item['label']!,
                  variant: TextVariant.bodySmall,
                  color: AppColors.neutral[300],
                ),
                const SizedBox(height: 3),
                AppText(
                  item['value']!,
                  variant: TextVariant.bodyMedium,
                  color: Colors.white,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Tags',
          variant: TextVariant.headlineSmall,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _tags.map((tag) => _TagChip(tag: tag)).toList(),
        ),
      ],
    );
  }
}

class _CoverImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCoverPreviewDialog(context),
      child: Hero(
        tag: 'cover-image',
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AppImage.network(
              'https://n14.mbxma.org/thumb/W600/ampi/d20/d207b824a6a501f5267eb3aaeb301a6642f279a7_400_600_104898.jpeg',
              width: 108,
              height: 144,
              fit: BoxFit.cover,
              errorWidget: Container(
                color: AppColors.subtleBackground,
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 38,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCoverPreviewDialog(BuildContext context) {
    showDialog(
      context: context,
      dialogElevation: 0,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      dialogBorderRadius: BorderRadius.circular(24),
      dialogSurfaceBlur: 1.5,
      builder: (context) => StandardDialog(
        titleWidget: const SizedBox.shrink(),
        content: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Hero(
                tag: 'cover-image',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AppImage.network(
                    'https://n14.mbxma.org/thumb/W600/ampi/d20/d207b824a6a501f5267eb3aaeb301a6642f279a7_400_600_104898.jpeg',
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: 410,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      color: AppColors.subtleBackground,
                      height: 410,
                      width: double.infinity,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white54,
                          size: 60,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 18,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const AppText(
                      'Cover Preview',
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      variant: TextVariant.titleLarge,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.transparent,
                  child: Button(
                    iconOnly: true,
                    leftIcon: Icons.close_rounded,
                    shape: ButtonShape.fullRounded,
                    size: ButtonSize.small,
                    density: ButtonDensity.iconComfortable,
                    variant: ButtonVariant.light,
                    colors: ButtonColors(
                      background: Colors.black.withValues(alpha: 0.6),
                      text: Colors.white,
                      hover: Colors.black.withValues(alpha: 0.8),
                    ),
                    onPressed: () => closeOverlayWithResult(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: const [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [],
          ),
        ],
      ),
      animationType: DialogAnimationType.scale,
      enterAnimations: [
        PopoverAnimationType.fadeIn,
        PopoverAnimationType.scale,
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;

  const _TagChip({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      child: AppText(
        tag,
        variant: TextVariant.labelMedium,
        color: AppColors.primary,
      ),
    );
  }
}

class ChaptersSection extends StatefulWidget {
  const ChaptersSection({super.key});

  @override
  State<ChaptersSection> createState() => _ChaptersSectionState();
}

class _ChaptersSectionState extends State<ChaptersSection> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedLanguage = 'English';
  final LayerLink _languagePopoverLink = LayerLink();
  int _currentPage = 1;
  final int _chaptersPerPage = 10;
  late int _totalPages;
  late List<Map<String, dynamic>> _allChapters;
  List<Map<String, dynamic>> _filteredChapters = [];

  @override
  void initState() {
    super.initState();
    _initializeChapters();
  }

  void _initializeChapters() {
    _allChapters = List.generate(45, (index) {
      final chapterNum = 45 - index;
      return {
        'number': chapterNum,
        'uploaded': '${(index % 6) + 1} day${(index % 6) == 0 ? '' : 's'} ago',
        'group': 'MangaScans',
      };
    });
    _filteredChapters = List.from(_allChapters);
    _updateTotalPages();
  }

  void _updateTotalPages() {
    _totalPages =
        (_filteredChapters.length / _chaptersPerPage).ceil().clamp(1, 999);
    if (_currentPage > _totalPages) _currentPage = _totalPages;
  }

  List<Map<String, dynamic>> get _pagedChapters {
    final start = (_currentPage - 1) * _chaptersPerPage;
    final end =
        (_currentPage * _chaptersPerPage).clamp(0, _filteredChapters.length);
    return _filteredChapters.sublist(start, end);
  }

  void _onPageChange(int newPage) {
    setState(() => _currentPage = newPage);
  }

  void _onGotoChapter(String val) {
    final chapNum = int.tryParse(val);
    if (chapNum == null) {
      setState(() {
        _filteredChapters = List.from(_allChapters);
        _updateTotalPages();
        _currentPage = 1;
      });
      return;
    }
    final idx = _allChapters.indexWhere((c) => c['number'] == chapNum);
    if (idx != -1) {
      setState(() {
        _filteredChapters = [_allChapters[idx]];
        _updateTotalPages();
        _currentPage = 1;
      });
    } else {
      setState(() {
        _filteredChapters = [];
        _updateTotalPages();
        _currentPage = 1;
      });
    }
  }

  void _onGotoFieldChanged(String val) {
    if (val.isEmpty) {
      setState(() {
        _filteredChapters = List.from(_allChapters);
        _updateTotalPages();
        _currentPage = 1;
      });
    }
  }

  void _onLanguageChange(String lang) {
    setState(() => _selectedLanguage = lang);
  }

  void _showLanguagePopover() {
    showPopover(
      context: context,
      layerLink: _languagePopoverLink,
      alignment: Alignment.bottomRight,
      anchorAlignment: Alignment.topRight,
      offset: const Offset(0, -8),
      barrierDismissable: true,
      modal: false,
      builder: (popoverCtx) => _LanguagePopover(
        selectedLanguage: _selectedLanguage,
        onLanguageSelected: (lang) {
          _onLanguageChange(lang);
          closeOverlay(popoverCtx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card.withValues(alpha: 0.97),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildChaptersHeader(),
            const SizedBox(height: 8),
            _buildTableHeader(),
            const SizedBox(height: 4),
            _buildChaptersList(),
            const SizedBox(height: 10),
            Center(
              child: Pagination(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onPageChanged: _onPageChange,
                theme: PaginationTheme.custom(
                  primaryColor: AppColors.primary,
                  textColor: AppColors.neutral,
                  backgroundColor: AppColors.card,
                  borderRadius: const BorderRadius.all(Radius.circular(7)),
                ),
                size: PaginationSize.small,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChaptersHeader() {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 0),
      child: Row(
        children: [
          AppText(
            'Chapters',
            variant: TextVariant.headlineSmall,
            color: AppColors.neutral,
            fontWeight: FontWeight.bold,
          ),
          const Spacer(),
          _buildGotoChapterField(),
          _buildLanguageSelector(),
        ],
      ),
    );
  }

  Widget _buildGotoChapterField() {
    return Container(
      width: 110,
      height: 36,
      margin: const EdgeInsets.only(right: 6),
      child: TextField(
        controller: _searchController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.go,
        onChanged: _onGotoFieldChanged,
        onSubmitted: _onGotoChapter,
        decoration: InputDecoration(
          hintText: 'Goto chap',
          hintStyle: TextStyle(
            color: AppColors.neutral[400],
            fontSize: 12.5,
          ),
          filled: true,
          fillColor: AppColors.card.withValues(alpha: 0.93),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        style: TextStyle(color: AppColors.neutral),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return CompositedTransformTarget(
      link: _languagePopoverLink,
      child: GestureDetector(
        onTap: _showLanguagePopover,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              const Icon(Icons.language, color: AppColors.neutral, size: 17),
              const SizedBox(width: 4),
              AppText(
                _selectedLanguage.substring(0, 2).toUpperCase(),
                variant: TextVariant.labelMedium,
                color: AppColors.neutral,
              ),
              const Icon(Icons.arrow_drop_down,
                  color: AppColors.neutral, size: 17),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: AppText(
              'Chap',
              variant: TextVariant.labelMedium,
              color: AppColors.neutral[300],
            ),
          ),
          SizedBox(
            width: 80,
            child: AppText(
              'Uploaded',
              variant: TextVariant.labelMedium,
              color: AppColors.neutral[300],
            ),
          ),
          Expanded(
            child: AppText(
              'Group',
              variant: TextVariant.labelMedium,
              color: AppColors.neutral[300],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChaptersList() {
    if (_pagedChapters.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(18),
        child: Center(
          child: AppText(
            'No chapters found.',
            color: AppColors.neutral[300],
            variant: TextVariant.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      children: _pagedChapters.map((chapter) {
        final idx = _pagedChapters.indexOf(chapter);
        final isEven = idx % 2 == 0;
        return _ChapterRow(
          chapter: chapter,
          isEven: isEven,
        );
      }).toList(),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final bool isEven;

  const _ChapterRow({
    required this.chapter,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isEven
            ? AppColors.background.withValues(alpha: 0.97)
            : AppColors.card.withValues(alpha: 0.91),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: AppText(
              'Ch. ${chapter['number']}',
              variant: TextVariant.bodyMedium,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(
            width: 80,
            child: AppText(
              chapter['uploaded'] as String,
              variant: TextVariant.bodySmall,
              color: AppColors.neutral[300],
            ),
          ),
          Expanded(
            child: AppText(
              chapter['group'] as String,
              variant: TextVariant.bodySmall,
              color: AppColors.neutral[300],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagePopover extends StatelessWidget {
  final String selectedLanguage;
  final Function(String) onLanguageSelected;

  const _LanguagePopover({
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withValues(alpha: 0.09),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageMenuItem(context, 'English'),
            _buildLanguageMenuItem(context, 'Korean'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageMenuItem(BuildContext context, String lang) {
    return InkWell(
      onTap: () => onLanguageSelected(lang),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: selectedLanguage == lang
            ? AppColors.primary.withValues(alpha: 0.11)
            : Colors.transparent,
        child: Row(
          children: [
            if (selectedLanguage == lang)
              const Icon(Icons.check, color: Colors.green, size: 17)
            else
              const SizedBox(width: 17),
            const SizedBox(width: 6),
            AppText(
              lang,
              variant: TextVariant.labelMedium,
              color: AppColors.neutral[300],
            ),
          ],
        ),
      ),
    );
  }
}
