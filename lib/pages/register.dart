import 'package:chatty/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String username = '';

  final OutlineInputBorder _inputDecoration = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(color: Colors.grey),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              const Align(
                child: Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('Username'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 45,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          username = value;
                        });
                      },
                      decoration: InputDecoration(
                        enabledBorder: _inputDecoration,
                        focusedBorder: _inputDecoration,
                        hintText: 'Enter your username',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14.0,
                          horizontal: 18.0,
                        ),
                      ),
                    ),
                  ),
                  const Text('Email'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 45,
                    child: TextField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      decoration: InputDecoration(
                        enabledBorder: _inputDecoration,
                        focusedBorder: _inputDecoration,
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Password'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 45,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          password = value;
                        });
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: _inputDecoration,
                        focusedBorder: _inputDecoration,
                        hintText: 'Enter your password',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 18.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Confirm Password'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 45,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          confirmPassword = value;
                        });
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        enabledBorder: _inputDecoration,
                        focusedBorder: _inputDecoration,
                        hintText: 'Confirm your password',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              OutlinedButton(
                onPressed: () async {
                  // if password != confirm password show error
                  // else try to create user with email and password
                  // if there is an error show error
                  if (password != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'The password is not matching.',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                  } else {
                    try {
                      await _auth.createUserWithEmailAndPassword(
                        email: email,
                        password: password,
                      );
                      await FirebaseFirestore.instance.collection('users').add({
                        'name': username,
                        'email': email,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'Register success.',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                      Navigator.pushNamed(context, LoginPage.id);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'This email is already exist.',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Register'),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, LoginPage.id);
                  },
                  child: const Text('Have an account? Login here')),
            ],
          ),
        ),
      ),
    );
  }
}
