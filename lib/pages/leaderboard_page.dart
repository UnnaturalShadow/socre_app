import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/score_logic.dart';
import '../utils/sound_manager.dart';

class LeaderboardPage extends StatelessWidget {
  final GameState game;
  const LeaderboardPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final sortedPlayers = ScoreLogic.getLeaderboard(game.players);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Scores'),
        automaticallyImplyLeading: false, // Removes default back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Leaderboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: sortedPlayers.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final player = sortedPlayers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    title: Text(
                      player.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    trailing: Text(
                      '${player.totalScore} pts',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                SoundManager.playButtonSound();
                // Return to home and reset game
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              ),
              child: const Text(
                'Restart Game',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
