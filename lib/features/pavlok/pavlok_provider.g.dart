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

String _$pavlokHash() => r'74d37bd27aca710a786c95a8e7bf7f7caf5fc085';
