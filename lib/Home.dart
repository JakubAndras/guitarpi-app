import 'package:bc_ui_flutter/page/ConnectionPage.dart';
import 'package:bc_ui_flutter/page/MainPage.dart';
import 'package:bc_ui_flutter/page/HelpPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int currentIndex = 0;

  late final List<Widget> screens = [
    ConnectionPage(switchToMainPage: switchToMainPage),
    const MainPage(),
    HelpPage(),
  ];

  void switchToMainPage() {
    // ConnectionPage already kicked off the connection via ConnectionNotifier;
    // here we only move to the pedalboard tab.
    setState(() {
      currentIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    // BottomNavigationBar insets its content by the bottom safe area (e.g. the
    // iPhone home indicator). Add it to the fixed height so the 34px icons keep
    // their full 44px content area instead of overflowing.
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: !isPortrait && currentIndex == 1
          ? null
          : SizedBox(
        height: 44 + bottomInset,
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          iconSize: 34,
          showUnselectedLabels: false,
          showSelectedLabels: false,
          selectedFontSize: 0,
          unselectedFontSize: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.app_settings_alt),
              label: 'Connection & Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_music_outlined),
              label: 'PedalBoard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.live_help_outlined),
              label: 'Help & Usage',
            ),
          ],
          currentIndex: currentIndex,
          onTap: (index) => setState(() => currentIndex = index),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}
