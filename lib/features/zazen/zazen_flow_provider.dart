import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
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
  ended,
  tapWaiting,
  result,
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
  Timer? _timer;
  DateTime? _timerStartedAt;
  Duration? _timerDuration;
  VoidCallback? _timerCallback;
  Duration? _savedRemaining;

  @override
  ZazenFlowState build() {
    ref.onDispose(() => _timer?.cancel());

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
    _cancelTimers();
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
    if (state.phase == ZazenFlowPhase.calibrating) {
      ref.read(zazenCalibrationProvider.notifier).reset();
    }
    if (state.phase == ZazenFlowPhase.inProgress) {
      ref.read(zazenKatsuProvider.notifier).stop();
    }
  }

  void resume() {
    _restoreTimer();
    if (state.phase == ZazenFlowPhase.calibrating) {
      ref.read(zazenCalibrationProvider.notifier).start();
    }
    if (state.phase == ZazenFlowPhase.inProgress) {
      ref.read(zazenKatsuProvider.notifier).start();
    }
  }

  void advanceToResult() {
    _timer?.cancel();
    state = state.copyWith(phase: ZazenFlowPhase.result);
  }

  void reset() {
    _cancelTimers();
    // ビルドフェーズ中の状態変更を避けるため1フレーム遅延させる
    Future<void>(() {
      ref.read(zazenCalibrationProvider.notifier).reset();
      ref.read(zazenKatsuProvider.notifier).stop();
      state = const ZazenFlowState();
    });
  }

  // ---- Phase transitions ----

  void _onCalibrationDone() {
    state = state.copyWith(phase: ZazenFlowPhase.postureConfirmed);
    _schedule(const Duration(seconds: 3), _toKoan);
  }

  void _toKoan() {
    state = state.copyWith(phase: ZazenFlowPhase.koan, koan: randomKoan());
    _schedule(const Duration(seconds: 10), _toEyesHalfClosed);
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
    _schedule(Duration(minutes: ref.read(zazenDurationProvider)), _toEnded);
  }

  void _toEnded() {
    ref.read(zazenKatsuProvider.notifier).stop();
    state = state.copyWith(phase: ZazenFlowPhase.ended);
    _schedule(const Duration(seconds: 5), _toTapWaiting);
  }

  void _toTapWaiting() {
    state = state.copyWith(phase: ZazenFlowPhase.tapWaiting);
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

  void _cancelTimers() {
    _timer?.cancel();
    _timer = null;
    _savedRemaining = null;
  }
}
