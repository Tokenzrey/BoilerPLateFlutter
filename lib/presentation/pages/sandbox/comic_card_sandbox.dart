import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/comic_card.dart';
import 'package:boilerplate/core/widgets/components/display/comic_search_result_item.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';

class ComicCardSandbox extends StatefulWidget {
  const ComicCardSandbox({super.key});

  @override
  State<ComicCardSandbox> createState() => _ComicCardSandboxState();
}

class _ComicCardSandboxState extends State<ComicCardSandbox> {
  // Mock data for comic cards/search results
  final List<Map<String, dynamic>> _comicData = [
    {
      'title': 'One Piece',
      'altTitle': ['ワンピース', 'OP'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/81s8xJUzWGL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 1079',
      'updated': '3 hours ago',
      'scanlator': 'VIZ Media',
      'likes': '24K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': true
    },
    {
      'title': 'Jujutsu Kaisen',
      'altTitle': ['呪術廻戦', 'JJK'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/81TmHlRleJL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 226',
      'updated': '1 day ago',
      'scanlator': 'Shueisha',
      'likes': '18K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': false
    },
    {
      'title': 'Solo Leveling',
      'altTitle': ['나 혼자만 레벨업', 'Level Up Alone'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/81oMQeUFJ2L._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 179',
      'updated': '2 days ago',
      'scanlator': 'D&C Webtoon',
      'likes': '26K',
      'countryCodeUrl': 'https://flagcdn.com/w80/kr.png',
      'isBookmarked': true
    },
    {
      'title': 'Chainsaw Man',
      'altTitle': ['チェンソーマン'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/81rJHYQgWYL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 132',
      'updated': '5 hours ago',
      'scanlator': 'MangaPlus',
      'likes': '31K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': false
    },
    {
      'title': 'Black Clover',
      'altTitle': ['ブラッククローバー'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/91Vn5ZhR7xL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 368',
      'updated': '4 days ago',
      'scanlator': 'VIZ Media',
      'likes': '15K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': true
    },
    {
      'title': 'Dragon Ball Super',
      'altTitle': ['ドラゴンボール超'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/71RfN5yKYpL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 92',
      'updated': '1 week ago',
      'scanlator': 'MangaPlus',
      'likes': '42K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': false
    },
    {
      'title': 'Hunter x Hunter',
      'altTitle': ['ハンター×ハンター', 'HxH'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/81Gdpl6mT-L._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 390',
      'updated': '3 months ago',
      'scanlator': 'VIZ Media',
      'likes': '28K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': true
    },
    {
      'title': 'The Beginning After The End',
      'altTitle': ['TBATE'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/91adZ7eKNsL._AC_UF1000,1000_QL80_.jpg',
      'chapter': 'Chapter 172',
      'updated': '6 hours ago',
      'scanlator': 'TurtleMe',
      'likes': '19K',
      'countryCodeUrl': 'https://flagcdn.com/w80/us.png',
      'isBookmarked': true
    },
    {
      'title': 'Tower of God',
      'altTitle': ['신의 탑', 'Kami no Tou'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/71t0qJv5SuL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 594',
      'updated': '12 hours ago',
      'scanlator': 'LINE Webtoon',
      'likes': '21K',
      'countryCodeUrl': 'https://flagcdn.com/w80/kr.png',
      'isBookmarked': false
    },
    {
      'title': 'One Punch Man',
      'altTitle': ['ワンパンマン', 'OPM'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/81VdCSQCteL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 181',
      'updated': '2 weeks ago',
      'scanlator': 'VIZ Media',
      'likes': '33K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': true
    },
    {
      'title': 'Bleach',
      'altTitle': ['ブリーチ'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/71T4jTj0LFL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 686',
      'updated': 'Completed',
      'scanlator': 'VIZ Media',
      'likes': '40K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': false
    },
    {
      'title': 'Omniscient Reader\'s Viewpoint',
      'altTitle': ['전지적 독자 시점', 'ORV'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/71OVFhKFzNL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 147',
      'updated': '1 day ago',
      'scanlator': 'Flame Scans',
      'likes': '16K',
      'countryCodeUrl': 'https://flagcdn.com/w80/kr.png',
      'isBookmarked': true
    },
    {
      'title': 'Spy x Family',
      'altTitle': ['スパイファミリー'],
      'imageUrl':
          'https://m.media-amazon.com/images/I/71M2h+aFzlL._AC_UF894,1000_QL80_.jpg',
      'chapter': 'Chapter 84',
      'updated': '3 days ago',
      'scanlator': 'MangaPlus',
      'likes': '27K',
      'countryCodeUrl': 'https://flagcdn.com/w80/jp.png',
      'isBookmarked': false
    },
  ];

  int _bookmarkClickCount = 0;
  String _lastClickedComic = 'None';
  String _lastClickedArea = 'None';

  // For search result demo
  String _searchKeyword = "man";
  String _lastSearchClicked = "None";
  String _lastSearchClickedArea = "None";

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = _searchKeyword;
    _searchController.addListener(() {
      if (_searchKeyword != _searchController.text) {
        setState(() {
          _searchKeyword = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusSection(),
          const Divider(height: 32),
          AppText(
            'Comic Card Examples',
            variant: TextVariant.headlineSmall,
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              double maxWidth = constraints.maxWidth;
              if (maxWidth >= 1200) {
                crossAxisCount = 3;
              } else if (maxWidth >= 800) {
                crossAxisCount = 2;
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 0.54,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _comicData.length,
                itemBuilder: (context, index) {
                  final comic = _comicData[index];
                  return _buildComicCardVariant(comic, index);
                },
              );
            },
          ),
          const SizedBox(height: 36),
          AppText(
            'Comic Search Result List',
            variant: TextVariant.headlineSmall,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _buildSearchStatusSection(),
          _buildSearchBar(),
          const SizedBox(height: 8),
          ..._buildComicSearchResults(),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Interaction Tracking',
            variant: TextVariant.titleMedium,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Last Clicked Comic: $_lastClickedComic',
                      variant: TextVariant.bodyMedium,
                      color: AppColors.foreground,
                    ),
                    AppText(
                      'Last Clicked Area: $_lastClickedArea',
                      variant: TextVariant.bodyMedium,
                      color: AppColors.foreground,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Bookmark Click Count: $_bookmarkClickCount',
                      variant: TextVariant.bodyMedium,
                      color: AppColors.foreground,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComicCardVariant(Map<String, dynamic> comic, int index) {
    switch (index % 3) {
      case 0:
        return ComicCard(
          title: comic['title'],
          imageUrl: comic['imageUrl'],
          chapter: comic['chapter'],
          updated: comic['updated'],
          scanlator: comic['scanlator'],
          likes: comic['likes'],
          countryCodeUrl: comic['countryCodeUrl'],
          isBookmarked: comic['isBookmarked'],
          onTap: () => _updateClickedComic(comic['title'], 'Card'),
          onImageTap: () => _updateClickedComic(comic['title'], 'Image'),
          onTitleTap: () => _updateClickedComic(comic['title'], 'Title'),
          onChapterTap: () => _updateClickedComic(comic['title'], 'Chapter'),
          onDetailTap: () => _updateClickedComic(comic['title'], 'Details'),
          onBookmarkChanged: (isBookmarked) {
            setState(() {
              comic['isBookmarked'] = isBookmarked;
              _bookmarkClickCount++;
              _lastClickedComic = comic['title'];
              _lastClickedArea = 'Bookmark';
            });
          },
        );
      case 1:
        return ComicCard(
          title: comic['title'],
          imageUrl: comic['imageUrl'],
          chapter: comic['chapter'],
          updated: comic['updated'],
          scanlator: comic['scanlator'],
          likes: comic['likes'],
          countryCodeUrl: comic['countryCodeUrl'],
          isBookmarked: comic['isBookmarked'],
          onTap: () => _updateClickedComic(comic['title'], 'Card'),
          onTitleTap: () => _updateClickedComic(comic['title'], 'Title'),
          onBookmarkChanged: (isBookmarked) {
            setState(() {
              comic['isBookmarked'] = isBookmarked;
              _bookmarkClickCount++;
            });
          },
          style: ComicCardStyle(
            backgroundColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            hoverBoxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
            titleStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            chapterStyle: TextStyle(
              fontSize: 12,
              color: AppColors.secondary,
            ),
            bookmarkActiveColor: AppColors.accent,
          ),
        );
      case 2:
        return ComicCard(
          title: comic['title'],
          imageUrl: comic['imageUrl'],
          chapter: comic['chapter'],
          updated: comic['updated'],
          scanlator: comic['scanlator'],
          likes: comic['likes'],
          countryCodeUrl: comic['countryCodeUrl'],
          isBookmarked: comic['isBookmarked'],
          onlyTitle: true,
          onTap: () => _updateClickedComic(comic['title'], 'Card'),
          onBookmarkChanged: (isBookmarked) {
            setState(() {
              comic['isBookmarked'] = isBookmarked;
              _bookmarkClickCount++;
            });
          },
          style: ComicCardStyle(
            backgroundColor: AppColors.background,
            borderRadius: BorderRadius.circular(8),
            imageBorderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.foreground,
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        );
      default:
        return ComicCard(
          title: comic['title'],
          imageUrl: comic['imageUrl'],
          chapter: comic['chapter'],
          updated: comic['updated'],
          scanlator: comic['scanlator'],
          likes: comic['likes'],
          countryCodeUrl: comic['countryCodeUrl'],
          isBookmarked: comic['isBookmarked'],
        );
    }
  }

  void _updateClickedComic(String title, String area) {
    setState(() {
      _lastClickedComic = title;
      _lastClickedArea = area;
    });
  }

  Widget _buildSearchStatusSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              'Last Search Clicked: $_lastSearchClicked',
              variant: TextVariant.bodySmall,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: AppText(
              'Area: $_lastSearchClickedArea',
              variant: TextVariant.bodySmall,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        AppText(
          "Search Keyword:",
          variant: TextVariant.bodySmall,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              hintText: "e.g. man, op, hunter",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.primary, width: 1),
              ),
              isDense: true,
            ),
            controller: _searchController,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildComicSearchResults() {
    // Filter by search keyword on title or altTitle
    final kw = _searchKeyword.trim().toLowerCase();
    final filtered = kw.isEmpty
        ? _comicData
        : _comicData.where((comic) {
            final inTitle =
                comic['title'].toString().toLowerCase().contains(kw);
            final inAlt = (comic['altTitle'] as List?)
                    ?.any((alt) => alt.toString().toLowerCase().contains(kw)) ??
                false;
            return inTitle || inAlt;
          }).toList();

    if (filtered.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: AppText(
            'No results found.',
            variant: TextVariant.bodyLarge,
            color: AppColors.destructive,
          ),
        )
      ];
    }

    return [
      ...filtered.map((comic) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: ComicSearchResult(
              title: comic['title'],
              altTitle: List<String>.from(comic['altTitle'] ?? []),
              imageUrl: comic['imageUrl'],
              searchKeyword: _searchKeyword,
              style: ComicSearchResultStyle(
                backgroundColor: Colors.white,
                hoverBackgroundColor: AppColors.primary.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(7),
                padding: const EdgeInsets.all(12),
                titleStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                subtitleStyle: const TextStyle(fontSize: 13),
                highlightBackgroundColor:
                    AppColors.warning.withValues(alpha: 0.7),
                highlightTextColor: Colors.black,
                borderColor: AppColors.primary,
                borderWidth: 0.7,
                imageBorderRadius: BorderRadius.circular(6),
              ),
              onTap: () => setState(() {
                _lastSearchClicked = comic['title'];
                _lastSearchClickedArea = 'Row';
              }),
              onThumbnailTap: () => setState(() {
                _lastSearchClicked = comic['title'];
                _lastSearchClickedArea = 'Thumbnail';
              }),
              onTitleTap: () => setState(() {
                _lastSearchClicked = comic['title'];
                _lastSearchClickedArea = 'Title';
              }),
              onAltTitleTap: () => setState(() {
                _lastSearchClicked = comic['title'];
                _lastSearchClickedArea = 'AltTitle';
              }),
            ),
          ))
    ];
  }
}
