import 'package:chefkit/common/constants.dart';
import 'package:chefkit/views/layout/triangle_painter.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final String hintText;

  const SearchBarWidget({
    super.key,
    this.hintText = 'Search ingredient ... ',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF0D0A2C).withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              cursorColor: Color(0xFF1C0F0D).withOpacity(0.7),
              style: TextStyle(
                color: Color(0xFF1C0F0D).withOpacity(0.7),
                fontSize: 18,
                fontFamily: "LeagueSpartan",
              ),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
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
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
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
              IconButton(onPressed: () {}, icon: Icon(Icons.search_outlined, color: AppColors.white, size: 30,)),
            ],
          ),
        ],
      ),
    );
  }
}
