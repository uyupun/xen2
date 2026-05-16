import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/pages/imu_debug_page.dart';
import 'package:xen2/pages/top_page.dart';

const _imuDebug = bool.fromEnvironment('IMU_DEBUG');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ProviderScope(child: MyApp()));
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
