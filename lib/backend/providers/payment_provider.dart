import 'package:flutter/material.dart';
import '../models/payment_model.dart' as models;
import '../services/payment_services.dart';

class PaymentProvider extends ChangeNotifier {
  List<models.Payment> _payments = [];
  bool _isLoading = false;
  String? _error;

  List<models.Payment> get payments => _payments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserPayments(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await PaymentServices.getUserPayments(token);
      _payments = data.map((json) => models.Payment.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPayment({
    required String bookingId,
    required String amount,
    required String paymentMethod,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await PaymentServices.createPayment(
        bookingId: bookingId,
        amount: amount,
        paymentMethod: paymentMethod,
        token: token,
      );
      
      final newPayment = models.Payment.fromJson(data);
      _payments.add(newPayment);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getPaymentStatus(String paymentId, String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await PaymentServices.getPaymentStatus(paymentId, token);
      final updatedPayment = models.Payment.fromJson(data);
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index != -1) {
        _payments[index] = updatedPayment;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
