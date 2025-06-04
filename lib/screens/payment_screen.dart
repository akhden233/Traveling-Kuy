import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../backend/models/destination_model.dart';
import '../backend/utils/formatters.dart';
import '../backend/utils/constants/constants_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final Destination destination;
  final String packageType;
  final String price;
  final int userId;

  const PaymentScreen({
    super.key,
    required this.destination,
    required this.packageType,
    required this.price,
    required this.userId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isSubmitting = false;
  DateTime? _selectedDate;
  String? _paymentUrl;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _startMidtransPayment() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking date')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final orderPayload = {
        'user_id': widget.userId,
        'destination_id': widget.destination.destination_id,
        'packageType': widget.packageType,
        'booking_date': _selectedDate!.toIso8601String(),
        'quantity': 1,
      };

      final orderResponse = await http.post(
        Uri.parse('$orderEndpoint/create'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: orderPayload.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
            .join('&'),
      );

      if (orderResponse.statusCode != 200) {
        throw Exception('Failed to create order: ${orderResponse.body}');
      }

      final orderData = jsonDecode(orderResponse.body);
      final orderId = orderData['order_id'];

      final midtransPayload = {
        'payment_type': 'bank_transfer',
        'transaction_details': {
          'order_id': orderId.toString(),
          'gross_amount': double.tryParse(widget.price) ?? 0,
        },
        'bank_transfer': {
          'bank': 'bca',
        },
        'customer_details': {
          'first_name': 'Customer',
          'email': 'customer@example.com',
        },
      };

      final midtransResponse = await http.post(
        Uri.parse('$orderEndpoint/midtrans/charge'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(midtransPayload),
      );

      if (midtransResponse.statusCode != 200) {
        throw Exception('Failed to initiate Midtrans payment: ${midtransResponse.body}');
      }

      final midtransData = jsonDecode(midtransResponse.body);
      final redirectUrl = midtransData['redirect_url'] ?? midtransData['actions']?[0]?['url'];

      if (redirectUrl == null) {
        throw Exception('No redirect URL received from Midtrans');
      }

      if (kIsWeb) {
        if (await canLaunchUrl(redirectUrl)) {
          await launchUrl(redirectUrl);
        } else {
          throw Exception('Could not launch payment URL');
        }
      } else {
        setState(() {
          _paymentUrl = redirectUrl;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget buildInAppWebView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Midtrans Payment'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _paymentUrl = null;
            });
          },
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_paymentUrl!)),
        onLoadStop: (controller, url) {
          if (url.toString().contains('your_redirect_success_url')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment successful')),
            );
            setState(() {
              _paymentUrl = null;
            });
          } else if (url.toString().contains('your_redirect_failure_url')) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment failed or cancelled')),
            );
            setState(() {
              _paymentUrl = null;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_paymentUrl != null && !kIsWeb) {
      return buildInAppWebView();
    }

    final dateText = _selectedDate == null
        ? 'Select booking date'
        : DateFormat('yyyy-MM-dd').format(_selectedDate!);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.destination.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Package: ${widget.packageType}',
              style: const TextStyle(fontSize: 18, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              'Price: ${Formatters.currencyFormat.format(double.tryParse(widget.price) ?? 0)}',
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(47, 73, 44, 1),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: Text(dateText),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _startMidtransPayment,
              child: _isSubmitting
                  ? const CircularProgressIndicator()
                  : const Text('Pay with Midtrans'),
            ),
          ],
        ),
      ),
    );
  }
}
