/// Backend ticket generation code snippet for review
/// This example uses the 'pdf' package in Dart to generate a PDF ticket.
/// You can integrate this function into your OrderService after payment approval.

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class TicketGenerator {
  Future<File> generateTicketPdf({
    required int orderId,
    required String userName,
    required String destinationName,
    required DateTime bookingDate,
    required int quantity,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Text('Traveling Kuy Ticket', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Text('Order ID: $orderId'),
                pw.Text('Name: $userName'),
                pw.Text('Destination: $destinationName'),
                pw.Text('Booking Date: ${bookingDate.toLocal().toString().split(' ')[0]}'),
                pw.Text('Quantity: $quantity'),
                pw.SizedBox(height: 20),
                pw.Text('Thank you for your purchase!', style: pw.TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );

    // Save the PDF file to a temporary directory or desired location
    final output = File('tickets/ticket_order_$orderId.pdf');
    await output.create(recursive: true);
    await output.writeAsBytes(await pdf.save());

    return output;
  }
}

/// Integration snippet in OrderService after payment approval:
///
/// await TicketGenerator().generateTicketPdf(
///   orderId: orderId,
///   userName: userName,
///   destinationName: destinationName,
///   bookingDate: bookingDate,
///   quantity: quantity,
/// );
///
/// Then send notification to user with the ticket file or link.
