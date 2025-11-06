// lib/main.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Simple O-Hel scorekeeper app
/// - Uses Provider for app state.
/// - Light theme by default; tweak colors via AppColors.seedColor.
void main() {
  runApp(const OHelApp());
}

class AppColors {
  static const seedColor = Colors.deepPurple;
}

class OHelApp extends StatelessWidget {
  const OHelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O-Hel Scorekeeper',
      theme: ThemeData(
        colorScheme:
        ColorScheme.fromSeed(seedColor: AppColors.seedColor, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

/// HOME PAGE with "Play" button
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('O-Hel Scorekeeper')),
      body: Center(
        child: ElevatedButton(
          child: const Padding(
            padding: EdgeInsets.all(18.0),
            child: Text('Play', style: TextStyle(fontSize: 20)),
          ),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SetupPage()));
          },
        ),
      ),
    );
  }
}

/// SETUP PAGE: sliders for player count and rounds.
class SetupPage extends StatefulWidget {
  const SetupPage({super.key});
  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int _players = 4;
  int _rounds = 5;

  int _maxRoundsForPlayers(int players) => 52 ~/ players; // floor(52 / players)

  @override
  void initState() {
    super.initState();
    _players = 4;
    _rounds = 5;
  }

  @override
  Widget build(BuildContext context) {
    final maxRounds = _maxRoundsForPlayers(_players).clamp(1, 52);
    if (_rounds > maxRounds) _rounds = maxRounds;

    return Scaffold(
      appBar: AppBar(title: const Text('Game Setup')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Players: $_players', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: _players.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              label: '$_players',
              onChanged: (v) => setState(() {
                _players = v.round();
              }),
            ),
            const SizedBox(height: 16),
            Text('Rounds: $_rounds (max ${maxRounds})', style: Theme.of(context).textTheme.titleMedium),
            Slider(
              value: _rounds.toDouble(),
              min: 1,
              max: maxRounds.toDouble().clamp(1, 52),
              divisions: maxRounds < 1 ? 1 : maxRounds,
              label: '$_rounds',
              onChanged: (v) => setState(() {
                _rounds = max(1, v.round());
              }),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                final initialDealer = Random().nextInt(_players);
                final model = GameModel.createNew(numberOfPlayers: _players, numberOfRounds: _rounds, initialDealer: initialDealer);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => ChangeNotifierProvider.value(value: model, child: const ScorePage())),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text('Start Game'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MODEL: Player & RoundCell & GameModel

/// Immutable player model
class Player {
  Player({required this.name});
  String name;
}

/// Single cell for a player in a given round
class RoundCell {
  RoundCell({this.bid = 0, this.handsWon = 0, this.pointsThisRound = 0});
  int bid;
  int handsWon;
  int pointsThisRound;
}

/// ChangeNotifier that holds entire game state and logic
class GameModel extends ChangeNotifier {
  GameModel._({
    required this.players,
    required this.numberOfRounds,
    required this.initialDealer,
    required this.cardsSequence,
  })  : _cells = List.generate(numberOfRounds, (_) => List.generate(players.length, (_) => RoundCell()));

  /// Factory to create a new game given inputs.
  factory GameModel.createNew({required int numberOfPlayers, required int numberOfRounds, required int initialDealer}) {
    final players = List.generate(numberOfPlayers, (i) => Player(name: 'Player ${i + 1}'));
    // Build card sequence: simple symmetrical sequence (1..peak..1) where peak = ceil(rounds / 2)
    final peak = (numberOfRounds / 2).ceil();
    final List<int> seq = List<int>.generate(peak, (i) => i + 1);
    final down = List<int>.generate(numberOfRounds - peak, (i) => peak - (i + 1)).where((v) => v >= 1).toList();
    final cardsSequence = [...seq, ...down];
    return GameModel._(
      players: players,
      numberOfRounds: numberOfRounds,
      initialDealer: initialDealer,
      cardsSequence: cardsSequence,
    );
  }

  final List<Player> players;
  final int numberOfRounds;
  final int initialDealer;
  final List<int> cardsSequence;
  late final List<List<RoundCell>> _cells;

  int currentRoundIndex = 0; // 0-based
  bool gameFinished = false;

  List<List<RoundCell>> get cells => _cells;

  int get playerCount => players.length;

  /// Returns dealer index for round (0-based). Dealer rotates clockwise.
  int dealerIndexForRound(int roundIndex) {
    return (initialDealer + roundIndex) % playerCount;
  }

  /// Returns bidding order indices for a given round.
  /// Bidding starts at the player to the dealer's RIGHT and proceeds clockwise.
  List<int> biddingOrderForRound(int roundIndex) {
    final dealer = dealerIndexForRound(roundIndex);
    final start = (dealer - 1 + playerCount) % playerCount;
    return List<int>.generate(playerCount, (i) => (start + i) % playerCount);
  }

  int cardsForRound(int roundIdx) {
    if (roundIdx < 0 || roundIdx >= cardsSequence.length) return 1;
    return cardsSequence[roundIdx];
  }

  /// Calculates points for a single player's round using the rules:
  /// - If handsWon == bid => +10 * bid
  /// - If handsWon > bid => +10 * bid + (handsWon - bid)
  /// - If handsWon < bid => -10 * bid
  /// Special case: bid == 0:
  /// - If handsWon == 0 => +10
  /// - If handsWon > 0 => -10 * handsWon
  static int pointsForRound({required int bid, required int handsWon}) {
    if (bid == 0) {
      return (handsWon == 0) ? 10 : -10 * handsWon;
    }
    if (handsWon == bid) return 10 * bid;
    if (handsWon > bid) return 10 * bid + (handsWon - bid);
    // handsWon < bid
    return -10 * bid;
  }

  /// Update a single cell (bid/hands) and recalc points + cumulative downstream.
  void updateCell({required int roundIndex, required int playerIndex, int? bid, int? handsWon}) {
    final cell = _cells[roundIndex][playerIndex];
    if (bid != null) cell.bid = bid;
    if (handsWon != null) cell.handsWon = handsWon;
    cell.pointsThisRound = pointsForRound(bid: cell.bid, handsWon: cell.handsWon);
    _recomputeCumulativeScores();
    notifyListeners();
  }

  /// Recomputes cumulative scores across rounds for each player and stores pointsThisRound (cells already have).
  void _recomputeCumulativeScores() {
    // pointsThisRound is per round. cumulative is derived from summing up to current round.
    // We do nothing to store cumulative in cell; the UI will compute cumulative up to row index.
    // But ensure all cells have correct pointsThisRound already (should be true).
  }

  /// Helper to get cumulative points for a player up to and including `roundIndex`.
  int cumulativeForPlayerUpTo({required int playerIndex, required int roundIndex}) {
    int sum = 0;
    for (int r = 0; r <= roundIndex && r < numberOfRounds; r++) {
      sum += _cells[r][playerIndex].pointsThisRound;
    }
    return sum;
  }

  /// Advance to next round. If last round, mark finished and compute final leaderboard.
  void nextRound() {
    if (currentRoundIndex < numberOfRounds - 1) {
      currentRoundIndex++;
    } else {
      gameFinished = true;
    }
    notifyListeners();
  }

  /// Edit a player's name
  void setPlayerName(int index, String newName) {
    players[index].name = newName;
    notifyListeners();
  }

  /// Reset the entire game (used when returning to home)
  void reset() {
    // For convenience, leave model untouched; consumer will recreate via SetupPage
    // But we clear everything anyway:
    for (final row in _cells) {
      for (final cell in row) {
        cell.bid = 0;
        cell.handsWon = 0;
        cell.pointsThisRound = 0;
      }
    }
    currentRoundIndex = 0;
    gameFinished = false;
    notifyListeners();
  }

  /// Returns sorted leaderboard pairs of (name, score)
  List<MapEntry<String, int>> leaderboard() {
    final List<MapEntry<String, int>> list = [];
    for (int i = 0; i < playerCount; i++) {
      final score = cumulativeForPlayerUpTo(playerIndex: i, roundIndex: numberOfRounds - 1);
      list.add(MapEntry(players[i].name, score));
    }
    list.sort((a, b) => b.value.compareTo(a.value));
    return list;
  }
}

/// SCORE PAGE: spreadsheet-like display
class ScorePage extends StatelessWidget {
  const ScorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameModel>(
      builder: (context, model, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Scoreboard'),
            actions: [
              PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    // Show edit cell mode: the simplest UX is to instruct user to tap a cell to edit.
                    await showDialog(
                      context: context,
                      builder: (_) =>
                          AlertDialog(
                            title: const Text('Edit Cell'),
                            content: const Text(
                                'Tap any cell to edit its bid / hands won.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK')),
                            ],
                          ),
                    );
                  } else if (v == 'home') {
                    // Reset and return home (as requested)
                    model.reset();
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const HomePage()), (
                        _) => false);
                  }
                },
                itemBuilder: (_) =>
                [
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit Cell (tap a cell)')),
                  const PopupMenuItem(
                      value: 'home', child: Text('Return to Home (reset)')),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              _buildHeaderRow(model, context),
              Expanded(child: _buildScoreGrid(model, context)),
              _buildBottomControls(model, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderRow(GameModel model, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(children: [
        const SizedBox(width: 120,
            child: Text(
                'Round', style: TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(model.playerCount, (i) {
                return GestureDetector(
                  onTap: () async {
                    final newName = await _showEditPlayerNameDialog(
                        context, model.players[i].name);
                    if (newName != null && newName
                        .trim()
                        .isNotEmpty) {
                      model.setPlayerName(i, newName.trim());
                    }
                  },
                  child: Container(
                    width: 130,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme
                          .of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.08),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(model.players[i].name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold))),
                            const SizedBox(width: 6),
                            const Icon(Icons.person, size: 18),
                          ],
                        ),
                        Text('Tap to edit name', style: Theme
                            .of(context)
                            .textTheme
                            .bodySmall),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ]),
    );
  }

  Future<String?> _showEditPlayerNameDialog(BuildContext context,
      String current) {
    final controller = TextEditingController(text: current);
    return showDialog<String>(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Edit player name'),
            content: TextField(controller: controller,
                decoration: const InputDecoration(labelText: 'Name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text('Save')),
            ],
          ),
    );
  }

  Widget _buildScoreGrid(GameModel model, BuildContext context) {
    // Build a table-like scrollable area (vertical + horizontal)
    return Scrollbar(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column (round numbers)
            Column(
              children: List.generate(model.numberOfRounds, (r) {
                final cards = model.cardsForRound(r);
                final isCurrent = r == model.currentRoundIndex &&
                    !model.gameFinished;
                return Container(
                  width: 120,
                  height: 84,
                  margin: const EdgeInsets.all(4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isCurrent ? Theme
                        .of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.12) : null,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Round ${r + 1}', style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('$cards card(s)', style: Theme
                          .of(context)
                          .textTheme
                          .bodySmall),
                      const Spacer(),
                      if (isCurrent) const Text('Current', style: TextStyle(
                          fontSize: 12, fontStyle: FontStyle.italic)),
                    ],
                  ),
                );
              }),
            ),
            // Player columns
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(model.playerCount, (p) {
                    return Column(
                      children: List.generate(model.numberOfRounds, (r) {
                        final cell = model.cells[r][p];
                        final cards = model.cardsForRound(r);
                        final dealerHere = model.dealerIndexForRound(r) == p;
                        final cumulative = model.cumulativeForPlayerUpTo(
                            playerIndex: p, roundIndex: r);
                        return GestureDetector(
                          onTap: () async {
                            // Edit via dialog
                            final result = await _showEditCellDialog(
                                context,
                                model,
                                r,
                                p,
                                cell.bid,
                                cell.handsWon,
                                cards);
                            if (result != null) {
                              model.updateCell(roundIndex: r,
                                  playerIndex: p,
                                  bid: result.bid,
                                  handsWon: result.handsWon);
                            }
                          },
                          child: Container(
                            width: 130,
                            height: 84,
                            margin: const EdgeInsets.all(4),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              children: [
                                // top row: bid (L) and hands won (R)
                                Row(
                                  children: [
                                    Expanded(child: Text('Bid: ${cell.bid}')),
                                    Expanded(child: Text(
                                        'Won: ${cell.handsWon}',
                                        textAlign: TextAlign.right)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // bottom: cumulative score
                                Expanded(
                                  child: Row(
                                    children: [
                                      if (dealerHere)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Theme
                                                .of(context)
                                                .colorScheme
                                                .primary
                                                .withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(
                                                8),
                                          ),
                                          child: const Text('Dealer',
                                              style: TextStyle(fontSize: 10)),
                                        ),
                                      const Spacer(),
                                      Text('Total: $cumulative',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

  /// Dialog result type
  class _CellEditResult {
  final int bid;
  final int handsWon;
  _CellEditResult(this.bid, this.handsWon);
  }

  Future<_CellEditResult?> _showEditCellDialog(BuildContext context, GameModel model, int roundIndex, int playerIndex, int currentBid, int currentHandsWon, int cardsThisRound) {
  final bidController = TextEditingController(text: '$currentBid');
  final wonController = TextEditingController(text: '$currentHandsWon');
  return showDialog<_CellEditResult>(
  context: context,
  builder: (_) => AlertDialog(
  title: Text('Edit ${model.players[playerIndex].name} - Round ${roundIndex + 1}'),
  content: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
  Text('Cards this round: $cardsThisRound'),
  TextField(
  controller: bidController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: 'Bid (0 allowed)'),
  ),
  TextField(
  controller: wonController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(labelText: 'Hands won'),
  ),
  ],
  ),
  actions: [
  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
  TextButton(
  onPressed: () {
  final bid = int.tryParse(bidController.text.trim()) ?? 0;
  final won = int.tryParse(wonController.text.trim()) ?? 0;
  // Validate: bid cannot exceed cardsThisRound
  if (bid < 0 || bid > cardsThisRound) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bid must be between 0 and $cardsThisRound')));
  return;
  }
  if (won < 0 || won > cardsThisRound) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hands won must be between 0 and $cardsThisRound')));
  return;
  }
  Navigator.pop(context, _CellEditResult(bid, won));
  },
  child: const Text('Save'),
  ),
  ],
  ),
  );
  }

  Widget _buildBottomControls(GameModel model, BuildContext context) {
  return Padding(
  padding: const EdgeInsets.all(12.0),
  child: Row(
  children: [
  ElevatedButton.icon(
  onPressed: model.gameFinished
  ? null
      : () {
  // Advance round after confirming all hands input for current round? We let user advance; scores already updated when hands entered.
  model.nextRound();
  if (model.gameFinished) {
  _showLeaderboard(context, model);
  }
  },
  icon: const Icon(Icons.skip_next),
  label: const Text('Next Round'),
  ),
  const SizedBox(width: 12),
  Text('Round ${model.currentRoundIndex + 1} / ${model.numberOfRounds}'),
  const Spacer(),
  ElevatedButton.icon(
  onPressed: () => _showLeaderboard(context, model),
  icon: const Icon(Icons.emoji_events),
  label: const Text('Leaderboard'),
  ),
  ],
  ),
  );
  }

  void _showLeaderboard(BuildContext context, GameModel model) {
  final board = model.leaderboard();
  showDialog(
  context: context,
  builder: (_) => AlertDialog(
  title: const Text('Final Leaderboard'),
  content: Column(
  mainAxisSize: MainAxisSize.min,
  children: board.map((e) => ListTile(title: Text(e.key), trailing: Text('${e.value}'))).toList(),
  ),
  actions: [
  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
  ],
  ),
  );
}

