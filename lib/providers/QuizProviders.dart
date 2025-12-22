import 'package:flutter/foundation.dart';
import '../QuizModel.dart';
import '../services/firebase_quiz_service.dart';

class QuizProvider with ChangeNotifier {
  // Private state variables
  List<QuizModel> _quizzes = [];
  QuizModel? _currentQuiz;
  Set<String> _selectedMods = {};
  Map<String, double> _quizProgress = {}; // Store progress by quiz ID
  Map<String, bool> _quizCompletion = {}; // Store completion status by quiz ID
  bool _isLoading = false;
  String? _errorMessage;

  // ✅ Firebase service instance
  final FirebaseQuizService _firebaseQuizService = FirebaseQuizService();

  // Public getters
  List<QuizModel> get quizzes => _quizzes;
  QuizModel? get currentQuiz => _currentQuiz;
  Set<String> get selectedMods => _selectedMods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get quiz progress by ID
  double getQuizProgress(String quizId) {
    return _quizProgress[quizId] ?? 0.0;
  }

  // Get quiz completion status by ID
  bool isQuizCompleted(String quizId) {
    return _quizCompletion[quizId] ?? false;
  }

  // ✅ Load all quizzes from FIREBASE (instead of local data)
  Future<void> loadQuizzes() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Fetch quizzes from Firebase
      _quizzes = [];

      // Listen to Firebase stream
      _firebaseQuizService.getQuizzes().listen((quizList) {
        _quizzes = quizList;

        // Initialize progress tracking for all quizzes
        for (var quiz in _quizzes) {
          if (!_quizProgress.containsKey(quiz.id)) {
            _quizProgress[quiz.id] = quiz.progress;
            _quizCompletion[quiz.id] = quiz.isCompleted;
          }
        }

        _isLoading = false;
        notifyListeners();
      }, onError: (e) {
        _isLoading = false;
        _errorMessage = 'Failed to load quizzes from Firebase: $e';
        notifyListeners();
      });

    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load quizzes: $e';
      notifyListeners();
    }
  }

  // ✅ Load single quiz from Firebase
  Future<void> loadQuizById(String quizId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final quiz = await _firebaseQuizService.getQuizById(quizId);
      if (quiz != null) {
        _currentQuiz = quiz;
      } else {
        _errorMessage = 'Quiz not found';
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load quiz: $e';
      notifyListeners();
    }
  }

  // Set the current active quiz
  void setCurrentQuiz(QuizModel quiz) {
    _currentQuiz = quiz;
    notifyListeners();
  }

  // Set current quiz by ID
  void setCurrentQuizById(String quizId) {
    final quiz = _quizzes.firstWhere(
          (q) => q.id == quizId,
      orElse: () => _quizzes.first,
    );
    setCurrentQuiz(quiz);
  }

  // Clear current quiz
  void clearCurrentQuiz() {
    _currentQuiz = null;
    notifyListeners();
  }

  // Toggle a mod (add or remove)
  void toggleMod(String modId) {
    if (_selectedMods.contains(modId)) {
      _selectedMods.remove(modId);
    } else {
      _selectedMods.add(modId);
    }
    notifyListeners();
  }

  // Add a mod
  void addMod(String modId) {
    if (!_selectedMods.contains(modId)) {
      _selectedMods.add(modId);
      notifyListeners();
    }
  }

  // Remove a mod
  void removeMod(String modId) {
    if (_selectedMods.contains(modId)) {
      _selectedMods.remove(modId);
      notifyListeners();
    }
  }

  // Clear all selected mods
  void clearMods() {
    _selectedMods.clear();
    notifyListeners();
  }

  // Check if a specific mod is selected
  bool isModSelected(String modId) {
    return _selectedMods.contains(modId);
  }

  // Update quiz progress (0.0 to 1.0)
  void updateQuizProgress(String quizId, double progress) {
    if (progress < 0.0 || progress > 1.0) {
      throw ArgumentError('Progress must be between 0.0 and 1.0');
    }

    _quizProgress[quizId] = progress;
    notifyListeners();
  }

  // Mark quiz as completed
  void markQuizCompleted(String quizId, {bool completed = true}) {
    _quizCompletion[quizId] = completed;
    // If completed, set progress to 100%
    if (completed) {
      _quizProgress[quizId] = 1.0;
    }
    notifyListeners();
  }

  // Update quiz progress based on quiz results
  void updateQuizResultProgress(String quizId, int correctAnswers, int totalQuestions) {
    if (totalQuestions > 0) {
      final progress = correctAnswers / totalQuestions;
      updateQuizProgress(quizId, progress);
      // Mark as completed if user got all answers correct
      if (correctAnswers == totalQuestions) {
        markQuizCompleted(quizId);
      }
    }
  }

  // ✅ Get questions for current quiz FROM FIREBASE
  Future<List<QuestionModel>> getCurrentQuizQuestions() async {
    if (_currentQuiz == null) {
      return [];
    }
    return await _firebaseQuizService.getQuizQuestions(_currentQuiz!.id);
  }

  // ✅ Get questions for any quiz by ID FROM FIREBASE
  Future<List<QuestionModel>> getQuestionsForQuiz(String quizId) async {
    return await _firebaseQuizService.getQuizQuestions(quizId);
  }

  // Get quiz by ID
  QuizModel? getQuizById(String quizId) {
    try {
      return _quizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  // Get filtered quizzes by difficulty
  List<QuizModel> getQuizzesByDifficulty(String difficulty) {
    return _quizzes.where((quiz) => quiz.difficulty == difficulty).toList();
  }

  // Get completed quizzes
  List<QuizModel> getCompletedQuizzes() {
    return _quizzes.where((quiz) => isQuizCompleted(quiz.id)).toList();
  }

  // Get incomplete quizzes
  List<QuizModel> getIncompleteQuizzes() {
    return _quizzes.where((quiz) => !isQuizCompleted(quiz.id)).toList();
  }

  // Get quizzes in progress (started but not completed)
  List<QuizModel> getQuizzesInProgress() {
    return _quizzes.where((quiz) {
      final progress = getQuizProgress(quiz.id);
      return progress > 0.0 && progress < 1.0;
    }).toList();
  }

  // Reset all quiz progress
  void resetAllProgress() {
    _quizProgress.clear();
    _quizCompletion.clear();
    for (var quiz in _quizzes) {
      _quizProgress[quiz.id] = 0.0;
      _quizCompletion[quiz.id] = false;
    }
    notifyListeners();
  }

  // Reset specific quiz progress
  void resetQuizProgress(String quizId) {
    _quizProgress[quizId] = 0.0;
    _quizCompletion[quizId] = false;
    notifyListeners();
  }

  // Get total number of completed quizzes
  int get completedQuizCount {
    return _quizCompletion.values.where((completed) => completed).length;
  }

  // Get total number of quizzes
  int get totalQuizCount {
    return _quizzes.length;
  }

  // Get overall completion percentage
  double get overallCompletionPercentage {
    if (_quizzes.isEmpty) return 0.0;
    return completedQuizCount / totalQuizCount;
  }

  // Calculate score multiplier based on selected mods
  double getScoreMultiplier() {
    double multiplier = 1.0;
    if (_selectedMods.contains('double_time')) {
      multiplier += 0.5;
    }
    if (_selectedMods.contains('no_time')) {
      multiplier += 0.0;
    }
    if (_selectedMods.contains('perfectionist')) {
      multiplier += 1.0;
    }
    if (_selectedMods.contains('one_more_try')) {
      multiplier += 0.25;
    }
    return multiplier;
  }

  // Calculate final score with mod multipliers
  int calculateFinalScore(int baseScore) {
    return (baseScore * getScoreMultiplier()).round();
  }
}
