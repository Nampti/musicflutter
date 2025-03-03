import 'package:flutter/material.dart';

class AccountTab extends StatelessWidget {
  final VoidCallback onLogout;

  const AccountTab({required this.onLogout, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Account Tab'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onLogout, // Gọi callback khi nhấn Logout
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
