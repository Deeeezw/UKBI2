import 'dart:math';

// Main Quiz Model with ID
class QuizModel {
  final String id; // Unique quiz identifier
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
}

// Question Model with randomized answers
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
    // Shuffle the options and find the new index of correct answer
    shuffledOptions = List.from(originalOptions);
    shuffledOptions.shuffle(Random());
    correctAnswerIndex = shuffledOptions.indexOf(correctAnswer);
  }

  // Method to reshuffle if needed
  void reshuffleOptions() {
    shuffledOptions.shuffle(Random());
    correctAnswerIndex = shuffledOptions.indexOf(correctAnswer);
  }
}

// Quiz data storage
class QuizDataStore {
  // Get questions by quiz ID
  static Map<String, List<QuestionModel>> getQuizQuestions() {
    return {
      'quiz_majas': List.generate(
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
          originalOptions: [
            'Jenis makanan',
            'Gaya bahasa',
            'Alat musik',
            'Tempat wisata',
          ],
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
          originalOptions: [
            'Personifikasi',
            'Hiperbola',
            'Metafora',
            'Simile',
          ],
          correctAnswer: 'Metafora',
        ),
      ],
      'quiz_sejarah': List.generate(
        10,
        (index) => QuestionModel(
          question: 'Sejarah Question ${index + 1}: Historical facts about Indonesian language.',
          originalOptions: ['1920s', '1930s', '1940s', '1950s'],
          correctAnswer: '1920s',
        ),
      ),
      'quiz_diksi': List.generate(
        10,
        (index) => QuestionModel(
          question: 'Diksi Question ${index + 1}: Choose the correct word meaning.',
          originalOptions: ['Meaning A', 'Meaning B', 'Meaning C', 'Meaning D'],
          correctAnswer: 'Meaning A',
        ),
      ),
      // Default questions for unknown quiz IDs
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

  // Get quiz by ID
  static QuizModel? getQuizById(String id) {
    final quizzes = getSampleQuizzes();
    try {
      return quizzes.firstWhere((quiz) => quiz.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get questions for a specific quiz ID
  static List<QuestionModel> getQuestionsForQuiz(String quizId) {
    final allQuestions = getQuizQuestions();
    return allQuestions.containsKey(quizId) 
        ? allQuestions[quizId]! 
        : allQuestions['default']!;
  }

  // Sample quiz list data with IDs
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
        id: 'quiz_sejarah',
        title: 'Sejarah Bahasa Indonesia',
        author: 'By Johanto',
        progress: 0.7,
        difficulty: 'Normal',
        isCompleted: false,
        description: 'Perjalanan memahami asal usul Bahasa Indonesia.',
        duration: 40,
        questionCount: 10,
        rating: 4.8,
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
