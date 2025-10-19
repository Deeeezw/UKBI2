import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/UserProviders.dart';

class UserCard extends StatelessWidget {
  const UserCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userStats = userProvider.currentUser;  // Changed from userStats to currentUser

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                userStats.username,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Performance',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text('Rank:', style: _rowStyle()),
                        const SizedBox(height: 2),
                        Text(userStats.rank, style: _valueStyle()),
                      ],
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: Column(
                      children: [
                        Text('UKBI:', style: _rowStyle()),
                        const SizedBox(height: 2),
                        Text(userStats.ukbiLevel, style: _valueStyle()),
                      ],
                    ),
                  ),
                  _verticalDivider(),
                  Expanded(
                    child: Column(
                      children: [
                        Text('Accuracy:', style: _rowStyle()),
                        const SizedBox(height: 2),
                        Text(userStats.accuracyFormatted, style: _valueStyle()),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _verticalDivider() => Container(
      width: 1, height: 32, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 4));

  static TextStyle _rowStyle() => const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500);

  static TextStyle _valueStyle() => const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold);
}
