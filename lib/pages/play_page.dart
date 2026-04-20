import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:perfect_freehand/perfect_freehand.dart';
import 'package:xen2/components/outlined_text.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/features/pavlok/pavlok_provider.dart';
import 'package:xen2/features/vr_player/dual_vr_player.dart';
import 'package:xen2/features/vr_player/dual_vr_player_controller_notifier_provider.dart';
import 'package:xen2/pages/top_page.dart';

class PlayPage extends StatefulHookConsumerWidget {
  const PlayPage({super.key});

  @override
  PlayPageState createState() => PlayPageState();
}

class PlayPageState extends ConsumerState<PlayPage> {
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _bellPlayer;

  @override
  void initState() {
    super.initState();
    _bgmPlayer = AudioPlayer();
    _bgmPlayer.audioCache.prefix = '';
    _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    _bellPlayer = AudioPlayer();
    _bellPlayer.audioCache.prefix = '';
  }

  @override
  void dispose() {
    _bgmPlayer.stop();
    _bgmPlayer.dispose();
    _bellPlayer.stop();
    _bellPlayer.dispose();
    super.dispose();
  }

  Future<void> _runZazenFlow(ValueNotifier<Widget> foregroundWidget) async {
    // 姿勢の検証
    await Future.delayed(const Duration(seconds: 20));

    // 検証完了
    foregroundWidget.value = const _PostureConfirmed();
    await Future.delayed(const Duration(seconds: 5));

    // 坐禅開始（動画と音声を再生）
    foregroundWidget.value = const _ZazenInProgress();
    ref.read(dualVrPlayerControllerProvider.notifier).play();
    await _bellPlayer.play(
      AssetSource('assets/temple_bell_start.mp3'),
      volume: 0.5,
    );
    await Future.delayed(const Duration(seconds: 9));
    // todo: ループ時に音が途切れないようにしたい
    await _bgmPlayer.play(AssetSource('assets/pink_noise.mp3'), volume: 0.25);
    await Future.delayed(const Duration(seconds: 30));

    // 喝（Pavlokへ通信して刺激を与える）
    foregroundWidget.value = const _Katsu();
    await Future.delayed(const Duration(seconds: 30));

    // 坐禅終了（動画と音声を停止）
    // foregroundWidget.value = const _ZazenEnding();
    ref.read(dualVrPlayerControllerProvider.notifier).pause();
    await _bgmPlayer.stop();
    await _bellPlayer.stop();
    await _bellPlayer.play(
      AssetSource('assets/temple_bell_end.mp3'),
      volume: 0.5,
    );
    await Future.delayed(const Duration(seconds: 3));

    // リザルト画面の表示
    foregroundWidget.value = const _ResultDisplay();
  }

  @override
  Widget build(BuildContext context) {
    final foregroundWidget = useState<Widget>(const _PostureDetecting());

    useEffect(() {
      _runZazenFlow(foregroundWidget);

      return null;
    }, []);

    return Scaffold(
      body: Stack(
        children: [
          DualVrPlayer(
            assetPath: 'assets/skybox.mp4',
            foregroundWidget: foregroundWidget.value,
          ),
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const TopPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostureDetecting extends StatelessWidget {
  const _PostureDetecting();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedText(text: 'VRゴーグルを装着して\n坐禅の姿勢でお待ちください', fontSize: 20),
        SizedBox(height: 8),
        OutlinedText(text: '検知中...', fontSize: 14),
      ],
    );
  }
}

class _PostureConfirmed extends StatelessWidget {
  const _PostureConfirmed();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OutlinedText(text: '姿勢を確認しました', fontSize: 20),
        SizedBox(height: 8),
        OutlinedText(text: 'まもなく開始します', fontSize: 14),
      ],
    );
  }
}

class _ZazenInProgress extends StatelessWidget {
  const _ZazenInProgress();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _Katsu extends HookConsumerWidget {
  const _Katsu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countdown = useState(3);
    useEffect(() {
      if (countdown.value >= 0) {
        Future.delayed(const Duration(seconds: 1), () async {
          countdown.value -= 1;
          if (countdown.value == 0) {
            ref.read(pavlokProvider.future).catchError((e) {
              debugPrint('Failed to connect to Pavlok: $e');
            });
          }
        });
      }
      return null;
    }, [countdown.value]);

    final text = countdown.value > 0 ? '警策を行います: ${countdown.value}' : '';

    return OutlinedText(text: text, fontSize: 20);
  }
}

class _ZazenEnding extends StatelessWidget {
  const _ZazenEnding();

  @override
  Widget build(BuildContext context) {
    return const OutlinedText(text: '終了', fontSize: 20);
  }
}

class _ResultDisplay extends HookWidget {
  const _ResultDisplay();

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 4),
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

    return SizedBox(
      width: 180,
      height: 450,
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, _) => CustomPaint(
                painter: _HanshiPainter(progress: controller.value),
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
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HanshiPainter extends CustomPainter {
  const _HanshiPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppColors.background,
    );

    if (progress <= 0) return;

    const totalPoints = 100;
    final visibleCount = (totalPoints * progress).round().clamp(0, totalPoints);
    if (visibleCount < 2) return;

    final inputPoints = List.generate(visibleCount, (i) {
      final t = i / (totalPoints - 1);
      final y = size.height * 0.1 + t * size.height * 0.8;
      final wobble = sin(t * pi * 8) * 6.0;
      final x = size.width / 2 + wobble;
      final pressure = 0.4 + sin(t * pi * 4).abs() * 0.5;
      return PointVector(x, y, pressure);
    });

    final outlinePoints = getStroke(
      inputPoints,
      options: StrokeOptions(
        size: 16,
        thinning: 0.7,
        smoothing: 0.5,
        streamline: 0.3,
        start: StrokeEndOptions.start(taperEnabled: true, customTaper: 20),
        end: StrokeEndOptions.end(taperEnabled: true, customTaper: 20),
      ),
    );

    if (outlinePoints.length < 2) return;

    final path = Path()..moveTo(outlinePoints.first.dx, outlinePoints.first.dy);
    for (final p in outlinePoints.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
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
  bool shouldRepaint(_HanshiPainter old) => old.progress != progress;
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
