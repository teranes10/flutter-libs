class TSearchFilter<T> {
  final String Function(T) itemToString;

  const TSearchFilter({required this.itemToString});

  List<T> apply(Iterable<T> items, String query) {
    if (query.isEmpty) return items.toList();
    final lowerQuery = query.toLowerCase();
    return items.where((item) => _matches(item, lowerQuery)).toList();
  }

  bool _matches(T item, String query) {
    final text = itemToString(item);
    return text.toLowerCase().contains(query);
  }
}
