import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'intro_screen.dart';
import 'signin.dart';
import 'signup.dart';
import 'home.dart';
import 'admin.dart';
import 'detail_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase Intro',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => IntroScreen(),
        '/signin': (context) => SignInScreen(),
        '/signup': (context) => SignUpPage(),
        '/home': (context) => HomePage(),
        '/admin': (context) => AdminPage(),
        '/detail_page': (context) => DetailPage(),
      },
    );
  }
}
