import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicflutter/ui/discovery/discovery.dart';
import 'package:musicflutter/ui/home/home.dart';
import 'package:musicflutter/ui/settings/settings.dart';
import 'package:musicflutter/ui/user/user.dart';

class MusicHomePage extends StatefulWidget {
  final VoidCallback onLogout; // Nhận callback từ MusicAppp

  const MusicHomePage({required this.onLogout, super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      const HomeTab(),
      const DiscoveryTab(),
      AccountTab(onLogout: widget.onLogout), // Truyền onLogout cho AccountTab
      const SettingsTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Music App')),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.album),
              label: 'Discovery',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}
