import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/pavlok/pavlok_provider.dart';

part 'zazen_katsu_provider.g.dart';

enum KatsuStatus { idle, detecting, detected, warning, cooldown }

@Riverpod(keepAlive: true)
class ZazenKatsu extends _$ZazenKatsu {
  // デバッグ画面の_ForwardDetectionCardStateと同じ判定条件
  static const _rollMin = 70.0 * (pi / 180);
  static const _rollMax = 110.0 * (pi / 180);
  static const _pitchThreshold = 20.0 * (pi / 180);
  static const _requiredMs = 5000;

  StreamSubscription<AttitudeData>? _sub;
  Timer? _warningTimer;
  Timer? _cooldownTimer;
  int? _inRangeSince;

  @override
  KatsuStatus build() {
    ref.onDispose(() {
      _sub?.cancel();
      _warningTimer?.cancel();
      _cooldownTimer?.cancel();
    });
    return KatsuStatus.idle;
  }

  void start() {
    _inRangeSince = null;
    state = KatsuStatus.idle;
    _sub = ImuService.instance.attitudeStream.listen(_onData);
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _warningTimer?.cancel();
    _cooldownTimer?.cancel();
    state = KatsuStatus.idle;
  }

  bool _isForward(AttitudeData data) {
    final absRoll = data.roll.abs();
    final absPitch = data.pitch.abs();
    return absRoll >= _rollMin && absRoll <= _rollMax && absPitch <= _pitchThreshold;
  }

  void _onData(AttitudeData data) {
    final inRange = _isForward(data);

    switch (state) {
      case KatsuStatus.idle:
        if (inRange) {
          _inRangeSince = data.timestampMs;
          state = KatsuStatus.detecting;
        }

      case KatsuStatus.detecting:
        if (inRange) {
          final elapsed = data.timestampMs - _inRangeSince!;
          if (elapsed >= _requiredMs) {
            state = KatsuStatus.detected;
          }
        } else {
          _inRangeSince = null;
          state = KatsuStatus.idle;
        }

      case KatsuStatus.detected:
        if (!inRange) {
          _warningTimer?.cancel();
          state = KatsuStatus.warning;
          _warningTimer = Timer(const Duration(seconds: 3), () {
            // 喝: Pavlokへ刺激を送る
            ref.read(pavlokProvider.future).catchError((e) {
              debugPrint('Failed to connect to Pavlok: $e');
            });
            state = KatsuStatus.cooldown;
            _cooldownTimer = Timer(const Duration(seconds: 5), () {
              state = KatsuStatus.detected;
            });
          });
        }

      case KatsuStatus.warning:
      case KatsuStatus.cooldown:
        break;
    }
  }
}
