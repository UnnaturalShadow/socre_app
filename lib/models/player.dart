class Player {
  String name;
  int totalScore;
  int bid;
  int handsWon;

  Player({
    required this.name,
    this.totalScore = 0,
    this.bid = 0,
    this.handsWon = 0,
  });

  void resetRound() {
    bid = 0;
    handsWon = 0;
  }

  int calculateRoundScore(int handSize) {
    if (bid == handsWon) {
      // Correct bid — reward is 10 + bid
      return 10 + bid;
    } else {
      // Incorrect bid — lose 1 point per difference
      return -((bid - handsWon).abs());
    }
  }

  @override
  String toString() =>
      'Player(name: $name, totalScore: $totalScore, bid: $bid, handsWon: $handsWon)';
}
