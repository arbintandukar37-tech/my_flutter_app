import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/widgets/glass_card.dart';
import 'package:habit_flow/models/habit_category.dart';
import 'package:habit_flow/providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Settings', style: AppTypography.heading2),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('GENERAL'),
          GlassCard(
            backgroundColor: AppColors.card,
            child: Column(
              children: [
                ListTile(
                  title: Text('Default Streak Freezes', style: AppTypography.bodyMedium),
                  subtitle: Text('Per week for new habits', style: AppTypography.caption),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: AppColors.textSecondary),
                        onPressed: () {
                          if (settings.defaultFreezesPerWeek > 0) {
                            settingsNotifier.updateFreezes(settings.defaultFreezesPerWeek - 1);
                          }
                        },
                      ),
                      Text('${settings.defaultFreezesPerWeek}', style: AppTypography.bodyMedium),
                      IconButton(
                        icon: const Icon(Icons.add, color: AppColors.textSecondary),
                        onPressed: () {
                          if (settings.defaultFreezesPerWeek < 4) {
                            settingsNotifier.updateFreezes(settings.defaultFreezesPerWeek + 1);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                _buildDivider(),
                ListTile(
                  title: Text('Default Category', style: AppTypography.bodyMedium),
                  trailing: DropdownButton<HabitCategory>(
                    value: settings.defaultCategory,
                    dropdownColor: AppColors.surface,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                    items: HabitCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text('${cat.emoji} ${cat.label}', style: AppTypography.bodyMedium),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) settingsNotifier.updateCategory(val);
                    },
                  ),
                ),
                _buildDivider(),
                SwitchListTile(
                  title: Text('Show Completed Habits', style: AppTypography.bodyMedium),
                  activeThumbColor: AppColors.accent,
                  value: settings.showCompletedHabits,
                  onChanged: (val) => settingsNotifier.toggleShowCompleted(val),
                ),
                _buildDivider(),
                SwitchListTile(
                  title: Text('Haptic Feedback', style: AppTypography.bodyMedium),
                  activeThumbColor: AppColors.accent,
                  value: settings.hapticEnabled,
                  onChanged: (val) => settingsNotifier.toggleHaptic(val),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader('DATA'),
          GlassCard(
            backgroundColor: AppColors.card,
            child: Column(
              children: [
                ListTile(
                  title: Text('Export Data', style: AppTypography.bodyMedium),
                  trailing: const Icon(Icons.download_rounded, color: AppColors.textSecondary),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Export feature coming soon!')),
                    );
                  },
                ),
                _buildDivider(),
                ListTile(
                  title: Text('Reset All Data', style: AppTypography.bodyMedium.copyWith(color: AppColors.missed)),
                  trailing: const Icon(Icons.delete_forever_rounded, color: AppColors.missed),
                  onTap: () => _confirmReset(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader('ABOUT'),
          GlassCard(
            backgroundColor: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Column(
                children: [
                  Text('Habit Flow Breezy', style: AppTypography.heading2),
                  const SizedBox(height: 4),
                  Text('Version 1.0.0', style: AppTypography.caption),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Built with Flutter ', style: AppTypography.caption),
                      const Icon(Icons.favorite, color: AppColors.missed, size: 14),
                    ],
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(
        title,
        style: AppTypography.label.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border.withValues(alpha: 0.5),
      indent: 16,
      endIndent: 16,
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Reset All Data?', style: AppTypography.heading3),
        content: Text(
          'This will permanently delete all your habits, logs, and settings. This action cannot be undone.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data reset to initial state')),
              );
            },
            child: const Text('Reset', style: TextStyle(color: AppColors.missed)),
          ),
        ],
      ),
    );
  }
}
