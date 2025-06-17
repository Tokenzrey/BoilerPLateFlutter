import 'package:boilerplate/constants/colors.dart';
import 'package:boilerplate/core/widgets/components/display/button.dart';
import 'package:boilerplate/core/widgets/components/typography.dart';
import 'package:boilerplate/core/widgets/navbar/navigation.dart';
import 'package:boilerplate/di/service_locator.dart';
// import 'package:boilerplate/domain/usecase/comic/followed_comic_usecase.dart';
import 'package:boilerplate/presentation/store/comic/comic_store.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

const List<String> items = [
  "Reading",
  "Unfollow",
  "Completed",
  "Dropped",
  "Plan to Read"
];

class MylistScreen extends StatefulWidget {
  const MylistScreen({super.key});

  @override
  State<MylistScreen> createState() => _MylistScreenState();
}

class _MylistScreenState extends State<MylistScreen> {
  static final uId = FirebaseAuth.instance.currentUser?.uid;
  String searchVal = "";
  List<String> comics = [];

  final Map<int, String> curStatus = {};
  final FollowedComicStore comicStore = getIt<FollowedComicStore>();


  @override
  void initState() {
    super.initState();
    // comicStore.addComic(AddFollowedComicParams(
    //   userId: "$uId",
    //   slug: "tes",
    //   hid: "tes",
    //   chap: "tes",
    //   title: "The Sword God From the Destroyed World",
    //   imageUrl: "ezXpBL.jpg",
    //   rating: "1",
    //   totalContent: "1",
    //   lastRead: "2025-06-16",
    //   updatedAt: "2025-06-16",
    //   addedAt: "2025-06-16",
    // ));
    comicStore.loadComics(uId!);
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithNavBar(
      backgroundColor: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 80, 0, 64),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      onChanged: (value) => setState(() => searchVal = value),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.card.withValues(alpha: 0.93),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon:
                            Icon(Icons.search, color: AppColors.neutral[400]),
                        hintText: "Search title...",
                        hintStyle: TextStyle(
                          color: AppColors.neutral[400],
                          fontSize: 14.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      style: TextStyle(
                        color: AppColors.neutral,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Button(
                    variant: ButtonVariant.outlined,
                    onPressed: () {},
                    layout: const ButtonLayout(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    colors: ButtonColors(
                      background: Colors.transparent,
                      border: AppColors.primary.withAlpha(90),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.filter_list, color: Colors.blue, size: 18),
                        SizedBox(width: 6),
                        AppText("Filter",
                            color: Colors.blue, fontWeight: FontWeight.w600),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Observer(
                builder: (_) {
                  final comics = comicStore.filteredComics?? [];
                  if (comics.isEmpty) {
                    return Center(
                      child: AppText(
                        "No comics found.",
                        color: AppColors.neutral[500],
                        style: const TextStyle(fontSize: 16),
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    itemCount: comics.length,
                    itemBuilder: (ctx, idx) {
                      final comic = comics[idx];
                      final curVal = curStatus[idx] ?? items.first;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ComicListTile(
                          title: comic.title,
                          status: curVal,
                          onStatusChanged: (val) {
                            final newVal = val ?? items.first;
                            setState(() => curStatus[idx] = newVal);
                            if (newVal == "Unfollow") {
                              // print(comic.id);
                              comicStore.removeComic(comic.id!);
                            }
                          },
                          imageUrl: "https://meo.comick.pictures/${comic.imageUrl}",
                          continueVal: "Ch. ${idx + 1}",
                          rating: comic.addedAt,
                          allContent: comic.totalContent,
                          lastRead: comic.lastRead,
                          updated: comic.updatedAt,
                          added: comic.addedAt,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ComicListTile extends StatelessWidget {
  final String title;
  final String imageUrl;
  final String continueVal;
  final String rating;
  final String allContent;
  final String status;
  final String lastRead;
  final String updated;
  final String added;
  final void Function(String?) onStatusChanged;

  const ComicListTile({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.continueVal,
    required this.rating,
    required this.allContent,
    required this.status,
    required this.lastRead,
    required this.updated,
    required this.added,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card.withValues(alpha: 0.98),
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  width: 54,
                  height: 72,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: AppColors.neutral[200],
                    width: 54,
                    height: 72,
                    child: Icon(Icons.broken_image,
                        size: 24, color: AppColors.neutral[400]),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    AppText(
                      title,
                      color: AppColors.neutral,
                      fontWeight: FontWeight.w700,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildStat(Icons.book, continueVal, AppColors.primary),
                        const SizedBox(width: 12),
                        _buildStat(Icons.star, rating, Colors.amber[700]!),
                        const SizedBox(width: 12),
                        _buildStat(Icons.library_books, allContent,
                            AppColors.neutral[600]!),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                width: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: status,
                              isDense: true,
                              icon: Icon(Icons.arrow_drop_down,
                                  size: 16, color: AppColors.primary),
                              items: items
                                  .map((val) => DropdownMenuItem(
                                        value: val,
                                        child: Text(val,
                                            style:
                                                const TextStyle(fontSize: 12)),
                                      ))
                                  .toList(),
                              onChanged: onStatusChanged,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              menuMaxHeight: 200,
                              dropdownColor: AppColors.card,
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Meta Column (moved to right side)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildMetaText("Last", lastRead),
                            const SizedBox(height: 2),
                            _buildMetaText("Updated", updated),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        AppText(
          value,
          style: const TextStyle(fontSize: 12),
          color: AppColors.neutral[400],
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildMetaText(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          "$label: ",
          style: const TextStyle(fontSize: 11),
          color: AppColors.neutral[300],
        ),
        AppText(
          value,
          style: const TextStyle(fontSize: 11),
          color: AppColors.neutral[200],
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }
}
