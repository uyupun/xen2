import 'package:flutter/material.dart';
import 'package:xen2/components/outlined_text.dart';

class PostureConfirmed extends StatelessWidget {
  const PostureConfirmed({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedText(text: 'VRゴーグルを装着して\n坐禅の姿勢でお待ちください', fontSize: 20),
        SizedBox(height: 8),
        OutlinedText(text: '調整済み', fontSize: 14),
      ],
    );
  }
}
