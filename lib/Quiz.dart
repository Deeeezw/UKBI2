import 'dart:async';
import 'package:flutter/material.dart';
import 'QuizModel.dart';
import 'QuizMod.dart';
import 'ResultScreen.dart';

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
