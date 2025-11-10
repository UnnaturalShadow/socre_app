import 'package:flutter/material.dart';
import 'utils/sound_manager.dart';
import 'pages/home_page.dart';

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
      theme: ThemeData.light(), // Placeholder, you can customize
      home: const HomePage(),
    );
  }
}
