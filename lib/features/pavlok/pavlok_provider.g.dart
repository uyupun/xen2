// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pavlok_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pavlok)
final pavlokProvider = PavlokProvider._();

final class PavlokProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  PavlokProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pavlokProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pavlokHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return pavlok(ref);
  }
}

String _$pavlokHash() => r'bb1bfa0553663eed9b6b1b49e8d5ad2f20aa1017';
