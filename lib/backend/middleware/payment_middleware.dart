import '../models/payment_model.dart';
import '../models/booking_model.dart';

class PaymentMiddleware {
  static bool validatePaymentData({
    required double amount,
    required PaymentMethod method,
    required Booking booking,
  }) {
    // Validasi jumlah pembayaran
    if (amount <= 0) {
      throw Exception('Jumlah pembayaran tidak valid');
    }

    // Validasi jumlah pembayaran harus sama dengan total booking
    if (amount != booking.totalPrice) {
      throw Exception('Jumlah pembayaran tidak sesuai dengan total booking');
    }

    // Validasi status booking
    if (booking.status != BookingStatus.confirmed) {
      throw Exception('Booking belum dikonfirmasi');
    }

    return true;
  }

  static String generatePaymentReference() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'PAY$timestamp$random';
  }

  static Map<String, dynamic> preparePaymentData({
    required String bookingId,
    required double amount,
    required PaymentMethod method,
  }) {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'method': method.toString(),
      'status': PaymentStatus.pending.toString(),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  static bool canProcessRefund(Payment payment) {
    // Pembayaran hanya bisa direfund jika statusnya completed
    return payment.status == PaymentStatus.completed;
  }

  static bool validateProofOfPayment(String proofUrl) {
    // Validasi format URL bukti pembayaran
    if (!proofUrl.startsWith('http://') && !proofUrl.startsWith('https://')) {
      throw Exception('Format URL bukti pembayaran tidak valid');
    }

    // Validasi ekstensi file (opsional)
    final validExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];
    final hasValidExtension = validExtensions.any((ext) => 
      proofUrl.toLowerCase().endsWith(ext)
    );

    if (!hasValidExtension) {
      throw Exception('Format file bukti pembayaran tidak didukung');
    }

    return true;
  }

  static Map<String, dynamic> prepareRefundData({
    required String paymentId,
    required String reason,
  }) {
    return {
      'paymentId': paymentId,
      'reason': reason,
      'status': PaymentStatus.refunded.toString(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
