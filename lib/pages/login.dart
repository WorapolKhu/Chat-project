import 'package:chatty/pages/home.dart';
import 'package:chatty/pages/register.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Username/E-mail/Phone number'),
                  TextField(
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  const Text('Password'),
                  TextField(
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 150,
              ),
              OutlinedButton(
                  onPressed: () async {
                    try {
                      _auth.signInWithEmailAndPassword(
                          email: email, password: password);
                      if (context.mounted) {
                        print('login success changing page');
                        Navigator.pushNamed(context, HomePage.id);
                      }
                    } catch (e) {
                      // TODO: show error
                      print(e);
                    }
                  },
                  child: Text('Login')),
              TextButton(
                  onPressed: donothing, child: const Text('Forget password')),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RegisterPage.id);
                  },
                  child: const Text('Don\'t have an account? Register here'))
            ],
          ),
        ),
      ),
    );
  }
}
