import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:xen2/features/vr_player/dual_vr_player_controller.dart';

part 'dual_vr_player_controller_notifier_provider.g.dart';

@riverpod
class DualVrPlayerControllerNotifier extends _$DualVrPlayerControllerNotifier {
  @override
  DualVrPlayerController? build() => null;

  void attach({required VoidCallback onPlay, required VoidCallback onPause}) {
    state = state != null
        ? state!.copyWith(onPlay: onPlay, onPause: onPause)
        : DualVrPlayerController(onPlay: onPlay, onPause: onPause);
  }

  void detach() {
    state = null;
  }

  void play() {
    state?.onPlay.call();
  }

  void pause() {
    state?.onPause.call();
  }
}
