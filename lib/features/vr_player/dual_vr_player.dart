import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vr_player/vr_player.dart';
import 'package:xen2/features/vr_player/dual_vr_player_controller_notifier_provider.dart';
import 'package:xen2/features/vr_player/video_loader.dart';

class DualVrPlayer extends ConsumerStatefulWidget {
  const DualVrPlayer({
    super.key,
    required this.assetPath,
    this.foregroundWidget = const SizedBox.shrink(),
  });

  final String assetPath;
  final Widget foregroundWidget;

  @override
  ConsumerState<DualVrPlayer> createState() => _DualVrPlayerState();
}

class _DualVrPlayerState extends ConsumerState<DualVrPlayer> {
  VrPlayerController? _leftController;
  VrPlayerController? _rightController;
  int _createdCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ref.read(dualVrPlayerControllerProvider.notifier).detach();
    _leftController?.dispose();
    _rightController?.dispose();
    super.dispose();
  }

  void _play() {
    _leftController?.play();
    _rightController?.play();
  }

  void _pause() {
    _leftController?.pause();
    _rightController?.pause();
  }

  void _onPlayerCreated(
    int index,
    VrPlayerController controller,
    VrPlayerObserver observer,
  ) {
    if (index == 0) {
      _leftController = controller;
    } else {
      _rightController = controller;
    }

    observer.onFinishedChange = (isFinished) {
      if (isFinished) {
        controller.seekTo(0);
        controller.play();
      }
    };

    _createdCount++;
    if (_createdCount == 2) {
      _loadBoth();
    }
  }

  Future<void> _loadBoth() async {
    try {
      final path = await loadVideoPath(widget.assetPath);
      await Future.wait([
        _leftController!.loadVideo(videoUrl: path),
        _rightController!.loadVideo(videoUrl: path),
      ]);
      ref
          .read(dualVrPlayerControllerProvider.notifier)
          .attach(onPlay: _play, onPause: _pause);
    } catch (e) {
      debugPrint('DualVrPlayer: failed to load video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final halfWidth = size.width / 2;

    return Stack(
      children: [
        // 左側のVRプレイヤー
        Positioned(
          left: 0,
          top: 0,
          width: halfWidth,
          height: size.height,
          child: VrPlayer(
            x: 0,
            y: 0,
            width: halfWidth,
            height: size.height,
            onCreated: (c, o) => _onPlayerCreated(0, c, o),
          ),
        ),
        // 右側のVRプレイヤー
        Positioned(
          left: halfWidth,
          top: 0,
          width: halfWidth,
          height: size.height,
          child: VrPlayer(
            x: 0,
            y: 0,
            width: halfWidth,
            height: size.height,
            onCreated: (c, o) => _onPlayerCreated(1, c, o),
          ),
        ),
        // 中央の区切り線
        Positioned(
          left: halfWidth - 0.5,
          top: 0,
          bottom: 0,
          child: Container(width: 1, color: Colors.white24),
        ),
        // 左側テキスト
        Positioned(
          left: 0,
          top: 0,
          width: halfWidth,
          height: size.height,
          child: Center(child: widget.foregroundWidget),
        ),
        // 右側テキスト
        Positioned(
          left: halfWidth,
          top: 0,
          width: halfWidth,
          height: size.height,
          child: Center(child: widget.foregroundWidget),
        ),
      ],
    );
  }
}
