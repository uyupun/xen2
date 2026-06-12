import 'dart:async';
import 'dart:math';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xen2/features/imu/imu_service.dart';

part 'zazen_calibration_provider.g.dart';

enum CalibrationStatus { idle, detecting, calibrated }

@Riverpod(keepAlive: true)
class ZazenCalibration extends _$ZazenCalibration {
  static const _rollMin = 70.0 * (pi / 180);
  static const _rollMax = 110.0 * (pi / 180);
  static const _pitchThreshold = 20.0 * (pi / 180);
  static const _requiredMs = 5000;

  StreamSubscription<AttitudeData>? _sub;
  Completer<void>? _completer;
  int? _inRangeSince;

  @override
  CalibrationStatus build() {
    ref.onDispose(() => _sub?.cancel());
    return CalibrationStatus.idle;
  }

  Future<void> start() async {
    _completer = Completer<void>();
    _inRangeSince = null;
    // ビルドフェーズ中の状態変更を避けるため1フレーム遅延させる
    await Future<void>(() {});
    state = CalibrationStatus.detecting;
    _sub = ImuService.instance.attitudeStream.listen(_onData);
    await _completer!.future;
  }

  void reset() {
    _sub?.cancel();
    _sub = null;
    _completer = null;
    _inRangeSince = null;
    state = CalibrationStatus.idle;
  }

  void _onData(AttitudeData data) {
    final absRoll = data.roll.abs();
    final absPitch = data.pitch.abs();
    final inRange =
        absRoll >= _rollMin &&
        absRoll <= _rollMax &&
        absPitch <= _pitchThreshold;

    if (inRange) {
      _inRangeSince ??= data.timestampMs;
      if (data.timestampMs - _inRangeSince! >= _requiredMs) {
        _sub?.cancel();
        _sub = null;
        if (!(_completer?.isCompleted ?? true)) {
          state = CalibrationStatus.calibrated;
          _completer!.complete();
        }
      }
    } else {
      _inRangeSince = null;
    }
  }
}
