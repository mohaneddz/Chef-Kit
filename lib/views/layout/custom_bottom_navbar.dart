import '../../common/constants.dart';
import 'package:flutter/material.dart';
import 'package:chefkit/l10n/app_localizations.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border(
          top: BorderSide(color: Colors.black.withOpacity(0.2)),
          left: BorderSide(color: Colors.black.withOpacity(0.2)),
          right: BorderSide(color: Colors.black.withOpacity(0.2)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.explore_outlined,
                  selectedIcon: Icons.explore,
                  label: AppLocalizations.of(context)!.navDiscovery,
                  index: 0,
                  color: AppColors.red600,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.shopping_bag_outlined,
                  selectedIcon: Icons.shopping_bag,
                  label: AppLocalizations.of(context)!.navInventory,
                  index: 1,
                  color: AppColors.red600,
                ),
              ),
              // center button with fixed width so tap areas don't overlap
              SizedBox(width: 80, child: Center(child: _buildCenterButton())),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.favorite_border,
                  selectedIcon: Icons.favorite,
                  label: AppLocalizations.of(context)!.navFavorite,
                  index: 3,
                  color: AppColors.red600,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: AppLocalizations.of(context)!.navProfile,
                  index: 4,
                  color: AppColors.red600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required Color color,
  }) {
    final isSelected = widget.selectedIndex == index;

    return GestureDetector(
      onTap: () => widget.onItemTapped(index),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              color: isSelected ? color : Colors.grey[400],
              size: 32,
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: SizedBox(
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: isSelected ? color : Colors.grey[400],
                      fontSize: isSelected ? 12 : 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: const Offset(0, -35),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.red600,
                      AppColors.red600,
                      Color(0xFFFFAA6B),
                    ],
                    stops: [0, 0.4, 1],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: const Color(0xFFFFAA6B).withOpacity(0.4),
                      blurRadius: 15,
                      spreadRadius: -2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => widget.onItemTapped(2),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated pulsing circle effect
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Container(
                            width: 60 * (1 + _animationController.value * 0.3),
                            height: 60 * (1 + _animationController.value * 0.3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFFFF6B6B).withOpacity(
                                    0.3 * (1 - _animationController.value),
                                  ),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Button itself
                      Container(
                        width: 60,
                        height: 60,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.local_fire_department,
                          color: Colors.white,
                          size: 32,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// import 'package:chefkit/common/app_colors.dart';
// import 'package:flutter/material.dart';

// class CustomBottomNavigationBar extends StatefulWidget {
//   final int selectedIndex;
//   final Function(int) onItemTapped;

//   const CustomBottomNavigationBar({
//     Key? key,
//     required this.selectedIndex,
//     required this.onItemTapped,
//   }) : super(key: key);

//   @override
//   State<CustomBottomNavigationBar> createState() =>
//       _CustomBottomNavigationBarState();
// }

// class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _scaleAnimation;
//   late Animation<double> _rotationAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat(reverse: true);

//     _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Curves.easeInOut,
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//           child: SizedBox(
//             height: 56,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Expanded(
//                   child: _buildNavItem(
//                     icon: Icons.explore_outlined,
//                     selectedIcon: Icons.explore,
//                     label: 'Discovery',
//                     index: 0,
//                     color: AppColors.red600,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildNavItem(
//                     icon: Icons.shopping_bag_outlined,
//                     selectedIcon: Icons.shopping_bag,
//                     label: 'Inventory',
//                     index: 1,
//                     color: AppColors.red600,
//                   ),
//                 ),
//                 Expanded(child: _buildCenterButton()),
//                 Expanded(
//                   child: _buildNavItem(
//                     icon: Icons.favorite_border,
//                     selectedIcon: Icons.favorite,
//                     label: 'Favorite',
//                     index: 3,
//                     color: AppColors.red600,
//                   ),
//                 ),
//                 Expanded(
//                   child: _buildNavItem(
//                     icon: Icons.person_outline,
//                     selectedIcon: Icons.person,
//                     label: 'Profile',
//                     index: 4,
//                     color: AppColors.red600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavItem({
//     required IconData icon,
//     required IconData selectedIcon,
//     required String label,
//     required int index,
//     required Color color,
//   }) {
//     final isSelected = widget.selectedIndex == index;

//     return GestureDetector(
//       onTap: () => widget.onItemTapped(index),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               isSelected ? selectedIcon : icon,
//               color: isSelected ? color : Colors.grey[400],
//               size: 26,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? color : Colors.grey[400],
//                 fontSize: 12,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCenterButton() {
//     return AnimatedBuilder(
//       animation: _animationController,
//       builder: (context, child) {
//         return Transform.translate(
//           offset: const Offset(0, -35),
//           child: Transform.scale(
//             scale: _scaleAnimation.value,
//             child: Transform.rotate(
//               angle: _rotationAnimation.value,
//               child: Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [
//                       Color(0xFFFF6B6B),
//                       Color(0xFFFF8E8E),
//                       Color(0xFFFFAA6B),
//                     ],
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                   ),
//                   shape: BoxShape.circle,
//                   boxShadow: [
//                     BoxShadow(
//                       color: const Color(0xFFFF6B6B).withOpacity(0.6),
//                       blurRadius: 20,
//                       spreadRadius: 2,
//                       offset: const Offset(0, 5),
//                     ),
//                     BoxShadow(
//                       color: const Color(0xFFFFAA6B).withOpacity(0.4),
//                       blurRadius: 15,
//                       spreadRadius: -2,
//                       offset: const Offset(0, 8),
//                     ),
//                   ],
//                 ),
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // Animated pulsing circle effect
//                     AnimatedBuilder(
//                       animation: _animationController,
//                       builder: (context, child) {
//                         return Container(
//                           width: 60 * (1 + _animationController.value * 0.3),
//                           height: 60 * (1 + _animationController.value * 0.3),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             gradient: RadialGradient(
//                               colors: [
//                                 Color(0xFFFF6B6B)
//                                     .withOpacity(0.3 * (1 - _animationController.value)),
//                                 Colors.transparent,
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                     // Button itself
//                     InkWell(
//                       borderRadius: BorderRadius.circular(30),
//                       onTap: () => widget.onItemTapped(2),
//                       child: Container(
//                         width: 60,
//                         height: 60,
//                         alignment: Alignment.center,
//                         child: Icon(
//                           Icons.local_fire_department,
//                           color: Colors.white,
//                           size: 32,
//                           shadows: [
//                             Shadow(
//                               color: Colors.black.withOpacity(0.3),
//                               offset: Offset(0, 2),
//                               blurRadius: 4,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
