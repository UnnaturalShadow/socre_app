import 'player.dart';
import 'score_logic.dart';

class GameState {
  List<Player> players = [];
  int currentRound = 1;
  int totalRounds = 10;
  int dealerIndex = 0;

  GameState({this.totalRounds = 10});

  void startNewGame(List<String> playerNames, int totalRoundsInput) {
    totalRounds = totalRoundsInput;
    currentRound = 1;
    dealerIndex = ScoreLogic.randomDealerIndex(playerNames.length);
    players = playerNames.map((name) => Player(name: name)).toList();
  }

  void nextRound() {
    for (final player in players) {
      player.resetRound();
    }
    currentRound++;
    dealerIndex = (dealerIndex + 1) % players.length;
  }

  bool get isGameOver => currentRound > totalRounds;

  Player get currentDealer => players[dealerIndex];
}
