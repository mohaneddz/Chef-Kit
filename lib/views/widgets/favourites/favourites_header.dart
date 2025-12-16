import 'package:flutter/material.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class FavouritesHeader extends StatelessWidget {
  const FavouritesHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.favouritesTitle,
          style: TextStyle(
            color: theme.textTheme.titleLarge?.color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.favouritesSubtitle,
          style: TextStyle(
            color: theme.textTheme.bodySmall?.color,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontFamily: "LeagueSpartan",
          ),
        ),
      ],
    );
  }
}
