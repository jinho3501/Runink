import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:RunInk/Loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Bottom_Bar.dart';
import 'Member/LoginScreen.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // 로그인 상태 확인
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: isLoggedIn ? "/" : "/login",
      routes: {
        "/": (_) => BottomBarApp(),
        "/login": (_) => Loading(),
      },
      // home 속성 제거
      debugShowCheckedModeBanner: false,
    );
  }
}