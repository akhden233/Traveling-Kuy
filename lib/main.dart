import 'package:flutter/material.dart'; 
import '../screens/travel_screen.dart';

void main() => runApp(const TravelKuyApp());

class TravelKuyApp extends StatelessWidget {
  const TravelKuyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const TravelScreen(),
    );
  }
}