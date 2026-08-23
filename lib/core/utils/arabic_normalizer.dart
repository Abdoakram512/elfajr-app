class ArabicNormalizer {
  ArabicNormalizer._();

  /// Normalizes Arabic text for smart, accent-insensitive and spelling-variation-insensitive searching.
  ///
  /// - Unifies all Alef variants: [أ, إ, آ, ٱ] -> ا
  /// - Unifies Taa Marbuta and Haa: [ة, ه] -> ه
  /// - Unifies Yaa, Alef Maqsura and Nabrah: [ى, ي, ئ] -> ي
  /// - Unifies Waw and Waw with Hamza: [ؤ, و] -> و
  /// - Unifies standalone Hamza: ء -> ء
  /// - Removes all diacritics / tashkeel (Fatha, Damma, Kasra, Tanween, Shadda, Sukun, etc.)
  /// - Removes Tatweel / Kashida: ـ
  /// - Converts Arabic-Indic numerals (٠١٢٣٤٥٦٧٨٩) to standard digits (0123456789)
  static String normalize(String? text) {
    if (text == null || text.trim().isEmpty) return '';

    var normalized = text.trim().toLowerCase();

    // 1. Convert Arabic-Indic numerals to ASCII digits
    const arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
    const asciiDigits = '0123456789';
    for (int i = 0; i < arabicIndicDigits.length; i++) {
      normalized = normalized.replaceAll(arabicIndicDigits[i], asciiDigits[i]);
    }

    // 2. Remove all Arabic diacritics / tashkeel and tatweel
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '');

    // 3. Normalize all Alef variants to bare Alef (ا)
    normalized = normalized.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // 4. Normalize Taa Marbuta (ة) to Haa (ه)
    normalized = normalized.replaceAll('ة', 'ه');

    // 5. Normalize Alef Maqsura (ى) and Hamza on Yaa (ئ) to Yaa (ي)
    normalized = normalized.replaceAll(RegExp(r'[ىئ]'), 'ي');

    // 6. Normalize Waw with Hamza (ؤ) to Waw (و)
    normalized = normalized.replaceAll('ؤ', 'و');

    // 7. Remove any extra multiple spaces
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

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
