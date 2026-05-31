import 'package:flutter/material.dart';
import 'package:xen2/constants/app_colors.dart';

class GradientSlider extends StatelessWidget {
  const GradientSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 60,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '時間',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$value',
                    style: TextStyle(
                      fontSize: 48,
                      height: 1,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextSpan(
                    text: '分',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            trackShape: _GradientTrackShape(),
            thumbColor: AppColors.background,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayColor: AppColors.textPrimary.withValues(alpha: 0.2),
            showValueIndicator: ShowValueIndicator.onDrag,
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            label: '$value分',
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '初級（$min分）',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
            Text(
              '上級（$max分）',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ],
        ),
      ],
    );
  }
}

class _GradientTrackShape extends SliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackLeft = offset.dx;
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF44D85A), Color(0xFFED9237), Color(0xFFCE2626)],
      ).createShader(trackRect);

    final radius = Radius.circular(trackRect.height / 2);
    context.canvas.drawRRect(RRect.fromRectAndRadius(trackRect, radius), paint);
  }
}
