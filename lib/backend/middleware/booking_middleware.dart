import '../models/booking_model.dart';
import '../models/destination_model.dart';

class BookingMiddleware {
  static bool validateBookingData({
    required DateTime visitDate,
    required int numberOfVisitors,
    required Destination destination,
  }) {
    // Validasi tanggal kunjungan
    if (visitDate.isBefore(DateTime.now())) {
      throw Exception('Tanggal kunjungan tidak valid');
    }

    // Validasi jumlah pengunjung
    if (numberOfVisitors <= 0) {
      throw Exception('Jumlah pengunjung harus lebih dari 0');
    }

    // Validasi status destinasi
    if (!destination.is_active) {
      throw Exception('Destinasi tidak tersedia saat ini');
    }

    return true;
  }

  static double calculateTotalPrice({
    required bool isPackage,
    required int numberOfVisitors,
    required Destination destination,
  }) {
    // Pilih paket
    final basePrice = isPackage 
    ? destination.price["Package"] 
    : destination.price["Only-Ticket"];

    if (basePrice == null) {
      throw ArgumentError("Price should be of type double");
    }
    return basePrice * numberOfVisitors;
  }

  static bool canCancelBooking(Booking booking) {
    // Booking hanya bisa dibatalkan jika statusnya pending atau confirmed
    return booking.status == BookingStatus.pending ||
        booking.status == BookingStatus.confirmed;
  }

  static bool canModifyBooking(Booking booking) {
    // Booking hanya bisa dimodifikasi jika statusnya pending
    return booking.status == BookingStatus.pending;
  }

  static String generateBookingReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'BK$timestamp$random';
  }

  static Map<String, dynamic> prepareBookingData({
    required String uid,
    required String destination_id,
    required DateTime visitDate,
    required int numberOfVisitors,
    required bool isPackage,
    required double totalPrice,
  }) {
    return {
      'userId': uid,
      'destinationId': destination_id,
      'visitDate': visitDate.toIso8601String(),
      'numberOfVisitors': numberOfVisitors,
      'isPackage': isPackage,
      'totalPrice': totalPrice,
      'status': BookingStatus.pending.name,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
