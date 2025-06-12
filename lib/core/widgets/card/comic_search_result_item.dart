import 'package:flutter/material.dart';

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

class _ComicListItemState extends State<ComicSearchResult> {
  bool _isHovering = false;

  List<TextSpan> _highlightedText(String fullText, String keyword) {
    if (keyword.isEmpty) return [TextSpan(text: fullText)];

    final matches = RegExp(RegExp.escape(keyword), caseSensitive: false)
        .allMatches(fullText);
    if (matches.isEmpty) return [TextSpan(text: fullText)];

    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans
            .add(TextSpan(text: fullText.substring(lastMatchEnd, match.start)));
      }

      spans.add(TextSpan(
        text: fullText.substring(match.start, match.end),
        style: TextStyle(
          backgroundColor: Colors.yellow[400],
          fontWeight: FontWeight.bold,
        ),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(lastMatchEnd)));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final joinedAltTitle = widget.altTitle.join(', ');

    return InkWell(
      onTap: () {},
      onHover: (hovering) {
        setState(() {
          _isHovering = hovering;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: _isHovering ? Colors.blueGrey.shade800 : Colors.transparent,
        child: ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              widget.imageUrl,
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 60,
                height: 90,
                color: Colors.grey,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
          title: Text.rich(
            TextSpan(
              children: _highlightedText(widget.title, widget.searchKeyword),
            ),
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            joinedAltTitle,
            style: TextStyle(
                fontSize: 14, color: Colors.grey.withValues(alpha: 0.7)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
