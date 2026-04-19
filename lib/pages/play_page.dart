import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/components/outlined_text.dart';
import 'package:xen2/features/vr_player/dual_vr_player.dart';
import 'package:xen2/features/vr_player/dual_vr_player_controller_notifier_provider.dart';

class PlayPage extends StatefulHookConsumerWidget {
  const PlayPage({super.key});

  @override
  PlayPageState createState() => PlayPageState();
}

class PlayPageState extends ConsumerState<PlayPage> {
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _bellPlayer;

  @override
  void initState() {
    super.initState();
    _bgmPlayer = AudioPlayer();
    _bgmPlayer.audioCache.prefix = '';
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bellPlayer = AudioPlayer();
    _bellPlayer.audioCache.prefix = '';
  }

  @override
  void dispose() {
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _bellPlayer.stop();
    _bellPlayer.dispose();
    super.dispose();
  }

  Future<void> _flow(ValueNotifier<Widget> foregroundWidget) async {
    // 姿勢の検証
    await Future.delayed(const Duration(seconds: 15));

    // 検証完了
    foregroundWidget.value = const _Flow2();
    await Future.delayed(const Duration(seconds: 5));

    // 坐禅開始（動画と音声を再生）
    foregroundWidget.value = const _Flow3();
    ref.read(dualVrPlayerControllerProvider.notifier).play();
    await _bellPlayer.play(
      AssetSource('assets/temple_bell_start.mp3'),
      volume: 0.5,
    );
    await Future.delayed(const Duration(seconds: 9));
    // todo: ループ時に音が途切れないようにしたい
    await _bgmPlayer.play(AssetSource('assets/pink_noise.mp3'), volume: 0.25);
    await Future.delayed(const Duration(seconds: 60));

    // 坐禅終了（動画と音声を停止）
    foregroundWidget.value = const _Flow4();
    ref.read(dualVrPlayerControllerProvider.notifier).pause();
    await _bgmPlayer.stop();
    await _bellPlayer.play(AssetSource('assets/temple_bell.mp3'), volume: 0.5);
    await Future.delayed(const Duration(seconds: 3));

    // リザルト画面の表示
    foregroundWidget.value = const _Flow5();
  }

  @override
  Widget build(BuildContext context) {
    final foregroundWidget = useState<Widget>(const _Flow1());

    useEffect(() {
      _flow(foregroundWidget);

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
    return const OutlinedText(text: '終了', fontSize: 20);
  }
}

class _Flow5 extends StatelessWidget {
  const _Flow5();

  @override
  Widget build(BuildContext context) {
    return const OutlinedText(text: '終了', fontSize: 20);
  }
}
