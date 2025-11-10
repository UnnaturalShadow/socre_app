import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blueAccent,
    brightness: Brightness.light,
  ),
  scaffoldBackgroundColor: Colors.grey[50],
  textTheme: const TextTheme(
    titleLarge: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    bodyMedium: TextStyle(fontSize: 16),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    elevation: 2,
  ),
);
