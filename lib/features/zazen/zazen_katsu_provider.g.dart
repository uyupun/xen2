// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zazen_katsu_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ZazenKatsu)
final zazenKatsuProvider = ZazenKatsuProvider._();

final class ZazenKatsuProvider
    extends $NotifierProvider<ZazenKatsu, KatsuStatus> {
  ZazenKatsuProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zazenKatsuProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zazenKatsuHash();

  @$internal
  @override
  ZazenKatsu create() => ZazenKatsu();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KatsuStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KatsuStatus>(value),
    );
  }
}

String _$zazenKatsuHash() => r'4d8897a54365d5670c9d34fa9abea3f2bc98cc58';

abstract class _$ZazenKatsu extends $Notifier<KatsuStatus> {
  KatsuStatus build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KatsuStatus, KatsuStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KatsuStatus, KatsuStatus>,
              KatsuStatus,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
