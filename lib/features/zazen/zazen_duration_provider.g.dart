// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zazen_duration_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ZazenDuration)
final zazenDurationProvider = ZazenDurationProvider._();

final class ZazenDurationProvider
    extends $NotifierProvider<ZazenDuration, int> {
  ZazenDurationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'zazenDurationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$zazenDurationHash();

  @$internal
  @override
  ZazenDuration create() => ZazenDuration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$zazenDurationHash() => r'd2a2578cb9abfaa14b319b60802d8b93229ea3fd';

abstract class _$ZazenDuration extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
