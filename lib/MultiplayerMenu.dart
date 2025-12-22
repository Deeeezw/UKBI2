import 'package:flutter/material.dart';
import 'QuizModel.dart';
import 'QuizMultiLobby.dart';
import 'services/firebase_multiplayer_service.dart';
import 'services/firebase_quiz_service.dart';
import 'package:provider/provider.dart';
import 'providers/UserProviders.dart';

class MultiplayerMenu extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;

  const MultiplayerMenu({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
  });

  @override
  State<MultiplayerMenu> createState() => _MultiplayerMenuState();
}

class _MultiplayerMenuState extends State<MultiplayerMenu> {
  final FirebaseMultiplayerService _multiplayerService = FirebaseMultiplayerService();
  final FirebaseQuizService _quizService = FirebaseQuizService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background_listquiz.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildUserInfoCard(),
                  const SizedBox(height: 20),
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildQuizListSection(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUserOrNull;
        final name = user?.username ?? widget.currentUserName;

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 24, 8),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: Colors.black, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text(
                'Welcome, $name',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildUserInfoCard() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUserOrNull;

        final name = user?.username ?? widget.currentUserName;
        final rank = user?.rank ?? 'Unranked';
        final ukbi = user?.ukbiLevel ?? 'Pemula';
        final accuracy =
        user != null ? '${user.accuracy.toStringAsFixed(2)}%' : '0.00%';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Performance',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoItem(label: 'Rank', value: rank),
                  _InfoItem(label: 'UKBI', value: ukbi),
                  _InfoItem(label: 'Accuracy', value: accuracy),
                ],
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Quiz Match Here',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildQuizListSection(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Rooms',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4C15A9),
                ),
              ),
              TextButton(
                onPressed: () => _showCreateRoomDialog(context),
                child: const Text(
                  'Create Room',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4C15A9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 280,
          child: StreamBuilder<List<MultiplayerRoom>>(
            stream: _multiplayerService.getAvailableRooms(),
            builder: (context, roomSnapshot) {
              if (roomSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!roomSnapshot.hasData || roomSnapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No rooms available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => _showCreateRoomDialog(context),
                        child: const Text('Create a new room'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 24, right: 12),
                itemCount: roomSnapshot.data!.length,
                itemBuilder: (context, index) {
                  final room = roomSnapshot.data![index];
                  return FutureBuilder<QuizModel?>(
                    future: _quizService.getQuizById(room.quizId),
                    builder: (context, quizSnapshot) {
                      if (!quizSnapshot.hasData) {
                        return const SizedBox(width: 220, child: Center(child: CircularProgressIndicator()));
                      }

                      final quiz = quizSnapshot.data!;
                      return _buildRoomCard(
                        context: context,
                        room: room,
                        quiz: quiz,
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoomCard({
    required BuildContext context,
    required MultiplayerRoom room,
    required QuizModel quiz,
  }) {
    return GestureDetector(
      onTap: () => _joinRoom(context, room, quiz),
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    quiz.imagePath,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Icon(Icons.quiz, size: 50),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  quiz.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Host: ${room.hostName}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C15A9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        quiz.difficulty,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    Text(
                      '${room.currentPlayers} / ${room.maxPlayers}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _joinRoom(BuildContext context, MultiplayerRoom room, QuizModel quiz) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await _multiplayerService.joinRoom(
      roomId: room.id,
      playerId: widget.currentUserId,
      playerName: widget.currentUserName,
    );

    Navigator.pop(context); // Close loading

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizMultiLobby(
            quiz: quiz,
            roomId: room.id,
            currentUserId: widget.currentUserId,
            currentUserName: widget.currentUserName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join room')),
      );
    }
  }

  Future _showCreateRoomDialog(BuildContext context) async {
    // Get list of quizzes
    final quizzes = await _quizService.getQuizzes().first;
    if (quizzes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No quizzes available')),
      );
      return;
    }

    QuizModel? selectedQuiz = quizzes.first;
    int maxPlayers = 10;

    // Save parent context from the state
    final parentContext = this.context;

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Room'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<QuizModel>(
                  value: selectedQuiz,
                  decoration: const InputDecoration(labelText: 'Select Quiz'),
                  items: quizzes.map((quiz) {
                    return DropdownMenuItem(
                      value: quiz,
                      child: Text(quiz.title),
                    );
                  }).toList(),
                  onChanged: (quiz) {
                    setState(() => selectedQuiz = quiz);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Max players:'),
                    const SizedBox(width: 12),
                    DropdownButton<int>(
                      value: maxPlayers,
                      items: const [2, 4, 6, 8, 10].map((v) {
                        return DropdownMenuItem(
                          value: v,
                          child: Text(v.toString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => maxPlayers = value);
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedQuiz == null) return;

              // Close the settings dialog
              Navigator.of(dialogContext).pop();

              // Show loading using parentContext
              showDialog(
                context: parentContext,
                barrierDismissible: false,
                builder: (_) =>
                const Center(child: CircularProgressIndicator()),
              );

              final roomId = await _multiplayerService.createRoom(
                quizId: selectedQuiz!.id,
                hostId: widget.currentUserId,
                hostName: widget.currentUserName,
                maxPlayers: maxPlayers,
              );

              // Close loading dialog
              if (Navigator.of(parentContext).canPop()) {
                Navigator.of(parentContext).pop();
              }

              if (!mounted) return;

              if (roomId != null) {
                Navigator.push(
                  parentContext,
                  MaterialPageRoute(
                    builder: (_) => QuizMultiLobby(
                      quiz: selectedQuiz!,
                      roomId: roomId,
                      currentUserId: widget.currentUserId,
                      currentUserName: widget.currentUserName,
                      isHost: true,
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(parentContext).showSnackBar(
                  const SnackBar(content: Text('Failed to create room')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
