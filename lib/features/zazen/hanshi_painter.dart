import 'dart:math';

import 'package:flutter/material.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/features/imu/imu_service.dart';

class HanshiPainter extends CustomPainter {
  const HanshiPainter({
    required this.progress,
    this.postureHistory = const [],
    this.postureBaseline,
  });

  final double progress;
  final List<AttitudeData> postureHistory;
  final AttitudeData? postureBaseline;

  // ±20° の逸脱を ±maxSwayPx にマッピング
  static const _swayScale = 20.0 * (pi / 180);
  static const maxSwayPx = 100.0;

  // キャリブレーション時の姿勢(baseline)からの逸脱量を計算。
  // baseline がない場合は正面(roll=±90°, pitch=0°)を基準とする。
  //   pitchDev : pitch の基準からの逸脱（前後傾き、符号付き）
  //   rollDev  : |roll| の基準からの逸脱（左右傾き、符号付き）
  // → 基準姿勢のとき必ず 0
  double _computeSway(AttitudeData sample) {
    final basePitch = postureBaseline?.pitch ?? 0.0;
    final baseRoll = postureBaseline?.roll.abs() ?? (pi / 2);
    final pitchDev = sample.pitch - basePitch;
    final rollDev = sample.roll.abs() - baseRoll;
    return ((pitchDev + rollDev) / _swayScale).clamp(-1.0, 1.0) * maxSwayPx;
  }

  // 500msサンプリングの角を丸めるための移動平均（±4サンプル ≒ ±2秒）。
  // 描画途中に線の形が変わらないよう、常に全履歴を対象に計算する
  List<double> _smoothedSwayValues() {
    const half = 4;
    final total = postureHistory.length;
    return List.generate(total, (i) {
      final start = (i - half).clamp(0, total - 1);
      final end = (i + half).clamp(0, total - 1);
      var sum = 0.0;
      for (var j = start; j <= end; j++) {
        sum += _computeSway(postureHistory[j]);
      }
      return sum / (end - start + 1);
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.clipRect(bounds);

    if (progress <= 0) return;

    final hasPostureData = postureHistory.isNotEmpty;
    final totalPoints = hasPostureData ? postureHistory.length : 100;
    final visibleCount = (totalPoints * progress).round().clamp(0, totalPoints);
    if (visibleCount < 2) return;

    const demoMaxSway = 20.0;
    final smoothedSwayValues = hasPostureData ? _smoothedSwayValues() : null;

    final inputPoints = List.generate(visibleCount, (i) {
      final t = totalPoints > 1 ? i / (totalPoints - 1) : 0.0;
      final x = size.width * 0.1 + t * size.width * 0.8;
      final sway = smoothedSwayValues != null
          ? smoothedSwayValues[i]
          : sin(t * pi * 6) * demoMaxSway;
      final y = size.height / 2 + sway;
      // 揺れが小さい(直立) = 筆圧強く太い、揺れが大きい = 筆が浮いて細い
      final maxSway = hasPostureData ? maxSwayPx : demoMaxSway;
      final pressure =
          (1.0 - (sway.abs() / maxSway).clamp(0.0, 1.0)) * 0.65 + 0.35;
      return PointVector(x, y, pressure);
    });

    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: 22,
        thinning: 0.8,
        smoothing: 0.6,
        streamline: 0.6,
        start: StrokeEndOptions.start(taperEnabled: false),
        end: StrokeEndOptions.end(taperEnabled: false),
      ),
    );

    if (outlinePoints.length < 2) return;

    // 隣接点の中点を通る二次ベジェで角丸に
    final path = Path();
    path.moveTo(
      (outlinePoints[0].dx + outlinePoints[1].dx) / 2,
      (outlinePoints[0].dy + outlinePoints[1].dy) / 2,
    );
    for (var i = 1; i < outlinePoints.length - 1; i++) {
      final mid = Offset(
        (outlinePoints[i].dx + outlinePoints[i + 1].dx) / 2,
        (outlinePoints[i].dy + outlinePoints[i + 1].dy) / 2,
      );
      path.quadraticBezierTo(
        outlinePoints[i].dx,
        outlinePoints[i].dy,
        mid.dx,
        mid.dy,
      );
    }
    path.lineTo(outlinePoints.last.dx, outlinePoints.last.dy);
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.textPrimary
        ..style = PaintingStyle.fill
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(HanshiPainter old) => old.progress != progress;
}
