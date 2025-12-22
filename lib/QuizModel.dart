import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

// Main Quiz Model with Firebase support
class QuizModel {
  final String id;
  final String title;
  final String author;
  final double progress;
  final String difficulty;
  final bool isCompleted;
  final String description;
  final int duration;
  final int questionCount;
  final double rating;
  final String imagePath;

  QuizModel({
    required this.id,
    required this.title,
    required this.author,
    required this.progress,
    required this.difficulty,
    required this.isCompleted,
    required this.description,
    required this.duration,
    required this.questionCount,
    required this.rating,
    required this.imagePath,
  });

  // Convert from Firebase DocumentSnapshot
  factory QuizModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuizModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      progress: (data['progress'] ?? 0.0).toDouble(),
      difficulty: data['difficulty'] ?? 'Normal',
      isCompleted: data['isCompleted'] ?? false,
      description: data['description'] ?? '',
      duration: data['duration'] ?? 30,
      questionCount: data['questionCount'] ?? 10,
      rating: (data['rating'] ?? 0.0).toDouble(),
      imagePath: data['imagePath'] ?? 'assets/gambar_randomquiz.png',
    );
  }

  // Convert from JSON
  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      progress: (json['progress'] ?? 0.0).toDouble(),
      difficulty: json['difficulty'] ?? 'Normal',
      isCompleted: json['isCompleted'] ?? false,
      description: json['description'] ?? '',
      duration: json['duration'] ?? 30,
      questionCount: json['questionCount'] ?? 10,
      rating: (json['rating'] ?? 0.0).toDouble(),
      imagePath: json['imagePath'] ?? 'assets/gambar_randomquiz.png',
    );
  }

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'progress': progress,
      'difficulty': difficulty,
      'isCompleted': isCompleted,
      'description': description,
      'duration': duration,
      'questionCount': questionCount,
      'rating': rating,
      'imagePath': imagePath,
    };
  }
}

// Question Model with Firebase support
class QuestionModel {
  final String question;
  final List<String> originalOptions;
  final String correctAnswer;
  late List<String> shuffledOptions;
  late int correctAnswerIndex;

  QuestionModel({
    required this.question,
    required this.originalOptions,
    required this.correctAnswer,
  }) {
    shuffledOptions = List.from(originalOptions);
    shuffledOptions.shuffle(Random());
    correctAnswerIndex = shuffledOptions.indexOf(correctAnswer);
  }

  void reshuffleOptions() {
    shuffledOptions.shuffle(Random());
    correctAnswerIndex = shuffledOptions.indexOf(correctAnswer);
  }

  // Convert from Firebase
  factory QuestionModel.fromFirestore(Map<String, dynamic> data) {
    return QuestionModel(
      question: data['question'] ?? '',
      originalOptions: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
    );
  }

  // Convert from JSON
  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? '',
      originalOptions: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
    );
  }

  // Convert to JSON for Firebase
  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'options': originalOptions,
      'correctAnswer': correctAnswer,
    };
  }
}

// Multiplayer Room Model
class MultiplayerRoom {
  final String id;
  final String quizId;
  final String hostId;
  final String hostName;
  final List<String> playerIds;
  final List<String> playerNames;
  final int maxPlayers;
  final String status; // 'waiting', 'playing', 'finished'
  final DateTime createdAt;

  MultiplayerRoom({
    required this.id,
    required this.quizId,
    required this.hostId,
    required this.hostName,
    required this.playerIds,
    required this.playerNames,
    this.maxPlayers = 10,
    this.status = 'waiting',
    required this.createdAt,
  });

  factory MultiplayerRoom.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MultiplayerRoom(
      id: doc.id,
      quizId: data['quizId'] ?? '',
      hostId: data['hostId'] ?? '',
      hostName: data['hostName'] ?? '',
      playerIds: List<String>.from(data['playerIds'] ?? []),
      playerNames: List<String>.from(data['playerNames'] ?? []),
      maxPlayers: data['maxPlayers'] ?? 10,
      status: data['status'] ?? 'waiting',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'hostId': hostId,
      'hostName': hostName,
      'playerIds': playerIds,
      'playerNames': playerNames,
      'maxPlayers': maxPlayers,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  int get currentPlayers => playerIds.length;
}

// Quiz data store - now with local fallback
class QuizDataStore {
  static Map<String, List<QuestionModel>> getQuizQuestions() {
    return {
      'quiz_spok': List.generate(
        10,
            (index) => QuestionModel(
          question: 'SPOK Question ${index + 1}: Identify the subject in the sentence.',
          originalOptions: ['Option A', 'Option B', 'Option C', 'Option D'],
          correctAnswer: 'Option A',
        ),
      ),
      'quiz_majas': [
        QuestionModel(
          question: 'Apa arti kata majas dalam Bahasa Indonesia?',
          originalOptions: ['Jenis makanan', 'Gaya bahasa', 'Alat musik', 'Tempat wisata'],
          correctAnswer: 'Gaya bahasa',
        ),
        QuestionModel(
          question: 'Manakah contoh majas perbandingan?',
          originalOptions: [
            'Waktu adalah uang.',
            'Aku lapar sekali.',
            'Dia sedang membaca buku.',
            'Mereka pergi ke pasar.',
          ],
          correctAnswer: 'Waktu adalah uang.',
        ),
        QuestionModel(
          question: 'Pilih kalimat yang menggunakan majas personifikasi:',
          originalOptions: [
            'Angin berbisik di telingaku.',
            'Aku berlari cepat sekali.',
            'Mereka makan bersama di taman.',
            'Ibu sedang tidur siang.',
          ],
          correctAnswer: 'Angin berbisik di telingaku.',
        ),
        QuestionModel(
          question: 'Apa itu persajakan dalam puisi Bahasa Indonesia?',
          originalOptions: [
            'Pola bunyi pada akhir baris',
            'Tema puisi',
            'Jumlah kata dalam baris',
            'Nama pengarang',
          ],
          correctAnswer: 'Pola bunyi pada akhir baris',
        ),
        QuestionModel(
          question: '"Hatiku hancur mendengar kabar itu."\nMajas apa yang digunakan pada kalimat tersebut?',
          originalOptions: ['Personifikasi', 'Hiperbola', 'Metafora', 'Simile'],
          correctAnswer: 'Metafora',
        ),
      ],
      'default': List.generate(
        10,
            (index) => QuestionModel(
          question: 'Question ${index + 1}: What is something?',
          originalOptions: ['Option 1', 'Option 2', 'Option 3', 'Option 4'],
          correctAnswer: 'Option 1',
        ),
      ),
    };
  }

  static List<QuestionModel> getQuestionsForQuiz(String quizId) {
    final allQuestions = getQuizQuestions();
    return allQuestions.containsKey(quizId) ? allQuestions[quizId]! : allQuestions['default']!;
  }

  static List<QuizModel> getSampleQuizzes() {
    return [
      QuizModel(
        id: 'quiz_spok',
        title: 'Subjek, Predikat, Objek, dan Keterangan',
        author: 'By Mas Owi',
        progress: 0.1,
        difficulty: 'Easy',
        isCompleted: false,
        description: 'Ini quiz SPOK.',
        duration: 30,
        questionCount: 10,
        rating: 5.0,
        imagePath: 'assets/gambar_randomquiz.png',
      ),
      QuizModel(
        id: 'quiz_majas',
        title: 'Majas dan Persatiran',
        author: 'By AbdulGaming69',
        progress: 0.5,
        difficulty: 'Normal',
        isCompleted: false,
        description: 'Quiz menuju penyatir professional.',
        duration: 25,
        questionCount: 5,
        rating: 4.5,
        imagePath: 'assets/gambar_randomquiz.png',
      ),
      QuizModel(
        id: 'quiz_diksi',
        title: 'Diksi',
        author: 'By Professor Abdulahab',
        progress: 1.0,
        difficulty: 'Hard',
        isCompleted: true,
        description: 'Kenali diksi dan artinya.',
        duration: 45,
        questionCount: 10,
        rating: 4.9,
        imagePath: 'assets/gambar_randomquiz.png',
      ),
    ];
  }
}
