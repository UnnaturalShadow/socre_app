import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/player.dart';


class PlayerHeaderCell extends StatelessWidget {
  final Player player;
  final bool isDealer;

  const PlayerHeaderCell({super.key, required this.player, this.isDealer = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 50,
      alignment: Alignment.center,
      color: isDealer ? Colors.blue.shade300 : Colors.grey.shade300,
      child: Text(
        player.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
