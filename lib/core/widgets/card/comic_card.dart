import 'package:flutter/material.dart';

class ComicCard extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String chapter;
  final String updated;
  final String scanlator;
  final String likes;
  final String countryCodeUrl;
  final bool isBookmarked;

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
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 3 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              Flexible(
                flex: 7,
                child: Stack(
                  children: [
                    Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                    ),
                    // Country flag
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Image.network(
                        countryCodeUrl,
                        width: 24,
                        height: 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Bookmark icon
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bookmark, color: Colors.greenAccent, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              Flexible(
                flex: 3,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(chapter, style: TextStyle(color: Colors.white70)),

                            Row(
                              children: [
                                Icon(Icons.thumb_up_alt_outlined, size: 14, color: Colors.white60),
                                SizedBox(width: 4),
                                Text(likes, style: TextStyle(color: Colors.white60)),
                              ],
                            ),
                          ]
                        ),
                        // const SizedBox(height: 2),
                        Text(updated, style: TextStyle(color: Colors.white70)),
                        // const SizedBox(height: 2),
                        Text(scanlator, style: TextStyle(color: Colors.white60)),
                        const SizedBox(height: 2),
                        
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
