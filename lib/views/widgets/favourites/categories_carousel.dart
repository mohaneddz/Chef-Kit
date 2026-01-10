import 'package:chefkit/views/widgets/favourites/collection_card.dart';
import 'package:flutter/material.dart';

class CategoriesCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategoryTap;
  final PageController pageController;

  const CategoriesCarousel({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategoryTap,
    required this.pageController,
  });

  void _handleTap(int index) {
    final realIndex = index % categories.length;
    onCategoryTap(realIndex);

    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox(height: 130);
    }

    // When fewer than 3 categories, use a simpler centered layout
    if (categories.length < 3) {
      return SizedBox(
        height: 130,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: categories.asMap().entries.map((entry) {
            final index = entry.key;
            final categoryData = entry.value;
            return GestureDetector(
              onTap: () => onCategoryTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: AnimatedScale(
                  scale: selectedIndex == index ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 200),
                  child: SizedBox(
                    width:
                        (MediaQuery.of(context).size.width - 60) /
                        categories.length,
                    child: CollectionCard(
                      title: categoryData['title'],
                      subtitle: categoryData['subtitle'],
                      imagePaths: List<String>.from(categoryData['imagePaths']),
                      isActive: selectedIndex == index,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: PageView.builder(
        controller: pageController,
        clipBehavior: Clip.none,
        itemBuilder: (context, index) {
          final realIndex = index % categories.length;
          final categoryData = categories[realIndex];
          return GestureDetector(
            onTap: () => _handleTap(index),
            child: AnimatedScale(
              scale: selectedIndex == realIndex ? 1.0 : 0.9,
              duration: const Duration(milliseconds: 200),
              child: CollectionCard(
                title: categoryData['title'],
                subtitle: categoryData['subtitle'],
                imagePaths: List<String>.from(categoryData['imagePaths']),
                isActive: selectedIndex == realIndex,
              ),
            ),
          );
        },
      ),
    );
  }
}
