import 'package:flutter/material.dart';
import 'package:road/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farm Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
