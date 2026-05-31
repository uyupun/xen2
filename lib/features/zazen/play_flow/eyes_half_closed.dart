import 'package:flutter/material.dart';
import 'package:xen2/components/outlined_text.dart';

class EyesHalfClosed extends StatelessWidget {
  const EyesHalfClosed({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [OutlinedText(text: '目は半分ほど閉じることを推奨します', fontSize: 20)],
    );
  }
}
