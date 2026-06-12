import 'package:flutter/material.dart';
import 'package:xen2/components/outlined_text.dart';

class ZazenEnded extends StatelessWidget {
  const ZazenEnded({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedText(text: 'お疲れ様でした', fontSize: 20),
        SizedBox(height: 8),
        OutlinedText(text: 'VRゴーグルを外してください', fontSize: 20),
      ],
    );
  }
}
