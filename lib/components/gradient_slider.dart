import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:xen2/constants/app_colors.dart';

class GradientSlider extends StatefulWidget {
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
  State<GradientSlider> createState() => _GradientSliderState();
}

class _GradientSliderState extends State<GradientSlider> {
  PictureInfo? _svgPicture;

  @override
  void initState() {
    super.initState();
    _loadSvg();
  }

  Future<void> _loadSvg() async {
    final info = await vg.loadPicture(
      const SvgAssetLoader('assets/logo_transparent.svg'),
      null,
    );
    if (mounted) {
      setState(() => _svgPicture = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 14,
                  trackShape: _GradientTrackShape(
                    minLabel: '初級',
                    maxLabel: '上級',
                  ),
                  thumbShape: _SvgThumbShape(
                    pictureInfo: _svgPicture,
                    radius: 24,
                  ),
                  overlayColor: Colors.transparent,
                  showValueIndicator: ShowValueIndicator.alwaysVisible,
                  valueIndicatorColor: AppColors.primary,
                  valueIndicatorShape: const _BubbleValueIndicatorShape(),
                  valueIndicatorTextStyle: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: Slider(
                  value: widget.value.toDouble(),
                  min: widget.min.toDouble(),
                  max: widget.max.toDouble(),
                  label: '${widget.value}分',
                  onChanged: (v) => widget.onChanged(v.round()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SvgThumbShape extends SliderComponentShape {
  const _SvgThumbShape({required this.pictureInfo, this.radius = 24});

  final PictureInfo? pictureInfo;
  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(radius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;

    if (pictureInfo == null) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
      return;
    }

    final scale = (radius * 2) / pictureInfo!.size.width;
    canvas.save();
    canvas.translate(center.dx - radius, center.dy - radius);
    canvas.scale(scale);
    canvas.drawPicture(pictureInfo!.picture);
    canvas.restore();
  }
}

class _BubbleValueIndicatorShape extends SliderComponentShape {
  const _BubbleValueIndicatorShape();

  static const double _height = 22.0;
  static const double _cornerRadius = 100.0;
  static const double _pointerHeight = 8.0;
  static const double _pointerWidth = 10.0;
  static const double _horizontalPadding = 6.0;
  static const double _gapAboveThumb = 20.0;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(0, _height + _pointerHeight + _gapAboveThumb);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final opacity = activationAnimation.value;
    if (opacity == 0.0) return;

    final canvas = context.canvas;
    final color = (sliderTheme.valueIndicatorColor ?? AppColors.primary)
        .withValues(alpha: opacity);

    final bubbleWidth = labelPainter.width + _horizontalPadding * 2;
    final pointerTip = center.dy - _gapAboveThumb;
    final bubbleBottom = pointerTip - _pointerHeight;
    final bubbleTop = bubbleBottom - _height;
    final left = center.dx - bubbleWidth / 2;
    final right = center.dx + bubbleWidth / 2;

    final path = Path()
      ..addRRect(
        RRect.fromLTRBR(
          left,
          bubbleTop,
          right,
          bubbleBottom,
          const Radius.circular(_cornerRadius),
        ),
      )
      ..moveTo(center.dx - _pointerWidth / 2, bubbleBottom)
      ..lineTo(center.dx, pointerTip)
      ..lineTo(center.dx + _pointerWidth / 2, bubbleBottom)
      ..close();

    canvas.drawPath(path, Paint()..color = color);

    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        bubbleTop + (_height - labelPainter.height) / 2,
      ),
    );
  }
}

class _GradientTrackShape extends SliderTrackShape {
  const _GradientTrackShape({this.minLabel = '', this.maxLabel = ''});

  final String minLabel;
  final String maxLabel;

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

    final radius = Radius.circular(trackRect.height / 2);
    context.canvas.drawRRect(
      RRect.fromRectAndRadius(trackRect, radius),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF44D85A), Color(0xFFED9237), Color(0xFFCE2626)],
        ).createShader(trackRect),
    );

    const labelStyle = TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );
    const hPad = 10.0;

    void paintLabel(String text, {required bool alignRight}) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final dy = trackRect.center.dy - tp.height / 2;
      final dx = alignRight
          ? trackRect.right - tp.width - hPad
          : trackRect.left + hPad;
      tp.paint(context.canvas, Offset(dx, dy));
    }

    paintLabel(minLabel, alignRight: false);
    paintLabel(maxLabel, alignRight: true);
  }
}
