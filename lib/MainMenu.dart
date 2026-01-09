import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'WelcomePage.dart';
import 'ProfileMenu.dart';
import 'MultiplayerMenu.dart';
import 'QuizList.dart';
import 'providers/UserProviders.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/mainmenu2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 15,
          ),
          child: Stack(
            children: [
              
              Positioned(
                top: screenHeight * 0.120,
                left: screenWidth * 0.10,
                child: _buildProfilePicture(context),
              ),
              
              Positioned(
                top: screenHeight * 0.23,
                left: screenWidth * 0.07,
                child: _buildUserNameSection(context),
              ),
              
              Positioned(
                top: screenHeight * 0.165,
                right: screenWidth * 0.08,
                left: screenWidth * 0.41,
                child: _buildPerformanceStats(context),
              ),
              
              Positioned(
                top: screenHeight * 0.49,
                left: screenWidth * 0.5 - 75,
                child: _buildPlayButton(context),
              ),
             
              Positioned(
                bottom: screenHeight * 0.075,
                left: 0,
                right: 0,
                child: _buildBottomButtons(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildProfilePicture(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUserOrNull;
        if (user == null) {
          return const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, size: 45, color: Colors.white),
          );
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileMenu()),
            );
          },
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
              border: Border.all(
                color: const Color(0xFF2D0A5E),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: user.avatarUrl != null
                ? ClipOval(
              child: Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person,
                      size: 45, color: Colors.grey);
                },
              ),
            )
                : const Icon(
              Icons.person,
              size: 45,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserNameSection(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUserOrNull;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileMenu()),
            );
          },
          child: SizedBox(
            width: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  user.username.split(' ').first, 
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28, 
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'UKBI: ${user.ukbiLevel}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPerformanceStats(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUserOrNull;
        if (user == null) {
          return const SizedBox.shrink();
        }

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileMenu()),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Performance',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              _buildStatRow('Rank', user.rank),
              const SizedBox(height: 5),
              _buildStatRow(
                  'Accuracy', '${user.accuracy.toStringAsFixed(2)}%'),
              const SizedBox(height: 5),
              _buildStatRow('Quiz Finished', '${user.quizzesCompleted}'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.75),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuizListPage()),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2D0A5E),
          border: Border.all(
            color: const Color(0xFF7B3FF2),
            width: 5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD600),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Color(0xFF2D0A5E),
                size: 45,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Play',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomButton(
            icon: Icons.settings,
            label: 'Options',
            hasWhiteCircle: true,
            onTap: () => _showOptionsDialog(context),
          ),
          _buildBottomButton(
            icon: Icons.add,
            label: 'Create',
            hasWhiteCircle: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Create Quiz - Coming Soon!')),
              );
            },
          ),
          _buildBottomButton(
            icon: Icons.people,
            label: 'Multiplayer',
            hasWhiteCircle: true,
            onTap: () async {
              final userProvider = context.read<UserProvider>();
              var user = userProvider.currentUserOrNull;

              
              if (user == null) {
                print('User data not loaded, attempting to load...');

                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please login first')),
                  );
                  return;
                }

               
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) => const Center(child: CircularProgressIndicator()),
                );

                try {
                  await userProvider.loadUserData(userId: currentUser.uid);
                  Navigator.pop(context); 

                  user = userProvider.currentUserOrNull;
                  if (user == null) {
                    throw Exception('Failed to load user data');
                  }
                } catch (e) {
                  Navigator.pop(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading user data: $e')),
                  );
                  return;
                }
              }

              
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MultiplayerMenu(
                    currentUserId: user!.userId,
                    currentUserName: user.username,
                  ),
                ),
              );
            },
          ),

        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required String label,
    required bool hasWhiteCircle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: hasWhiteCircle ? 75 : null,
            height: hasWhiteCircle ? 60 : null,
            decoration: hasWhiteCircle
                ? BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
                : null,
            child: Icon(
              icon,
              color: const Color(0xFF2D0A5E),
              size: 35,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF4C15A9)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings - Coming Soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.pop(context);
                await _logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userEmail');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomePage()),
          (route) => false,
    );
  }
}
