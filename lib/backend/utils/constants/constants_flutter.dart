import 'dart:io';
import 'package:flutter/foundation.dart';

// API Base URL
String get baseUrl {
  if (kIsWeb) {
    return "http://127.0.0.1:5000";
  } else if (Platform.isAndroid) {
    return "http://10.0.2.2:5000"; // emulator
  } else {
    return "http://127.0.0.1:5000"; // iOS simulator or desktop dev
  }
}

// API Endpoints
String get authEndpoint => "$baseUrl/auth";
String get bookingEndpoint => "$baseUrl/booking";
String get paymentEndpoint => "$baseUrl/payment";
String get notificationEndpoint => "$baseUrl/notification";
String get destinationEndpoint => "$baseUrl/destination";

// Key
const String tokenKey = 'auth_token';
const String userIdKey = 'uid';

//  Durasi TO
const Duration apiTO = Duration(seconds: 15);
