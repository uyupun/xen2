import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/components/outlined_text.dart';
import 'package:xen2/features/pavlok/pavlok_provider.dart';
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

  Future<void> _runZazenFlow(ValueNotifier<Widget> foregroundWidget) async {
    // 姿勢の検証
    await Future.delayed(const Duration(seconds: 15));

    // 検証完了
    foregroundWidget.value = const _PostureConfirmed();
    await Future.delayed(const Duration(seconds: 5));

    // 坐禅開始（動画と音声を再生）
    foregroundWidget.value = const _ZazenInProgress();
    ref.read(dualVrPlayerControllerProvider.notifier).play();
    await _bellPlayer.play(
      AssetSource('assets/temple_bell_start.mp3'),
      volume: 0.5,
    );
    await Future.delayed(const Duration(seconds: 9));
    // todo: ループ時に音が途切れないようにしたい
    await _bgmPlayer.play(AssetSource('assets/pink_noise.mp3'), volume: 0.25);
    await Future.delayed(const Duration(seconds: 30));

    // 喝（Pavlokへ通信して刺激を与える）
    foregroundWidget.value = const _Katsu();
    await Future.delayed(const Duration(seconds: 30));

    // 坐禅終了（動画と音声を停止）
    foregroundWidget.value = const _ZazenEnding();
    ref.read(dualVrPlayerControllerProvider.notifier).pause();
    await _bgmPlayer.stop();
    await _bellPlayer.play(AssetSource('assets/temple_bell.mp3'), volume: 0.5);
    await Future.delayed(const Duration(seconds: 3));

    // リザルト画面の表示
    foregroundWidget.value = const _ResultDisplay();
  }

  @override
  Widget build(BuildContext context) {
    final foregroundWidget = useState<Widget>(const _PostureDetecting());

    useEffect(() {
      _runZazenFlow(foregroundWidget);

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

class _PostureDetecting extends StatelessWidget {
  const _PostureDetecting();

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

class _PostureConfirmed extends StatelessWidget {
  const _PostureConfirmed();

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

class _ZazenInProgress extends StatelessWidget {
  const _ZazenInProgress();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _Katsu extends HookConsumerWidget {
  const _Katsu();

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

class _ZazenEnding extends StatelessWidget {
  const _ZazenEnding();

  @override
  Widget build(BuildContext context) {
    return const OutlinedText(text: '終了', fontSize: 20);
  }
}

class _ResultDisplay extends StatelessWidget {
  const _ResultDisplay();

  @override
  Widget build(BuildContext context) {
    return const OutlinedText(text: '終了', fontSize: 20);
  }
}
