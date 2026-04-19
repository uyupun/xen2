// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dual_vr_player_controller_notifier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DualVrPlayerControllerNotifier)
final dualVrPlayerControllerProvider =
    DualVrPlayerControllerNotifierProvider._();

final class DualVrPlayerControllerNotifierProvider
    extends
        $NotifierProvider<
          DualVrPlayerControllerNotifier,
          DualVrPlayerController?
        > {
  DualVrPlayerControllerNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dualVrPlayerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dualVrPlayerControllerNotifierHash();

  @$internal
  @override
  DualVrPlayerControllerNotifier create() => DualVrPlayerControllerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DualVrPlayerController? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DualVrPlayerController?>(value),
    );
  }
}

String _$dualVrPlayerControllerNotifierHash() =>
    r'600cab4efb177f03c9b9472b63599e4ef40c9198';

abstract class _$DualVrPlayerControllerNotifier
    extends $Notifier<DualVrPlayerController?> {
  DualVrPlayerController? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<DualVrPlayerController?, DualVrPlayerController?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DualVrPlayerController?, DualVrPlayerController?>,
              DualVrPlayerController?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
