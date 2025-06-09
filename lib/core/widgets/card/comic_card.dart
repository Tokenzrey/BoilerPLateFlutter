import 'package:boilerplate/di/service_locator.dart';
import 'package:boilerplate/presentation/store/theme/theme_store.dart';
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
  
  final ThemeStore _themeStore = getIt<ThemeStore>();
  
  bool _isHoveringCard = false;
  bool _isHoveringBookmark = false;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _themeStore.darkMode;
    final textColor = isDark ? Colors.white54 : Colors.black54;
    final titleColor = isDark ? Colors.white : Colors.black;

    return InkWell(
      onTap: () {},
      onHover: (hovering) {
        setState(() => _isHoveringCard = hovering);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: _isHoveringCard? Colors.white : Colors.black26,
              blurRadius: _isHoveringCard? 12 : 4,
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
                        top: 1,
                        left: 1,
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
                        // top: 1,
                        right: 1,
                        child: InkWell(
                          onTap: () {
                            setState(() => _isBookmarked = !_isBookmarked);
                          },
                          onHover: (hovering) {
                            setState(() => _isHoveringBookmark = hovering);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.all(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(
                                begin: 20,
                                end: (_isBookmarked || _isHoveringBookmark) ? 28 : 20,
                              ),
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              builder: (context, size, child) {
                                return Icon(
                                  Icons.bookmark,
                                  size: size,
                                  color: Color.lerp(
                                    Colors.grey,
                                    Colors.greenAccent,
                                    (_isBookmarked || _isHoveringBookmark) ? 1 : 0,
                                  ),
                                );
                              },
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
                          Text(widget.chapter, style: TextStyle(color: textColor)),

                          Row(
                            children: [
                              Icon(Icons.thumb_up_alt_outlined, size: 14, color: textColor),
                              SizedBox(width: 2),
                              Text(widget.likes, style: TextStyle(color: textColor)),
                            ],
                          ),
                        ]
                      ),
                      Text(widget.updated, style: TextStyle(color: textColor)),
                      Text(widget.scanlator, style: TextStyle(color: textColor)),
                      const SizedBox(height: 4),
                    
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, color: titleColor, fontSize: 16),
                    ),
                  ],
                ),  
              ),
            ),
          ],
        ),
      ),
    );
  }
}
