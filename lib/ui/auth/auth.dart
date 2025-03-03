import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const AuthScreen({required this.onLoginSuccess, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const HeaderSection(),
                const SizedBox(height: 40.0),
                SocialLoginSection(onLoginSuccess: onLoginSuccess),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    // Chuyển đến màn hình đăng ký (chưa triển khai)
                  },
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset('assets/itune.png', height: 100.0, width: 100.0),
        const SizedBox(height: 10.0),
        const Text(
          'Welcome to Music App',
          style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class SocialLoginSection extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const SocialLoginSection({required this.onLoginSuccess, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SocialLoginButton(
          text: 'Continue with Google',
          color: Colors.white,
          textColor: Colors.black87,
          icon: Image.asset('assets/google_logo.png', height: 24.0),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Google login clicked')),
            );
            onLoginSuccess();
          },
        ),
        const SizedBox(height: 16.0),
        SocialLoginButton(
          text: 'Continue with Facebook',
          color: const Color(0xFF3B5998),
          textColor: Colors.white,
          icon: Image.asset('assets/facebook_logo.png', height: 24.0),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Facebook login clicked')),
            );
            onLoginSuccess();
          },
        ),
        const SizedBox(height: 16.0),
      ],
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final Widget icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    required this.text,
    required this.color,
    required this.textColor,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        elevation: 6.0,
        minimumSize: const Size(double.infinity, 50.0),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(width: 12.0),
          Text(
            text,
            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
