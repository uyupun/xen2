import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'zazen_duration_provider.g.dart';

// TODO: SharedPreferences等で永続化する
@Riverpod(keepAlive: true)
class ZazenDuration extends _$ZazenDuration {
  @override
  int build() => 1;

  void update(int minutes) => state = minutes;
}
