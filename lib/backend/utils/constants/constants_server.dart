// API base Url
const String baseUrl = 'http://127.0.0.1:5000';

// API Endpoints
const String authEndpoint = "$baseUrl/auth";
const String bookingEndpoint = "$baseUrl/booking";
const String paymentEndpoint = "$baseUrl/payment";
const String notificationEndpoint = "$baseUrl/notification";
const String destinationEndpoint = "$baseUrl/destination";
const String userProfileEndpoint = "$baseUrl/user";

// Key
const String tokenKey = 'auth_token';
const String userIdKey = 'uid';

//  Durasi TO
const Duration apiTO = Duration(seconds: 30);