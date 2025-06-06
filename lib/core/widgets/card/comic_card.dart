import 'package:flutter/material.dart';

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

class _ComicCardState extends State<ComicCard> {

  bool isHovering = false;
  late bool isBookmarked;

  @override
  void initState() {
    super.initState();
    isBookmarked = widget.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 600 ? 14.0 : 16.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 6,
            // Image section
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: [
                  Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                  ),
                  // Country flag
                  if (widget.showCountryFlag)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Image.network(
                        widget.countryCodeUrl,
                        width: 24,
                        height: 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                  // Bookmark icon
                  if (widget.showBookmark)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: InkWell(
                        onTap: () {
                          setState(() => isBookmarked = !isBookmarked);
                        },
                        onHover: (hovering) {
                          setState(() => isHovering = hovering);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.ease,
                          padding: const EdgeInsets.all(4),
                          decoration: isBookmarked ? null : BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Icon(
                            Icons.bookmark, 
                            color: isBookmarked || isHovering? Colors.greenAccent : null, 
                            size: isBookmarked? 28 : 20,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),  
          ),
          
          Flexible(
            flex: 3,
            // Comic Details section
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  if (!widget.onlyTitle)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.chapter, style: TextStyle(color: Colors.white70, fontSize: fontSize)),

                        Row(
                          children: [
                            Icon(Icons.thumb_up_alt_outlined, size: fontSize, color: Colors.white60),
                            SizedBox(width: 2),
                            Text(widget.likes, style: TextStyle(color: Colors.white60, fontSize: fontSize)),
                          ],
                        ),
                      ]
                    ),
                    Text(widget.updated, style: TextStyle(color: Colors.white70, fontSize: fontSize)),
                    Text(widget.scanlator, style: TextStyle(color: Colors.white60, fontSize: fontSize)),
                    const SizedBox(height: 4),
                  
                  Text(
                    widget.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: fontSize+2),
                  ),
                ],
              ),  
            ),
          ),
        ],
      ),
    );
  }
}
