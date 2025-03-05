import 'package:flutter/material.dart';
import '../widgets/travel_card.dart';  

class TravelScreen extends StatelessWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset('assets/background_awal.png', fit: BoxFit.cover),

          // Gambar "TRAVELING KUY" di atas
          Column(
            children: [
              const SizedBox(height: 150),
              Image.asset('assets/TRAVELING.png', width: 220),
              const SizedBox(height: 5),
              Image.asset('assets/KUY.png', width: 100),
            ],
          ),

          // Card di bagian bawah
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: TravelCard(),
            ),
          ),
        ],
      ),
    );
  }
}