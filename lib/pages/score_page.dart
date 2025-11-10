import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../models/score_logic.dart';
import '../utils/sound_manager.dart';
import '../models/player.dart';

class ScorePage extends StatefulWidget {
  final GameState game;
  const ScorePage({super.key, required this.game});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage> {
  late ScrollController _horizontal;
  late ScrollController _vertical;
  late int handSize;

  @override
  void initState() {
    super.initState();
    _horizontal = ScrollController();
    _vertical = ScrollController();
    handSize = widget.game.currentRound;
  }

  @override
  void dispose() {
    _horizontal.dispose();
    _vertical.dispose();
    super.dispose();
  }

  void _nextRound() {
    ScoreLogic.calculateRoundScores(widget.game.players, handSize);
    widget.game.nextRound();

    if (widget.game.isGameOver) {
      Navigator.pushReplacementNamed(
        context,
        '/leaderboard',
        arguments: widget.game,
      );
    } else {
      setState(() {
        handSize = widget.game.currentRound;
      });
    }
  }

  void _editCellDialog(Player player, String field) {
    final controller = TextEditingController(
      text: field == 'bid'
          ? player.bid.toString()
          : player.handsWon.toString(),
    );
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit ${player.name}\'s $field'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onTap: () => controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller.text.length,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text) ?? 0;
              setState(() {
                if (field == 'bid') player.bid = val;
                if (field == 'hands') player.handsWon = val;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTable() {
    final players = widget.game.players;
    final dealer = widget.game.currentDealer;

    return InteractiveViewer(
      constrained: false,
      child: Column(
        children: [
          // Fixed top row (player names)
          Row(
            children: [
              Container(
                width: 80,
                height: 50,
                alignment: Alignment.center,
                color: Theme.of(context).colorScheme.secondaryContainer,
                child: const Text(
                  'Round',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ...players.map(
                    (p) => Container(
                  width: 120,
                  height: 50,
                  alignment: Alignment.center,
                  color: p == dealer
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Theme.of(context).colorScheme.surfaceVariant,
                  child: Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          // Round rows
          Expanded(
            child: Scrollbar(
              controller: _vertical,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _vertical,
                scrollDirection: Axis.vertical,
                child: Column(
                  children: List.generate(
                    widget.game.totalRounds,
                        (roundIndex) {
                      final isCurrent =
                          (roundIndex + 1) == widget.game.currentRound;
                      return Row(
                        children: [
                          Container(
                            width: 80,
                            height: 60,
                            alignment: Alignment.center,
                            color: isCurrent
                                ? Theme.of(context).colorScheme.secondaryContainer
                                : Theme.of(context).colorScheme.surfaceVariant,
                            child: Text('${roundIndex + 1}'),
                          ),
                          ...players.map((p) {
                            return GestureDetector(
                              onTap: () {
                                if (isCurrent) {
                                  _editCellDialog(p, 'bid');
                                }
                              },
                              child: Container(
                                width: 120,
                                height: 60,
                                margin:
                                const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.black26),
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceVariant,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('Bid: ${p.bid}'),
                                    Text('Won: ${p.handsWon}'),
                                    Text('Score: ${p.totalScore}'),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final validBids = ScoreLogic.isValidBidTotal(widget.game.players, handSize);

    return Scaffold(
      appBar: AppBar(
        title: Text('Round ${widget.game.currentRound} — Dealer: ${widget.game.currentDealer.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () async {
              await showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
                items: [
                  PopupMenuItem(
                    value: 'edit',
                    child: const Text('Edit Scores'),
                    onTap: () {},
                  ),
                  PopupMenuItem(
                    value: 'home',
                    child: const Text('Return Home'),
                    onTap: () {
                      Navigator.popUntil(context, ModalRoute.withName('/'));
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!validBids)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "! You cannot bid higher than the number of cards in your hand!",
                style: TextStyle(color: Colors.red),
              ),
            ),
          Expanded(child: _buildScoreTable()),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                SoundManager.playSaveSound();
                _nextRound();
              },
              child: const Text('Next Round'),
            ),
          ),
        ],
      ),
    );
  }
}
