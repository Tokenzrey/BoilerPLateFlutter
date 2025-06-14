import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/utils/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/display/comic_search_result_item.dart';

class SearchModal extends StatefulWidget {

  const SearchModal({
    super.key,
  });

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, dynamic>> items = [
    {
      'title': 'The Infinite Mage',
      'altTitle': ['Infinite Wizard', 'Infinite Mage'],
      'image': 'https://n14.mbxma.org/thumb/W600/ampi/d20/d207b824a6a501f5267eb3aaeb301a6642f279a7_400_600_104898.jpeg',
    },
    {
      'title': 'Incorrect White Mage',
      'altTitle': ['Incorrect White Mage'],
      'image': 'https://meo.comick.pictures/7XyGe.jpg',
    },
  ];

  List<ComicSearchResult> searchResult = [];


  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        searchResult.clear();
      });
      return;
    }
    final searchLower = query.toLowerCase();

    List<Map<String,dynamic>> filterResult = items.where((item) {
      final title = item['title']?.toLowerCase() ?? '';
      final altTitles = item['altTitle'] as List<String>? ?? [];
      final hasMatchInAltTitle = altTitles.any((alt) => alt.toLowerCase().contains(searchLower));
      return title.contains(searchLower) || hasMatchInAltTitle;
    }).toList();

    setState(() {
      searchResult.clear();
      for (var comic in filterResult) {
        searchResult.add(
          ComicSearchResult(
            title: comic['title'] ?? '',
            altTitle: comic['altTitle'] ?? [comic['title']],
            imageUrl: comic['image'] ?? '',
            searchKeyword: query,
          ),
        );
      }
    });
  }


  void _handleSubmit(String query) {
    Navigator.of(context).pop();
    AppRouter.push(context, '/search?q=$query');
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      constraints: const BoxConstraints(
        maxWidth: 340,
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(38),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            autofocus: true,
            controller: _textController,
            onChanged: (inputQuery) {
              _performSearch(inputQuery);
            },
            onSubmitted: (inputQuery) {
              _handleSubmit(inputQuery);
            },
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: "Comic Search...",
            ),
          ),
          // const SizedBox(height: 8),
          Flexible(
            fit: FlexFit.loose,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: searchResult.length,
              itemBuilder: (context, index) => searchResult[index],
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}