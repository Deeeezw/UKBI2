import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String userId;
  final String username;
  final String rank;
  final String ukbiLevel;
  final double accuracy;
  final int totalScore;
  final int quizzesCompleted;
  final double rankingScore;
  final String? avatarUrl;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.rank,
    required this.ukbiLevel,
    required this.accuracy,
    required this.totalScore,
    required this.quizzesCompleted,
    required this.rankingScore,
    this.avatarUrl,
  });

  String get accuracyFormatted => '${accuracy.toStringAsFixed(2)}%';

  factory LeaderboardEntry.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      double rankingScore,
      ) {
    final data = doc.data() ?? {};
    return LeaderboardEntry(
      userId: doc.id,
      username: data['username'] ?? 'Player',
      rank: data['rank']?.toString() ?? 'Unranked',
      ukbiLevel: data['ukbiLevel'] ?? 'Pemula',
      accuracy: (data['accuracy'] ?? 0).toDouble(),
      totalScore: (data['totalScore'] ?? 0) as int,
      quizzesCompleted: (data['quizzesCompleted'] ?? 0) as int,
      rankingScore: rankingScore,
      avatarUrl: data['avatarUrl'],
    );
  }
}

class FirebaseLeaderboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const double maxPossibleScore = 50000.0;
  static const int minQuizzesForRanking = 5;
  static const double accuracyWeight = 0.7; // 70%
  static const double scoreWeight = 0.3; // 30%

  /// Calculate ranking score for a user
  double calculateRankingScore({
    required double accuracy,
    required int totalScore,
  }) {
    final accuracyComponent = (accuracy / 100) * (accuracyWeight * 10000);
    final scoreComponent = (totalScore / maxPossibleScore) * (scoreWeight * 10000);
    return accuracyComponent + scoreComponent;
  }

  /// Get top N players from leaderboard
  Future<List<LeaderboardEntry>> getTopPlayers({
    int limit = 100,
  }) async {
    try {
      // Get all users who have completed minimum quizzes
      final snapshot = await _firestore
          .collection('users')
          .where('quizzesCompleted', isGreaterThanOrEqualTo: minQuizzesForRanking)
          .orderBy('quizzesCompleted', descending: false) // Required for compound query
          .get();

      // Calculate ranking scores and sort
      List<LeaderboardEntry> entries = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final accuracy = (data['accuracy'] ?? 0).toDouble();
        final totalScore = (data['totalScore'] ?? 0) as int;

        final rankingScore = calculateRankingScore(
          accuracy: accuracy,
          totalScore: totalScore,
        );

        entries.add(LeaderboardEntry.fromFirestore(doc, rankingScore));
      }

      // Sort by ranking score
      entries.sort((a, b) => b.rankingScore.compareTo(a.rankingScore));

      // Assign ranks
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        entries[i] = LeaderboardEntry(
          userId: entry.userId,
          username: entry.username,
          rank: '#${i + 1}',
          ukbiLevel: entry.ukbiLevel,
          accuracy: entry.accuracy,
          totalScore: entry.totalScore,
          quizzesCompleted: entry.quizzesCompleted,
          rankingScore: entry.rankingScore,
          avatarUrl: entry.avatarUrl,
        );
      }

      // Return top N
      return entries.take(limit).toList();
    } catch (e) {
      print('Error loading leaderboard: $e');
      return [];
    }
  }

  /// Get user's position in leaderboard
  Future<int> getUserPosition(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) return -1;

      final userData = userDoc.data()!;
      final userAccuracy = (userData['accuracy'] ?? 0).toDouble();
      final userScore = (userData['totalScore'] ?? 0) as int;
      final userQuizzes = (userData['quizzesCompleted'] ?? 0) as int;

      if (userQuizzes < minQuizzesForRanking) return -1;

      final userRankingScore = calculateRankingScore(
        accuracy: userAccuracy,
        totalScore: userScore,
      );

      // Get all qualified users
      final snapshot = await _firestore
          .collection('users')
          .where('quizzesCompleted', isGreaterThanOrEqualTo: minQuizzesForRanking)
          .get();

      int betterThanUser = 0;

      for (var doc in snapshot.docs) {
        if (doc.id == userId) continue;

        final data = doc.data();
        final accuracy = (data['accuracy'] ?? 0).toDouble();
        final totalScore = (data['totalScore'] ?? 0) as int;

        final rankingScore = calculateRankingScore(
          accuracy: accuracy,
          totalScore: totalScore,
        );

        if (rankingScore > userRankingScore) {
          betterThanUser++;
        }
      }

      return betterThanUser + 1; // Position is 1-indexed
    } catch (e) {
      print('Error getting user position: $e');
      return -1;
    }
  }

  /// Stream leaderboard updates in real-time
  Stream<List<LeaderboardEntry>> streamLeaderboard({int limit = 100}) {
    return _firestore
        .collection('users')
        .where('quizzesCompleted', isGreaterThanOrEqualTo: minQuizzesForRanking)
        .snapshots()
        .map((snapshot) {
      List<LeaderboardEntry> entries = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final accuracy = (data['accuracy'] ?? 0).toDouble();
        final totalScore = (data['totalScore'] ?? 0) as int;

        final rankingScore = calculateRankingScore(
          accuracy: accuracy,
          totalScore: totalScore,
        );

        entries.add(LeaderboardEntry.fromFirestore(doc, rankingScore));
      }

      // Sort by ranking score
      entries.sort((a, b) => b.rankingScore.compareTo(a.rankingScore));

      // Assign ranks
      for (int i = 0; i < entries.length; i++) {
        final entry = entries[i];
        entries[i] = LeaderboardEntry(
          userId: entry.userId,
          username: entry.username,
          rank: '#${i + 1}',
          ukbiLevel: entry.ukbiLevel,
          accuracy: entry.accuracy,
          totalScore: entry.totalScore,
          quizzesCompleted: entry.quizzesCompleted,
          rankingScore: entry.rankingScore,
          avatarUrl: entry.avatarUrl,
        );
      }

      return entries.take(limit).toList();
    });
  }

  /// Update user stats after quiz completion
  Future<void> updateUserStatsAfterQuiz({
    required String userId,
    required int correctAnswers,
    required int wrongAnswers,
    required int scoreEarned,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User not found');
      }

      final data = userDoc.data()!;
      final currentCorrect = (data['correctAnswers'] ?? 0) as int;
      final currentWrong = (data['wrongAnswers'] ?? 0) as int;
      final currentScore = (data['totalScore'] ?? 0) as int;
      final currentQuizzes = (data['quizzesCompleted'] ?? 0) as int;
      final currentAccuracy = (data['accuracy'] ?? 0).toDouble();

      // Calculate new stats
      final newCorrect = currentCorrect + correctAnswers;
      final newWrong = currentWrong + wrongAnswers;
      final newScore = currentScore + scoreEarned;
      final newQuizzes = currentQuizzes + 1;

      // Calculate new accuracy
      final totalQuestions = correctAnswers + wrongAnswers;
      final quizAccuracy = totalQuestions > 0
          ? (correctAnswers / totalQuestions) * 100
          : 0.0;

      final totalAccuracy = (currentAccuracy * currentQuizzes) + quizAccuracy;
      final newAccuracy = totalAccuracy / newQuizzes;

      // Calculate new ranking score
      final newRankingScore = calculateRankingScore(
        accuracy: newAccuracy,
        totalScore: newScore,
      );

      // Determine UKBI level
      String ukbiLevel;
      if (newAccuracy >= 95.0) {
        ukbiLevel = 'Istimewa';
      } else if (newAccuracy >= 90.0) {
        ukbiLevel = 'Sangat Unggul';
      } else if (newAccuracy >= 85.0) {
        ukbiLevel = 'Unggul';
      } else if (newAccuracy >= 75.0) {
        ukbiLevel = 'Madya';
      } else if (newAccuracy >= 65.0) {
        ukbiLevel = 'Semenjana';
      } else {
        ukbiLevel = 'Pemula';
      }

      // Update Firestore
      await _firestore.collection('users').doc(userId).update({
        'correctAnswers': newCorrect,
        'wrongAnswers': newWrong,
        'totalScore': newScore,
        'quizzesCompleted': newQuizzes,
        'accuracy': newAccuracy,
        'ukbiLevel': ukbiLevel,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Error updating user stats: $e');
      rethrow;
    }
  }
}
