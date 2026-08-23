class ArabicNormalizer {
  ArabicNormalizer._();

  /// Normalizes Arabic text for smart, accent-insensitive and spelling-variation-insensitive searching.
  ///
  /// - Removes diacritics / tashkeel (Fatha, Damma, Kasra, Tanween, Shadda, Sukun)
  /// - Unifies Alef variants: [أ, إ, آ, ٱ] -> ا
  /// - Unifies Taa Marbuta / Haa: ة -> ه
  /// - Unifies Yaa / Alef Maqsura: ى -> ي
  /// - Removes Tatweel / Kashida: ـ -> ""
  static String normalize(String? text) {
    if (text == null || text.trim().isEmpty) return '';

    var normalized = text.trim().toLowerCase();

    // 1. Remove diacritics / tashkeel (064B - 0652) and dagger alef (0670) and tatweel (0640)
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u0652\u0670\u0640]'), '');

    // 2. Normalize Alef variants to bare Alef (ا)
    normalized = normalized.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // 3. Normalize Taa Marbuta (ة) to Haa (ه)
    normalized = normalized.replaceAll('ة', 'ه');

    // 4. Normalize Alef Maqsura (ى) to Yaa (ي)
    normalized = normalized.replaceAll('ى', 'ي');

    return normalized;
  }

  /// Checks if [target] contains [query] using normalized Arabic comparison.
  static bool matches(String? target, String? query) {
    if (query == null || query.trim().isEmpty) return true;
    if (target == null || target.trim().isEmpty) return false;

    final normalizedTarget = normalize(target);
    final normalizedQuery = normalize(query);

    return normalizedTarget.contains(normalizedQuery);
  }
}
