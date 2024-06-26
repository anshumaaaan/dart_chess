import 'package:flutter/material.dart';
import 'chess_board_detector.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chess Board Change Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChessBoardDetector(),
    );
  }
}