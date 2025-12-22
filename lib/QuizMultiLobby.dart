import 'package:flutter/material.dart';
import 'QuizModel.dart';
import 'QuizMulti.dart';
import 'QuizMod.dart';
import 'services/firebase_multiplayer_service.dart';

class QuizMultiLobby extends StatefulWidget {
  final QuizModel quiz;
  final String roomId;
  final String currentUserId;
  final String currentUserName;
  final bool isHost;

  const QuizMultiLobby({
    Key? key,
    required this.quiz,
    required this.roomId,
    required this.currentUserId,
    required this.currentUserName,
    this.isHost = false,
  }) : super(key: key);

  @override
  State<QuizMultiLobby> createState() => _QuizMultiLobbyState();
}

class _QuizMultiLobbyState extends State<QuizMultiLobby> {
  final FirebaseMultiplayerService _multiplayerService = FirebaseMultiplayerService();
  bool canStartQuiz = false;
  Set<String> selectedMods = {}; // Personal mods for each player

  @override
  void dispose() {
    // Leave room when exiting
    if (!canStartQuiz) {
      _multiplayerService.leaveRoom(
        roomId: widget.roomId,
        playerId: widget.currentUserId,
      );
    }
    super.dispose();
  }

  void _showModsDialog(BuildContext context) {
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
                children: modsList.map((mod) {
                  final isSelected = selectedMods.contains(mod.id);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedMods.remove(mod.id);
                        } else {
                          selectedMods.add(mod.id);
                        }
                      });
                    },
                    child: Card(
                      color: isSelected ? Colors.purpleAccent : Colors.white,
                      elevation: isSelected ? 8 : 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              mod.icon,
                              size: 34,
                              color: isSelected ? Colors.white : Colors.deepPurple,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mod.label,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isSelected ? Colors.white : Colors.deepPurple,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              mod.description,
                              style: TextStyle(
                                fontSize: 10,
                                color: isSelected ? Colors.white70 : Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              const Text(
                'Choose your personal mods',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: const Text(
                    'Done',
                    style: TextStyle(color: Colors.deepPurple),
                  ),
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
    return WillPopScope(
      onWillPop: () async {
        await _multiplayerService.leaveRoom(
          roomId: widget.roomId,
          playerId: widget.currentUserId,
        );
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<MultiplayerRoom?>(
          stream: _multiplayerService.getRoomStream(widget.roomId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final room = snapshot.data!;

            // Check if game started
            if (room.status == 'playing' && !canStartQuiz) {
              canStartQuiz = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuizMulti(
                      quiz: quiz,
                      userName: widget.currentUserName,
                      players: room.playerNames,
                      roomId: widget.roomId,
                      selectedMods: selectedMods, // Pass personal mods
                    ),
                  ),
                );
              });
            }

            return CustomScrollView(
              slivers: [
                // AppBar
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
                        onPressed: () async {
                          await _multiplayerService.leaveRoom(
                            roomId: widget.roomId,
                            playerId: widget.currentUserId,
                          );
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),

                // Image section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        quiz.imagePath,
                        fit: BoxFit.cover,
                        height: 200,
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
                ),

                // Bottom purple section
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
                        // White card with quiz info
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quiz.title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                quiz.author,
                                style: const TextStyle(color: Colors.grey, fontSize: 14),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  5,
                                      (index) => Icon(
                                    index < quiz.rating.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                quiz.description,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoChip(
                                      Icons.timer_outlined,
                                      '${quiz.duration} seconds',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildInfoChip(
                                      Icons.library_books_outlined,
                                      '${quiz.questionCount} Questions',
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Players lobby
                              Container(
                                height: 280,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEE1F7),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Players in Lobby',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${room.currentPlayers}/${room.maxPlayers}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF4C15A9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        itemCount: room.playerNames.length,
                                        itemBuilder: (context, index) {
                                          final playerName = room.playerNames[index];
                                          final isCurrentUser =
                                              room.playerIds[index] == widget.currentUserId;
                                          final isRoomHost =
                                              room.playerIds[index] == room.hostId;

                                          return ListTile(
                                            contentPadding:
                                            const EdgeInsets.symmetric(horizontal: 12),
                                            leading: CircleAvatar(
                                              backgroundColor: const Color(0xFF4C15A9),
                                              child: Text(
                                                '${index + 1}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Row(
                                              children: [
                                                Text(
                                                  playerName,
                                                  style: const TextStyle(
                                                    color: Color(0xFF4C15A9),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (isRoomHost) ...[
                                                  const SizedBox(width: 8),
                                                  const Icon(
                                                    Icons.star,
                                                    size: 16,
                                                    color: Colors.amber,
                                                  ),
                                                ],
                                              ],
                                            ),
                                            trailing: isCurrentUser
                                                ? Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'You',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            )
                                                : null,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Personal MODS button - Everyone can select
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade50,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _showModsDialog(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.tune, color: Colors.deepPurple),
                                SizedBox(width: 8),
                                Text(
                                  'MY MODS',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Show selected mods
                        if (selectedMods.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Active Mods:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedMods.map((modId) {
                                    final mod = QuizModsStore.getModById(modId);
                                    if (mod == null) return const SizedBox.shrink();
                                    return Chip(
                                      avatar: Icon(
                                        mod.icon,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      label: Text(
                                        mod.label,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                        ),
                                      ),
                                      backgroundColor: Colors.deepPurple,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'No mods selected - playing standard mode',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 24),

                        // START QUIZ button (host only)
                        if (widget.isHost)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: room.currentPlayers >= 2
                                  ? () async {
                                setState(() {
                                  canStartQuiz = true;
                                });
                                await _multiplayerService.startGame(widget.roomId);
                              }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4C15A9),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                room.currentPlayers >= 2
                                    ? 'START QUIZ'
                                    : 'Waiting for players...',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        else
                          const Center(
                            child: Text(
                              'Waiting for host to start...',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
