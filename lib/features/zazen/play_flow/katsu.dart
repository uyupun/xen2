import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:xen2/components/outlined_text.dart';

class Katsu extends HookWidget {
  const Katsu({super.key});

  @override
  Widget build(BuildContext context) {
    final countdown = useState(3);
    useEffect(() {
      if (countdown.value > 0) {
        Future.delayed(const Duration(seconds: 1), () {
          countdown.value -= 1;
        });
      }
      return null;
    }, [countdown.value]);

    final text = countdown.value > 0 ? '警策を行います: ${countdown.value}' : '';

    return OutlinedText(text: text, fontSize: 20);
  }
}
