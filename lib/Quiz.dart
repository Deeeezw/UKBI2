import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'MainMenu.dart';
import 'quizmodel.dart';
import 'quizmod.dart';

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
    final List<QuizModel> quizData = QuizDataStore.getSampleQuizzes();

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/list_quiz.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFF4C15A9));
              },
            ),
          ),
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
                      const Text(
                        'My Quiz List',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: quizData.length,
                    itemBuilder: (context, index) {
                      return _buildQuizCard(context: context, quiz: quizData[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCard({required BuildContext context, required QuizModel quiz}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuizDetailPage(quiz: quiz)),
        );
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
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.quiz, size: 30);
                    },
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
                        Text(quiz.difficulty, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
  Set<String> selectedMods = {};

  void showModsDialog(BuildContext context) {
    final modsList = QuizModsStore.getAllMods();
    
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: modsList.map((mod) => GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedMods.contains(mod.id)
                          ? selectedMods.remove(mod.id)
                          : selectedMods.add(mod.id);
                    });
                  },
                  child: Card(
                    color: selectedMods.contains(mod.id) ? Colors.purpleAccent : Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(mod.icon, size: 34, color: Colors.deepPurple),
                        const SizedBox(height: 10),
                        Text(mod.label,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        const SizedBox(height: 4),
                        Text(mod.description,
                            style: const TextStyle(fontSize: 12, color: Colors.black), textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 18),
              const Text('Tap to toggle MODS', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.deepPurple)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: const Text('Close', style: TextStyle(color: Colors.deepPurple)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quiz = widget.quiz;
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
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search...',
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
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, size: 80),
                  );
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              decoration: const BoxDecoration(
                color: Color(0xFF4C15A9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
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
                            style: TextStyle(color: Colors.grey[800], fontSize: 15, height: 1.5),
                            children: [
                              TextSpan(text: quiz.description),
                              TextSpan(
                                text: ' Read More',
                                style: const TextStyle(color: Color(0xFF4C15A9), fontWeight: FontWeight.bold),
                                recognizer: TapGestureRecognizer()..onTap = () {},
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(child: _buildInfoChip(Icons.timer_outlined, '${quiz.duration} minutes')),
                            const SizedBox(width: 16),
                            Expanded(child: _buildInfoChip(Icons.library_books_outlined, '${quiz.questionCount} Questions')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade50,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("MODS", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => showModsDialog(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: selectedMods.map((modId) {
                      final mod = QuizModsStore.getModById(modId);
                      if (mod == null) return const SizedBox.shrink();
                      return Chip(
                        avatar: Icon(mod.icon, size: 18),
                        label: Text(mod.label, style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.deepPurple,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizQuestionPage(
                              quiz: widget.quiz,
                              selectedMods: selectedMods,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4C15A9),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'START QUIZ',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
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

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6A35D8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class QuizQuestionPage extends StatefulWidget {
  final QuizModel quiz;
  final Set<String>? selectedMods;
  const QuizQuestionPage({Key? key, required this.quiz, this.selectedMods}) : super(key: key);

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> {
  int _selectedOptionIndex = -1;
  int currentQuestion = 1;
  late int totalQuestions;
  late double remainingSeconds;
  final double maxSeconds = 10.0;
  final double initialSeconds = 5.0;
  Timer? _timer;
  int correctAnswers = 0;
  int wrongAnswers = 0;
  late List<QuestionModel> questions;
  bool extraLifeUsed = false;

  @override
  void initState() {
    super.initState();
    totalQuestions = widget.quiz.questionCount;
    
    final activeMods = widget.selectedMods ?? {};
    
    // Set initial time based on mods
    remainingSeconds = QuizModsStore.isTimerDisabled(activeMods) 
        ? double.infinity 
        : initialSeconds;

    // Load questions using quiz ID
    questions = QuizDataStore.getQuestionsForQuiz(widget.quiz.id);

    if (questions.length > totalQuestions) {
      questions = questions.sublist(0, totalQuestions);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    
    final activeMods = widget.selectedMods ?? {};
    
    // Don't start timer if no_time mod is active
    if (QuizModsStore.isTimerDisabled(activeMods)) {
      return;
    }
    
    // Get timer decrement based on mods
    final timerDecrement = QuizModsStore.getTimerDecrement(activeMods);
    
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && remainingSeconds > 0) {
        setState(() {
          remainingSeconds -= timerDecrement;
          if (remainingSeconds < 0) remainingSeconds = 0;
        });
      } else if (remainingSeconds <= 0) {
        timer.cancel();
        if (mounted) {
          _showTimeUpDialog();
        }
      }
    });
  }

  void _showTimeUpDialog() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!'),
        content: const Text('Your time has run out. The quiz will end now.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToResults();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToResults() {
    _timer?.cancel();
    
    final activeMods = widget.selectedMods ?? {};
    
    // Calculate score with mod multiplier
    final score = QuizModsStore.calculateScore(
      correctAnswers: correctAnswers,
      activeMods: activeMods,
    );
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultPage(
          quiz: widget.quiz,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          totalQuestions: totalQuestions,
          finalScore: score,
          activeMods: activeMods,
        ),
      ),
    );
  }

  void _handleAnswer() {
    if (_selectedOptionIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option first!')),
      );
      return;
    }

    final activeMods = widget.selectedMods ?? {};
    final isCorrect = _selectedOptionIndex == questions[currentQuestion - 1].correctAnswerIndex;
    
    // Use mod logic to handle answer
    final result = QuizModsStore.handleAnswerWithMods(
      isCorrect: isCorrect,
      activeMods: activeMods,
      currentTime: remainingSeconds,
      maxTime: maxSeconds,
      extraLifeUsed: extraLifeUsed,
    );

    setState(() {
      if (isCorrect) {
        correctAnswers++;
      } else {
        wrongAnswers++;
      }
      
      // Handle extra life
      if (result['useExtraLife'] == true) {
        extraLifeUsed = true;
      }
      
      // Update time
      if (!QuizModsStore.isTimerDisabled(activeMods)) {
        remainingSeconds = QuizModsStore.calculateNewTime(
          currentTime: remainingSeconds,
          timeChange: result['timeChange'],
          maxTime: maxSeconds,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
        duration: const Duration(milliseconds: 800),
      ),
    );

    // Check if quiz should end
    if (result['endQuiz'] == true) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        _timer?.cancel();
        _navigateToResults();
      });
      return;
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (currentQuestion < totalQuestions && (remainingSeconds > 0 || QuizModsStore.isTimerDisabled(activeMods))) {
        setState(() {
          currentQuestion++;
          _selectedOptionIndex = -1;
        });
      } else {
        _timer?.cancel();
        _navigateToResults();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeMods = widget.selectedMods ?? {};
    final isTimerDisabled = QuizModsStore.isTimerDisabled(activeMods);
    
    return WillPopScope(
      onWillPop: () async {
        _timer?.cancel();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background_quiz.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 10),
                      _buildTimerProgress(isTimerDisabled),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    _buildQuestionCard(),
                    const SizedBox(height: 30),
                    _buildOptionsList(),
                    const SizedBox(height: 20),
                    _buildBottomButtons(context),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              _timer?.cancel();
              Navigator.of(context).pop();
            },
          ),
        ),
        const Text(
          "Let's Keep It Up!",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildTimerProgress(bool isTimerDisabled) {
    if (isTimerDisabled) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$currentQuestion/$totalQuestions',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'NO TIMER',
                style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }
    
    final double progress = remainingSeconds / maxSeconds;
    final bool isLowTime = remainingSeconds <= 3;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$currentQuestion/$totalQuestions',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation(
              isLowTime ? Colors.red : Colors.blueAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(35),
      decoration: BoxDecoration(
        color: const Color(0xFF4C15A9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        questions[currentQuestion - 1].question,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOptionsList() {
    final options = questions[currentQuestion - 1].shuffledOptions;
    return Column(
      children: List.generate(options.length, (index) {
        final isSelected = _selectedOptionIndex == index;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedOptionIndex = index;
            });
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.deepPurple.shade700
                  : const Color(0xFF4C15A9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              options[index],
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _timer?.cancel();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C15A9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: const Text(
              'Quit',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: ElevatedButton(
            onPressed: _handleAnswer,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C15A9),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(vertical: 18),
            ),
            child: Text(
              currentQuestion < totalQuestions ? 'Next' : 'Finish',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class QuizResultPage extends StatelessWidget {
  final QuizModel quiz;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final int? finalScore;
  final Set<String>? activeMods;

  const QuizResultPage({
    Key? key,
    required this.quiz,
    this.correctAnswers = 0,
    this.wrongAnswers = 0,
    this.totalQuestions = 0,
    this.finalScore,
    this.activeMods,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int accuracy = totalQuestions > 0
        ? ((correctAnswers / totalQuestions) * 100).round()
        : 0;
    final int score = finalScore ?? (correctAnswers * 1000);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_finishquiz.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.grey[100]);
              },
            ),
          ),
          Column(
            children: [
              _buildHeader(context),
              _buildOverviewContent(score, accuracy),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildFinishButton(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: const BoxDecoration(
        color: Color(0xFF4C15A9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You've finished ${quiz.title}!",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
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

  Widget _buildOverviewContent(int score, int accuracy) {
    final mods = activeMods ?? {};
    final hasActiveMods = mods.isNotEmpty;
    
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Overview',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4C15A9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 40, color: Colors.grey[400]),
                      ),
                      const SizedBox(width: 16),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Player',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'player_username',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildResultRow('Score', score.toString()),
                  const SizedBox(height: 12),
                  _buildResultRow('Correct', correctAnswers.toString()),
                  const SizedBox(height: 12),
                  _buildResultRow('Wrong', wrongAnswers.toString()),
                  const SizedBox(height: 12),
                  _buildResultRow('Accuracy', '$accuracy%'),
                  if (hasActiveMods) ...[
                    const SizedBox(height: 12),
                    _buildModsUsed(mods),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF6A35D8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModsUsed(Set<String> mods) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6A35D8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mods Used',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: mods.map((modId) {
              final mod = QuizModsStore.getModById(modId);
              if (mod == null) return const SizedBox.shrink();
              return Chip(
                avatar: Icon(mod.icon, size: 16, color: Colors.white),
                label: Text(
                  mod.label,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinishButton(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const QuizListPage()),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4C15A9),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'FINISH!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
