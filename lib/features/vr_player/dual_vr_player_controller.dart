import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'dual_vr_player_controller.freezed.dart';

@freezed
class DualVrPlayerController with _$DualVrPlayerController {
  const DualVrPlayerController({required this.onPlay, required this.onPause});

  @override
  final VoidCallback onPlay;
  @override
  final VoidCallback onPause;
}
