import 'package:flutter/material.dart';
import 'package:xen2/constants/app_colors.dart';

class CloseDialog extends StatelessWidget {
  const CloseDialog({
    super.key,
    required this.onContinue,
    required this.onExit,
  });

  final VoidCallback onContinue;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDDD9E6)),
      ),
      elevation: 4,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '坐禅を終了しますか？',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onContinue,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      foregroundColor: AppColors.textPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('続ける', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onExit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: const Text('終了する', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
