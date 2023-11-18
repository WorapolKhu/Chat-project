import 'package:chatty/pages/home.dart';
import 'package:chatty/pages/register.dart';
import 'package:chatty/pages/setting.dart';
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

  OutlineInputBorder _inputDecoration = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide(color: Colors.grey),
  );

  // ปรับความสูงของ TextField ตามที่คุณต้องการ

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 30),
              const Align(
                child: Text(
                  'Login',
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('E-mail'),
                  SizedBox(height: 10),
                  Container(
                    height: 50,
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      decoration: InputDecoration(
                        enabledBorder: _inputDecoration,
                        focusedBorder: _inputDecoration,
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 18.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Password'),
                  SizedBox(height: 10),
                  Container(
                    height: 50,
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
                        prefixIcon: Icon(Icons.lock),
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 100,
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await _auth.signInWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (context.mounted) {
                      print('Login success, changing page');
                      Navigator.pushNamed(context, HomePage.id);
                    }
                  } catch (e) {
                    // TODO: Show error
                    print(e);
                  }
                },
                child: Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement forgot password functionality
                },
                child: Text('Forgot password'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, RegisterPage.id);
                },
                child: Text("Sign up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
