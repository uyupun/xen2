// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zazen_flow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ZazenFlow)
final zazenFlowProvider = ZazenFlowProvider._();

final class ZazenFlowProvider
    extends $NotifierProvider<ZazenFlow, ZazenFlowState> {
  ZazenFlowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zazenFlowProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zazenFlowHash();

  @$internal
  @override
  ZazenFlow create() => ZazenFlow();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ZazenFlowState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ZazenFlowState>(value),
    );
  }
}

String _$zazenFlowHash() => r'6e2efacb89eceed7eaae1c31109720aefa3cfd26';

abstract class _$ZazenFlow extends $Notifier<ZazenFlowState> {
  ZazenFlowState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ZazenFlowState, ZazenFlowState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ZazenFlowState, ZazenFlowState>,
              ZazenFlowState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
