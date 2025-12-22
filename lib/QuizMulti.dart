import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'QuizModel.dart';
import 'providers/QuizProviders.dart';

class PlayerScore {
  final String name;
  int score;
  int correctAnswers;

  PlayerScore({
    required this.name,
    this.score = 0,
    this.correctAnswers = 0,
  });
}

class QuizMulti extends StatefulWidget {
  final QuizModel quiz;
  final String userName;
  final List<String> players;
  final String? roomId;
  final Set<String>? selectedMods;

  const QuizMulti({
    Key? key,
    required this.quiz,
    required this.userName,
    required this.players,
    this.roomId,
    this.selectedMods,
  }) : super(key: key);

  @override
  State<QuizMulti> createState() => _QuizMultiState();
}

class _QuizMultiState extends State<QuizMulti> with SingleTickerProviderStateMixin {
  int _selectedOptionIndex = -1;
  int currentQuestion = 1;
  late int totalQuestions;
  late double remainingSeconds;
  final double maxSeconds = 30.0;
  final double initialSeconds = 25.0;
  Timer? _timer;
  int correctAnswers = 0;
  int wrongAnswers = 0;

  // ✅ Changed to nullable and added loading state
  List<QuestionModel>? questions;
  bool _isLoadingQuestions = true;

  late List<PlayerScore> playerScores;

  // Animation states
  bool _showAnswer = false;
  bool _isAnswerCorrect = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    totalQuestions = widget.quiz.questionCount;
    remainingSeconds = initialSeconds;

    // ✅ Load questions from Firebase
    _loadQuestionsFromFirebase();

    _initializePlayerScores();

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  // ✅ NEW: Load questions from Firebase
  Future<void> _loadQuestionsFromFirebase() async {
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    try {
      print('🔥 [MULTIPLAYER] Loading questions for quiz: ${widget.quiz.id}');

      final loadedQuestions = await quizProvider.getQuestionsForQuiz(widget.quiz.id);

      if (loadedQuestions.isEmpty) {
        print('⚠️ [MULTIPLAYER] No questions found in Firebase, using local fallback');
        setState(() {
          questions = QuizDataStore.getQuestionsForQuiz(widget.quiz.id);
          if (questions!.length > totalQuestions) {
            questions = questions!.sublist(0, totalQuestions);
          }
          _isLoadingQuestions = false;
        });
        _startTimer();
        return;
      }

      print('✅ [MULTIPLAYER] Loaded ${loadedQuestions.length} questions from Firebase');

      setState(() {
        questions = loadedQuestions;
        if (questions!.length > totalQuestions) {
          questions = questions!.sublist(0, totalQuestions);
        }
        _isLoadingQuestions = false;
      });

      // Start timer after questions are loaded
      _startTimer();
    } catch (e) {
      print('❌ [MULTIPLAYER] Error loading questions: $e');
      // Fallback to local data
      setState(() {
        questions = QuizDataStore.getQuestionsForQuiz(widget.quiz.id);
        if (questions!.length > totalQuestions) {
          questions = questions!.sublist(0, totalQuestions);
        }
        _isLoadingQuestions = false;
      });
      _startTimer();
    }
  }

  void _initializePlayerScores() {
    playerScores = widget.players.map((name) {
      return PlayerScore(name: name);
    }).toList();
  }

  void _simulateOtherPlayersAnswers() {
    final random = Random();
    for (int i = 1; i < playerScores.length; i++) {
      final isCorrect = random.nextBool();
      if (isCorrect) {
        playerScores[i].correctAnswers++;
        playerScores[i].score += random.nextInt(50) + 50;
      }
    }
    playerScores.sort((a, b) => b.score.compareTo(a.score));
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && remainingSeconds > 0) {
        setState(() {
          remainingSeconds -= 0.1;
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizMultiResult(
          quiz: widget.quiz,
          correctAnswers: correctAnswers,
          wrongAnswers: wrongAnswers,
          totalQuestions: totalQuestions,
          playerScores: playerScores,
          userName: widget.userName,
        ),
      ),
    );
  }

  void _handleAnswer() async {
    if (_selectedOptionIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option first!')),
      );
      return;
    }

    // Pause timer during answer reveal
    _timer?.cancel();
    final isCorrect = _selectedOptionIndex == questions![currentQuestion - 1].correctAnswerIndex;

    // Show answer animation
    setState(() {
      _showAnswer = true;
      _isAnswerCorrect = isCorrect;
    });

    // Play scale animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    setState(() {
      if (isCorrect) {
        correctAnswers++;
        remainingSeconds = min(remainingSeconds + 3.0, maxSeconds);
        playerScores[0].correctAnswers++;
        playerScores[0].score += 100;
      } else {
        wrongAnswers++;
        remainingSeconds = max(remainingSeconds - 2.0, 0);
      }

      _simulateOtherPlayersAnswers();
    });

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    if (currentQuestion < totalQuestions && remainingSeconds > 0) {
      setState(() {
        currentQuestion++;
        _selectedOptionIndex = -1;
        _showAnswer = false;
        _isAnswerCorrect = false;
      });

      // Resume timer for next question
      _startTimer();
    } else {
      _navigateToResults();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Show loading screen while questions are being fetched
    if (_isLoadingQuestions || questions == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                color: Color(0xFF4C15A9),
              ),
              SizedBox(height: 20),
              Text(
                'Loading multiplayer questions...',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4C15A9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

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
                      _buildTimerProgress(),
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
          "Multiplayer Quiz",
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

  Widget _buildTimerProgress() {
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
        questions![currentQuestion - 1].question,
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
    final options = questions![currentQuestion - 1].shuffledOptions;

    return Column(
      children: List.generate(options.length, (index) {
        final isSelected = _selectedOptionIndex == index;
        final showFeedback = _showAnswer && isSelected;

        // Determine color based on answer state
        Color backgroundColor;
        Color borderColor = Colors.transparent;

        if (showFeedback) {
          backgroundColor = _isAnswerCorrect
              ? Colors.green.shade600
              : Colors.red.shade600;
          borderColor = _isAnswerCorrect
              ? Colors.green.shade300
              : Colors.red.shade300;
        } else if (isSelected) {
          backgroundColor = Colors.deepPurple.shade700;
        } else {
          backgroundColor = const Color(0xFF4C15A9);
        }

        return AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: showFeedback ? _scaleAnimation.value : 1.0,
              child: GestureDetector(
                onTap: _showAnswer ? null : () {
                  setState(() {
                    _selectedOptionIndex = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: borderColor,
                      width: showFeedback ? 3 : 0,
                    ),
                    boxShadow: showFeedback ? [
                      BoxShadow(
                        color: backgroundColor.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ] : [],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (showFeedback)
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Icon(
                            _isAnswerCorrect ? Icons.check_circle : Icons.cancel,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      Flexible(
                        child: Text(
                          options[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: showFeedback ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
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
            onPressed: _showAnswer ? null : () {
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
            onPressed: _showAnswer ? null : _handleAnswer,
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

// Keep your existing QuizMultiResult class unchanged below this line
class QuizMultiResult extends StatelessWidget {
  final QuizModel quiz;
  final int correctAnswers;
  final int wrongAnswers;
  final int totalQuestions;
  final List<PlayerScore> playerScores;
  final String userName;

  const QuizMultiResult({
    Key? key,
    required this.quiz,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.totalQuestions,
    required this.playerScores,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRank = playerScores.indexWhere((p) => p.name == userName) + 1;
    final userScore = playerScores.firstWhere((p) => p.name == userName).score;

    return Scaffold(
      backgroundColor: const Color(0xFF4C15A9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                'Quiz Finished!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Rank: #$userRank',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4C15A9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Score: $userScore',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          Icons.check_circle,
                          'Correct',
                          '$correctAnswers',
                          Colors.green,
                        ),
                        _buildStatItem(
                          Icons.cancel,
                          'Wrong',
                          '$wrongAnswers',
                          Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'Final Leaderboard',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: playerScores.length,
                          itemBuilder: (context, index) {
                            final player = playerScores[index];
                            final isCurrentUser = player.name == userName;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.amber.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCurrentUser
                                      ? Colors.amber
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: index < 3
                                          ? (index == 0
                                          ? Colors.amber
                                          : index == 1
                                          ? Colors.grey.shade400
                                          : Colors.brown.shade300)
                                          : const Color(0xFF4C15A9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        "${index + 1}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          'Correct: ${player.correctAnswers}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${player.score}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4C15A9),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4C15A9),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 40),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
