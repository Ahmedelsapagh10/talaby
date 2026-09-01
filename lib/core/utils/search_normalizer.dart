class SearchNormalizer {
  const SearchNormalizer._();

  static String normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
        .replaceAll('ـ', '')
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  static String normalizePhone(String value) {
    final trimmed = value.trim();
    final digits = trimmed.replaceAll(RegExp('[^0-9]'), '');
    return trimmed.startsWith('+') && digits.isNotEmpty ? '+$digits' : digits;
  }

  static List<String> prefixes(String value) {
    final normalized = normalize(value);
    if (normalized.length < 2) return const [];
    final candidates = <String>{normalized, ...normalized.split(' ')};
    final result = <String>{};
    for (final candidate in candidates) {
      for (var length = 2; length <= candidate.length; length++) {
        result.add(candidate.substring(0, length));
        if (result.length >= 200) return result.toList()..sort();
      }
    }
    return result.toList()..sort();
  }

  static bool matchesPrefix(String value, String query) {
    final search = normalize(query);
    if (search.length < 2) return false;
    return prefixes(value).contains(search);
  }
}
