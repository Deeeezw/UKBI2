import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'QuizModel.dart';
import 'QuizMod.dart';
import 'QuizList.dart';
import 'providers/UserProviders.dart';

class QuizResultPage extends StatefulWidget {
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
  State<QuizResultPage> createState() => _QuizResultPageState();
}

class _QuizResultPageState extends State<QuizResultPage> {
  bool _isUpdatingStats = false;

  @override
  void initState() {
    super.initState();
    // Update stats when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUserStats();
    });
  }

  Future<void> _updateUserStats() async {
    if (_isUpdatingStats) return;

    setState(() {
      _isUpdatingStats = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final score = widget.finalScore ?? (widget.correctAnswers * 1000);

      // Update stats in Firebase and reload leaderboard
      await userProvider.updateStatsAfterQuiz(
        correctAnswersInQuiz: widget.correctAnswers,
        wrongAnswersInQuiz: widget.wrongAnswers,
        scoreEarned: score,
      );

      print('✅ Stats updated successfully!');
    } catch (e) {
      print('❌ Error updating stats: $e');
    } finally {
      setState(() {
        _isUpdatingStats = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final int accuracy = widget.totalQuestions > 0
        ? ((widget.correctAnswers / widget.totalQuestions) * 100).round()
        : 0;
    final int score = widget.finalScore ?? (widget.correctAnswers * 1000);
    final bool passed = widget.correctAnswers == widget.totalQuestions;

    return Scaffold(
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return Stack(
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
                  _buildOverviewContent(score, accuracy, userProvider),
                ],
              ),
              // Loading indicator while updating stats
              if (_isUpdatingStats)
                Container(
                  color: Colors.black26,
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
            ],
          );
        },
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
                        ? "You've finished ${widget.quiz.title}!"
                        : "You failed ${widget.quiz.title}",
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

  Widget _buildOverviewContent(int score, int accuracy, UserProvider userProvider) {
    final mods = widget.activeMods ?? {};
    final hasActiveMods = mods.isNotEmpty;
    final userStats = userProvider.currentUser;

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
                        backgroundImage: userStats.avatarUrl != null
                            ? NetworkImage(userStats.avatarUrl!)
                            : null,
                        child: userStats.avatarUrl == null
                            ? Icon(Icons.person, size: 40, color: Colors.grey[400])
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userStats.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Rank: ${userStats.rank}',
                            style: const TextStyle(
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
                  _buildResultRow('Correct', widget.correctAnswers.toString()),
                  const SizedBox(height: 12),
                  _buildResultRow('Wrong', widget.wrongAnswers.toString()),
                  const SizedBox(height: 12),
                  _buildResultRow('Accuracy', '$accuracy%'),
                  const SizedBox(height: 12),
                  _buildResultRow('Total Score', userStats.totalScore.toString()),
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
        onPressed: _isUpdatingStats
            ? null
            : () {
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
        child: _isUpdatingStats
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
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
