import 'dart:math';

import 'player.dart';

class ScoreLogic {
  /// Randomly assign the first dealer
  static int randomDealerIndex(int playerCount) {
    final random = Random();
    return random.nextInt(playerCount);
  }

  /// Validates that the total of all bids does not equal the number of cards in hand
  static bool isValidBidTotal(List<Player> players, int handSize) {
    final totalBid = players.fold<int>(0, (sum, p) => sum + p.bid);
    return totalBid != handSize;
  }

  /// Updates all players’ total scores based on their performance
  static void calculateRoundScores(List<Player> players, int handSize) {
    for (var p in players) {
      p.totalScore += p.calculateRoundScore(handSize);
    }
  }

  /// Returns players sorted by descending score
  static List<Player> getLeaderboard(List<Player> players) {
    final sorted = [...players];
    sorted.sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return sorted;
  }
}
