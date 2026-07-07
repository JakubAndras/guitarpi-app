import 'package:bc_ui_flutter/page/ConnectionPage.dart';
import 'package:bc_ui_flutter/page/MainPage.dart';
import 'package:bc_ui_flutter/page/HelpPage.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  late ConnectionPage connectionPage;
  late MainPage mainPage;
  late HelpPage helpPage;
  List<Widget> screens = [];

  _HomePageState() {
    connectionPage = ConnectionPage(switchToMainPage: switchToMainPage);
    mainPage = MainPage();
    helpPage = HelpPage();

    screens = [
      connectionPage,
      mainPage,
      helpPage,
    ];
  }

  switchToMainPage() {
    setState(() {
      currentIndex = 1;
      mainPage.initConnection();
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
