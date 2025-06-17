import 'package:boilerplate/core/domain/usecase/use_case.dart';
import 'package:boilerplate/data/local/models/comic_chapters_model.dart';
import 'package:boilerplate/data/local/models/comic_details_model.dart';
import 'package:boilerplate/domain/entity/user/user.dart';
import 'package:boilerplate/domain/usecase/api/comic_chapters_usecase.dart';
import 'package:boilerplate/domain/usecase/api/comic_details_usecase.dart';
import 'package:boilerplate/domain/usecase/auth_firebase/get_current_user_usecase.dart';
import 'package:boilerplate/domain/usecase/comic/followed_comic_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'comic_detail_store.g.dart';

class ComicDetailStore = ComicDetailStoreBase with _$ComicDetailStore;

abstract class ComicDetailStoreBase with Store {
  final ComicDetailsUseCase comicDetailsUseCase;
  final ComicChaptersUseCase comicChaptersUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final AddFollowedComicUseCase addFollowedComicUseCase;
  final GetFollowedComicsUseCase getFollowedComicsUseCase;
  final DeleteFollowedComicsUseCase deleteFollowedComicsUseCase;

  ComicDetailStoreBase(
    this.comicDetailsUseCase,
    this.comicChaptersUseCase,
    this.getCurrentUserUseCase,
    this.addFollowedComicUseCase,
    this.getFollowedComicsUseCase,
    this.deleteFollowedComicsUseCase,
  );

  // --- Detail State ---
  @observable
  ComicDetailResponse? comicDetail;

  @observable
  bool isLoadingDetail = false;

  @observable
  String detailError = '';

  // --- Chapters State ---
  @observable
  ObservableList<ChapterDetailModel> chapters =
      ObservableList<ChapterDetailModel>();

  @observable
  bool isLoadingChapters = false;

  @observable
  String chaptersError = '';

  @observable
  int currentPage = 1;

  @observable
  int pageSize = 40;

  @observable
  int totalChapters = 0;

  @observable
  bool hasNextPage = false;

  @observable
  bool hasPrevPage = false;

  // --- Follow State ---
  @observable
  User? currentUser;

  @observable
  bool isFollowing = false;

  @observable
  bool isFollowingLoading = false;

  @observable
  String followError = '';

  @observable
  String? followId;

  @action
  void resetComicDetailState() {
    comicDetail = null;
    isLoadingDetail = false;
    detailError = '';
    chapters.clear();
    isLoadingChapters = false;
    chaptersError = '';
    currentPage = 1;
    totalChapters = 0;
    hasNextPage = false;
    hasPrevPage = false;
    isFollowing = false;
    isFollowingLoading = false;
    followError = '';
    followId = null;
  }

  // --- Public: Fetch Detail ---
  @action
  Future<void> fetchComicDetail(String slug) async {
    resetComicDetailState();
    
    isLoadingDetail = true;
    detailError = '';
    comicDetail = null;

    isFollowingLoading = false;

    final result = await comicDetailsUseCase(
      ComicDetailsParams(
        slug: slug,
        tachiyomi: true,
      ),
    );

    result.match(
      (failure) {
        detailError = failure.message;
      },
      (data) {
        comicDetail = data;
        debugPrint('Comic Detail Loaded: $data');

        // Debug logging to check what's coming from API
        debugPrint('Comic Detail HID: ${data.comic?.hid}');
        debugPrint('Comic Detail Title: ${data.comic?.title}');
        debugPrint('First Chapter HID: ${data.firstChap?.hid}');

        // After getting details, fetch chapters if possible
        if (data.comic?.hid?.isNotEmpty == true) {
          fetchChapters(hid: data.comic!.hid!);
        } else if (data.firstChap?.hid?.isNotEmpty == true) {
          fetchChapters(hid: data.firstChap!.hid!);
        } else {
          chaptersError = 'Unable to load chapters: Missing comic ID';
        }

        // Check if the comic is already followed
        checkFollowStatus(slug);
      },
    );

    isLoadingDetail = false;
  }

  // --- Public: Fetch Chapters with Pagination ---
  @action
  Future<void> fetchChapters({required String hid, int? page}) async {
    // Add validation to prevent API call with empty HID
    if (hid.isEmpty) {
      chaptersError = 'Cannot load chapters: Invalid comic ID';
      return;
    }

    isLoadingChapters = true;
    chaptersError = '';
    chapters.clear();

    final current = page ?? currentPage;
    final result = await comicChaptersUseCase(
      ComicChaptersParams(
        hid: hid,
        limit: pageSize,
        page: current,
        tachiyomi: true,
      ),
    );

    result.match(
      (failure) {
        chaptersError = failure.message;
      },
      (data) {
        final chaps = data.chapters ?? [];
        chapters.addAll(chaps);

        totalChapters = data.total ?? chaps.length;
        hasPrevPage = current > 1;
        // total/limit = jumlah halaman, page minimal 1
        final totalPages = ((totalChapters / pageSize).ceil()).clamp(1, 999);
        hasNextPage = current < totalPages;
      },
    );

    isLoadingChapters = false;
  }

  @action
  Future<void> checkFollowStatus(String slug) async {
    final timestamp = DateTime.now().toString();
    debugPrint(
        "[$timestamp][FollowStatus] 🔍 START: Checking follow status for slug: $slug");

    if (slug.isEmpty) {
      debugPrint(
          "[$timestamp][FollowStatus] ⚠️ Cannot check follow status: empty slug");
      isFollowingLoading = false;
      return;
    }

    // Log initial state
    debugPrint(
        "[$timestamp][FollowStatus] Current state before check: isFollowing=$isFollowing, isFollowingLoading=$isFollowingLoading");

    isFollowingLoading = true;
    followError = '';

    try {
      debugPrint("[$timestamp][FollowStatus] 📡 Fetching current user...");
      final userResult = await getCurrentUserUseCase.execute(NoParams());

      // Perbaikan: Proses match dilakukan tanpa async closure!
      if (userResult.isLeft()) {
        final failure = userResult.getLeft().toNullable();
        debugPrint(
            "[$timestamp][FollowStatus] ❌ Failed to get user: ${failure?.message}");
        currentUser = null;
        isFollowing = false;
        followError = failure?.message ?? '';
        return;
      }
      final user = userResult.getRight().toNullable();
      if (user == null) {
        debugPrint(
            "[$timestamp][FollowStatus] ⚠️ User is null after successful authentication");
        currentUser = null;
        isFollowing = false;
        return;
      }

      currentUser = user;
      debugPrint(
          "[$timestamp][FollowStatus] ✅ User authenticated - ID: ${user.id}, Username: ${user.username}");

      // Ambil daftar komik yang di-follow user
      debugPrint(
          "[$timestamp][FollowStatus] 📡 Fetching followed comics for user ${user.id}...");
      final followsResult = await getFollowedComicsUseCase.execute(
        GetFollowedComicParams(userId: user.id),
      );

      if (followsResult.isLeft()) {
        final failure = followsResult.getLeft().toNullable();
        followError = failure?.message ?? '';
        isFollowing = false;
        debugPrint(
            "[$timestamp][FollowStatus] ❌ Failed to get followed comics: ${failure?.message}");
        return;
      }

      final follows = followsResult.getRight().toNullable() ?? [];
      debugPrint(
          "[$timestamp][FollowStatus] ✅ Retrieved ${follows.length} followed comics");

      if (follows.isEmpty) {
        debugPrint(
            "[$timestamp][FollowStatus] ℹ️ No followed comics for this user");
        isFollowing = false;
        followId = null;
        return;
      }

      final matchingComics =
          follows.where((comic) => comic.slug == slug).toList();
      debugPrint(
          "[$timestamp][FollowStatus] Found ${matchingComics.length} matches for slug '$slug'");

      if (matchingComics.isNotEmpty) {
        final followedComic = matchingComics.first;
        isFollowing = followedComic.id?.isNotEmpty ?? false;
        followId = isFollowing ? followedComic.id : null;
        debugPrint(
            "[$timestamp][FollowStatus] ✅ Comic is followed. Follow ID: $followId");
      } else {
        isFollowing = false;
        followId = null;
        debugPrint(
            "[$timestamp][FollowStatus] ℹ️ Comic is not followed by this user");
      }
    } catch (e, stackTrace) {
      followError = "Error checking follow status: $e";
      debugPrint("[$timestamp][FollowStatus] ❌ Unexpected error: $e");
      debugPrint("[$timestamp][FollowStatus] Stack trace: $stackTrace");
      isFollowing = false;
      followId = null;
    } finally {
      isFollowingLoading = false;
      debugPrint(
          "[$timestamp][FollowStatus] 🏁 COMPLETE: Final state: isFollowing=$isFollowing, followId=$followId, isFollowingLoading=$isFollowingLoading, error='$followError'");
    }
  }

  @action
  Future<bool> toggleFollow() async {
    final timestamp = DateTime.now().toString();
    debugPrint(
        "[$timestamp][ToggleFollow] 🔄 START: Attempting to toggle follow status");

    // Log initial state
    debugPrint(
        "[$timestamp][ToggleFollow] Initial state: isFollowing=$isFollowing, isFollowingLoading=$isFollowingLoading, followId=$followId");

    if (currentUser == null) {
      followError = 'Please log in to follow comics';
      debugPrint(
          "[$timestamp][ToggleFollow] ⛔ Authentication required: No current user");
      return false;
    }

    if (comicDetail?.comic == null) {
      followError = 'Comic details not available';
      debugPrint(
          "[$timestamp][ToggleFollow] ⛔ Missing comic data: Cannot toggle follow");
      return false;
    }

    // Now we can safely set loading state
    isFollowingLoading = true;
    followError = '';
    bool success = false;

    try {
      if (isFollowing && followId != null) {
        // Unfollow comic
        debugPrint(
            "[$timestamp][ToggleFollow] 📡 Unfollowing comic with ID: $followId");

        final result = await deleteFollowedComicsUseCase.execute(
          DeleteFollowedComicsParams(comicId: followId!),
        );

        result.match(
          (failure) {
            followError = failure.message;
            debugPrint(
                "[$timestamp][ToggleFollow] ❌ Failed to unfollow: ${failure.message}");
            success = false;
          },
          (_) {
            isFollowing = false;
            followId = null;
            success = true;
            debugPrint(
                "[$timestamp][ToggleFollow] ✅ Successfully unfollowed comic");
          },
        );
      } else {
        // Follow comic
        final title = comicDetail!.comic!.title;
        debugPrint("[$timestamp][ToggleFollow] 📡 Following comic: '$title'");
        final now = DateTime.now().toIso8601String();

        // Log all parameters for debugging
        final slug = comicDetail!.comic!.slug ?? '';
        final hid = comicDetail!.comic!.hid ?? '';
        final chap = comicDetail!.firstChap?.chap ?? '1';
        final imageUrl = comicDetail!.comic!.coverUrl ?? '';
        final rating = comicDetail!.comic!.bayesianRating ?? '0';
        final totalContent =
            comicDetail!.comic!.chapterCount?.toString() ?? '0';

        debugPrint(
            "[$timestamp][ToggleFollow] Follow params - userId: ${currentUser!.id}, slug: $slug, hid: $hid, title: $title");

        final result = await addFollowedComicUseCase.execute(
          AddFollowedComicParams(
            userId: currentUser!.id,
            slug: slug,
            hid: hid,
            chap: chap,
            title: title ?? '',
            imageUrl: imageUrl,
            rating: rating,
            totalContent: totalContent,
            lastRead: now,
            updatedAt: now,
            addedAt: now,
          ),
        );

        result.match(
          (failure) {
            followError = failure.message;
            debugPrint(
                "[$timestamp][ToggleFollow] ❌ Failed to follow: ${failure.message}");
            success = false;
          },
          (_) {
            isFollowing = true;
            success = true;
            debugPrint(
                "[$timestamp][ToggleFollow] ✅ Successfully followed comic");

            // Instead of calling checkFollowStatus, we'll set a flag to check on next fetch
            debugPrint(
                "[$timestamp][ToggleFollow] Note: Follow ID will be retrieved on next status check");
          },
        );
      }
    } catch (e, stackTrace) {
      followError = "Error toggling follow: $e";
      debugPrint("[$timestamp][ToggleFollow] ❌ Unexpected error: $e");
      debugPrint("[$timestamp][ToggleFollow] Stack trace: $stackTrace");
      success = false;
    } finally {
      // Guarantee loading state is reset
      isFollowingLoading = false;

      // Log final state after the operation completed
      debugPrint(
          "[$timestamp][ToggleFollow] 🏁 COMPLETE: Final state: isFollowing=$isFollowing, followId=$followId, isFollowingLoading=$isFollowingLoading, success=$success, error='$followError'");
    }

    return success;
  }

  // --- UI Helpers ---
  @computed
  int get totalPages => ((totalChapters / pageSize).ceil()).clamp(1, 999);

  @action
  Future<void> goToPage(String hid, int page) async {
    if (page < 1 || (totalPages > 0 && page > totalPages)) return;
    currentPage = page;
    await fetchChapters(hid: hid, page: page);
  }

  // --- Data Accessor (example for UI) ---
  String get coverUrl => comicDetail?.comic?.coverUrl ?? '';

  String get title => comicDetail?.comic?.title ?? '-';

  String get alternativeTitles {
    if (comicDetail?.comic?.mdTitles == null ||
        comicDetail!.comic!.mdTitles!.isEmpty) {
      return '-';
    }
    return comicDetail!.comic!.mdTitles!
        .where((title) => title.title != null && title.title!.isNotEmpty)
        .map((title) => title.title)
        .join(', ');
  }

  String? get alternativeLangNative => (comicDetail?.comic?.langNative != null)
      ? comicDetail?.comic?.langNative
      : '-';

  String get description => comicDetail?.comic?.desc ?? '';

  String? get author => (comicDetail?.authors?.isNotEmpty ?? false)
      ? comicDetail!.authors!.first.name
      : '-';

  List<String> get authors =>
      (comicDetail?.authors != null && comicDetail!.authors!.isNotEmpty)
          ? comicDetail!.authors!
              .map((a) => a.name ?? '')
              .where((name) => name.isNotEmpty)
              .toList()
          : [];

  List<String> get artists =>
      comicDetail?.artists
          ?.map((a) => a.name ?? '')
          .where((name) => name.isNotEmpty)
          .toList() ??
      [];

  String? get artistText => (comicDetail?.artists?.isNotEmpty ?? false)
      ? comicDetail!.artists!.first.name
      : '-';

  String get artistsText {
    if (comicDetail?.artists == null || comicDetail!.artists!.isEmpty) {
      return '-';
    }
    return comicDetail!.artists!
        .map((a) => a.name)
        .where((name) => name != null && name.isNotEmpty)
        .join(', ');
  }

  String get statusText {
    final statusValue = comicDetail?.comic?.status;
    switch (statusValue) {
      case 1:
        return 'Ongoing';
      case 2:
        return 'Completed';
      case 3:
        return 'Cancelled';
      case 4:
        return 'Hiatus';
      default:
        return '-';
    }
  }

  List<String> get genres =>
      comicDetail?.comic?.mdComicMdGenres
          ?.map((g) => g.mdGenres?.name ?? '')
          .where((name) => name.isNotEmpty)
          .toList() ??
      [];

  String get genresText => genres.isNotEmpty ? genres.join(', ') : '-';

  String get year => comicDetail?.comic?.year?.toString() ?? '-';

  String? get firstChapterHid => comicDetail?.firstChap?.hid;

  Object get demographic => comicDetail?.comic?.demographic ?? '-';

  int? get views => comicDetail?.comic?.userFollowCount;

  int? get rating => comicDetail?.comic?.ratingCount;
}
