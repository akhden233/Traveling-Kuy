import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'backend/providers/auth_provider.dart';
import 'backend/providers/destination_provider.dart';
import 'backend/providers/userProfile_provider.dart';
import '../screens/travel_screen.dart';

void main() async {
  // Kondisi initialized Firebase (untuk Auth)
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDcvkIUbKEWFZ_r2bgaqgOr-jHeis1cSgU",
        authDomain: "travellingkuy0190.firebaseapp.com",
        projectId: "travellingkuy0190",
        storageBucket: "travellingkuy0190.appspot.com",
        messagingSenderId: "586337861286",
        appId: "1:586337861286:web:6fd7fbb6319c5ea014be67",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => UserprofileProvider()),
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
