import 'package:flutter/material.dart';
import '../../../../core/widgets/cards/stat_kpi_card.dart';

class AdminKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;

  const AdminKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return StatKpiCard(
      title: title,
      value: value,
      icon: icon,
      accentColor: accentColor,
    );
  }
}
