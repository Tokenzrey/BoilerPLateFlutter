import 'package:flutter/material.dart';
import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:boilerplate/core/widgets/components/display/comic_search_result_item.dart';

class SearchModal extends StatefulWidget {
  const SearchModal({super.key});

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Map<String, dynamic>> items = [
    {
      'title': 'The Infinite Mage',
      'altTitle': ['Infinite Wizard', 'Infinite Mage'],
      'image':
          'https://n14.mbxma.org/thumb/W600/ampi/d20/d207b824a6a501f5267eb3aaeb301a6642f279a7_400_600_104898.jpeg',
    },
    {
      'title': 'Incorrect White Mage',
      'altTitle': ['Incorrect White Mage'],
      'image': 'https://meo.comick.pictures/7XyGe.jpg',
    },
  ];

  List<ComicSearchResult> searchResult = [];
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward();
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => searchResult.clear());
      return;
    }
    final searchLower = query.toLowerCase();

    final filterResult = items.where((item) {
      final title = item['title']?.toLowerCase() ?? '';
      final altTitles = item['altTitle'] as List<String>? ?? [];
      final hasMatchInAltTitle =
          altTitles.any((alt) => alt.toLowerCase().contains(searchLower));
      return title.contains(searchLower) || hasMatchInAltTitle;
    }).toList();

    setState(() {
      searchResult = filterResult
          .map((comic) => ComicSearchResult(
                title: comic['title'] ?? '',
                altTitle: comic['altTitle'] ?? [comic['title']],
                imageUrl: comic['image'] ?? '',
                searchKeyword: query,
              ))
          .toList();
    });
  }

  void _handleSubmit(String query) {
    Navigator.of(context).pop();
    AppRouter.push(context, '/search?q=$query');
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(22);

    final screenSize = MediaQuery.of(context).size;
    final width = screenSize.width * 0.9;
    final height = screenSize.height * 0.4;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: width,
          constraints: BoxConstraints(
            maxWidth: width,
            maxHeight: height,
            minWidth: 240,
          ),
          decoration: BoxDecoration(
            color: AppColors.card.withValues(alpha: 0.99),
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 20,
                spreadRadius: 4,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  _searchField(context),
                  if (_textController.text.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        icon: Icon(Icons.close_rounded,
                            color: AppColors.neutral[400]),
                        splashRadius: 18,
                        onPressed: () {
                          setState(() {
                            _textController.clear();
                            searchResult.clear();
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                fit: FlexFit.loose,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  child: searchResult.isEmpty
                      ? _emptyState(_textController.text)
                      : ListView.separated(
                          shrinkWrap: true,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: searchResult.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, idx) => searchResult[idx],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _searchField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.neutral[850],
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 3,
            offset: const Offset(0, 1.2),
          ),
        ],
      ),
      child: TextField(
        autofocus: true,
        focusNode: _focusNode,
        controller: _textController,
        style: TextStyle(
            fontSize: 17,
            color: AppColors.neutral[800],
            fontWeight: FontWeight.w500),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 23),
          hintText: "Search comics...",
          hintStyle: TextStyle(
            color: AppColors.neutral[400],
            fontWeight: FontWeight.w400,
            fontSize: 16,
            letterSpacing: 0.1,
          ),
          border: InputBorder.none,
        ),
        onChanged: _performSearch,
        onSubmitted: _handleSubmit,
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _emptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                color: AppColors.neutral[600], size: 38),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? "Start typing to search comics"
                  : "No results for \"$query\"",
              style: TextStyle(
                color: AppColors.neutral[400],
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animController.dispose();
    super.dispose();
  }
}
