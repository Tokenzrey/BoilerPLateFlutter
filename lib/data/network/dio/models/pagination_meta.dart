/// Model for standardized pagination metadata
class PaginationMeta {
  /// The current page number
  final int currentPage;

  /// The number of items per page
  final int perPage;

  /// The total number of items across all pages
  final int total;

  /// The total number of pages
  final int lastPage;

  /// The index of the first item on the current page
  final int from;

  /// The index of the last item on the current page
  final int to;

  /// Whether there is a previous page
  bool get hasPrevious => currentPage > 1;

  /// Whether there is a next page
  bool get hasNext => currentPage < lastPage;

  /// Creates pagination metadata
  const PaginationMeta({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
    required this.from,
    required this.to,
  });

  /// Creates pagination metadata from JSON
  ///
  /// Supports both Laravel-style and common pagination formats
  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    // Handle Laravel-style pagination
    if (json.containsKey('current_page')) {
      return PaginationMeta(
        currentPage: json['current_page'] as int,
        perPage: json['per_page'] as int,
        total: json['total'] as int,
        lastPage: json['last_page'] as int,
        from: json['from'] as int? ?? 0,
        to: json['to'] as int? ?? 0,
      );
    }

    // Handle alternate pagination format
    return PaginationMeta(
      currentPage: json['page'] as int? ?? 1,
      perPage: json['limit'] as int? ?? json['per_page'] as int? ?? 10,
      total: json['total'] as int? ?? json['total_count'] as int? ?? 0,
      lastPage: json['pages'] as int? ?? json['total_pages'] as int? ?? 1,
      from: json['from'] as int? ?? 0,
      to: json['to'] as int? ?? 0,
    );
  }

  /// Creates an empty pagination meta
  factory PaginationMeta.empty() {
    return const PaginationMeta(
      currentPage: 1,
      perPage: 0,
      total: 0,
      lastPage: 1,
      from: 0,
      to: 0,
    );
  }

  /// Converts this pagination meta to JSON
  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
      'from': from,
      'to': to,
    };
  }

  @override
  String toString() =>
      'PaginationMeta(page: $currentPage, perPage: $perPage, total: $total)';
}

/// Paginated list with metadata
class PaginatedList<T> {
  /// List of items on the current page
  final List<T> data;

  /// Pagination metadata
  final PaginationMeta meta;

  /// Creates a paginated list
  const PaginatedList({
    required this.data,
    required this.meta,
  });

  /// Creates a paginated list from raw data and a mapper function
  factory PaginatedList.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final List<dynamic> items = json['data'] ?? json['items'] ?? [];
    final List<T> data = items.map((item) => fromJson(item)).toList();

    // Extract meta information
    final metaData = json['meta'] ?? json['pagination'] ?? json;

    final meta = PaginationMeta.fromJson(
        metaData is Map<String, dynamic> ? metaData : {});

    return PaginatedList<T>(
      data: data,
      meta: meta,
    );
  }

  /// Creates an empty paginated list
  factory PaginatedList.empty() {
    return PaginatedList<T>(
      data: <T>[],
      meta: PaginationMeta.empty(),
    );
  }

  /// Maps the items in this list to a new type
  PaginatedList<R> map<R>(R Function(T item) mapper) {
    return PaginatedList<R>(
      data: data.map(mapper).toList(),
      meta: meta,
    );
  }

  @override
  String toString() =>
      'PaginatedList(${data.length} items, page ${meta.currentPage} of ${meta.lastPage})';
}
