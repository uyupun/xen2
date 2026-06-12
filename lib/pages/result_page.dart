import 'package:flutter/material.dart';
import 'package:xen2/components/primary_button.dart';
import 'package:xen2/features/imu/imu_service.dart';
import 'package:xen2/features/zazen/play_flow/result_display.dart';
import 'package:xen2/pages/top_page.dart';

class ResultPage extends StatelessWidget {
  const ResultPage({
    super.key,
    this.postureHistory = const [],
    this.postureBaseline,
  });

  final List<AttitudeData> postureHistory;
  final AttitudeData? postureBaseline;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ResultDisplay(
              postureHistory: postureHistory,
              postureBaseline: postureBaseline,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 400,
              child: PrimaryButton(
                label: '坐禅を終了する',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const TopPage()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
