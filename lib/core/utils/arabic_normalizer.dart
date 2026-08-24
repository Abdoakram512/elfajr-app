class ArabicNormalizer {
  ArabicNormalizer._();

  static const String _arabicIndicDigits = '٠١٢٣٤٥٦٧٨٩';
  static const String _asciiDigits = '0123456789';

  /// Converts Arabic-Indic digits (٠١٢٣٤٥٦٧٨٩) to standard ASCII digits (0123456789)
  static String convertDigits(String? text) {
    if (text == null || text.trim().isEmpty) return '';
    var result = text.trim();
    for (int i = 0; i < _arabicIndicDigits.length; i++) {
      result = result.replaceAll(_arabicIndicDigits[i], _asciiDigits[i]);
    }
    return result;
  }

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

    var normalized = convertDigits(text).toLowerCase();

    // 1. Remove all Arabic diacritics / tashkeel and tatweel
    normalized = normalized.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u0640]'), '');

    // 2. Normalize all Alef variants to bare Alef (ا)
    normalized = normalized.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // 3. Normalize Taa Marbuta (ة) to Haa (ه)
    normalized = normalized.replaceAll('ة', 'ه');

    // 4. Normalize Alef Maqsura (ى) and Hamza on Yaa (ئ) to Yaa (ي)
    normalized = normalized.replaceAll(RegExp(r'[ىئ]'), 'ي');

    // 5. Normalize Waw with Hamza (ؤ) to Waw (و)
    normalized = normalized.replaceAll('ؤ', 'و');

    // 6. Remove any extra multiple spaces
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

  /// Generates common Egyptian phone number format variations for flexible querying
  static Set<String> generatePhoneVariations(String raw) {
    final normalized = convertDigits(raw);
    final digits = normalized.replaceAll(RegExp(r'\D'), '');
    final variations = <String>{normalized, digits};

    if (digits.isEmpty) return variations;

    if (digits.length == 11 && digits.startsWith('01')) {
      final withoutZero = digits.substring(1);
      variations.addAll([
        digits,
        '+20$withoutZero',
        '20$withoutZero',
        '0020$withoutZero',
        withoutZero,
      ]);
    } else if (digits.length == 12 && digits.startsWith('201')) {
      final local = '0${digits.substring(2)}';
      variations.addAll([
        local,
        '+$digits',
        digits,
        digits.substring(2),
      ]);
    } else if (digits.length == 10 && digits.startsWith('1')) {
      variations.addAll([
        '0$digits',
        '+20$digits',
        '20$digits',
        digits,
      ]);
    }

    return variations;
  }
}
