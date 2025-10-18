import 'package:flutter/material.dart';
import 'Quiz.dart';
import 'QuizModel.dart';
import 'QuizMod.dart';

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
    final bool passed = correctAnswers == totalQuestions; // User must answer all correctly to pass

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
              _buildHeader(context, passed),
              _buildOverviewContent(score, accuracy),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildFinishButton(context),
    );
  }

  Widget _buildHeader(BuildContext context, bool passed) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: passed ? const Color(0xFF4C15A9) : Colors.red.shade700,
        borderRadius: const BorderRadius.only(
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
                  Text(
                    passed ? 'Congratulations!' : 'Quiz Over!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    passed 
                        ? "You've finished ${quiz.title}!"
                        : "You failed ${quiz.title}",
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
