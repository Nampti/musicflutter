import 'package:flutter/material.dart';
import 'package:musicflutter/ui/ad/BannerAdWidget.dart';
import 'package:musicflutter/ui/ad/RewardedAdWidget.dart'; // Import the RewardedAdWidget
import 'package:musicflutter/ui/ad/InterstitialAdWidget.dart'; // Import the InterstitialAdWidget
import 'package:musicflutter/ui/discovery/discovery.dart';
import 'package:musicflutter/ui/home/home.dart';
import 'package:musicflutter/ui/settings/settings.dart';
import 'package:musicflutter/ui/user/user.dart';

class MusicHomePage extends StatefulWidget {
  final VoidCallback onLogout;

  const MusicHomePage({required this.onLogout, super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  late List<Widget> _tabs;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HomeTab(),
      const DiscoveryTab(),
      AccountTab(onLogout: widget.onLogout),
      const SettingsTab(),
    ];
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Show interstitial ad at natural break points
    if (index == 1 || index == 2) {
      // Show interstitial ad when switching to Discovery or Account tab
      showDialog(
        context: context,
        builder: (context) => const InterstitialAdWidget(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music App'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(child: _tabs[_currentIndex]),
          const RewardedAdWidget(),
          const BannerAdWidget(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabChanged,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.deepPurple,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.album_outlined),
              activeIcon: Icon(Icons.album),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Account',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
