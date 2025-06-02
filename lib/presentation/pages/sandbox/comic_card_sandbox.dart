import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/card/comic_card.dart';

class ComicCardPage extends StatelessWidget {
  const ComicCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyData = [
      ComicCard(
        title: 'The Infinite Mage',
        imageUrl: 'https://n14.mbxma.org/thumb/W600/ampi/d20/d207b824a6a501f5267eb3aaeb301a6642f279a7_400_600_104898.jpeg',
        chapter: 'Chap 120',
        updated: '15 hours ago',
        scanlator: 'Asurascans',
        likes: '1067',
        countryCodeUrl: 'https://flagcdn.com/w40/us.png',
        isBookmarked: true,
      ),
      ComicCard(
        title: 'Solo Leveling',
        imageUrl: 'https://img.niadd.com/logo/7/Solo_Leveling_Ragnarok.jpg',
        chapter: 'Chap 47',
        updated: '3 days ago',
        scanlator: 'Asura',
        likes: '890',
        countryCodeUrl: 'https://flagcdn.com/w40/us.png',
        isBookmarked: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('ComicCard Preview')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyData.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3 / 5,
        ),
        itemBuilder: (context, index) => dummyData[index],
      ),
    );
  }
}
