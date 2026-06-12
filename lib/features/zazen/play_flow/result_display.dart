import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/zazen/hanshi_painter.dart';

class ResultDisplay extends HookWidget {
  const ResultDisplay({
    super.key,
    this.postureHistory = const [],
    this.postureBaseline,
  });

  final List<AttitudeData> postureHistory;
  final AttitudeData? postureBaseline;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 3),
    );
    final showCard = useState(false);

    useEffect(() {
      controller.forward().then((_) {
        Future.delayed(const Duration(seconds: 3), () {
          showCard.value = true;
        });
      });
      return null;
    }, []);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: HanshiPainter.maxSwayPx * 2 + 24,
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) => CustomPaint(
                  painter: HanshiPainter(
                    progress: controller.value,
                    postureHistory: postureHistory,
                    postureBaseline: postureBaseline,
                  ),
                ),
              ),
            ),
            AnimatedOpacity(
              opacity: showCard.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: OverflowBox(
                maxWidth: double.infinity,
                child: const _KotowazaCard(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KotowazaCard extends StatelessWidget {
  const _KotowazaCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFAEEEE),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD9C8C8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '日日是好日',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '（にちにちこれこうじつ）',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Text(
              _toKanjiDate(DateTime.now()),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

String _toKanjiDate(DateTime date) {
  const digits = ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  final year = date.year
      .toString()
      .split('')
      .map((d) => digits[int.parse(d)])
      .join();
  return '$year年　${_toKanjiNumber(date.month)}月${_toKanjiNumber(date.day)}日';
}

String _toKanjiNumber(int n) {
  const digits = ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九'];
  if (n <= 9) return digits[n];
  if (n == 10) return '十';
  if (n < 20) return '十${digits[n - 10]}';
  if (n == 20) return '二十';
  if (n < 30) return '二十${digits[n - 20]}';
  if (n == 30) return '三十';
  return '三十${digits[n - 30]}';
}
