
# Comic Card

![image](https://github.com/user-attachments/assets/fe0f360b-5c04-459b-b88e-d484d565be32)

## Constructor

```dart
class ComicCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final String chapter;
  final String updated;
  final String scanlator;
  final String likes;
  final String countryCodeUrl;
  final bool isBookmarked;
  final bool showCountryFlag;
  final bool showBookmark;
  final bool onlyTitle;

  const ComicCard({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.chapter,
    required this.updated,
    required this.scanlator,
    required this.likes,
    required this.countryCodeUrl,
    this.isBookmarked = false,
    this.showCountryFlag = true,
    this.showBookmark = true,
    this.onlyTitle = false,
  });

  @override
  State<ComicCard> createState() => _ComicCardState();
}
```

## Cara Pemanggilan

```dart
ComicCard(
    title: 'The Infinite Mage',
    imageUrl: 'https://n14.mbxma.org/thumb/W600/ampi/d20/d207b824a6a501f5267eb3aaeb301a6642f279a7_400_600_104898.jpeg',
    chapter: 'Chap 120',
    updated: '15 hours ago',
    scanlator: 'Asurascans',
    likes: '1067',
    countryCodeUrl: 'https://flagcdn.com/w40/us.png',
    isBookmarked: true,
    showCountryFlag: true,
    showBookmark: true,
    onlyTitle: false,
),
```

## Contoh Penggunaan

```dart
import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/card/comic_card.dart';

class ComicCardSandboxPage extends StatelessWidget {
  const ComicCardSandboxPage({super.key});

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
        showCountryFlag: true,
        showBookmark: true,
        onlyTitle: false,
      ),
      ComicCard(
        title: 'Solo Leveling Ragnarok',
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
        padding: const EdgeInsets.all(8),
        itemCount: dummyData.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 3 / 7,
        ),
        itemBuilder: (context, index) => dummyData[index],
      ),
    );
  }
}
```


# Comic Search Item

![image](https://github.com/user-attachments/assets/0d3e1839-5aa4-4320-92bc-1d28a362640c)

## Constructor

```dart
class ComicSearchResult extends StatefulWidget {
  final String title;
  final List<String> altTitle;
  final String imageUrl;
  final String searchKeyword;
  // final VoidCallback onTap;

  const ComicSearchResult({
    super.key,
    required this.title,
    required this.altTitle,
    required this.imageUrl,
    required this.searchKeyword,
    // required this.onTap,
  });

  @override
  State<ComicSearchResult> createState() => _ComicListItemState();
}
```

## Cara Pemanggilan

```dart
  ComicSearchResult(
    title: 'Incorrect White Mage',
    imageUrl: 'https://meo.comick.pictures/7XyGe.jpg',
    altTitle: ['Incorrect White Mage'],
    searchKeyword: 'Mage',
  ),
```

## Contoh Penggunaan

```dart
import 'package:flutter/material.dart';
import 'package:boilerplate/core/widgets/card/comic_search_result_item.dart';

class ComicSearchSandboxPage extends StatelessWidget {
  const ComicSearchSandboxPage({super.key});

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
        imageUrl: 'https://n14.mbxma.org/thumb/W600/ampi/d20/d207b824a6a501f5267eb3aaeb301a6642f279a7_400_600_104898.jpeg',
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

```


