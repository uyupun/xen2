import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/components/outlined_text.dart';
import 'package:xen2/features/pavlok/pavlok_provider.dart';

class Katsu extends HookConsumerWidget {
  const Katsu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = useState(3);
    useEffect(() {
      if (countdown.value >= 0) {
        Future.delayed(const Duration(seconds: 1), () async {
          countdown.value -= 1;
          if (countdown.value == 0) {
            ref.read(pavlokProvider.future).catchError((e) {
              debugPrint('Failed to connect to Pavlok: $e');
            });
          }
        });
      }
      return null;
    }, [countdown.value]);

    final text = countdown.value > 0 ? '警策を行います: ${countdown.value}' : '';

    return OutlinedText(text: text, fontSize: 20);
  }
}
