import 'package:flutter/material.dart';

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
          actions: [
          ],
          bottom: const TabBar(
            indicatorColor: Color(0xFF4C15A9),
            labelColor: Color(0xFF4C15A9),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Leaderboard')
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
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 30),
          // Profile image (placeholder)
          CircleAvatar(
            radius: 46,
            backgroundColor: Colors.white,
            child: CircleAvatar(radius: 42, backgroundColor: Colors.grey.shade300),
          ),
          const SizedBox(height: 8),
          const Text("Wowo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
          const Text("Wowo#1985", style: TextStyle(color: Colors.white70)),
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('About Me', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                const Text('Lorem ipsum dolor sit amet consectetur. Nec eget accumsan molestie proin. Integer rhoncus vitae nisi natoque ac mus tellus scelerisque gravida.'),
                const SizedBox(height: 16),
                const Text('My Hobbies', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _chip('UI/UX'),
                    _chip('Graphics Design'),
                    _chip('Sports'),
                    _chip('Video Editor')
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
  Widget _chip(String label) => Chip(label: Text(label), backgroundColor: const Color(0xFFE0CAFF), labelStyle: const TextStyle(color: Color(0xFF4C15A9)));
}

class LeaderboardTab extends StatelessWidget {
  const LeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboard = [
      {"username": "Abdul", "rank": "#1", "ukbi": "Istimewa", "accuracy": "98.02%"},
      {"username": "Wiwi", "rank": "#2", "ukbi": "Istimewa", "accuracy": "97.00%"},
      {"username": "Anto", "rank": "#3", "ukbi": "Sangat Unggul", "accuracy": "95.25%"},
      {"username": "Kuda Lumping", "rank": "#4", "ukbi": "Unggul", "accuracy": "95.25%"},
    ];
    return Container(
      color: const Color(0xFF4C15A9),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
        itemCount: leaderboard.length,
        itemBuilder: (context, i) {
          final user = leaderboard[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ListTile(
              title: Text(
                user["username"] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('${user["rank"] ?? ''}   UKBI: ${user["ukbi"] ?? ''}'),
              trailing: Text(
                'Accuracy: ${user["accuracy"] ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.deepPurple),
              ),
            ),
          );
        },
      ),
    );
  }
}
