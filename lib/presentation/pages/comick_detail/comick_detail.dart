import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/layout/collapsible.dart';
import 'package:boilerplate/core/widgets/components/overlay/dialog.dart';
import 'package:boilerplate/core/widgets/components/overlay/popover.dart';
import 'package:boilerplate/data/local/models/comic_chapters_model.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/store/comic_detail/comic_detail_store.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart' hide showDialog;
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/components/image.dart';
import 'package:boilerplate/core/widgets/components/layout/pagination.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';

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
  final ComicDetailStore _store = getIt<ComicDetailStore>();
  final List<ReactionDisposer> _disposers = [];

  @override
  void initState() {
    super.initState();
    _loadData();

    // Setup reactions to monitor state changes
    _disposers.add(
      reaction(
        (_) => _store.followError,
        (error) {
          if (error.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void didUpdateWidget(covariant ComicDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comicId != widget.comicId) {
      _store.fetchComicDetail(widget.comicId);
    }
  }

  Future<void> _loadData() async {
    await _store.fetchComicDetail(widget.comicId);
  }

  @override
  void dispose() {
    // Clean up reactions
    for (final disposer in _disposers) {
      disposer();
    }
    super.dispose();
  }

  Future<void> _handleFollowAction() async {
    // Check if user is logged in
    if (_store.currentUser == null) {
      // Show login dialog
      final shouldLogin = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text('You need to be logged in to follow comics.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('LOGIN'),
            ),
          ],
        ),
      );

      if (!mounted) {
        return;
      }
      if (shouldLogin == true) {
        // Navigate to login screen
        context.go('/login');
      }
      return;
    }

    // Toggle follow state
    final success = await _store.toggleFollow();
    if (!mounted) {
      return;
    }
    // Show success feedback
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_store.isFollowing
              ? 'Comic added to your library'
              : 'Comic removed from your library'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _startReading() {
    if (_store.firstChapterHid != null) {
      context.goNamed(
        'comic-content',
        pathParameters: {'hid': _store.firstChapterHid!},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        if (_store.isLoadingDetail && _store.comicDetail == null) {
          return const Scaffold(
            body: Center(child: LoadingIndicator()),
          );
        }

        if (_store.detailError.isNotEmpty) {
          return Scaffold(
            body: ErrorStateWidget(
              message: _store.detailError,
              onRetry: _loadData,
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(),
          body: RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
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
                  _buildChaptersSection(),
                ],
              ),
            ),
          ),
        );
      },
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
    return Observer(
      builder: (_) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CoverImage(imageUrl: _store.coverUrl),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  _store.title,
                  variant: TextVariant.headlineLarge,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_store.alternativeTitles.isNotEmpty &&
                    _store.alternativeTitles != '-') ...[
                  const SizedBox(height: 8),
                  AppText(
                    'Alternative titles: ${_store.alternativeTitles}',
                    variant: TextVariant.bodySmall,
                    color: const Color(0xFFB0B8C5),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                _buildActionButtons(),
                const SizedBox(height: 14),
                _buildStatsRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Observer(
      builder: (_) {
        final bool isLoading = _store.isFollowingLoading;
        final bool isFollowing = _store.isFollowing;

        debugPrint("Building action buttons - isFollowingLoading: $isLoading");

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
              onPressed: _startReading,
            ),
            const SizedBox(height: 10),
            Button(
              text: isFollowing ? 'Following' : 'Follow',
              leftIcon: isFollowing ? Icons.bookmark : Icons.bookmark_border,
              variant:
                  isFollowing ? ButtonVariant.primary : ButtonVariant.neutral,
              shape: ButtonShape.fullRounded,
              loading: ButtonLoadingConfig(isLoading: isLoading),
              layout: const ButtonLayout(
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                borderRadius: BorderRadius.all(Radius.circular(22)),
                expanded: true,
              ),
              onPressed: isLoading ? null : _handleFollowAction,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsRow() {
    return Observer(
      builder: (_) => Row(
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFFEAD1A), size: 20),
          const SizedBox(width: 4),
          AppText(
            _store.rating?.toString() ?? '0',
            variant: TextVariant.bodyMedium,
            color: Colors.white,
          ),
          const SizedBox(width: 14),
          const Icon(Icons.thumb_up_outlined,
              color: Color(0xFFB0B8C5), size: 20),
          const SizedBox(width: 4),
          AppText(
            _store.views?.toString() ?? '0',
            variant: TextVariant.bodyMedium,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Observer(
      builder: (_) => Card(
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
                text: _store.description,
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
                expandCollapsePrefix: const Icon(Icons.expand_more,
                    color: Colors.white, size: 18),
                expandCollapseSuffix: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMoreInfoSection() {
    return Observer(
      builder: (_) {
        final moreInfo = [
          {'label': 'Author', 'value': _store.author ?? '-'},
          {
            'label': 'Native Lang',
            'value': _store.alternativeLangNative ?? '-'
          },
          {'label': 'Artists', 'value': _store.artistsText},
          {'label': 'Status', 'value': _store.statusText},
          {'label': 'Year', 'value': _store.year},
          {'label': 'Demographic', 'value': _store.demographic.toString()},
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagsSection() {
    return Observer(
      builder: (_) {
        if (_store.genres.isEmpty) {
          return const SizedBox.shrink();
        }

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
              children: _store.genres
                  .where((genre) => genre.isNotEmpty)
                  .map((tag) => _TagChip(tag: tag))
                  .toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChaptersSection() {
    return Observer(
      builder: (_) => ChaptersSection(
        chapters: _store.chapters,
        isLoading: _store.isLoadingChapters,
        currentPage: _store.currentPage,
        totalPages: _store.totalPages,
        onPageChanged: (page) => _store.firstChapterHid != null
            ? _store.goToPage(_store.firstChapterHid!, page)
            : null,
      ),
    );
  }
}

class _CoverImage extends StatelessWidget {
  final String imageUrl;

  const _CoverImage({required this.imageUrl});

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
              imageUrl.isNotEmpty
                  ? imageUrl
                  : 'https://placehold.co/108x144/png',
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
                    imageUrl.isNotEmpty
                        ? imageUrl
                        : 'https://placehold.co/600x900/png',
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

// Other classes remain the same
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
  final List<ChapterDetailModel> chapters;
  final bool isLoading;
  final int currentPage;
  final int totalPages;
  final Function(int)? onPageChanged;

  const ChaptersSection({
    super.key,
    required this.chapters,
    this.isLoading = false,
    this.currentPage = 1,
    this.totalPages = 1,
    required this.onPageChanged,
  });

  @override
  State<ChaptersSection> createState() => _ChaptersSectionState();
}

class _ChaptersSectionState extends State<ChaptersSection> {
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
            if (widget.chapters.isNotEmpty && widget.totalPages > 1) ...[
              const SizedBox(height: 10),
              Center(
                child: Pagination(
                  currentPage: widget.currentPage,
                  totalPages: widget.totalPages,
                  onPageChanged: widget.onPageChanged ?? (_) {},
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
          ],
        ),
      ),
    );
  }

  Widget _buildChaptersHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: const [
          AppText(
            'Chapters',
            variant: TextVariant.headlineSmall,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          Spacer(),
        ],
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
    if (widget.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.chapters.isEmpty) {
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
      children: List.generate(
        widget.chapters.length,
        (index) => _ChapterRow(
          chapter: widget.chapters[index],
          isEven: index % 2 == 0,
        ),
      ),
    );
  }
}

class _ChapterRow extends StatelessWidget {
  final ChapterDetailModel chapter;
  final bool isEven;

  const _ChapterRow({
    required this.chapter,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (chapter.hid != null) {
          context.goNamed(
            'comic-content',
            pathParameters: {'hid': chapter.hid!},
          );
        }
      },
      child: Container(
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
                'Ch. ${chapter.chap}',
                variant: TextVariant.bodyMedium,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              width: 80,
              child: AppText(
                _formatDate(chapter.createdAt),
                variant: TextVariant.bodySmall,
                color: AppColors.neutral[300],
              ),
            ),
            Expanded(
              child: AppText(
                chapter.groupName?.join(", ") ?? "-",
                variant: TextVariant.bodySmall,
                color: AppColors.neutral[300],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    try {
      if (dateString == null) {
        return 'Unknown';
      }

      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} min${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown';
    }
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.destructive,
            ),
            const SizedBox(height: 16),
            AppText(
              'Something went wrong',
              variant: TextVariant.headlineMedium,
              color: Colors.white,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              message,
              variant: TextVariant.bodyMedium,
              color: AppColors.neutral[300],
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Button(
              text: 'Try Again',
              variant: ButtonVariant.primary,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
