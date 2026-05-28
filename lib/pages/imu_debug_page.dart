import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/zazen/hanshi_painter.dart';

class ImuDebugPage extends StatelessWidget {
  const ImuDebugPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ImuService.instance;
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMU Debug'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            _ForwardDetectionCard(stream: service.attitudeStream),
            const SizedBox(height: 12),
            _PostureResultCard(stream: service.attitudeStream),
            const SizedBox(height: 12),
            _AttitudeCard(stream: service.attitudeStream),
            const SizedBox(height: 12),
            _ImuCard(
              title: 'Accelerometer',
              subtitle: 'm/s²',
              stream: service.accelerometerStream,
              builder: (data) => _XyzDisplay(x: data.x, y: data.y, z: data.z),
            ),
            const SizedBox(height: 12),
            _ImuCard(
              title: 'Gyroscope',
              subtitle: 'rad/s',
              stream: service.gyroscopeStream,
              builder: (data) => _XyzDisplay(x: data.x, y: data.y, z: data.z),
            ),
            const SizedBox(height: 12),
            _ImuCard(
              title: 'Magnetometer',
              subtitle: 'µT',
              stream: service.magnetometerStream,
              builder: (data) => _XyzDisplay(x: data.x, y: data.y, z: data.z),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _PostureResultCard extends StatefulWidget {
  const _PostureResultCard({required this.stream});
  final Stream<AttitudeData> stream;

  @override
  State<_PostureResultCard> createState() => _PostureResultCardState();
}

class _PostureResultCardState extends State<_PostureResultCard> {
  StreamSubscription<AttitudeData>? _sub;
  Timer? _samplingTimer;
  AttitudeData? _latestAttitude;
  AttitudeData? _baseline;
  final List<AttitudeData> _history = [];
  int _sampleCount = 0;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen((data) => _latestAttitude = data);
    _samplingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (_latestAttitude == null) return;
      _baseline ??= _latestAttitude;
      setState(() {
        _history.add(_latestAttitude!);
        _sampleCount = _history.length;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _samplingTimer?.cancel();
    super.dispose();
  }

  void _showResult() {
    final history = List<AttitudeData>.unmodifiable(_history);
    final baseline = _baseline;
    showDialog<void>(
      context: context,
      builder: (_) =>
          _HanshiDialog(postureHistory: history, postureBaseline: baseline),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('姿勢ログ', style: Theme.of(context).textTheme.titleMedium),
            Text(
              'サンプル数: $_sampleCount',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            if (_latestAttitude != null) ...[
              const SizedBox(height: 4),
              Text(
                'pitch: ${(_latestAttitude!.pitch * 180 / pi).toStringAsFixed(1)}°'
                '  |roll|−90°: ${((_latestAttitude!.roll.abs() - pi / 2) * 180 / pi).toStringAsFixed(1)}°'
                '  合計: ${((_latestAttitude!.pitch + _latestAttitude!.roll.abs() - pi / 2) * 180 / pi).toStringAsFixed(1)}°',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blue,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sampleCount >= 2 ? _showResult : null,
                child: const Text('結果を確認'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HanshiDialog extends StatefulWidget {
  const _HanshiDialog({
    required this.postureHistory,
    required this.postureBaseline,
  });

  final List<AttitudeData> postureHistory;
  final AttitudeData? postureBaseline;

  @override
  State<_HanshiDialog> createState() => _HanshiDialogState();
}

class _HanshiDialogState extends State<_HanshiDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('姿勢ログ', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: HanshiPainter.maxSwayPx * 2 + 24,
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => CustomPaint(
                    painter: HanshiPainter(
                      progress: _controller.value,
                      postureHistory: widget.postureHistory,
                      postureBaseline: widget.postureBaseline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('閉じる'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DetectionState { idle, detecting, detected, warning, cooldown }

// スマホが地面に垂直（VRゴーグル装着で正面向き）かどうかを絶対値で判定する。
// roll が ±90度付近かつ pitch が ±20度以内なら正面とみなす。
class _ForwardDetectionCard extends StatefulWidget {
  const _ForwardDetectionCard({required this.stream});
  final Stream<AttitudeData> stream;

  @override
  State<_ForwardDetectionCard> createState() => _ForwardDetectionCardState();
}

class _ForwardDetectionCardState extends State<_ForwardDetectionCard> {
  static const _rollMin = 70.0 * (pi / 180);
  static const _rollMax = 110.0 * (pi / 180);
  static const _pitchThreshold = 20.0 * (pi / 180);
  static const _requiredMs = 5000;

  StreamSubscription<AttitudeData>? _sub;
  Timer? _warningTimer;
  Timer? _cooldownTimer;
  _DetectionState _state = _DetectionState.idle;
  int? _inRangeSince;
  int _elapsedMs = 0;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen(_onData);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _warningTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  bool _isForward(AttitudeData data) {
    final absRoll = data.roll.abs();
    final absPitch = data.pitch.abs();
    return absRoll >= _rollMin &&
        absRoll <= _rollMax &&
        absPitch <= _pitchThreshold;
  }

  void _onData(AttitudeData data) {
    final inRange = _isForward(data);

    switch (_state) {
      case _DetectionState.idle:
        if (inRange) {
          setState(() {
            _state = _DetectionState.detecting;
            _inRangeSince = data.timestampMs;
            _elapsedMs = 0;
          });
        }

      case _DetectionState.detecting:
        if (inRange) {
          final elapsed = data.timestampMs - _inRangeSince!;
          if (elapsed >= _requiredMs) {
            setState(() => _state = _DetectionState.detected);
          } else {
            setState(() => _elapsedMs = elapsed);
          }
        } else {
          setState(() {
            _state = _DetectionState.idle;
            _inRangeSince = null;
            _elapsedMs = 0;
          });
        }

      case _DetectionState.detected:
        if (!inRange) {
          _warningTimer?.cancel();
          setState(() => _state = _DetectionState.warning);
          _warningTimer = Timer(const Duration(seconds: 3), () {
            if (!mounted) return;
            setState(() => _state = _DetectionState.cooldown);
            _cooldownTimer = Timer(const Duration(seconds: 5), () {
              if (!mounted) return;
              setState(() => _state = _DetectionState.detected);
            });
          });
        }

      case _DetectionState.warning:
      case _DetectionState.cooldown:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = ((_requiredMs - _elapsedMs) / 1000).ceil();
    final isDetectedLike =
        _state == _DetectionState.detected ||
        _state == _DetectionState.cooldown;

    return Card(
      color: switch (_state) {
        _DetectionState.warning => Colors.orange.shade50,
        _DetectionState.detected ||
        _DetectionState.cooldown => Colors.green.shade50,
        _ => null,
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('正面検知', style: Theme.of(context).textTheme.titleMedium),
            Text(
              'VRゴーグル装着で正面を向いた状態（地面に垂直）を5秒間維持で検知済みになります',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            switch (_state) {
              _DetectionState.idle => const Row(
                children: [
                  Icon(Icons.radio_button_unchecked, color: Colors.grey),
                  SizedBox(width: 8),
                  Text(
                    '正面を向いてください',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
              _DetectionState.detecting => Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '検知中... あと$remaining秒',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              _DetectionState.detected || _DetectionState.cooldown => Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Text(
                        '検知済み',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (isDetectedLike) ...[
                        const SizedBox(height: 4),
                        Text(
                          _state == _DetectionState.cooldown ? 'クールタイム中' : '',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              _DetectionState.warning => const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    '警策を行います',
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }
}

class _ImuCard<T> extends StatelessWidget {
  const _ImuCard({
    required this.title,
    required this.subtitle,
    required this.stream,
    required this.builder,
  });

  final String title;
  final String subtitle;
  final Stream<T> stream;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            StreamBuilder<T>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return builder(snapshot.data as T);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AttitudeCard extends StatelessWidget {
  const _AttitudeCard({required this.stream});
  final Stream<AttitudeData> stream;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attitude (OS Fused)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'iOS: CMDeviceMotion.attitude / Android: TYPE_ROTATION_VECTOR',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            StreamBuilder<AttitudeData>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final d = snapshot.data!;
                final toDeg = 180 / pi;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Euler Angles (deg)',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    _ValueRow('Roll ', d.roll * toDeg),
                    _ValueRow('Pitch', d.pitch * toDeg),
                    _ValueRow('Yaw  ', d.yaw * toDeg),
                    const Divider(height: 20),
                    Text(
                      'Quaternion',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    _ValueRow('w', d.qw),
                    _ValueRow('x', d.qx),
                    _ValueRow('y', d.qy),
                    _ValueRow('z', d.qz),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _XyzDisplay extends StatelessWidget {
  const _XyzDisplay({required this.x, required this.y, required this.z});
  final double x;
  final double y;
  final double z;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_ValueRow('x', x), _ValueRow('y', y), _ValueRow('z', z)],
    );
  }
}

class _ValueRow extends StatelessWidget {
  const _ValueRow(this.label, this.value);
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value.toStringAsFixed(5),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
