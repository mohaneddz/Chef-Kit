import 'package:flutter/material.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class SectionHeaderWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const SectionHeaderWidget({
    Key? key,
    required this.title,
    this.onSeeAllPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        if (onSeeAllPressed != null)
          GestureDetector(
            onTap: onSeeAllPressed,
            child: Text(
              AppLocalizations.of(context)!.seeAll,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFFF5D69),
                fontFamily: 'Poppins',
              ),
            ),
          ),
      ],
    );
  }
}
