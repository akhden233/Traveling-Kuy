import 'package:flutter/material.dart';
import '../screens/signin_screen.dart'; 
import '../widgets/social_button.dart';

class TravelCard extends StatelessWidget {
  const TravelCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: index == 0 ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == 0 ? Colors.grey[800] : Colors.grey[400],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Jelajahi dunia, ciptakan kenangan, Temukan destinasi impianmu sekarang bersama “Traveling Kuy”! ',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2F492C),
              fontSize: 14,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "don’t have an account?",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F492C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SigninScreen()),
                );
              },
              child: const Text(
                'Get Started',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "or Log in with",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              socialButton('assets/google.png'),
              const SizedBox(width: 10),
              socialButton('assets/apple.png'),
              const SizedBox(width: 10),
              socialButton('assets/facebook.png'),
            ],
          ),
        ],
      ),
    );
  }
}