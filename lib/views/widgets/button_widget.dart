import 'package:chefkit/common/constants.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.isLoading = false, 
  });

  final VoidCallback? onTap;
  final String text;
  final bool isLoading; 

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnTap = isLoading ? null : onTap;

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.white, 
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          onTap: effectiveOnTap, 
          splashColor: AppColors.red600.withOpacity(isLoading ? 0.0 : 0.2), 
          highlightColor: AppColors.red600.withOpacity(isLoading ? 0.0 : 0.1),
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.transparent, // Color is handled by Material
              borderRadius: BorderRadius.circular(30),
              border: isLoading
                  ? Border.all(color: AppColors.white.withOpacity(0.5))
                  : null,
            ),
            child: Center(
              child: isLoading
                  ? const SizedBox( 
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.red600),
                      ),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: AppColors.red600,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}