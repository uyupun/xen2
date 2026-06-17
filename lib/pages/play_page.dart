import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/components/outlined_text.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/zazen/zazen_flow_provider.dart';
import 'package:xen2/features/zazen/zazen_katsu_provider.dart';
import 'package:xen2/features/zazen/play_flow/close_dialog.dart';
import 'package:xen2/features/zazen/play_flow/countdown_display.dart';
import 'package:xen2/features/zazen/play_flow/eyes_half_closed.dart';
import 'package:xen2/features/zazen/play_flow/katsu.dart';
import 'package:xen2/features/zazen/play_flow/koan_display.dart';
import 'package:xen2/features/zazen/play_flow/posture_confirmed.dart';
import 'package:xen2/features/zazen/play_flow/posture_detecting.dart';
import 'package:xen2/features/zazen/play_flow/zazen_ended.dart';
import 'package:xen2/features/zazen/play_flow/zazen_in_progress.dart';
import 'package:xen2/features/vr_player/dual_vr_player.dart';
import 'package:xen2/features/vr_player/dual_vr_player_controller_notifier_provider.dart';
import 'package:xen2/pages/result_page.dart';
import 'package:xen2/pages/top_page.dart';

class PlayPage extends StatefulHookConsumerWidget {
  const PlayPage({super.key});

  @override
  PlayPageState createState() => PlayPageState();
}

class PlayPageState extends ConsumerState<PlayPage>
    with WidgetsBindingObserver {
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _bellPlayer;

  late DualVrPlayerControllerNotifier _vrControllerNotifier;
  late ZazenFlow _zazenFlowNotifier;

  AttitudeData? _latestAttitude;
  AttitudeData? _postureBaseline;
  final List<AttitudeData> _postureHistory = [];
  StreamSubscription<AttitudeData>? _attitudeSub;
  Timer? _samplingTimer;
  Timer? _bgmStartTimer;
  bool _bgmActive = false;
  DateTime? _bgmStartScheduledAt;
  Duration? _bgmStartDelay;
  Duration? _bgmStartRemaining;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vrControllerNotifier = ref.read(dualVrPlayerControllerProvider.notifier);
    _zazenFlowNotifier = ref.read(zazenFlowProvider.notifier);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    WidgetsBinding.instance.removeObserver(this);
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _bellPlayer.stop();
    _bellPlayer.dispose();
    _attitudeSub?.cancel();
    _samplingTimer?.cancel();
    _bgmStartTimer?.cancel();
    _vrControllerNotifier.pause();
    _zazenFlowNotifier.reset();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
        _onAppPaused();
      case AppLifecycleState.resumed:
        _onAppResumed();
      default:
        break;
    }
  }

  void _onAppPaused() {
    _zazenFlowNotifier.pause();
    _samplingTimer?.cancel();
    _pauseBgm();
  }

  void _onAppResumed() {
    _zazenFlowNotifier.resume();
    final phase = ref.read(zazenFlowProvider).phase;
    // 再開カウントダウン中はカウントダウン終了時にBGMを再開する
    if (phase == ZazenFlowPhase.resumeCountdown) return;
    _resumeBgm();
    if (phase == ZazenFlowPhase.inProgress) {
      _startSampling();
    }
  }

  void _showCloseDialog(BuildContext context) {
    _zazenFlowNotifier.pause();
    _samplingTimer?.cancel();
    _pauseBgm();

    final navigator = Navigator.of(context);
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CloseDialog(
        onContinue: () => Navigator.pop(ctx, false),
        onExit: () => Navigator.pop(ctx, true),
      ),
    ).then((shouldExit) {
      if (!mounted) return;
      if (shouldExit == true) {
        navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const TopPage()),
        );
      } else {
        // 坐禅中の場合はカウントダウンを挟んで再開する
        _zazenFlowNotifier.resumeWithCountdown();
        // 再開カウントダウン中はカウントダウン終了時にBGMを再開する
        if (ref.read(zazenFlowProvider).phase != ZazenFlowPhase.resumeCountdown) {
          _resumeBgm();
        }
      }
    });
  }

  void _scheduleBgmStart(Duration delay) {
    _bgmStartTimer?.cancel();
    _bgmStartScheduledAt = DateTime.now();
    _bgmStartDelay = delay;
    _bgmStartTimer = Timer(delay, () {
      _bgmActive = true;
      _bgmPlayer.play(AssetSource('assets/pink_noise.mp3'), volume: 0.25);
    });
  }

  void _pauseBgm() {
    // BGM開始前に中断された場合は残り時間を保存して再開時に復元する
    if (_bgmStartTimer?.isActive ?? false) {
      final elapsed = DateTime.now().difference(_bgmStartScheduledAt!);
      final remaining = _bgmStartDelay! - elapsed;
      _bgmStartRemaining = remaining.isNegative ? Duration.zero : remaining;
    }
    _bgmStartTimer?.cancel();
    if (_bgmActive) _bgmPlayer.pause();
  }

  void _resumeBgm() {
    if (_bgmActive) {
      _bgmPlayer.resume();
    } else if (_bgmStartRemaining != null) {
      _scheduleBgmStart(_bgmStartRemaining!);
      _bgmStartRemaining = null;
    }
  }

  void _onPhaseChanged(ZazenFlowPhase? prev, ZazenFlowPhase next) {
    switch (next) {
      case ZazenFlowPhase.postureConfirmed:
        _postureBaseline = _latestAttitude;
      case ZazenFlowPhase.inProgress:
        // 中断からの再開時は鐘を再度再生せず、BGMを再開する
        if (prev == ZazenFlowPhase.resumeCountdown) {
          _startSampling();
          _resumeBgm();
          return;
        }
        _vrControllerNotifier.play();
        _startSampling();
        _bellPlayer.play(
          AssetSource('assets/temple_bell_start.mp3'),
          volume: 0.5,
        );
        _scheduleBgmStart(const Duration(seconds: 9));
      case ZazenFlowPhase.ended:
        _bgmStartTimer?.cancel();
        _bgmStartRemaining = null;
        _bgmActive = false;
        _samplingTimer?.cancel();
        _samplingTimer = null;
        _vrControllerNotifier.pause();
        _bgmPlayer.stop();
        _bellPlayer.play(
          AssetSource('assets/temple_bell_end.mp3'),
          volume: 0.5,
        );
      default:
        break;
    }
  }

  void _startSampling() {
    _samplingTimer?.cancel();
    _samplingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_latestAttitude != null) _postureHistory.add(_latestAttitude!);
    });
  }

  Widget _buildForegroundWidget(ZazenFlowState flow, KatsuStatus katsu) {
    if (katsu == KatsuStatus.warning &&
        flow.phase == ZazenFlowPhase.inProgress) {
      return const Katsu();
    }

    return switch (flow.phase) {
      ZazenFlowPhase.idle => const SizedBox.shrink(),
      ZazenFlowPhase.calibrating => const PostureDetecting(),
      ZazenFlowPhase.postureConfirmed => const PostureConfirmed(),
      ZazenFlowPhase.koan =>
        flow.koan != null
            ? KoanDisplay(koan: flow.koan!)
            : const SizedBox.shrink(),
      ZazenFlowPhase.eyesHalfClosed => const EyesHalfClosed(),
      ZazenFlowPhase.countdown => CountdownDisplay(count: flow.countdownValue),
      ZazenFlowPhase.inProgress => const ZazenInProgress(),
      ZazenFlowPhase.resumeCountdown => CountdownDisplay(
        count: flow.countdownValue,
      ),
      ZazenFlowPhase.ended => const ZazenEnded(),
      ZazenFlowPhase.tapWaiting => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(zazenFlowProvider);
    final katsuStatus = ref.watch(zazenKatsuProvider);

    ref.listen(zazenFlowProvider.select((s) => s.phase), _onPhaseChanged);

    useEffect(() {
      _zazenFlowNotifier.start();
      return _zazenFlowNotifier.reset;
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          DualVrPlayer(
            assetPath: 'assets/skybox.mp4',
            foregroundWidget: _buildForegroundWidget(flowState, katsuStatus),
          ),
          if (flowState.phase == ZazenFlowPhase.tapWaiting)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => ResultPage(
                      postureHistory: List.unmodifiable(_postureHistory),
                      postureBaseline: _postureBaseline,
                    ),
                  ),
                ),
                child: const ColoredBox(
                  color: Colors.transparent,
                  child: Center(
                    child: OutlinedText(text: 'タップしてください', fontSize: 20),
                  ),
                ),
              ),
            ),
          // 坐禅終了後は中断ダイアログを表示しない
          if (flowState.phase != ZazenFlowPhase.ended &&
              flowState.phase != ZazenFlowPhase.tapWaiting)
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.background),
                onPressed: () => _showCloseDialog(context),
              ),
            ),
        ],
      ),
    );
  }
}
