import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

int donothing() {
  return 1;
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'Poppins'),
      home: const Scaffold(
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
      ),
    );
  }
}
