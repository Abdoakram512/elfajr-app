import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routes/route_names.dart';
import 'profile_navigation_tile.dart';
import 'profile_section_card.dart';

class ProfileInfoContentLinks extends StatelessWidget {
  final String? customSectionTitle;
  final IconData? customSectionIcon;
  final bool wrapInSectionCard;

  const ProfileInfoContentLinks({
    super.key,
    this.customSectionTitle,
    this.customSectionIcon,
    this.wrapInSectionCard = true,
  });

  @override
  Widget build(BuildContext context) {
    final tiles = [
      ProfileNavigationTile(
        title: 'info_content.about_us'.tr(),
        icon: Icons.info_outline_rounded,
        onTap: () => context.push(RouteNames.aboutUs),
      ),
      ProfileNavigationTile(
        title: 'info_content.faq.title'.tr(),
        icon: Icons.quiz_outlined,
        onTap: () => context.push(RouteNames.faq),
      ),
      ProfileNavigationTile(
        title: 'info_content.terms_privacy'.tr(),
        icon: Icons.verified_user_outlined,
        onTap: () => context.push(RouteNames.termsPrivacy),
      ),
      ProfileNavigationTile(
        title: 'info_content.contact_support'.tr(),
        icon: Icons.headset_mic_outlined,
        showDivider: false,
        onTap: () => context.push(RouteNames.contactSupport),
      ),
    ];

    if (!wrapInSectionCard) {
      return Column(children: tiles);
    }

    return ProfileSectionCard(
      title: customSectionTitle ?? 'profile.settings_and_support'.tr(),
      icon: customSectionIcon ?? Icons.help_outline_rounded,
      children: tiles,
    );
  }
}
