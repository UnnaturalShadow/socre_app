import 'package:flutter/material.dart';
import '../models/game_state.dart';
import 'score_cell.dart';
import 'player_header_cell.dart';
import 'round_number_cell.dart';
import '../models/player.dart';

class ScoreTable extends StatelessWidget {
  final GameState game;
  final Function(Player) onEditCell;

  const ScoreTable({super.key, required this.game, required this.onEditCell});

  @override
  Widget build(BuildContext context) {
    final players = game.players;
    final dealer = game.currentDealer;

    return Column(
      children: [
        // top row headers
        Row(
          children: [
            Container(
              width: 80,
              height: 50,
              alignment: Alignment.center,
              color: Colors.grey.shade400,
              child: const Text(
                'Round',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...players.map((p) => PlayerHeaderCell(player: p, isDealer: p == dealer)),
          ],
        ),
        // round rows
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: List.generate(
                game.totalRounds,
                    (roundIndex) {
                  final isCurrent = (roundIndex + 1) == game.currentRound;
                  return Row(
                    children: [
                      RoundNumberCell(round: roundIndex + 1, isCurrent: isCurrent),
                      ...players.map(
                            (p) => ScoreCell(
                          player: p,
                          isDealer: p == dealer,
                          isCurrentRound: isCurrent,
                          onEdit: () => onEditCell(p),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
