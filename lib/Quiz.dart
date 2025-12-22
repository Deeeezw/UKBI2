import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'QuizModel.dart';
import 'QuizMod.dart';
import 'ResultScreen.dart';
import 'providers/QuizProviders.dart';
import 'providers/UserProviders.dart';

class QuizQuestionPage extends StatefulWidget {
  final QuizModel quiz;
  final Set<String>? selectedMods;

  const QuizQuestionPage({Key? key, required this.quiz, this.selectedMods}) : super(key: key);

  @override
  State<QuizQuestionPage> createState() => _QuizQuestionPageState();
}

class _QuizQuestionPageState extends State<QuizQuestionPage> with SingleTickerProviderStateMixin {
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

  bool extraLifeUsed = false;

  // Animation states
  bool _showAnswer = false;
  bool _isAnswerCorrect = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    totalQuestions = widget.quiz.questionCount;
    final activeMods = widget.selectedMods ?? {};

    // Set initial time based on mods
    remainingSeconds = QuizModsStore.isTimerDisabled(activeMods)
        ? double.infinity
        : initialSeconds;

    // ✅ Load questions from Firebase
    _loadQuestionsFromFirebase();

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
      print('🔥 Loading questions for quiz: ${widget.quiz.id}');

      final loadedQuestions = await quizProvider.getQuestionsForQuiz(widget.quiz.id);

      if (loadedQuestions.isEmpty) {
        print('⚠️ No questions found in Firebase, using local fallback');
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

      print('✅ Loaded ${loadedQuestions.length} questions from Firebase');

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
      print('❌ Error loading questions: $e');
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

    // Update user stats via provider
    final quizProvider = Provider.of<QuizProvider>(context, listen: false);

    // Update quiz progress
    quizProvider.updateQuizProgress(
      widget.quiz.id,
      currentQuestion / totalQuestions,
    );

    // Mark quiz as completed if passed
    if (correctAnswers == totalQuestions) {
      quizProvider.markQuizCompleted(widget.quiz.id);
    }

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

  void _handleAnswer() async {
    if (_selectedOptionIndex == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option first!')),
      );
      return;
    }

    // Pause timer during answer reveal
    _timer?.cancel();
    final activeMods = widget.selectedMods ?? {};
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

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Check if quiz should end
    if (result['endQuiz'] == true) {
      _navigateToResults();
      return;
    }

    // Move to next question or end quiz
    if (currentQuestion < totalQuestions &&
        (remainingSeconds > 0 || QuizModsStore.isTimerDisabled(activeMods))) {
      setState(() {
        currentQuestion++;
        _selectedOptionIndex = -1;
        _showAnswer = false;
        _isAnswerCorrect = false;
      });

      // Resume timer for next question
      if (!QuizModsStore.isTimerDisabled(activeMods)) {
        _startTimer();
      }
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
    final activeMods = widget.selectedMods ?? {};
    final isTimerDisabled = QuizModsStore.isTimerDisabled(activeMods);

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
                'Loading questions from Firebase...',
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
