import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/player.dart';


class ScoreCell extends StatelessWidget {
  final Player player;
  final bool isDealer;
  final bool isCurrentRound;
  final VoidCallback onEdit;

  const ScoreCell({
    super.key,
    required this.player,
    this.isDealer = false,
    this.isCurrentRound = false,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Colors.white;
    if (isDealer) bgColor = Colors.blue.shade200;
    if (isCurrentRound) bgColor = Colors.yellow.shade200;

    return GestureDetector(
      onTap: onEdit,
      child: Container(
        width: 120,
        height: 60,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black26),
          color: bgColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bid: ${player.bid}'),
            Text('Won: ${player.handsWon}'),
            Text('Score: ${player.totalScore}'),
          ],
        ),
      ),
    );
  }
}
