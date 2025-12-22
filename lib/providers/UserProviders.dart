import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String userId;
  final String username;
  final String email;
  final String rank;
  final String ukbiLevel;
  final String? avatarUrl;
  final String displayName;
  final String aboutMe;
  final List<String> hobbies;
  final double accuracy;
  final int totalScore;
  final int quizzesCompleted;
  final int correctAnswers;
  final int wrongAnswers;

  UserModel({
    required this.userId,
    required this.username,
    required this.email,
    required this.rank,
    required this.ukbiLevel,
    this.avatarUrl,
    required this.displayName,
    required this.aboutMe,
    required this.hobbies,
    required this.accuracy,
    required this.totalScore,
    required this.quizzesCompleted,
    required this.correctAnswers,
    required this.wrongAnswers,
  });

  String get accuracyFormatted => '${accuracy.toStringAsFixed(1)}%';

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'displayName': displayName, // ✅ FIXED: Changed from 'displayname' to 'displayName'
      'email': email,
      'rank': rank,
      'ukbiLevel': ukbiLevel,
      'avatarUrl': avatarUrl,
      'aboutMe': aboutMe,
      'hobbies': hobbies,
      'accuracy': accuracy,
      'totalScore': totalScore,
      'quizzesCompleted': quizzesCompleted,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, String userId) {
    // ✅ Safely handle List<dynamic> to List<String> conversion
    List<String> hobbiesList = [];
    if (map['hobbies'] != null) {
      try {
        hobbiesList = List<String>.from(map['hobbies']);
      } catch (e) {
        print('⚠️ Error parsing hobbies: $e');
        hobbiesList = [];
      }
    }

    return UserModel(
      userId: userId,
      username: map['username'] ?? 'Unknown User',
      displayName: map['displayName'] ?? _generateRandomDisplayName(), // ✅ FIXED: Added fallback
      email: map['email'] ?? '',
      rank: map['rank'] ?? 'Unranked',
      ukbiLevel: map['ukbiLevel'] ?? 'Pemula',
      avatarUrl: map['avatarUrl'],
      aboutMe: map['aboutMe'] ?? '',
      hobbies: hobbiesList,
      accuracy: (map['accuracy'] ?? 0.0).toDouble(),
      totalScore: map['totalScore'] ?? 0,
      quizzesCompleted: map['quizzesCompleted'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      wrongAnswers: map['wrongAnswers'] ?? 0,
    );
  }

  // ✅ Generate random display name if not exists
  static String _generateRandomDisplayName() {
    final adjectives = ['Swift', 'Brave', 'Clever', 'Mighty', 'Silent', 'Wild', 'Bold', 'Quick'];
    final nouns = ['Tiger', 'Eagle', 'Dragon', 'Phoenix', 'Wolf', 'Falcon', 'Bear', 'Lion'];
    final random = DateTime.now().millisecondsSinceEpoch;
    final adj = adjectives[random % adjectives.length];
    final noun = nouns[(random ~/ 1000) % nouns.length];
    final num = (random % 1000).toString().padLeft(3, '0');
    return '$adj$noun$num';
  }
}

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  List<UserModel> _leaderboard = [];

  UserModel? get currentUserOrNull => _currentUser;

  UserModel get currentUser {
    if (_currentUser == null) {
      throw Exception('User data not loaded');
    }
    return _currentUser!;
  }

  List<UserModel> get leaderboard => _leaderboard;

  // Getters for easy access
  String get userId => currentUser.userId;
  String get username => currentUser.username;
  String get displayName => currentUser.displayName;
  String get email => currentUser.email;
  String get rank => currentUser.rank;
  String get ukbiLevel => currentUser.ukbiLevel;
  String? get avatarUrl => currentUser.avatarUrl;
  String get aboutMe => currentUser.aboutMe;
  List<String> get hobbies => currentUser.hobbies;
  double get accuracy => currentUser.accuracy;
  int get totalScore => currentUser.totalScore;
  int get quizzesCompleted => currentUser.quizzesCompleted;
  int get correctAnswers => currentUser.correctAnswers;
  int get wrongAnswers => currentUser.wrongAnswers;

  Future<void> loadUserData({String? userId}) async {
    try {
      String? uid = userId ?? FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) {
        print('❌ No user ID available');
        throw Exception('User not logged in');
      }

      print('🔍 Loading user data for: $uid');
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(uid).get();

      if (!snapshot.exists) {
        print('❌ User document not found for: $uid');
        throw Exception('User data not found');
      }

      print('✅ User document found');
      Map<String, dynamic> data = snapshot.data()!;

      // ✅ Use the factory constructor with built-in safe parsing
      _currentUser = UserModel.fromMap(data, uid);

      notifyListeners();
      print('✅ User data loaded successfully');
      print('✅ Username: ${_currentUser!.username}');
      print('✅ Display Name: ${_currentUser!.displayName}');
    } catch (e) {
      print('❌ Error in loadUserData: $e');
      rethrow;
    }
  }

  Future<void> updateUserData(Map<String, dynamic> updates) async {
    try {
      if (_currentUser == null) {
        throw Exception('No user loaded');
      }

      await _firestore.collection('users').doc(_currentUser!.userId).update(updates);

      // Reload user data after update
      await loadUserData(userId: _currentUser!.userId);
      print('✅ User data updated successfully');
    } catch (e) {
      print('❌ Error updating user data: $e');
      rethrow;
    }
  }

  Future<void> updateStatsAfterQuiz({
    required int correctAnswersInQuiz,
    required int wrongAnswersInQuiz,
    required int scoreEarned,
  }) async {
    try {
      if (_currentUser == null) {
        throw Exception('No user loaded');
      }

      final newTotalScore = _currentUser!.totalScore + scoreEarned;
      final newQuizzesCompleted = _currentUser!.quizzesCompleted + 1;
      final totalCorrect = _currentUser!.correctAnswers + correctAnswersInQuiz;
      final totalWrong = _currentUser!.wrongAnswers + wrongAnswersInQuiz;
      final totalQuestions = totalCorrect + totalWrong;
      final newAccuracy = totalQuestions > 0
          ? (totalCorrect / totalQuestions) * 100
          : 0.0;

      await _firestore.collection('users').doc(_currentUser!.userId).update({
        'totalScore': newTotalScore,
        'quizzesCompleted': newQuizzesCompleted,
        'correctAnswers': totalCorrect,
        'wrongAnswers': totalWrong,
        'accuracy': newAccuracy,
      });

      // Reload user data and leaderboard
      await loadUserData(userId: _currentUser!.userId);
      await loadLeaderboard();
      print('✅ Quiz stats updated successfully');
    } catch (e) {
      print('❌ Error updating quiz stats: $e');
      rethrow;
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      print('🔍 Loading leaderboard...');
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .orderBy('totalScore', descending: true)
          .limit(50)
          .get();

      _leaderboard = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners();
      print('✅ Leaderboard loaded: ${_leaderboard.length} users');
    } catch (e) {
      print('❌ Error loading leaderboard: $e');
      _leaderboard = [];
    }
  }

  void clearUser() {
    _currentUser = null;
    _leaderboard = [];
    notifyListeners();
    print('✅ User data cleared');
  }
}
