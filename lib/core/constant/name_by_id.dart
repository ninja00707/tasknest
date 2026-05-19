class NameById {
  static String getNameById<T>({
    required int id,
    required List<T> items,
    required int Function(T item) idSelector,
    required String Function(T item) nameSelector,
    String fallback = 'Unknown',
  }) {
    try {
      final item = items.firstWhere((element) => idSelector(element) == id);

      return nameSelector(item).toUpperCase();
    } catch (e) {
      return fallback;
    }
  }
}
