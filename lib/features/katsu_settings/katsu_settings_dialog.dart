import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/features/katsu_settings/katsu_settings_provider.dart';

class KatsuSettingsDialog extends ConsumerWidget {
  const KatsuSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(katsuSettingsProvider);
    final notifier = ref.read(katsuSettingsProvider.notifier);

    return AlertDialog(
      backgroundColor: AppColors.background,
      title: const Text(
        '喝の設定',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text(
                'Pavlok',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              value: settings.pavlokEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: notifier.setPavlokEnabled,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 8),
            Text(
              '刺激値: ${settings.stimulusValue}',
              style: TextStyle(
                color: settings.pavlokEnabled
                    ? AppColors.textPrimary
                    : AppColors.textPrimary.withValues(alpha: 0.4),
                fontSize: 14,
              ),
            ),
            Slider(
              value: settings.stimulusValue.toDouble(),
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: settings.pavlokEnabled
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.3),
              label: settings.stimulusValue.toString(),
              onChanged: settings.pavlokEnabled
                  ? (v) => notifier.setStimulusValue(v.round())
                  : null,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: Text(
                'バイブ',
                style: TextStyle(
                  color: settings.pavlokEnabled
                      ? AppColors.textPrimary.withValues(alpha: 0.4)
                      : AppColors.textPrimary,
                ),
              ),
              value: settings.vibrationEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: settings.pavlokEnabled
                  ? null
                  : notifier.setVibrationEnabled,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            '閉じる',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
