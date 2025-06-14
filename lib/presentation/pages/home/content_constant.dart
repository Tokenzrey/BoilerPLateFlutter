// Mock data for comics
const List<Map<String, dynamic>> followedComics = [
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

const List<Map<String, dynamic>> readingHistory = [
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

// Popular comics for each tab period
const Map<int, List<Map<String, dynamic>>> mostRecentComics = {
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
const Map<int, List<Map<String, dynamic>>> popularNewComics = {
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
const  Map<String, List<Map<String, dynamic>>> updatesComics = {
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
