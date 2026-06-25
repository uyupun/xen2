// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pavlok_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pavlok)
final pavlokProvider = PavlokFamily._();

final class PavlokProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  PavlokProvider._({
    required PavlokFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'pavlokProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pavlokHash();

  @override
  String toString() {
    return r'pavlokProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    final argument = this.argument as int;
    return pavlok(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PavlokProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pavlokHash() => r'289b4120d9a746da11c537cc90cc1e5099af8cad';

final class PavlokFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<void>, int> {
  PavlokFamily._()
    : super(
        retry: null,
        name: r'pavlokProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PavlokProvider call(int stimulusValue) =>
      PavlokProvider._(argument: stimulusValue, from: this);

  @override
  String toString() => r'pavlokProvider';
}
