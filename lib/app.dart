import 'package:flutter/material.dart';

import 'Home.dart';

/// Root application widget. Holds the [MaterialApp] with the dark theme and the
/// [HomePage] as home. Moved out of `main.dart` as part of the clean-architecture
/// refactor.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
    );
  }
}
