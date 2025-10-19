import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/UserProviders.dart';

class ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [],
          bottom: const TabBar(
            indicatorColor: Color(0xFF4C15A9),
            labelColor: Color(0xFF4C15A9),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Leaderboard'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ProfileTab(),
            LeaderboardTab(),
          ],
        ),
        backgroundColor: Color(0xFF4C15A9),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userStats = userProvider.currentUser;  // Changed from userStats to currentUser

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 30),
              // Profile image
              CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: userStats.avatarUrl != null
                      ? NetworkImage(userStats.avatarUrl!)
                      : null,
                  child: userStats.avatarUrl == null
                      ? Icon(Icons.person, size: 40, color: Colors.grey[600])
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userStats.username,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Colors.white,
                ),
              ),
              Text(
                userStats.userId,
                style: TextStyle(color: Colors.white70),
              ),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'About Me',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userStats?.aboutMe.isEmpty ?? true
                          ? 'No bio available'
                          : userStats!.aboutMe,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'My Hobbies',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: userStats?.hobbies.isEmpty ?? true
                          ? [_chip('No hobbies added')]
                          : userStats!.hobbies.map((hobby) => _chip(hobby)).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Statistics',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow('Rank', userStats?.rank ?? 'Unranked'),
                    _buildStatRow('UKBI Level', userStats?.ukbiLevel ?? 'N/A'),
                    _buildStatRow('Total Score', userStats?.totalScore.toString() ?? '0'),
                    _buildStatRow('Quizzes Completed', userStats?.quizzesCompleted.toString() ?? '0'),
                    _buildStatRow('Accuracy', userStats?.accuracyFormatted ?? '0%'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) => Chip(
    label: Text(label),
    backgroundColor: const Color(0xFFE0CAFF),
    labelStyle: const TextStyle(color: Color(0xFF4C15A9)),
  );
}

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final leaderboard = userProvider.leaderboard;

        if (leaderboard.isEmpty) {
          return const Center(
            child: Text(
              'No leaderboard data available',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          );
        }

        return Container(
          color: const Color(0xFF4C15A9),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
            itemCount: leaderboard.length,
            itemBuilder: (context, i) {
              final user = leaderboard[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: i == 0
                        ? Colors.amber
                        : i == 1
                        ? Colors.grey[400]
                        : i == 2
                        ? Colors.brown[300]
                        : Colors.deepPurple[100],
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  title: Text(
                    user.username,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('${user.rank} | UKBI: ${user.ukbiLevel}'),
                  trailing: Text(
                    'Accuracy: ${user.accuracyFormatted}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
