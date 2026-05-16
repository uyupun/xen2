import 'dart:math';
import 'package:flutter/material.dart';
import 'package:xen2/features/imu/imu_service.dart';

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
            _AttitudeCard(stream: service.attitudeStream),
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
