import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:xen2/constants/app_colors.dart';
import 'package:xen2/features/katsu_settings/katsu_settings_provider.dart';
import 'package:xen2/features/pavlok/pavlok_provider.dart';

class KatsuSettingsDialog extends HookConsumerWidget {
  const KatsuSettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(katsuSettingsProvider);
    final notifier = ref.read(katsuSettingsProvider.notifier);
    final isTesting = useState(false);
    final testResult = useState<({bool success, String message})?>(null);

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: AppColors.background,
      child: SizedBox.expand(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            title: const Text(
              '喝の設定',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    title: const Text(
                      'Pavlok',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                    value: settings.pavlokEnabled,
                    activeThumbColor: AppColors.primary,
                    onChanged: (v) {
                      notifier.setPavlokEnabled(v);
                      testResult.value = null;
                    },
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
                        ? (v) {
                            notifier.setStimulusValue(v.round());
                            testResult.value = null;
                          }
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
                  const SizedBox(height: 32),
                  if (settings.pavlokEnabled) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: isTesting.value
                            ? null
                            : () async {
                                isTesting.value = true;
                                testResult.value = null;
                                try {
                                  await ref.read(
                                    pavlokProvider(settings.stimulusValue)
                                        .future,
                                  );
                                  testResult.value = (
                                    success: true,
                                    message: '送信成功（刺激値: ${settings.stimulusValue}）',
                                  );
                                } catch (e) {
                                  testResult.value = (
                                    success: false,
                                    message: 'エラー: $e',
                                  );
                                } finally {
                                  isTesting.value = false;
                                }
                              },
                        icon: isTesting.value
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.bolt),
                        label: Text(isTesting.value ? '送信中...' : 'テスト送信'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    if (testResult.value != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Icon(
                              testResult.value!.success
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: testResult.value!.success
                                  ? Colors.green
                                  : Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                testResult.value!.message,
                                style: TextStyle(
                                  color: testResult.value!.success
                                      ? Colors.green
                                      : Colors.red,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
