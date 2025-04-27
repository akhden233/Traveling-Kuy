import 'dart:io';
import 'package:flutter/foundation.dart';

const bool isEmulator = false; // ubah ke true jika emulator

// API Base URL
String get baseUrl {
  if (kIsWeb) {
    return "http://127.0.0.1:5000";
  } else if (Platform.isAndroid) {
    return isEmulator
      ? "http://10.0.2.2:5000" // emulator
      : "http://192.168.243.229:5000"; // IP atau APP Domain    
  } else {
    return "http://127.0.0.1:5000"; // emulator
  }
}

// API Endpoints
String get authEndpoint => "$baseUrl/auth";
String get bookingEndpoint => "$baseUrl/booking";
String get paymentEndpoint => "$baseUrl/payment";
String get notificationEndpoint => "$baseUrl/notification";
String get destinationEndpoint => "$baseUrl/destination";
String get userProfileEndpoint => "$baseUrl/user";

// Key
const String tokenKey = 'auth_token';
const String userIdKey = 'uid';

//  Durasi TO
const Duration apiTO = Duration(seconds: 30);
