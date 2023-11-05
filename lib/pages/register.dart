import 'package:chatty/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

int donothing() {
  return 1;
}

class RegisterPage extends StatefulWidget {
  static String id = 'register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  String confirmPassword = '';
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
                'Register',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.w100),
              ),
              const SizedBox(
                height: 150,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Email'),
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) {
                      email = value;
                    },
                  ),
                  const Text('Password'),
                  TextField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    onChanged: (value) {
                      password = value;
                    },
                  ),
                  const Text('Confirm Password'),
                  TextField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    onChanged: (value) {
                      confirmPassword = value;
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 150,
              ),
              OutlinedButton(
                  onPressed: () async {
                    if (password != confirmPassword) {
                      // TODO: show error
                    } else {
                      try {
                        await _auth.createUserWithEmailAndPassword(
                            email: email, password: password);
                        print('success to register');
                      } catch (e) {
                        //TODO: show error messages
                        print(e);
                      }
                    }
                  },
                  child: const Text('Register')),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, LoginPage.id);
                  },
                  child: const Text('Have an account? Login here'))
            ],
          ),
        ),
      ),
    );
  }
}
