import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/UserProviders.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Profile'),
          backgroundColor: Colors.white,
          elevation: 0,
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
        backgroundColor: const Color(0xFF4C15A9),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userStats = userProvider.currentUser;

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 30),

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

             
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userStats.username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => _showEditDialog(
                        context,
                        'Edit Username',
                        userStats.username,
                            (value) {
                          userProvider.updateUserData({'username': value});
                        },
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

             
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      userStats.displayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () => _showEditDialog(
                        context,
                        'Edit Display Name',
                        userStats.displayName,
                            (value) {
                          userProvider.updateUserData({'displayName': value});
                        },
                      ),
                      child: const Icon(Icons.edit, color: Colors.white70, size: 16),
                    ),
                  ],
                ),
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
                   
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'About Me',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          color: const Color(0xFF4C15A9),
                          onPressed: () => _showEditDialog(
                            context,
                            'Edit About Me',
                            userStats.aboutMe,
                                (value) {
                              userProvider.updateUserData({'aboutMe': value});
                            },
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userStats.aboutMe.isEmpty
                          ? 'No bio available'
                          : userStats.aboutMe,
                      style: TextStyle(
                        color: userStats.aboutMe.isEmpty
                            ? Colors.grey
                            : Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                  
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Hobbies',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          color: const Color(0xFF4C15A9),
                          onPressed: () => _showEditHobbiesDialog(context, userProvider),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: userStats.hobbies.isEmpty
                          ? [_chip('No hobbies added')]
                          : userStats.hobbies.map((hobby) => _chip(hobby)).toList(),
                    ),

                    const SizedBox(height: 16),

                   
                    const Text(
                      'Statistics',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow('Rank', userStats.rank),
                    _buildStatRow('UKBI Level', userStats.ukbiLevel),
                    _buildStatRow('Total Score', userStats.totalScore.toString()),
                    _buildStatRow('Quizzes Completed', userStats.quizzesCompleted.toString()),
                    _buildStatRow('Accuracy', userStats.accuracyFormatted),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  
  static void _showEditDialog(
      BuildContext context,
      String title,
      String currentValue,
      Function(String) onSave, {
        int maxLines = 1,
      }) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Enter new value',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C15A9),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                onSave(controller.text.trim());
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile updated successfully!')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  
  static void _showEditHobbiesDialog(BuildContext context, UserProvider userProvider) {
    final currentHobbies = List<String>.from(userProvider.currentUser.hobbies);
    final hobbyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Hobbies'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: hobbyController,
                        decoration: const InputDecoration(
                          hintText: 'Add hobby',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Color(0xFF4C15A9)),
                      onPressed: () {
                        if (hobbyController.text.trim().isNotEmpty) {
                          setState(() {
                            currentHobbies.add(hobbyController.text.trim());
                            hobbyController.clear();
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                
                if (currentHobbies.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: currentHobbies.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(currentHobbies[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                currentHobbies.removeAt(index);
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C15A9),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                userProvider.updateUserData({'hobbies': currentHobbies});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hobbies updated successfully!')),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
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


class LeaderboardTab extends StatefulWidget {
  const LeaderboardTab({super.key});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadLeaderboard();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final leaderboard = userProvider.leaderboard;

        
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }

        
        if (leaderboard.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.leaderboard_outlined,
                  color: Colors.white54,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No leaderboard data available',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF4C15A9),
                  ),
                  onPressed: _loadData,
                  child: const Text('Reload'),
                ),
              ],
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
