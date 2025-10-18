import 'package:flutter/foundation.dart';

// User Stats Model
class UserStats {
  final String username;
  final String userId;
  final String rank;
  final String ukbiLevel;
  final double accuracy;
  final int totalScore;
  final int quizzesCompleted;
  final int correctAnswers;
  final int wrongAnswers;
  final String aboutMe;
  final List<String> hobbies;
  final String? avatarUrl;

  UserStats({
    required this.username,
    required this.userId,
    required this.rank,
    required this.ukbiLevel,
    required this.accuracy,
    this.totalScore = 0,
    this.quizzesCompleted = 0,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.aboutMe = '',
    this.hobbies = const [],
    this.avatarUrl,
  });

  // Calculate total attempts
  int get totalAttempts => correctAnswers + wrongAnswers;

  // Get formatted accuracy string
  String get accuracyFormatted => '${accuracy.toStringAsFixed(2)}%';

  // Copy with method for immutability
  UserStats copyWith({
    String? username,
    String? userId,
    String? rank,
    String? ukbiLevel,
    double? accuracy,
    int? totalScore,
    int? quizzesCompleted,
    int? correctAnswers,
    int? wrongAnswers,
    String? aboutMe,
    List<String>? hobbies,
    String? avatarUrl,
  }) {
    return UserStats(
      username: username ?? this.username,
      userId: userId ?? this.userId,
      rank: rank ?? this.rank,
      ukbiLevel: ukbiLevel ?? this.ukbiLevel,
      accuracy: accuracy ?? this.accuracy,
      totalScore: totalScore ?? this.totalScore,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      aboutMe: aboutMe ?? this.aboutMe,
      hobbies: hobbies ?? this.hobbies,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

// Leaderboard Entry Model
class LeaderboardEntry {
  final String username;
  final String rank;
  final String ukbiLevel;
  final double accuracy;
  final int totalScore;
  final double rankingScore;

  LeaderboardEntry({
    required this.username,
    required this.rank,
    required this.ukbiLevel,
    required this.accuracy,
    required this.totalScore,
    required this.rankingScore,
  });

  String get accuracyFormatted => '${accuracy.toStringAsFixed(2)}%';
}

class UserProvider with ChangeNotifier {
  // Private state variables
  UserStats _currentUser = UserStats(
    username: 'Wowo',
    userId: 'Wowo#1985',
    rank: '#1',
    ukbiLevel: 'Istimewa',
    accuracy: 98.02,
    totalScore: 15000,
    quizzesCompleted: 12,
    correctAnswers: 245,
    wrongAnswers: 5,
    aboutMe: 'Lorem ipsum dolor sit amet consectetur. Nec eget accumsan molestie proin. Integer rhoncus vitae nisi natoque ac mus tellus scelerisque gravida.',
    hobbies: ['UI/UX', 'Graphics Design', 'Sports', 'Video Editor'],
  );

  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Configuration
  static const double maxPossibleScore = 50000.0;
  static const int minQuizzesForRanking = 5;
  static const double accuracyWeight = 0.7; // 70%
  static const double scoreWeight = 0.3;    // 30%

  // Public getters
  UserStats get currentUser => _currentUser;
  String get username => _currentUser.username;
  String get userId => _currentUser.userId;
  String get rank => _currentUser.rank;
  String get ukbiLevel => _currentUser.ukbiLevel;
  double get accuracy => _currentUser.accuracy;
  String get accuracyFormatted => _currentUser.accuracyFormatted;
  int get totalScore => _currentUser.totalScore;
  int get quizzesCompleted => _currentUser.quizzesCompleted;
  int get correctAnswers => _currentUser.correctAnswers;
  int get wrongAnswers => _currentUser.wrongAnswers;
  int get totalAttempts => _currentUser.totalAttempts;
  String get aboutMe => _currentUser.aboutMe;
  List<String> get hobbies => _currentUser.hobbies;
  String? get avatarUrl => _currentUser.avatarUrl;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Calculate player's ranking score (used for leaderboard positioning)
  double calculateRankingScore() {
    // Weighted combination: 70% accuracy, 30% score
    final accuracyComponent = (_currentUser.accuracy / 100) * (accuracyWeight * 10000);
    
    // Normalize score to 0-3000 range
    final scoreComponent = (_currentUser.totalScore / maxPossibleScore) * (scoreWeight * 10000);
    
    return accuracyComponent + scoreComponent;
  }

  // Initialize/load user data
  Future<void> loadUserData({String? userId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Simulate loading delay (replace with actual database call later)
      await Future.delayed(const Duration(milliseconds: 500));

      // Here you would load from database/API
      // For now, we're using the default user data

      // Initialize leaderboard
      _initializeLeaderboard();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load user data: $e';
      notifyListeners();
    }
  }

  // Initialize sample leaderboard
  void _initializeLeaderboard() {
    _leaderboard = [
      LeaderboardEntry(
        username: 'Abdul',
        rank: '#1',
        ukbiLevel: 'Istimewa',
        accuracy: 98.02,
        totalScore: 15000,
        rankingScore: 7361.4,
      ),
      LeaderboardEntry(
        username: 'Wiwi',
        rank: '#2',
        ukbiLevel: 'Istimewa',
        accuracy: 97.00,
        totalScore: 14500,
        rankingScore: 7260.0,
      ),
      LeaderboardEntry(
        username: 'Anto',
        rank: '#3',
        ukbiLevel: 'Sangat Unggul',
        accuracy: 95.25,
        totalScore: 13000,
        rankingScore: 7447.5,
      ),
      LeaderboardEntry(
        username: 'Kuda Lumping',
        rank: '#4',
        ukbiLevel: 'Unggul',
        accuracy: 95.25,
        totalScore: 12800,
        rankingScore: 7435.5,
      ),
    ];

    // Sort leaderboard by ranking score
    _leaderboard.sort((a, b) => b.rankingScore.compareTo(a.rankingScore));

    // Update ranks
    for (int i = 0; i < _leaderboard.length; i++) {
      _leaderboard[i] = LeaderboardEntry(
        username: _leaderboard[i].username,
        rank: '#${i + 1}',
        ukbiLevel: _leaderboard[i].ukbiLevel,
        accuracy: _leaderboard[i].accuracy,
        totalScore: _leaderboard[i].totalScore,
        rankingScore: _leaderboard[i].rankingScore,
      );
    }
  }

  // Update username
  void updateUsername(String newUsername) {
    _currentUser = _currentUser.copyWith(username: newUsername);
    notifyListeners();
  }

  // Update about me
  void updateAboutMe(String newAboutMe) {
    _currentUser = _currentUser.copyWith(aboutMe: newAboutMe);
    notifyListeners();
  }

  // Update hobbies
  void updateHobbies(List<String> newHobbies) {
    _currentUser = _currentUser.copyWith(hobbies: newHobbies);
    notifyListeners();
  }

  // Add hobby
  void addHobby(String hobby) {
    final updatedHobbies = List<String>.from(_currentUser.hobbies)..add(hobby);
    _currentUser = _currentUser.copyWith(hobbies: updatedHobbies);
    notifyListeners();
  }

  // Remove hobby
  void removeHobby(String hobby) {
    final updatedHobbies = List<String>.from(_currentUser.hobbies)..remove(hobby);
    _currentUser = _currentUser.copyWith(hobbies: updatedHobbies);
    notifyListeners();
  }

  // Update avatar URL
  void updateAvatar(String? newAvatarUrl) {
    _currentUser = _currentUser.copyWith(avatarUrl: newAvatarUrl);
    notifyListeners();
  }

  // Update stats after completing a quiz (with cumulative average accuracy)
  void updateStatsAfterQuiz({
    required int correctAnswersInQuiz,
    required int wrongAnswersInQuiz,
    required int scoreEarned,
  }) {
    // Calculate accuracy for the current quiz (0-100%)
    final totalQuestionsInQuiz = correctAnswersInQuiz + wrongAnswersInQuiz;
    final currentQuizAccuracy = totalQuestionsInQuiz > 0
        ? (correctAnswersInQuiz / totalQuestionsInQuiz) * 100
        : 0.0;

    // Calculate new cumulative accuracy
    // Formula: (current accuracy * quizzes completed + latest quiz accuracy) / (quizzes completed + 1)
    final currentTotalAccuracy = _currentUser.accuracy * _currentUser.quizzesCompleted;
    final newTotalAccuracy = currentTotalAccuracy + currentQuizAccuracy;
    final newQuizzesCompleted = _currentUser.quizzesCompleted + 1;
    final newAccuracy = newTotalAccuracy / newQuizzesCompleted;

    // Update correct and wrong answer totals (for reference)
    final newCorrectAnswers = _currentUser.correctAnswers + correctAnswersInQuiz;
    final newWrongAnswers = _currentUser.wrongAnswers + wrongAnswersInQuiz;

    _currentUser = _currentUser.copyWith(
      correctAnswers: newCorrectAnswers,
      wrongAnswers: newWrongAnswers,
      accuracy: newAccuracy,
      totalScore: _currentUser.totalScore + scoreEarned,
      quizzesCompleted: newQuizzesCompleted,
    );

    // Update rank based on new score and accuracy
    _updateRankBasedOnScore();

    notifyListeners();
  }

  // Update rank and UKBI level based on weighted ranking score
  void _updateRankBasedOnScore() {
    final rankingScore = calculateRankingScore();
    final accuracy = _currentUser.accuracy;
    final quizzesCompleted = _currentUser.quizzesCompleted;
    
    // Check if user has completed minimum quizzes for ranking
    if (quizzesCompleted < minQuizzesForRanking) {
      _currentUser = _currentUser.copyWith(
        rank: 'Unranked',
        ukbiLevel: 'Pemula',
      );
      return;
    }

    // Determine UKBI level based on accuracy (knowledge level)
    String newUkbiLevel;
    if (accuracy >= 95.0) {
      newUkbiLevel = 'Istimewa';      // Exceptional
    } else if (accuracy >= 90.0) {
      newUkbiLevel = 'Sangat Unggul'; // Very Excellent
    } else if (accuracy >= 85.0) {
      newUkbiLevel = 'Unggul';        // Excellent
    } else if (accuracy >= 75.0) {
      newUkbiLevel = 'Madya';         // Intermediate
    } else if (accuracy >= 65.0) {
      newUkbiLevel = 'Semenjana';     // Basic
    } else {
      newUkbiLevel = 'Pemula';        // Beginner
    }

    // Determine rank based on ranking score
    // In real implementation, this would query database for actual position
    String newRank;
    if (rankingScore >= 9000) {
      newRank = '#1';
    } else if (rankingScore >= 8000) {
      newRank = '#2';
    } else if (rankingScore >= 7000) {
      newRank = '#3';
    } else if (rankingScore >= 6000) {
      newRank = '#4-10';
    } else if (rankingScore >= 5000) {
      newRank = '#11-50';
    } else if (rankingScore >= 4000) {
      newRank = '#51-100';
    } else if (rankingScore >= 3000) {
      newRank = '#101-500';
    } else {
      newRank = '#500+';
    }

    _currentUser = _currentUser.copyWith(
      ukbiLevel: newUkbiLevel,
      rank: newRank,
    );
  }

  // Manually update user stats (for testing or admin purposes)
  void updateUserStats({
    String? rank,
    String? ukbiLevel,
    double? accuracy,
    int? totalScore,
    int? quizzesCompleted,
    int? correctAnswers,
    int? wrongAnswers,
  }) {
    _currentUser = _currentUser.copyWith(
      rank: rank,
      ukbiLevel: ukbiLevel,
      accuracy: accuracy,
      totalScore: totalScore,
      quizzesCompleted: quizzesCompleted,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
    );
    notifyListeners();
  }

  // Load leaderboard data
  Future<void> loadLeaderboard() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Simulate loading delay (replace with actual database call)
      await Future.delayed(const Duration(milliseconds: 500));

      // Here you would load from database/API
      _initializeLeaderboard();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load leaderboard: $e';
      notifyListeners();
    }
  }

  // Get user's leaderboard position
  int getUserLeaderboardPosition() {
    final userRankingScore = calculateRankingScore();
    
    int position = 1;
    for (var entry in _leaderboard) {
      if (entry.rankingScore > userRankingScore) {
        position++;
      }
    }
    
    return position;
  }

  // Check if user is in top 3
  bool get isTopThree {
    return getUserLeaderboardPosition() <= 3;
  }

  // Check if user is ranked
  bool get isRanked {
    return _currentUser.quizzesCompleted >= minQuizzesForRanking;
  }

  // Get quizzes needed for ranking
  int get quizzesNeededForRanking {
    final remaining = minQuizzesForRanking - _currentUser.quizzesCompleted;
    return remaining > 0 ? remaining : 0;
  }

  // Reset user stats (for testing purposes)
  void resetStats() {
    _currentUser = _currentUser.copyWith(
      rank: 'Unranked',
      ukbiLevel: 'Pemula',
      accuracy: 0.0,
      totalScore: 0,
      quizzesCompleted: 0,
      correctAnswers: 0,
      wrongAnswers: 0,
    );
    notifyListeners();
  }

  // Calculate average score per quiz
  double get averageScorePerQuiz {
    if (_currentUser.quizzesCompleted == 0) return 0.0;
    return _currentUser.totalScore / _currentUser.quizzesCompleted;
  }

  // Get performance level string
  String get performanceLevel {
    if (_currentUser.accuracy >= 95.0) return 'Excellent';
    if (_currentUser.accuracy >= 85.0) return 'Great';
    if (_currentUser.accuracy >= 75.0) return 'Good';
    if (_currentUser.accuracy >= 65.0) return 'Fair';
    return 'Needs Improvement';
  }

  // Check if user has completed any quiz
  bool get hasCompletedQuiz {
    return _currentUser.quizzesCompleted > 0;
  }
}
