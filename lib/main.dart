import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:papyrus/Home.dart';
import 'package:papyrus/authentication/Login.dart';
import 'package:papyrus/authentication/Register.dart';
import 'firebase_options.dart';

final bool _isIOS = Platform.isIOS;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
        title: 'Flutter Demo',
        initialRoute: '/login',
        theme: CupertinoThemeData(
         primaryColor: CupertinoColors.activeOrange
        ),
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const RegisterScreen(),

      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }


  CupertinoPageScaffold _buildCupertino() {
    return CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w300),
            ),
          ],
        ),
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return _buildCupertino();

  }
}
