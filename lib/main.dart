import 'package:chatty/pages/chat.dart';
import 'package:chatty/pages/home.dart';
import 'package:chatty/pages/login.dart';
import 'package:chatty/pages/setting.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:chatty/pages/register.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        LoginPage.id: (context) => const LoginPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        HomePage.id: (context) => const HomePage(),
        SettingPage.id: (context) => const SettingPage(),
        ChatPage.id: (context) => const ChatPage()
      },
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: RegisterPage.id,
    );
  }
}
