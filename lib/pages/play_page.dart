import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/components/outlined_text.dart';
import 'package:xen2/features/vr_player/dual_vr_player.dart';
import 'package:xen2/features/vr_player/dual_vr_player_controller_notifier_provider.dart';

class PlayPage extends HookConsumerWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vrPlayerController = ref.watch(
      dualVrPlayerControllerProvider.notifier,
    );
    final foregroundWidget = useState<Widget>(const _Flow1());

    useEffect(() {
      // 姿勢の検知
      Future.delayed(const Duration(seconds: 20), () {
        foregroundWidget.value = const _Flow2();
      }).then((_) {
        // 検知後に動画と音声を再生
        Future.delayed(const Duration(seconds: 5), () {
          foregroundWidget.value = const _Flow3();
          vrPlayerController.play();
        }).then((_) {
          // 動画と音声を停止
          Future.delayed(const Duration(seconds: 60), () {
            vrPlayerController.pause();
            foregroundWidget.value = const _Flow4();
          });
        });
      });

      return null;
    }, []);

    return Scaffold(
      body: DualVrPlayer(
        assetPath: 'assets/skybox.mp4',
        foregroundWidget: foregroundWidget.value,
      ),
    );
  }
}

class _Flow1 extends StatelessWidget {
  const _Flow1();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedText(text: 'VRゴーグルを装着して\n坐禅の姿勢でお待ちください', fontSize: 20),
        SizedBox(height: 8),
        OutlinedText(text: '検知中...', fontSize: 14),
      ],
    );
  }
}

class _Flow2 extends StatelessWidget {
  const _Flow2();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedText(text: '姿勢を確認しました', fontSize: 20),
        SizedBox(height: 8),
        OutlinedText(text: 'まもなく開始します', fontSize: 14),
      ],
    );
  }
}

class _Flow3 extends StatelessWidget {
  const _Flow3();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _Flow4 extends StatelessWidget {
  const _Flow4();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedText(text: '終了しました', fontSize: 20),
        SizedBox(height: 8),
        OutlinedText(text: 'ご利用ありがとうございました', fontSize: 14),
      ],
    );
  }
}
