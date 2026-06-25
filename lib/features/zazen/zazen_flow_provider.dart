import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/zazen/koans.dart';
import 'package:xen2/features/zazen/zazen_calibration_provider.dart';
import 'package:xen2/features/zazen/zazen_duration_provider.dart';
import 'package:xen2/features/zazen/zazen_katsu_provider.dart';

part 'zazen_flow_provider.g.dart';

enum ZazenFlowPhase {
  idle,
  calibrating,
  postureConfirmed,
  koan,
  eyesHalfClosed,
  countdown,
  inProgress,
  resumeCountdown,
  ended,
  tapWaiting,
}

class ZazenFlowState {
  const ZazenFlowState({
    this.phase = ZazenFlowPhase.idle,
    this.countdownValue = 3,
    this.koan,
  });

  final ZazenFlowPhase phase;
  final int countdownValue;
  final Koan? koan;

  ZazenFlowState copyWith({
    ZazenFlowPhase? phase,
    int? countdownValue,
    Koan? koan,
  }) => ZazenFlowState(
    phase: phase ?? this.phase,
    countdownValue: countdownValue ?? this.countdownValue,
    koan: koan ?? this.koan,
  );
}

@Riverpod(keepAlive: true)
class ZazenFlow extends _$ZazenFlow {
  // フェーズタイマー
  Timer? _timer;
  DateTime? _timerStartedAt;
  Duration? _timerDuration;
  VoidCallback? _timerCallback;
  Duration? _savedRemaining;

  // 喝再開タイマー
  Timer? _katsuResumeTimer;

  // 再開カウントダウンタイマー
  Timer? _resumeCountdownTimer;

  // IMU・サンプリング（PlayPageから移管）
  StreamSubscription<AttitudeData>? _imuSub;
  AttitudeData? _latestAttitude;
  Timer? _samplingTimer;
  final List<AttitudeData> _postureHistory = [];
  AttitudeData? _postureBaseline;

  /// リザルト画面用ゲッター
  List<AttitudeData> get postureHistory => List.unmodifiable(_postureHistory);
  AttitudeData? get postureBaseline => _postureBaseline;

  @override
  ZazenFlowState build() {
    ref.onDispose(() {
      _timer?.cancel();
      _katsuResumeTimer?.cancel();
      _resumeCountdownTimer?.cancel();
      _samplingTimer?.cancel();
      _imuSub?.cancel();
    });

    ref.listen(zazenCalibrationProvider, (_, next) {
      if (next == CalibrationStatus.calibrated &&
          state.phase == ZazenFlowPhase.calibrating) {
        _onCalibrationDone();
      }
    });

    return const ZazenFlowState();
  }

  // ---- Public API ----

  void start() {
    _cancelAllTimers();
    _imuSub?.cancel();
    _postureHistory.clear();
    _postureBaseline = null;
    _imuSub = ImuService.instance.attitudeStream.listen((data) {
      _latestAttitude = data;
    });
    // ビルドフェーズ中の状態変更を避けるため1フレーム遅延させる
    Future<void>(() {
      ref.read(zazenCalibrationProvider.notifier).reset();
      ref.read(zazenKatsuProvider.notifier).stop();
      state = const ZazenFlowState(phase: ZazenFlowPhase.calibrating);
      ref.read(zazenCalibrationProvider.notifier).start();
    });
  }

  void pause() {
    _saveTimer();
    _samplingTimer?.cancel();
    _katsuResumeTimer?.cancel();
    _resumeCountdownTimer?.cancel();
    if (state.phase == ZazenFlowPhase.calibrating) {
      ref.read(zazenCalibrationProvider.notifier).reset();
    }
    if (state.phase == ZazenFlowPhase.inProgress) {
      ref.read(zazenKatsuProvider.notifier).pause();
    }
  }

  void resume() {
    if (state.phase == ZazenFlowPhase.resumeCountdown) {
      _startResumeCountdown();
      return;
    }
    _restoreTimer();
    if (state.phase == ZazenFlowPhase.calibrating) {
      ref.read(zazenCalibrationProvider.notifier).start();
    }
    if (state.phase == ZazenFlowPhase.inProgress) {
      _startSampling();
      _resumeKatsu();
    }
  }

  void resumeWithCountdown() {
    if (state.phase == ZazenFlowPhase.inProgress ||
        state.phase == ZazenFlowPhase.resumeCountdown) {
      _startResumeCountdown();
    } else {
      resume();
    }
  }

  void reset() {
    _cancelAllTimers();
    _imuSub?.cancel();
    _imuSub = null;
    _postureHistory.clear();
    _postureBaseline = null;
    // ビルドフェーズ中の状態変更を避けるため1フレーム遅延させる
    Future<void>(() {
      ref.read(zazenCalibrationProvider.notifier).reset();
      ref.read(zazenKatsuProvider.notifier).stop();
      state = const ZazenFlowState();
    });
  }

  // ---- Phase transitions ----

  void _onCalibrationDone() {
    _postureBaseline = _latestAttitude;
    // 音を先出しするため、状態変更を100ms遅延させる
    Timer(const Duration(milliseconds: 100), () {
      state = state.copyWith(phase: ZazenFlowPhase.postureConfirmed);
      _schedule(const Duration(seconds: 3), _toKoan);
    });
  }

  void _toKoan() {
    state = state.copyWith(phase: ZazenFlowPhase.koan, koan: randomKoan());
    _schedule(const Duration(seconds: 15), _toEyesHalfClosed);
  }

  void _toEyesHalfClosed() {
    state = state.copyWith(phase: ZazenFlowPhase.eyesHalfClosed);
    _schedule(const Duration(seconds: 5), _startCountdown);
  }

  void _startCountdown() {
    state = state.copyWith(phase: ZazenFlowPhase.countdown, countdownValue: 3);
    _schedule(const Duration(seconds: 1), _tickCountdown);
  }

  void _tickCountdown() {
    final next = state.countdownValue - 1;
    if (next > 0) {
      state = state.copyWith(countdownValue: next);
      _schedule(const Duration(seconds: 1), _tickCountdown);
    } else {
      _toInProgress();
    }
  }

  void _toInProgress() {
    state = state.copyWith(phase: ZazenFlowPhase.inProgress);
    ref.read(zazenKatsuProvider.notifier).start();
    _startSampling();
    final zazenDuration = Duration(minutes: ref.read(zazenDurationProvider));
    _schedule(zazenDuration - const Duration(seconds: 5), _stopKatsuBeforeEnd);
  }

  void _stopKatsuBeforeEnd() {
    ref.read(zazenKatsuProvider.notifier).stop();
    _schedule(const Duration(seconds: 5), _toEnded);
  }

  void _toEnded() {
    _stopSampling();
    state = state.copyWith(phase: ZazenFlowPhase.ended);
    _schedule(const Duration(seconds: 10), _toTapWaiting);
  }

  void _toTapWaiting() {
    state = state.copyWith(phase: ZazenFlowPhase.tapWaiting);
  }

  // ---- IMU・サンプリング ----

  void _startSampling() {
    _samplingTimer?.cancel();
    _samplingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_latestAttitude != null) _postureHistory.add(_latestAttitude!);
    });
  }

  void _stopSampling() {
    _samplingTimer?.cancel();
    _samplingTimer = null;
  }

  void _startResumeCountdown() {
    state = state.copyWith(
      phase: ZazenFlowPhase.resumeCountdown,
      countdownValue: 3,
    );
    _scheduleResumeCountdownTick();
  }

  void _scheduleResumeCountdownTick() {
    _resumeCountdownTimer?.cancel();
    _resumeCountdownTimer = Timer(const Duration(seconds: 1), () {
      final next = state.countdownValue - 1;
      if (next > 0) {
        state = state.copyWith(countdownValue: next);
        _scheduleResumeCountdownTick();
      } else {
        _finishResumeCountdown();
      }
    });
  }

  void _finishResumeCountdown() {
    state = state.copyWith(phase: ZazenFlowPhase.inProgress);
    _restoreTimer();
    _startSampling();
    _resumeKatsu();
  }

  void _resumeKatsu() {
    final katsuNotifier = ref.read(zazenKatsuProvider.notifier);
    // 中断時に喝の警告中だった場合は警告カウントダウンからやり直す
    if (katsuNotifier.pausedInWarning) {
      katsuNotifier.resumeWarning();
      return;
    }
    _katsuResumeTimer?.cancel();
    _katsuResumeTimer = Timer(const Duration(seconds: 3), () {
      if (state.phase == ZazenFlowPhase.inProgress) {
        ref.read(zazenKatsuProvider.notifier).start(armed: true);
      }
    });
  }

  // ---- Timer helpers ----

  void _schedule(Duration duration, VoidCallback callback) {
    _timer?.cancel();
    _timerDuration = duration;
    _timerStartedAt = DateTime.now();
    _timerCallback = callback;
    _timer = Timer(duration, callback);
  }

  void _saveTimer() {
    if (_timer != null && _timerStartedAt != null && _timerDuration != null) {
      final elapsed = DateTime.now().difference(_timerStartedAt!);
      final remaining = _timerDuration! - elapsed;
      _savedRemaining = remaining.isNegative ? Duration.zero : remaining;
      _timer!.cancel();
      _timer = null;
    }
  }

  void _restoreTimer() {
    if (_savedRemaining != null && _timerCallback != null) {
      _schedule(_savedRemaining!, _timerCallback!);
      _savedRemaining = null;
    }
  }

  void _cancelAllTimers() {
    _timer?.cancel();
    _timer = null;
    _savedRemaining = null;
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _katsuResumeTimer?.cancel();
    _katsuResumeTimer = null;
    _resumeCountdownTimer?.cancel();
    _resumeCountdownTimer = null;
  }
}
