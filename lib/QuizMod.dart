import 'package:flutter/material.dart';

// Quiz Mod Model
class QuizMod {
  final String id;
  final IconData icon;
  final String label;
  final String description;

  QuizMod({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
  });
}

// Quiz Mods Storage and Logic
class QuizModsStore {
  // Get all available mods
  static List<QuizMod> getAllMods() {
    return [
      QuizMod(
        id: 'double_time',
        icon: Icons.timer_outlined,
        label: 'DOUBLE TIME',
        description: 'Timer 2x faster',
      ),
      QuizMod(
        id: 'no_time',
        icon: Icons.timer_off_outlined,
        label: 'NO TIME',
        description: 'No timer',
      ),
      QuizMod(
        id: 'perfectionist',
        icon: Icons.percent,
        label: 'PERFECTIONIST',
        description: 'No mistakes allowed',
      ),
      QuizMod(
        id: 'one_more_try',
        icon: Icons.refresh,
        label: 'ONE MORE TRY',
        description: 'One extra life',
      ),
    ];
  }

  // Get mod by ID
  static QuizMod? getModById(String id) {
    final mods = getAllMods();
    try {
      return mods.firstWhere((mod) => mod.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if a mod ID exists
  static bool modExists(String id) {
    return getAllMods().any((mod) => mod.id == id);
  }

  // ----- MOD LOGIC FUNCTIONS -----

  // Calculate timer decrement speed based on active mods
  static double getTimerDecrement(Set<String> activeMods) {
    if (activeMods.contains('no_time')) {
      return 0.0; // No timer
    } else if (activeMods.contains('double_time')) {
      return 0.2; // 2x faster (normal is 0.1)
    }
    return 0.1; // Normal speed
  }

  // Check if timer should be disabled
  static bool isTimerDisabled(Set<String> activeMods) {
    return activeMods.contains('no_time');
  }

  // Check if perfectionist mode is active
  static bool isPerfectionistMode(Set<String> activeMods) {
    return activeMods.contains('perfectionist');
  }

  // Check if one more try is available
  static bool hasExtraLife(Set<String> activeMods) {
    return activeMods.contains('one_more_try');
  }

  // Handle answer result with mod effects
  // Returns: Map with keys 'timeChange' (double), 'endQuiz' (bool), 'useExtraLife' (bool)
  static Map<String, dynamic> handleAnswerWithMods({
    required bool isCorrect,
    required Set<String> activeMods,
    required double currentTime,
    required double maxTime,
    required bool extraLifeUsed,
  }) {
    Map<String, dynamic> result = {
      'timeChange': 0.0,
      'endQuiz': false,
      'useExtraLife': false,
      'message': '',
    };

    if (isCorrect) {
      // Correct answer: add time (unless no_time is active)
      if (!isTimerDisabled(activeMods)) {
        result['timeChange'] = 2.0;
        result['message'] = 'Correct! +2 seconds';
      } else {
        result['message'] = 'Correct!';
      }
    } else {
      // Wrong answer
      if (isPerfectionistMode(activeMods)) {
        // Perfectionist mode: check for extra life
        if (hasExtraLife(activeMods) && !extraLifeUsed) {
          result['useExtraLife'] = true;
          result['message'] = 'Wrong! Extra life used!';
        } else {
          result['endQuiz'] = true;
          result['message'] = 'Wrong! Perfectionist mode - Quiz ended!';
        }
      } else {
        // Normal wrong answer: subtract time (unless no_time is active)
        if (!isTimerDisabled(activeMods)) {
          result['timeChange'] = -2.0;
          result['message'] = 'Wrong! -2 seconds';
        } else {
          result['message'] = 'Wrong!';
        }
      }
    }

    return result;
  }

  // Calculate new remaining time with bounds checking
  static double calculateNewTime({
    required double currentTime,
    required double timeChange,
    required double maxTime,
  }) {
    double newTime = currentTime + timeChange;
    if (newTime > maxTime) newTime = maxTime;
    if (newTime < 0) newTime = 0;
    return newTime;
  }

  // Get initial timer value based on mods
  static double getInitialTime(Set<String> activeMods, double defaultInitialTime) {
    if (isTimerDisabled(activeMods)) {
      return double.infinity; // Or a very large number
    }
    return defaultInitialTime;
  }

  // Get score multiplier based on active mods
  static double getScoreMultiplier(Set<String> activeMods) {
    double multiplier = 1.0;
    
    if (activeMods.contains('double_time')) {
      multiplier += 0.5; // +50% for double time
    }
    if (activeMods.contains('perfectionist')) {
      multiplier += 1.0; // +100% for perfectionist
    }
    if (activeMods.contains('no_time')) {
      multiplier -= 0.2; // -20% for no time (easier)
    }
    
    return multiplier;
  }

  // Calculate final score with mod multiplier
  static int calculateScore({
    required int correctAnswers,
    required Set<String> activeMods,
    int baseScorePerQuestion = 1000,
  }) {
    double baseScore = correctAnswers * baseScorePerQuestion.toDouble();
    double multiplier = getScoreMultiplier(activeMods);
    return (baseScore * multiplier).round();
  }
}
