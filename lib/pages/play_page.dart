import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/components/outlined_text.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/zazen/zazen_flow_provider.dart';
import 'package:xen2/features/zazen/zazen_katsu_provider.dart';
import 'package:xen2/features/zazen/play_flow/countdown_display.dart';
import 'package:xen2/features/zazen/play_flow/eyes_half_closed.dart';
import 'package:xen2/features/zazen/play_flow/katsu.dart';
import 'package:xen2/features/zazen/play_flow/koan_display.dart';
import 'package:xen2/features/zazen/play_flow/posture_confirmed.dart';
import 'package:xen2/features/zazen/play_flow/posture_detecting.dart';
import 'package:xen2/features/zazen/play_flow/result_display.dart';
import 'package:xen2/features/zazen/play_flow/zazen_ended.dart';
import 'package:xen2/features/zazen/play_flow/zazen_in_progress.dart';
import 'package:xen2/features/vr_player/dual_vr_player.dart';
import 'package:xen2/features/vr_player/dual_vr_player_controller_notifier_provider.dart';
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
    ref.read(zazenFlowProvider.notifier).pause();
    _bgmStartTimer?.cancel();
    _samplingTimer?.cancel();
    if (_bgmActive) _bgmPlayer.pause();
  }

  void _onAppResumed() {
    ref.read(zazenFlowProvider.notifier).resume();
    if (_bgmActive) _bgmPlayer.resume();
    if (ref.read(zazenFlowProvider).phase == ZazenFlowPhase.inProgress) {
      _startSampling();
    }
  }

  void _onPhaseChanged(ZazenFlowPhase? prev, ZazenFlowPhase next) {
    switch (next) {
      case ZazenFlowPhase.postureConfirmed:
        _postureBaseline = _latestAttitude;
      case ZazenFlowPhase.inProgress:
        _vrControllerNotifier.play();
        _startSampling();
        _bellPlayer.play(
          AssetSource('assets/temple_bell_start.mp3'),
          volume: 0.5,
        );
        _bgmStartTimer = Timer(const Duration(seconds: 9), () {
          _bgmActive = true;
          _bgmPlayer.play(AssetSource('assets/pink_noise.mp3'), volume: 0.25);
        });
      case ZazenFlowPhase.ended:
        _bgmStartTimer?.cancel();
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
      ZazenFlowPhase.ended => const ZazenEnded(),
      ZazenFlowPhase.tapWaiting => const SizedBox.shrink(),
      ZazenFlowPhase.result => ResultDisplay(
        postureHistory: List.unmodifiable(_postureHistory),
        postureBaseline: _postureBaseline,
      ),
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
                onTap: () =>
                    ref.read(zazenFlowProvider.notifier).advanceToResult(),
                child: const ColoredBox(
                  color: Colors.transparent,
                  child: Center(
                    child: OutlinedText(text: 'タップしてください', fontSize: 20),
                  ),
                ),
              ),
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
