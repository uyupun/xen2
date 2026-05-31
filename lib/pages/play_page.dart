import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/zazen/koans.dart';
import 'package:xen2/features/zazen/zazen_calibration_provider.dart';
import 'package:xen2/features/zazen/play_flow/countdown_display.dart';
import 'package:xen2/features/zazen/play_flow/eyes_half_closed.dart';
import 'package:xen2/features/zazen/play_flow/katsu.dart';
import 'package:xen2/features/zazen/play_flow/koan_display.dart';
import 'package:xen2/features/zazen/play_flow/posture_confirmed.dart';
import 'package:xen2/features/zazen/play_flow/posture_detecting.dart';
import 'package:xen2/features/zazen/play_flow/result_display.dart';
import 'package:xen2/features/zazen/play_flow/zazen_in_progress.dart';
import 'package:xen2/features/vr_player/dual_vr_player.dart';
import 'package:xen2/features/vr_player/dual_vr_player_controller_notifier_provider.dart';
import 'package:xen2/pages/top_page.dart';

class PlayPage extends StatefulHookConsumerWidget {
  const PlayPage({super.key});

  @override
  PlayPageState createState() => PlayPageState();
}

class PlayPageState extends ConsumerState<PlayPage> {
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _bellPlayer;

  AttitudeData? _latestAttitude;
  AttitudeData? _postureBaseline;
  final List<AttitudeData> _postureHistory = [];
  StreamSubscription<AttitudeData>? _attitudeSub;
  Timer? _samplingTimer;

  @override
  void initState() {
    super.initState();
    _bgmPlayer = AudioPlayer();
    _bgmPlayer.audioCache.prefix = '';
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bellPlayer = AudioPlayer();
    _bellPlayer.audioCache.prefix = '';
    _attitudeSub = ImuService.instance.attitudeStream.listen((data) {
      _latestAttitude = data;
    });
  }

  @override
  void dispose() {
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _bellPlayer.stop();
    _bellPlayer.dispose();
    _attitudeSub?.cancel();
    _samplingTimer?.cancel();
    super.dispose();
  }

  Future<void> _runZazenFlow(ValueNotifier<Widget> foregroundWidget) async {
    // キャリブレーション（VRゴーグル装着＋正面向きを5秒間維持で完了）
    await ref.read(zazenCalibrationProvider.notifier).start();

    // キャリブレーション完了 + ベースライン記録
    _postureBaseline = _latestAttitude;
    foregroundWidget.value = const PostureConfirmed();
    await Future.delayed(const Duration(seconds: 3));

    // 公案をランダムに表示
    foregroundWidget.value = KoanDisplay(koan: randomKoan());
    await Future.delayed(const Duration(seconds: 10));

    // 目を半分閉じることを推奨
    foregroundWidget.value = const EyesHalfClosed();
    await Future.delayed(const Duration(seconds: 5));

    // カウントダウン 3 / 2 / 1
    for (var i = 3; i >= 1; i--) {
      foregroundWidget.value = CountdownDisplay(count: i);
      await Future.delayed(const Duration(seconds: 1));
    }

    // 坐禅開始（動画と音声を再生）+ 1秒ごとにサンプリング開始
    foregroundWidget.value = const ZazenInProgress();
    ref.read(dualVrPlayerControllerProvider.notifier).play();
    _samplingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_latestAttitude != null) _postureHistory.add(_latestAttitude!);
    });
    await _bellPlayer.play(
      AssetSource('assets/temple_bell_start.mp3'),
      volume: 0.5,
    );
    await Future.delayed(const Duration(seconds: 9));
    // todo: ループ時に音が途切れないようにしたい
    await _bgmPlayer.play(AssetSource('assets/pink_noise.mp3'), volume: 0.25);
    await Future.delayed(const Duration(seconds: 30));

    // 喝（Pavlokへ通信して刺激を与える）
    foregroundWidget.value = const Katsu();
    await Future.delayed(const Duration(seconds: 30));

    // 坐禅終了（動画と音声を停止）+ サンプリング停止
    _samplingTimer?.cancel();
    _samplingTimer = null;
    ref.read(dualVrPlayerControllerProvider.notifier).pause();
    await _bgmPlayer.stop();
    await _bellPlayer.stop();
    await _bellPlayer.play(
      AssetSource('assets/temple_bell_end.mp3'),
      volume: 0.5,
    );
    await Future.delayed(const Duration(seconds: 3));

    // リザルト画面の表示
    foregroundWidget.value = ResultDisplay(
      postureHistory: List.unmodifiable(_postureHistory),
      postureBaseline: _postureBaseline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final foregroundWidget = useState<Widget>(const PostureDetecting());

    useEffect(() {
      _runZazenFlow(foregroundWidget);

      return null;
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          DualVrPlayer(
            assetPath: 'assets/skybox.mp4',
            foregroundWidget: foregroundWidget.value,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const TopPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
