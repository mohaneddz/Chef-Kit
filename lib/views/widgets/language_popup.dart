import 'package:flutter/material.dart';
import '../../common/app_colors.dart';

class LanguagePopup extends StatefulWidget {
  const LanguagePopup({Key? key}) : super(key: key);

  @override
  State<LanguagePopup> createState() => _LanguagePopupState();
}

class _LanguagePopupState extends State<LanguagePopup> {
  String _selectedLanguage = 'en'; // Static - no actual logic

  final List<Map<String, dynamic>> _languages = [
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English',
      'flag': '🇬🇧',
    },
    {
      'code': 'fr',
      'name': 'French',
      'nativeName': 'Français',
      'flag': '🇫🇷',
    },
    {
      'code': 'ar',
      'name': 'Arabic',
      'nativeName': 'العربية',
      'flag': '🇩🇿',
    },
    {
      'code': 'es',
      'name': 'Spanish',
      'nativeName': 'Español',
      'flag': '🇪🇸',
    },
    {
      'code': 'it',
      'name': 'Italian',
      'nativeName': 'Italiano',
      'flag': '🇮🇹',
    },
    {
      'code': 'de',
      'name': 'German',
      'nativeName': 'Deutsch',
      'flag': '🇩🇪',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.red600,
                        AppColors.red600.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Select Language',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[600], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search language...',
                        hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Language List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final language = _languages[index];
                  return _buildLanguageOption(
                    code: language['code'],
                    name: language['name'],
                    nativeName: language['nativeName'],
                    flag: language['flag'],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Apply Button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    AppColors.red600,
                    AppColors.red600.withOpacity(0.8),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.red600.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Static - no actual logic
                  final selectedLang = _languages.firstWhere(
                    (lang) => lang['code'] == _selectedLanguage,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${selectedLang['name']}'),
                      backgroundColor: AppColors.success1,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Apply Language',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required String code,
    required String name,
    required String nativeName,
    required String flag,
  }) {
    final isSelected = _selectedLanguage == code;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLanguage = code;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.red600.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.red600
                : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.red600.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Flag
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.red600.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  flag,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Language Names
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    nativeName,
                    style: TextStyle(
                      color: const Color(0xFF6A7282),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            // Check Mark
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.red600,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
