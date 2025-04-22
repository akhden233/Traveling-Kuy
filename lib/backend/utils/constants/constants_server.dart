// API base Url
const String baseUrl = 'http://localhost:5000';

// API Endpoints
const String authEndpoint = "$baseUrl/auth";
const String bookingEndpoint = "$baseUrl/booking";
const String paymentEndpoint = "$baseUrl/payment";
const String notificationEndpoint = "$baseUrl/notification";
const String destinationEndpoint = "$baseUrl/destination";

// Key
const String tokenKey = 'auth_token';
const String userIdKey = 'uid';

//  Durasi TO
const Duration apiTO = Duration(seconds: 15);