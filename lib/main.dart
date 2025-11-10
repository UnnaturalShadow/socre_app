import 'package:flutter/material.dart';
import 'utils/color_scheme.dart';
import 'utils/sound_manager.dart';
import 'pages/home_page.dart';
import 'pages/setup_page.dart';
import 'pages/score_page.dart';
import 'pages/leaderboard_page.dart';
import 'models/game_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SoundManager.init();
  runApp(const OHelApp());
}

class OHelApp extends StatelessWidget {
  const OHelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'O Hel Scorekeeper',
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomePage());

          case '/setup':
            return MaterialPageRoute(builder: (_) => const SetupPage());

          case '/score':
            final game = settings.arguments;
            if (game == null || game is! GameState) {
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('Error: No game data found!'),
                  ),
                ),
              );
            }
            return MaterialPageRoute(builder: (_) => ScorePage(game: game));

          case '/leaderboard':
            final game = settings.arguments;
            if (game == null || game is! GameState) {
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('Error: No game data found!'),
                  ),
                ),
              );
            }
            return MaterialPageRoute(builder: (_) => LeaderboardPage(game: game));

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('Route not found: ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}
