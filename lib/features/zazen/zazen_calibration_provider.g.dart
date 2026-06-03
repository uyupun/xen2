// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zazen_calibration_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ZazenCalibration)
final zazenCalibrationProvider = ZazenCalibrationProvider._();

final class ZazenCalibrationProvider
    extends $NotifierProvider<ZazenCalibration, CalibrationStatus> {
  ZazenCalibrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zazenCalibrationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zazenCalibrationHash();

  @$internal
  @override
  ZazenCalibration create() => ZazenCalibration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalibrationStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalibrationStatus>(value),
    );
  }
}

String _$zazenCalibrationHash() => r'058fda72f4366910e2292ff2a12af434f5e0e194';

abstract class _$ZazenCalibration extends $Notifier<CalibrationStatus> {
  CalibrationStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CalibrationStatus, CalibrationStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalibrationStatus, CalibrationStatus>,
              CalibrationStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
