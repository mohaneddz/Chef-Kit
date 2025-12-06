import 'package:flutter/material.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class FavouritesHeader extends StatelessWidget {
  const FavouritesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.favouritesTitle,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.favouritesSubtitle,
          style: const TextStyle(
            color: Color(0xFF4A5565),
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "LeagueSpartan",
          ),
        ),
      ],
    );
  }
}
