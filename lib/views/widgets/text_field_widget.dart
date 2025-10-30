import 'package:chefkit/common/app_colors.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.trailingIcon,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? trailingIcon;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      cursorColor: Colors.white,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: "LeagueSpartan",
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.all(17),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontFamily: "LeagueSpartan",
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.trailingIcon,
              color: AppColors.red600,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
