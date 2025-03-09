import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import '../screens/travel_screen.dart';

void main() { 
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
    child: TravelKuyApp(),
    ),
  );
}
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