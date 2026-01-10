import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/layout/triangle_painter.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SearchBarWidget extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search ingredient ... ',
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0xFF0D0A2C).withOpacity(isDark ? 0.2 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: AbsorbPointer(
                absorbing: onTap != null,
                child: TextFormField(
                  onChanged: onChanged,
                  readOnly: onTap != null,
                  cursorColor: theme.textTheme.bodyLarge?.color,
                  style: TextStyle(
                    color: theme.textTheme.bodyLarge?.color,
                    fontSize: 18,
                    fontFamily: "LeagueSpartan",
                  ),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: isDark ? AppColors.darkCard : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusDirectional.horizontal(
                    end: Radius.circular(10),
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(isRtl ? math.pi : 0),
                    child: CustomPaint(
                      size: Size(70, 49),
                      painter: TrianglePainter(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFFF7B00),
                            Color(0xFFFFA547),
                            Color(0xFFFFC48B),
                          ],
                        ),
                        stratProportion: 1,
                        endProportion: 0,
                        adjustment: 0.7,
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadiusDirectional.horizontal(
                    end: Radius.circular(10),
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(isRtl ? math.pi : 0),
                    child: CustomPaint(
                      size: Size(90, 49),
                      painter: TrianglePainter(
                        isReversed: true,
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFFEF2A39).withOpacity(0.75),
                            Color(0xFFFFC58F),
                          ],
                          stops: [0.2, 1],
                        ),
                        stratProportion: 1,
                        endProportion: 0,
                        adjustment: 0.6,
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.search_outlined,
                    color: AppColors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
