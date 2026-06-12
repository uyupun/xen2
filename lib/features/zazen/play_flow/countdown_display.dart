import 'package:flutter/material.dart';
import 'package:xen2/components/outlined_text.dart';

class CountdownDisplay extends StatelessWidget {
  const CountdownDisplay({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return OutlinedText(text: '$count', fontSize: 20);
  }
}
