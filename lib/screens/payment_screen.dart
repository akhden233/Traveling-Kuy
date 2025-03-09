import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final Map<String, String> destination;
  final String packageType;
  final String price;

  const PaymentScreen({
    super.key,
    required this.destination,
    required this.packageType,
    required this.price,
  });

  void _handlePaymentSelection(BuildContext context, String paymentMethod) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("You selected $paymentMethod"),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        Navigator.of(context).push(_createRoute(paymentMethod));
      }
    });
  }

  Route _createRoute(String paymentMethod) {
    return PageRouteBuilder(
      pageBuilder:
          (context, animation, secondaryAnimation) =>
              PaymentConfirmationScreen(paymentMethod: paymentMethod),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  destination["image"]!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                destination["title"]!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Paket: $packageType",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                destination["description"] ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 10),
              Text(
                "Harga: $price",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(47, 73, 44, 1),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "CHOOSE PAYMENT",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildPaymentOption(context, "BCA", "assets/BCA.png"),
              _buildPaymentOption(context, "Mandiri", "assets/mandiri.png"),
              _buildPaymentOption(context, "BNI", "assets/BNI.png"),
              _buildPaymentOption(context, "BRI", "assets/BRI.png"),
              const SizedBox(height: 10),
              const Text(
                "You can make transfers using ATM / M-Banking / Internet Banking",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 20),
              _buildPaymentOption(context, "Indomaret", "assets/indomaret.png"),
              _buildPaymentOption(context, "Alfamart", "assets/alfamart.png"),
              _buildPaymentOption(
                context,
                "Visa, Mastercard, Rupay & more",
                "assets/card.png",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(
    BuildContext context,
    String title,
    String imagePath,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 40, color: Colors.red);
          },
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: () => _handlePaymentSelection(context, title),
      ),
    );
  }
}

// Halaman Konfirmasi Pembayaran
class PaymentConfirmationScreen extends StatelessWidget {
  final String paymentMethod;

  const PaymentConfirmationScreen({super.key, required this.paymentMethod});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "You have chosen to pay with:",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Text(
              paymentMethod,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Confirm"),
            ),
          ],
        ),
      ),
    );
  }
}
