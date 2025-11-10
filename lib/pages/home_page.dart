import 'package:flutter/material.dart';
import '../utils/sound_manager.dart';
import 'setup_page.dart'; // Import the SetupPage directly

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "O Hel Scorekeeper",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                SoundManager.playButtonSound();

                // Navigate directly using MaterialPageRoute
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SetupPage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              ),
              child: const Text("Play"),
            ),
          ],
        ),
      ),
    );
  }
}
