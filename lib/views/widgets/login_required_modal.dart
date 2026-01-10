import 'package:chefkit/common/constants.dart';
import 'package:chefkit/l10n/app_localizations.dart';
import 'package:chefkit/views/screens/authentication/singup_page.dart';
import 'package:flutter/material.dart';

/// Shows a modal dialog prompting the user to sign up or log in.
/// Used when a guest user tries to use a feature that requires authentication.
void showLoginRequiredModal(BuildContext context, {String? customMessage}) {
  final loc = AppLocalizations.of(context)!;
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (dialogContext) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red600.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 48,
                color: AppColors.red600,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              loc.loginRequiredTitle,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: theme.textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              customMessage ?? loc.loginRequiredMessage,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Poppins',
                color: theme.textTheme.bodyMedium?.color,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SingupPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.red600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  loc.signUp,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Cancel Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: TextButton.styleFrom(
                  foregroundColor: theme.textTheme.bodyMedium?.color,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  loc.cancel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
