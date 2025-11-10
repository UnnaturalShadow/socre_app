import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/score_logic.dart';
import '../utils/sound_manager.dart';

class LeaderboardPage extends StatelessWidget {
  final GameState game;
  const LeaderboardPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final sorted = ScoreLogic.getLeaderboard(game.players);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Final Scores'),
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
              child: ListView.builder(
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final p = sorted[index];
                  return ListTile(
                    leading: Text('#${index + 1}'),
                    title: Text(p.name),
                    trailing: Text('${p.totalScore} pts'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                SoundManager.playButtonSound();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
              child: const Text('Restart Game'),
            ),
          ],
        ),
      ),
    );
  }
}
