import 'package:flutter/material.dart';

int donothing() {
  return 1;
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Login',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w100),
            ),
            SizedBox(
              height: 150,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Username/E-mail/Phone number'),
                TextField(),
                Text('Password'),
                TextField(),
              ],
            ),
            SizedBox(
              height: 150,
            ),
            OutlinedButton(onPressed: donothing, child: Text('Login')),
            TextButton(onPressed: donothing, child: Text('Forget password'))
          ],
        ),
      ),
    );
  }
}
