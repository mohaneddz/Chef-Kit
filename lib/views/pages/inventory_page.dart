import 'package:chefkit/common/app_colors.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(child: Column(
        children: [
          SizedBox(
            width: 144,
            height: 173,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 144,
                  height: 117,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white
                  ),
                )
              ],
            )
          )
        ],
      )),
    );
  }
}
