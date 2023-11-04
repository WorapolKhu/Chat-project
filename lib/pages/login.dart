import 'package:chatty/pages/register.dart';
import 'package:flutter/material.dart';

int donothing() {
  return 1;
}

class LoginPage extends StatefulWidget {
  static String id = 'login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Login',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w100),
            ),
            const SizedBox(
              height: 150,
            ),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username/E-mail/Phone number'),
                TextField(),
                Text('Password'),
                TextField(),
              ],
            ),
            const SizedBox(
              height: 150,
            ),
            const OutlinedButton(onPressed: donothing, child: Text('Login')),
            const TextButton(
                onPressed: donothing, child: Text('Forget password')),
            TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegisterPage.id);
                },
                child: const Text('Don\'t have an account? Register here'))
          ],
        ),
      ),
    );
  }
}
