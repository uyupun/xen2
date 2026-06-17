import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:xen2/components/primary_button.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/zazen/hanshi_painter.dart';
import 'package:xen2/pages/top_page.dart';

class ResultPage extends HookWidget {
  const ResultPage({
    super.key,
    this.postureHistory = const [],
    this.postureBaseline,
  });

  final List<AttitudeData> postureHistory;
  final AttitudeData? postureBaseline;

  static const _fadeDuration = Duration(milliseconds: 1500);

  @override
  Widget build(BuildContext context) {
    final strokeController = useAnimationController(
      duration: const Duration(seconds: 2),
    );
    final strokeVisible = useState(true);
    final resultVisible = useState(false);

    useEffect(() {
      final sePlayer = AudioPlayer();
      sePlayer.audioCache.prefix = '';

      Timer? startTimer;
      Timer? animationTimer;
      Timer? fadeOutTimer;
      Timer? fadeInTimer;
      // 遷移後2秒待ってから音とアニメーションを開始
      // 音を先出しするため、アニメーション開始を50ms遅延させる
      // 一筆書きを描き終えて3秒後にゆっくり消し、
      // 消えきってから日日是好日をゆっくり表示する
      startTimer = Timer(const Duration(seconds: 2), () {
        sePlayer.play(AssetSource('assets/brush_stroke.wav'));
        animationTimer = Timer(const Duration(milliseconds: 50), () {
          strokeController.forward().then((_) {
            fadeOutTimer = Timer(const Duration(seconds: 3), () {
              strokeVisible.value = false;
              fadeInTimer = Timer(_fadeDuration, () {
                resultVisible.value = true;
              });
            });
          });
        });
      });
      return () {
        sePlayer.dispose();
        startTimer?.cancel();
        animationTimer?.cancel();
        fadeOutTimer?.cancel();
        fadeInTimer?.cancel();
      };
    }, []);

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedOpacity(
            opacity: resultVisible.value ? 1.0 : 0.0,
            duration: _fadeDuration,
            child: IgnorePointer(
              ignoring: !resultVisible.value,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Textが中央に来るようにするためのスペーサー
                    const SizedBox(),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'にちにちこれこうじつ',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 12,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          '日日是好日',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        // 高さの微調整
                        SizedBox(height: 20),
                      ],
                    ),
                    SizedBox(
                      width: 400,
                      child: PrimaryButton(
                        label: '坐禅を終了する',
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const TopPage()),
                            (route) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: strokeVisible.value ? 1.0 : 0.0,
            duration: _fadeDuration,
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: HanshiPainter.maxSwayPx * 2 + 24,
                  child: AnimatedBuilder(
                    animation: strokeController,
                    builder: (context, _) => CustomPaint(
                      painter: HanshiPainter(
                        progress: strokeController.value,
                        postureHistory: postureHistory,
                        postureBaseline: postureBaseline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
