import 'package:flutter/material.dart';
import 'Member/Start.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () { // 3초 뒤 Start화면 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Start()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Image.asset(
          'assets/images/Logo.png',
          width: 150,
        ),
      ),
    );
  }
}