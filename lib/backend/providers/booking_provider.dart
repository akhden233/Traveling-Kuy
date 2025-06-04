// import 'package:flutter/material.dart';
// import '../models/booking_model.dart' as models;
// import '../services/booking_services.dart';

// class BookingProvider with ChangeNotifier {
//   List<models.Booking> _bookings = [];
//   bool _isLoading = false;
//   String? _error;

//   List<models.Booking> get bookings => _bookings;
//   bool get isLoading => _isLoading;
//   String? get error => _error;

//   Future<void> loadUserBookings(String token) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final data = await BookingServices.getUserBookings(token);
//       _bookings = data.map((json) => models.Booking.fromJson(json)).toList();
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> createBooking({
//     required String destinationId,
//     required DateTime visitDate,
//     required int numberOfVisitors,
//     required String token,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final data = await BookingServices.createBooking(
//         destinationId: destinationId,
//         visitDate: visitDate,
//         numberOfVisitors: numberOfVisitors,
//         token: token,
//       );
      
//       final newBooking = models.Booking.fromJson(data);
//       _bookings.add(newBooking);
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> cancelBooking(String bookingId, String token) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       await BookingServices.cancelBooking(bookingId, token);
//       final index = _bookings.indexWhere((b) => b.id == bookingId);
//       if (index != -1) {
//         _bookings[index] = _bookings[index].copyWith(
//           status: models.BookingStatus.cancelled,
//         );
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> modifyBooking({
//     required String bookingId,
//     required DateTime visitDate,
//     required int numberOfVisitors,
//     required String token,
//   }) async {
//     _isLoading = true;
//     _error = null;
//     notifyListeners();

//     try {
//       final data = await BookingServices.modifyBooking(
//         bookingId: bookingId,
//         visitDate: visitDate,
//         numberOfVisitors: numberOfVisitors,
//         token: token,
//       );
      
//       final updatedBooking = models.Booking.fromJson(data);
//       final index = _bookings.indexWhere((b) => b.id == bookingId);
//       if (index != -1) {
//         _bookings[index] = updatedBooking;
//       }
//     } catch (e) {
//       _error = e.toString();
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// }
