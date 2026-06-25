// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'katsu_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KatsuSettings)
final katsuSettingsProvider = KatsuSettingsProvider._();

final class KatsuSettingsProvider
    extends $NotifierProvider<KatsuSettings, KatsuSettingsState> {
  KatsuSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'katsuSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$katsuSettingsHash();

  @$internal
  @override
  KatsuSettings create() => KatsuSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KatsuSettingsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KatsuSettingsState>(value),
    );
  }
}

String _$katsuSettingsHash() => r'38c1748c465b0ea4d9385b71bded28680003f29e';

abstract class _$KatsuSettings extends $Notifier<KatsuSettingsState> {
  KatsuSettingsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KatsuSettingsState, KatsuSettingsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KatsuSettingsState, KatsuSettingsState>,
              KatsuSettingsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
