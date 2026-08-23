/// Extension and helper for standardizing Arabic nationality forms (e.g. converting feminine to masculine)
extension NationalityFormatter on String? {
  String toMasculineNationality() {
    if (this == null || this!.trim().isEmpty) return '';
    final raw = this!.trim();
    switch (raw) {
      case 'مصرية':
        return 'مصري';
      case 'سورية':
        return 'سوري';
      case 'سودانية':
        return 'سوداني';
      case 'يمنية':
        return 'يمني';
      case 'فلسطينية':
        return 'فلسطيني';
      case 'أردنية':
        return 'أردني';
      case 'عراقية':
        return 'عراقي';
      case 'لبنانية':
        return 'لبناني';
      default:
        return raw;
    }
  }
}
