import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/models/habit_category.dart';
import 'package:habit_flow/providers/habits_provider.dart';
import 'package:habit_flow/providers/habit_logs_provider.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/screens/home/widgets/daily_progress_ring.dart';
import 'package:habit_flow/screens/home/widgets/category_header.dart';
import 'package:habit_flow/screens/home/widgets/habit_card.dart';
import 'package:habit_flow/screens/create_habit/create_habit_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late DateTime selectedDate;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _selectDate(DateTime date) {
    setState(() {
      selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final logs = ref.watch(habitLogsProvider);

    final scheduledHabits = habits.where((h) => h.frequency.isScheduledForDate(selectedDate)).toList();
    
    // Group habits by category
    final habitsByCategory = <HabitCategory, List<Habit>>{};
    for (var cat in HabitCategory.values) {
      habitsByCategory[cat] = scheduledHabits.where((h) => h.category == cat).toList();
    }

    final hasHabits = scheduledHabits.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: AppTypography.heading2.copyWith(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(DateTime.now()),
                    style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            
            // Date Ribbon
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final date = DateTime.now().subtract(const Duration(days: 3)).add(Duration(days: index));
                  final isSelected = date.year == selectedDate.year && date.month == selectedDate.month && date.day == selectedDate.day;
                  final isToday = date.year == DateTime.now().year && date.month == DateTime.now().month && date.day == DateTime.now().day;
                  
                  return GestureDetector(
                    onTap: () => _selectDate(date),
                    child: Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.accent : AppColors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isToday && !isSelected ? AppColors.accent : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormat('E').format(date),
                            style: AppTypography.caption.copyWith(
                              color: isSelected ? AppColors.accentDim : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            date.day.toString(),
                            style: AppTypography.heading3.copyWith(
                              color: isSelected ? AppColors.accentDim : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
            
            // Progress Ring
            const Center(
              child: DailyProgressRing(),
            ),

            const SizedBox(height: 24),

            // Main Content
            Expanded(
              child: hasHabits
                  ? ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: HabitCategory.values.length,
                      itemBuilder: (context, index) {
                        final category = HabitCategory.values.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
                        final cat = category[index];
                        final catHabits = habitsByCategory[cat] ?? [];
                        
                        if (catHabits.isEmpty) return const SizedBox.shrink();

                        int completedCount = 0;
                        for (var habit in catHabits) {
                          if (ref.read(habitLogsProvider.notifier).isCompletedForDate(habit.id, selectedDate)) {
                            completedCount++;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CategoryHeader(
                              category: cat,
                              completedCount: completedCount,
                              totalCount: catHabits.length,
                            ),
                            const SizedBox(height: 12),
                            ...catHabits.map((habit) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: HabitCard(
                                habit: habit,
                                date: selectedDate,
                              ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0, duration: 400.ms),
                            )),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: AppColors.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            'No habits scheduled for this day.',
                            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CreateHabitScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.accentDim,
                            ),
                            child: const Text('Create your first habit'),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
