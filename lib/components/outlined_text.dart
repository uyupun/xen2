import 'package:flutter/material.dart';
import 'package:xen2/constants/app_colors.dart';

class OutlinedText extends StatelessWidget {
  const OutlinedText({super.key, required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: fontSize, color: AppColors.textPrimary);
    return Stack(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3
              ..color = Colors.white,
          ),
        ),
        Text(text, textAlign: TextAlign.center, style: style),
      ],
    );
  }
}
