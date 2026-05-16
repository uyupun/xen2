import 'dart:async';
import 'package:flutter/services.dart';

class ImuData {
  final double x;
  final double y;
  final double z;
  final int timestampMs;

  const ImuData({
    required this.x,
    required this.y,
    required this.z,
    required this.timestampMs,
  });

  factory ImuData.fromMap(Map<dynamic, dynamic> map) {
    return ImuData(
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      z: (map['z'] as num).toDouble(),
      timestampMs: (map['timestamp'] as num).toInt(),
    );
  }

  @override
  String toString() =>
      'ImuData(x: ${x.toStringAsFixed(4)}, y: ${y.toStringAsFixed(4)}, z: ${z.toStringAsFixed(4)})';
}

/// OSが内部センサーフュージョン（カルマンフィルタ等）で算出した姿勢データ。
/// iOS: CMDeviceMotion.attitude / Android: TYPE_ROTATION_VECTOR
class AttitudeData {
  final double qw;
  final double qx;
  final double qy;
  final double qz;

  /// ラジアン単位。
  /// iOS/Android ともに右手系だが座標軸の定義が異なる点に注意。
  final double roll;
  final double pitch;
  final double yaw;

  final int timestampMs;

  const AttitudeData({
    required this.qw,
    required this.qx,
    required this.qy,
    required this.qz,
    required this.roll,
    required this.pitch,
    required this.yaw,
    required this.timestampMs,
  });

  factory AttitudeData.fromMap(Map<dynamic, dynamic> map) {
    return AttitudeData(
      qw: (map['qw'] as num).toDouble(),
      qx: (map['qx'] as num).toDouble(),
      qy: (map['qy'] as num).toDouble(),
      qz: (map['qz'] as num).toDouble(),
      roll: (map['roll'] as num).toDouble(),
      pitch: (map['pitch'] as num).toDouble(),
      yaw: (map['yaw'] as num).toDouble(),
      timestampMs: (map['timestamp'] as num).toInt(),
    );
  }
}

class ImuService {
  ImuService._();
  static final ImuService instance = ImuService._();

  static const _accelChannel = EventChannel('imu_fusion/accelerometer');
  static const _gyroChannel = EventChannel('imu_fusion/gyroscope');
  static const _magChannel = EventChannel('imu_fusion/magnetometer');
  static const _attitudeChannel = EventChannel('imu_fusion/attitude');

  Stream<ImuData>? _accelerometerStream;
  Stream<ImuData>? _gyroscopeStream;
  Stream<ImuData>? _magnetometerStream;
  Stream<AttitudeData>? _attitudeStream;

  /// 加速度 (m/s²)
  Stream<ImuData> get accelerometerStream =>
      _accelerometerStream ??= _accelChannel
          .receiveBroadcastStream()
          .map((e) => ImuData.fromMap(e as Map));

  /// 角速度 (rad/s)
  Stream<ImuData> get gyroscopeStream =>
      _gyroscopeStream ??= _gyroChannel
          .receiveBroadcastStream()
          .map((e) => ImuData.fromMap(e as Map));

  /// 磁場強度 (µT)
  Stream<ImuData> get magnetometerStream =>
      _magnetometerStream ??= _magChannel
          .receiveBroadcastStream()
          .map((e) => ImuData.fromMap(e as Map));

  /// OSフュージョン済み姿勢データ（クォータニオン + オイラー角）
  Stream<AttitudeData> get attitudeStream =>
      _attitudeStream ??= _attitudeChannel
          .receiveBroadcastStream()
          .map((e) => AttitudeData.fromMap(e as Map));
}
