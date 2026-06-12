import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/pages/imu_debug_page.dart';
import 'package:xen2/pages/top_page.dart';

const _imuDebug = bool.fromEnvironment('IMU_DEBUG');

void main() async {
  // 1. ネイティブの初期化
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  // 環境変数の読み込み
  await dotenv.load();
  // 画面を横向き
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  // 2. 先に「2秒タイマー」を裏でスタートさせておく
  final splashTimer = Future.delayed(const Duration(seconds: 2));

  runApp(const ProviderScope(child: MyApp()));

  // 4. 「最初の1コマが画面に描画された瞬間」を待つ
  await WidgetsBinding.instance.endOfFrame;

  // 5. さらに2秒タイマーが終わるのを待つ
  await splashTimer;

  // 両方完了したらスプラッシュを消去
  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xen',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: _imuDebug ? const ImuDebugPage() : const TopPage(),
    );
  }
}
