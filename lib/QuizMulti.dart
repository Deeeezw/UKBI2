import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'MainMenu.dart';

class QuizModel {
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
}

class QuizDataStore {
  static Map<String, List<QuestionModel>> getQuizQuestions() {
    return {
      "Majas dan Persatiran": [
        QuestionModel(
          question: "Apa arti kata 'majas' dalam Bahasa Indonesia?",
          originalOptions: ["Jenis makanan", "Gaya bahasa", "Alat musik", "Tempat wisata"],
          correctAnswer: "Gaya bahasa",
        ),
        QuestionModel(
          question: "Manakah contoh majas perbandingan?",
          originalOptions: [
            "Waktu adalah uang.",
            "Aku lapar sekali.",
            "Dia sedang membaca buku.",
            "Mereka pergi ke pasar."
          ],
          correctAnswer: "Waktu adalah uang.",
        ),
        QuestionModel(
          question: "Pilih kalimat yang menggunakan majas personifikasi",
          originalOptions: [
            "Angin berbisik di telingaku.",
            "Aku berlari cepat sekali.",
            "Mereka makan bersama di taman.",
            "Ibu sedang tidur siang."
          ],
          correctAnswer: "Angin berbisik di telingaku.",
        ),
        QuestionModel(
          question: "Apa itu persajakan dalam puisi Bahasa Indonesia?",
          originalOptions: [
            "Pola bunyi pada akhir baris",
            "Tema puisi",
            "Jumlah kata dalam baris",
            "Nama pengarang"
          ],
          correctAnswer: "Pola bunyi pada akhir baris",
        ),
        QuestionModel(
          question: "Hatiku hancur mendengar kabar itu. apa yang digunakan pada kalimat tersebut?",
          originalOptions: [
            "Personifikasi",
            "Hiperbola",
            "Metafora",
            "Simile"
          ],
          correctAnswer: "Metafora",
        ),
      ],
    };
  }
}

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: QuizListPage(),
    );
  }
}

class QuizListPage extends StatelessWidget {
  const QuizListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quizData = [
      QuizModel(
        title: "Majas dan Persatiran",
        author: "By AbdulGaming69",
        progress: 0.7,
        difficulty: "Normal",
        isCompleted: false,
        description: "Quiz menuju penyair profesional.",
        duration: 25,
        questionCount: 5,
        rating: 4.5,
        imagePath: "assets/gambar/randomquiz.png",
      ),
    ];
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFF4C15A9))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const MainMenu()),
                                (route) => false,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      const Text("My Quiz List", style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: quizData.length,
                    itemBuilder: (context, index) => buildQuizCard(context: context, quiz: quizData[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQuizCard({required BuildContext context, required QuizModel quiz}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => QuizDetailPage(quiz: quiz)));
      },
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    quiz.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.quiz, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quiz.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(quiz.author, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        if (quiz.isCompleted)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: quiz.progress,
                              backgroundColor: Colors.grey[300],
                              valueColor: const AlwaysStoppedAnimation(Color(0xFF7B3FF2)),
                              minHeight: 10,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(quiz.difficulty, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizDetailPage extends StatefulWidget {
  final QuizModel quiz;
  const QuizDetailPage({Key? key, required this.quiz}) : super(key: key);

  @override
  State<QuizDetailPage> createState() => _QuizDetailPageState();
}

class _QuizDetailPageState extends State<QuizDetailPage> {
  final List<String> players = [
    "Abdul", "Rojali", "Yanto", "Anwar", "Amba", "Rizki", "Fajar", "Dedi", "Guntur", "Bima"
  ];
  bool atBottom = false;

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
    String currentUserName = players[0];
    int userStreak = 5;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            pinned: true,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: "Search...",
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Image.asset(
                quiz.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 80),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF4C15A9),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(quiz.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                        const SizedBox(height: 4),
                        Text(quiz.author, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            5,
                                (index) => Icon(
                              index < quiz.rating.floor() ? Icons.star : Icons.star_border,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(color: Colors.grey, fontSize: 15, height: 1.5),
                            children: [
                              TextSpan(text: quiz.description),
                              const TextSpan(
                                text: " Read More",
                                style: TextStyle(color: Color(0xFF4C15A9), fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: buildInfoChip(Icons.timer_outlined, "${quiz.duration} minutes")),
                            const SizedBox(width: 16),
                            Expanded(child: buildInfoChip(Icons.library_books_outlined, "${quiz.questionCount} Questions")),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 260,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEE1F7),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: Text("List Player", style: TextStyle(fontWeight: FontWeight.bold))),
                              Expanded(
                                child: NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    final isAtBottom = scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent &&
                                        scrollInfo.metrics.maxScrollExtent > 0;
                                    if (isAtBottom && !atBottom) {
                                      setState(() => atBottom = true);
                                    } else if (!isAtBottom && atBottom) {
                                      setState(() => atBottom = false);
                                    }
                                    return false;
                                  },
                                  child: ListView.builder(
                                    itemCount: players.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                        title: Text(
                                          "${index + 1}. ${players[index]}",
                                          style: const TextStyle(color: Color(0xFF4C15A9), fontWeight: FontWeight.w600),
                                        ),
                                        trailing: Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF4C15A9),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          child: Text(
                                            "#${index + 1}",
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (atBottom)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizQuestionPage(
                                      quiz: quiz,
                                      userName: currentUserName,
                                      userStreak: userStreak,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C15A9),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("START QUIZ", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF6A35D8), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class QuizQuestionPage extends StatefulWidget {
  final QuizModel quiz;
  final String userName;
  final int userStreak;
  const QuizQuestionPage({
    Key? key,
    required this.quiz,
    required this.userName,
    required this.userStreak,
  }) : super(key: key);

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int selectedOptionIndex = -1;
  int currentQuestion = 1;
  late int totalQuestions;
  late double remainingSeconds;
  final double maxSeconds = 10.0;
  Timer? timer;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  late List<QuestionModel> questions;

  @override
  void initState() {
    super.initState();
    final allQuestions = QuizDataStore.getQuizQuestions();
    if (allQuestions.containsKey(widget.quiz.title)) {
      questions = allQuestions[widget.quiz.title]!;
    } else {
      questions = allQuestions["Majas dan Persatiran"]!;
    }
    totalQuestions = widget.quiz.questionCount;
    if (questions.length > totalQuestions) {
      questions = questions.sublist(0, totalQuestions);
    }
    remainingSeconds = maxSeconds;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.userName} is on x${widget.userStreak} Streak!'),
          backgroundColor: Colors.amber,
          duration: const Duration(seconds: 2),
        ),
      );
      startTimer();
    });
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        remainingSeconds -= 0.1;
        if (remainingSeconds <= 0) {
          remainingSeconds = 0;
          timer.cancel();
          showTimeUpDialog();
        }
      });
    });
  }

  void showTimeUpDialog() {
    timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Times Up!'),
        content: const Text('Your time has run out. The quiz will end now.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              navigateToResults();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void navigateToResults() {
    timer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          quiz: widget.quiz,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          totalQuestions: totalQuestions,
        ),
      ),
    );
  }

  void handleAnswer() {
    if (selectedOptionIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option first!')),
      );
      return;
    }
    final isCorrect = selectedOptionIndex == questions[currentQuestion - 1].correctAnswerIndex;
    setState(() {
      if (isCorrect) {
        correctAnswers++;
        remainingSeconds = min(remainingSeconds + 5.0, maxSeconds);
      } else {
        wrongAnswers++;
        remainingSeconds = max(remainingSeconds - 5.0, 0);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Correct! +5 seconds' : 'Wrong! -5 seconds'),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 700),
      ),
    );

    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      if (currentQuestion < totalQuestions && remainingSeconds > 0) {
        setState(() {
          currentQuestion++;
          selectedOptionIndex = -1;
        });
      } else {
        timer?.cancel();
        navigateToResults();
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = questions.isNotEmpty ? questions[currentQuestion - 1].shuffledOptions : [];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: currentQuestion / totalQuestions,
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation(Color(0xFF4C15A9)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${currentQuestion}/$totalQuestions', style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('${remainingSeconds.toStringAsFixed(1)}s', style: TextStyle(color: remainingSeconds < 3 ? Colors.red : Colors.black)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C15A9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: questions.isEmpty
                    ? const Center(child: Text("No questions loaded"))
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      questions[currentQuestion - 1].question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    ...List.generate(options.length, (idx) {
                      final isSelected = selectedOptionIndex == idx;
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedOptionIndex = idx);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.amber.shade700 : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF4C15A9), width: 2),
                          ),
                          child: Text(
                            options[idx],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      timer?.cancel();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Quit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C15A9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: handleAnswer,
                    child: Text(currentQuestion == totalQuestions ? "Finish" : "Next"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C15A9),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 36),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizResultPage extends StatelessWidget {
  final QuizModel quiz;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;

  const QuizResultPage({
    Key? key,
    required this.quiz,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: Color(0xFF4C15A9),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Quiz Finished!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            Text('Correct Answers: $correctAnswers'),
            Text('Wrong Answers: $wrongAnswers'),
            Text('Total Questions: $totalQuestions'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4C15A9),
                foregroundColor: Colors.white,
              ),
              child: Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
