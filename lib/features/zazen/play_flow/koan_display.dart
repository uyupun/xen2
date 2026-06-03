import 'package:flutter/material.dart';
import 'package:xen2/components/outlined_text.dart';
import 'package:xen2/features/zazen/koans.dart';

class KoanDisplay extends StatelessWidget {
  const KoanDisplay({super.key, required this.koan});

  final Koan koan;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedText(text: koan.ruby, fontSize: 10),
        OutlinedText(text: koan.character, fontSize: 20),
        const SizedBox(height: 12),
        OutlinedText(text: koan.description, fontSize: 14),
      ],
    );
  }
}
