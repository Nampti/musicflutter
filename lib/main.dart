import 'package:flutter/material.dart';
import 'package:musicflutter/ui/auth/auth.dart';
import 'package:musicflutter/ui/layout/layout.dart';

void main() => runApp(const MusicAppp());

class MusicAppp extends StatefulWidget {
  const MusicAppp({super.key});

  @override
  State<MusicAppp> createState() => _MusicApppState();
}

class _MusicApppState extends State<MusicAppp> {
  bool _isLoggedIn = false; // Trạng thái đăng nhập giả lập

  void _onLoginSuccess() {
    setState(() {
      _isLoggedIn = true; // Chuyển trạng thái khi đăng nhập thành công
    });
  }

  void _onLogout() {
    setState(() {
      _isLoggedIn = false; // Chuyển trạng thái khi đăng xuất
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home:
          _isLoggedIn
              ? MusicHomePage(onLogout: _onLogout) // Truyền callback onLogout
              : AuthScreen(onLoginSuccess: _onLoginSuccess),
      debugShowCheckedModeBanner: false,
    );
  }
}
