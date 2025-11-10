import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../utils/sound_manager.dart';
import 'score_page.dart'; // Import ScorePage directly

class SetupPage extends StatefulWidget {
  const SetupPage({super.key});

  @override
  State<SetupPage> createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  int numPlayers = 3;
  int numRounds = 5;
  List<TextEditingController> nameControllers = [];

  @override
  void initState() {
    super.initState();
    _updateNameControllers();
  }

  void _updateNameControllers() {
    nameControllers =
        List.generate(numPlayers, (i) => TextEditingController(text: "Player ${i + 1}"));
  }

  int get maxRounds => (52 ~/ numPlayers);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Game Setup"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "Select number of players:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              min: 2,
              max: 10,
              divisions: 8,
              label: "$numPlayers",
              value: numPlayers.toDouble(),
              onChanged: (val) {
                setState(() {
                  numPlayers = val.toInt();
                  if (numRounds > maxRounds) {
                    numRounds = maxRounds;
                  }
                  _updateNameControllers();
                });
              },
            ),
            Text("Players: $numPlayers"),

            const SizedBox(height: 20),
            const Text(
              "Select number of rounds:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Slider(
              min: 1,
              max: maxRounds.toDouble(),
              divisions: maxRounds - 1,
              label: "$numRounds",
              value: numRounds.toDouble(),
              onChanged: (val) {
                setState(() {
                  numRounds = val.toInt();
                });
              },
            ),
            Text("Rounds: $numRounds (Max allowed: $maxRounds)"),

            const SizedBox(height: 30),
            const Text(
              "Enter player names:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            ...List.generate(
              numPlayers,
                  (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: nameControllers[index],
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: "Player ${index + 1} Name",
                    border: const OutlineInputBorder(),
                  ),
                  onTap: () {
                    // Auto-select text for faster overwrite
                    nameControllers[index].selection = TextSelection(
                      baseOffset: 0,
                      extentOffset: nameControllers[index].text.length,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                SoundManager.playSaveSound();
                final playerNames = nameControllers.map((c) => c.text.trim()).toList();

                final game = GameState(totalRounds: numRounds);
                game.startNewGame(playerNames, numRounds);

                // Navigate directly using MaterialPageRoute
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ScorePage(game: game),
                  ),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text("Start Game"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
