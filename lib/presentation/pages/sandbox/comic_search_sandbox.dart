import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/components/display/comic_search_result_item.dart';

class ComicSearchSandbox extends StatelessWidget {
  const ComicSearchSandbox({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyData = [
      ComicSearchResult(
        title: 'Incorrect White Mage',
        imageUrl: 'https://meo.comick.pictures/7XyGe.jpg',
        altTitle: ['Incorrect White Mage'],
        searchKeyword: 'Mage',
      ),
      ComicSearchResult(
        title: 'The Infinite Mage',
        imageUrl:
            'https://n14.mbxma.org/thumb/W600/ampi/d20/d207b824a6a501f5267eb3aaeb301a6642f279a7_400_600_104898.jpeg',
        altTitle: ['Infinite Wizard', 'Infinite Mage'],
        searchKeyword: 'Mage',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ComicSearch Preview')),
      body: ListView.builder(
        itemCount: dummyData.length,
        itemBuilder: (context, index) => dummyData[index],
      ),
    );
  }
}
