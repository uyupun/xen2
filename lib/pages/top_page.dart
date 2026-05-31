import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/components/gradient_slider.dart';
import 'package:xen2/components/primary_button.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/features/zazen/zazen_duration_provider.dart';
import 'package:xen2/pages/play_page.dart';

class TopPage extends ConsumerWidget {
  const TopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(zazenDurationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Xen',
                  style: TextStyle(fontSize: 48, height: 1, letterSpacing: 10),
                ),
                Text('Extreme Xen', style: TextStyle(fontSize: 14, height: 1)),
              ],
            ),
            SizedBox(
              width: 400,
              child: GradientSlider(
                value: duration,
                onChanged: (minutes) {
                  ref.read(zazenDurationProvider.notifier).update(minutes);
                },
              ),
            ),
            SizedBox(
              width: 250,
              child: PrimaryButton(
                label: '禅',
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PlayPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
