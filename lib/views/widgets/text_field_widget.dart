import 'package:chefkit/common/constants.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatefulWidget {
  const TextFieldWidget({
    super.key,
    required this.controller,
    required this.hintText,
    this.trailingIcon,
    this.isPassword = false,
    this.errorText,
    this.textColor = Colors.white,
    this.hintColor = Colors.white,
    this.fillColor,
    this.borderColor = Colors.white,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? trailingIcon;
  final bool isPassword;
  final String? errorText;
  final Color textColor;
  final Color hintColor;
  final Color? fillColor;
  final Color borderColor;

  @override
  State<TextFieldWidget> createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      cursorColor: widget.textColor,
      style: TextStyle(
        color: widget.textColor,
        fontSize: 16,
        fontFamily: "LeagueSpartan",
      ),
      decoration: InputDecoration(
        fillColor: widget.fillColor ?? Colors.white.withOpacity(0.15),
        filled: true,
        contentPadding: const EdgeInsets.all(17),
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: widget.hintColor,
          fontSize: 16,
          fontFamily: "LeagueSpartan",
        ),
        errorText: widget.errorText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: widget.borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: widget.borderColor, width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: AppColors.red600.withOpacity(0.5),
            width: 2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.red600, width: 2.2),
        ),
        errorStyle: const TextStyle(
          color: AppColors.red600,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 20.0),
          child: Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              // Background of icon circle adapts to light/dark
              // If text is dark (light bg), icon bg should be light grey?
              // Let's keep it simple: White circle if text is white,
              // Dark circle if text is dark might be weird.
              // Let's use logic: if textColor is white -> white circle. if black -> grey circle.
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            // We need to fix this container color to be adaptable too?
            // For now let's keep it white as the user main color is red, red on white looks good.
            // But if background is white, white on white is invisible.
            // Let's add iconBackgroundColor

            // Wait, I can't add complex logic inside the build easily without clutter.
            // Let's just create a decoration that works for both or simply use white.
            // If the background of the Input is "filled", "white" icon bg is fine usually.
            // Actually, if I have a white background page, and grey input fill, white icon circle looks okay.
            child: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.red600,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() => _obscure = !_obscure);
                    },
                  )
                : Icon(widget.trailingIcon, color: AppColors.red600, size: 20),
          ),
        ),
      ),
    );
  }
}
