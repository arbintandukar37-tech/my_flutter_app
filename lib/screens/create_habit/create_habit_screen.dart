import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:habit_flow/models/habit.dart';
import 'package:habit_flow/models/habit_type.dart';
import 'package:habit_flow/models/habit_frequency.dart';
import 'package:habit_flow/models/habit_category.dart';
import 'package:habit_flow/theme/app_colors.dart';
import 'package:habit_flow/theme/app_typography.dart';
import 'package:habit_flow/providers/habits_provider.dart';
import 'package:habit_flow/utils/haptic_utils.dart';
import 'package:habit_flow/screens/create_habit/widgets/icon_picker.dart';
import 'package:habit_flow/screens/create_habit/widgets/frequency_picker.dart';
import 'package:habit_flow/screens/create_habit/widgets/category_selector.dart';
import 'package:habit_flow/screens/create_habit/widgets/target_config.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  final Habit? habit;

  const CreateHabitScreen({super.key, this.habit});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentStep = 0;

  // Habit Draft State
  String _name = '';
  int _iconCodePoint = Icons.self_improvement.codePoint;
  HabitType _type = HabitType.good;
  HabitFrequency _frequency = const HabitFrequency(type: FrequencyType.daily);
  bool _isQuantitative = false;
  double? _targetQuantity = 1.0;
  String? _unit;
  HabitCategory _category = HabitCategory.morning;
  int _color = 0xFF00E676; // Default to green

  @override
  void initState() {
    super.initState();
    if (widget.habit != null) {
      final h = widget.habit!;
      _name = h.name;
      _nameController.text = h.name;
      _iconCodePoint = h.iconCodePoint;
      _type = h.type;
      _frequency = h.frequency;
      _isQuantitative = h.isQuantitative;
      _targetQuantity = h.targetQuantity;
      _unit = h.unit;
      _category = h.category;
      _color = h.color;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep == 0 && _name.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a habit name')),
      );
      return;
    }
    
    if (_currentStep < 4) {
      HapticUtils.lightTap();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _saveHabit();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      HapticUtils.lightTap();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveHabit() {
    final habit = Habit(
      id: widget.habit?.id ?? const Uuid().v4(),
      name: _name.trim(),
      iconCodePoint: _iconCodePoint,
      color: _color,
      type: _type,
      frequency: _frequency,
      isQuantitative: _isQuantitative,
      targetQuantity: _isQuantitative ? _targetQuantity : null,
      unit: _isQuantitative ? _unit : null,
      category: _category,
      createdAt: widget.habit?.createdAt ?? DateTime.now(),
    );

    if (widget.habit == null) {
      ref.read(habitsProvider.notifier).addHabit(habit);
    } else {
      ref.read(habitsProvider.notifier).updateHabit(habit);
    }

    HapticUtils.successBuzz();
    Navigator.of(context).pop();
  }

  Widget _buildDotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final isActive = index == _currentStep;
        final isCompleted = index < _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: isActive ? 24 : 8,
          decoration: BoxDecoration(
            color: isCompleted || isActive ? AppColors.accent : AppColors.card,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.habit == null ? 'New Habit' : 'Edit Habit',
          style: AppTypography.heading3,
        ),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: _prevPage,
              )
            : IconButton(
                icon: const Icon(Icons.close, color: AppColors.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: _buildDotIndicator(),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                  _buildStep5(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('What do you want to achieve?', style: AppTypography.heading2),
          const SizedBox(height: 24),
          TextField(
            controller: _nameController,
            style: AppTypography.body.copyWith(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'e.g. Read a book',
              hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.accent),
              ),
            ),
            onChanged: (val) {
              setState(() {
                _name = val;
              });
            },
          ),
          const SizedBox(height: 32),
          Text('Choose an icon', style: AppTypography.heading3),
          const SizedBox(height: 16),
          IconPicker(
            selectedIconCodePoint: _iconCodePoint,
            onIconSelected: (cp) {
              setState(() {
                _iconCodePoint = cp;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Is this a good or bad habit?', style: AppTypography.heading2),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildTypeCard(HabitType.good),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTypeCard(HabitType.bad),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeCard(HabitType type) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () {
        HapticUtils.lightTap();
        setState(() {
          _type = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cardHover : AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.border,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(type.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(type.label, style: AppTypography.heading3),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How often?', style: AppTypography.heading2),
          const SizedBox(height: 24),
          FrequencyPicker(
            initialFrequency: _frequency,
            onFrequencyChanged: (freq) {
              setState(() {
                _frequency = freq;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Set a target', style: AppTypography.heading2),
          const SizedBox(height: 24),
          TargetConfig(
            isQuantitative: _isQuantitative,
            targetQuantity: _targetQuantity,
            unit: _unit,
            onTypeChanged: (isQuant) {
              setState(() {
                _isQuantitative = isQuant;
              });
            },
            onTargetChanged: (val) {
              setState(() {
                _targetQuantity = val;
              });
            },
            onUnitChanged: (val) {
              setState(() {
                _unit = val;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Categorize & Style', style: AppTypography.heading2),
          const SizedBox(height: 24),
          CategorySelector(
            selectedCategory: _category,
            onCategorySelected: (cat) {
              setState(() {
                _category = cat;
              });
            },
            selectedColor: _color,
            onColorSelected: (color) {
              setState(() {
                _color = color;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.background,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: _nextPage,
          child: Text(
            _currentStep < 4 ? 'Next' : (widget.habit == null ? 'Create Habit' : 'Save Habit'),
            style: AppTypography.button.copyWith(color: AppColors.background),
          ),
        ),
      ),
    );
  }
}
