import 'package:flutter/material.dart';
 
  Widget socialButton(String assetPath) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey),
      ),
      child: Image.asset(assetPath, width: 24, height: 24),
    );
  }