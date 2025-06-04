import 'dart:convert';
import 'package:http/http.dart' as http;
import '../db/db.dart';
import '../config.dart';

class OrderService {
  Future<int> createOrder(Map<String, dynamic> data) async {
    final conn = await dbConn.getConnection();
    final results = await conn?.query('''
      INSERT INTO orders (user_id, destination_id, package_type, booking_date, quantity, status, created_at, updated_at) 
      VALUES (?, ?, ?, ?, ?, 'pending', NOW(), NOW())
      ''', [
        data['user_id'],
        data['destination_id'],
        data['packageType'],
        data['booking_date'],
        data['quantity'],
      ],
    );
    return results!.insertId!;
  }

  Future<void> uploadPayment(int orderId, String file_path) async {
    final conn = await dbConn.getConnection();
    if(conn == null){
      throw Exception('Database Connected');
    }

    await conn.query('''
      INSERT INTO payment (order_id, file_path, uploaded_at)
      VALUES (?, ?, NOW())
    ''',
    [orderId, file_path]);
  }

  Future<void> generateTicketIfApproved() async {
    final conn = await dbConn.getConnection();
    final results = await conn?.query('''
    SELECT id FROM orders WHERE status = 'approved' AND id NOT IN (SELECT order_id FROM tickets)
    ''');

    for (var row in results!) {
      final orderId = row[0];
      final ticketCode = "TK${DateTime.now().millisecondsSinceEpoch}";
      await conn?.query('''
        INSERT INTO tickets (order_id, ticket_code, issued_at)
        VALUES (?, ?, NOW())
      ''',
      [orderId, ticketCode]);
    }
  }

  Future<List<Map<String, dynamic>>> getUserTickets(int userId) async {
    final conn = await dbConn.getConnection();
    final results = await conn?.query('''
      SELECT t.ticket_code, t.issued_at, d.name AS destination 
      FROM tickets t
      JOIN orders o ON o.id = t.order_id
      JOIN destinations d ON d.id = o.destination_id
      WHERE o.user_id = ?
    ''', [userId]);

    return results!.map((r) => {
      'ticket_code': r[0],
      'issued_at': r[1],
      'destination': r[2],
    })
    .toList();
  }

  Future<Map<String, dynamic>> createMidtransTransaction(Map<String, dynamic> data) async {
    final url = Uri.parse('\$midtransApiUrl/charge');
    final headers = {
      'Content-Type' : 'application/json',
      'Accept' : 'application/json',
      'Authorization' : 'Basic ${base64Encode(utf8.encode(midtransServerKey + ':'))}'
    };

    final body = jsonEncode(data);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create Midtrans transaction: \${response.body}');
    }
  }

  Future<void> handleMidtransNotification(Map<String, dynamic> notification) async {
    final orderId = int.parse(notification['order_id'].toString());
    final transactionStatus = notification['transaction_status'];
    final fraudStatus = notification['fraud_status'];

    String newStatus = 'pending';

    if (transactionStatus == 'capture') {
      if (fraudStatus == 'challenge'){
        newStatus = 'challenge';
      } else if (fraudStatus == 'accept') {
        newStatus = 'paid';
      }
    } else if (transactionStatus == 'settlement') {
      newStatus = 'paid';
    } else if (transactionStatus == 'deny' || transactionStatus == 'cancel' || transactionStatus ==  'expire') {
      newStatus = 'payment_failed';
    }

    final conn = await dbConn.getConnection();
    await conn?.query(
      'UPDATE orders SET status = ?, updated_at = NOW() WHERE id = ?',
      [newStatus, orderId],
    );
  }

//   Future<List<Map<String, dynamic>>> getUserOrders(int userId) async {
//     final conn = await dbConn.getConnection();
//     final result = await conn!.query(
//       'SELECT * FROM orders WHERE user_id = ? ORDER BY created_at DESC',
//       [userId],
//     );
//     return result.map((row) => {
//       'id': row['id'],
//       'destination_id': row['destination_id'],
//       'packageType': row['package_type'],
//       'booking_date': row['booking_date'].toString(),
//       'quantity': row['quantity'],
//       'status': row['status'],
//     }).toList();
//   }

//   Future<void> updateOrderStatus(int orderId, String status) async {
//     final conn = await dbConn.getConnection();
//     await conn?.query(
//       'UPDATE orders SET status = ?, updated_at = NOW() WHERE id = ?',
//       [status, orderId],
//     );
//   } 

//   Future<void> createPayment(Map<String, dynamic> data) async {
//     final conn = await dbConn.getConnection();
//     await conn?.query(
//       'INSERT INTO payments (order_id, user_id, payment_screenshot_url, status, created_at) VALUES (?, ?, ?, ?, NOW())',
//       [
//         data['order_id'],
//         data['user_id'],
//         data['payment_screenshot_url'],
//         'pending',
//       ],
//     );
//   }

//   Future<Map<String, dynamic>?> getPaymentByOrderId(int orderId) async {
//     final conn = await dbConn.getConnection();
//     final result = await conn?.query(
//       'SELECT * FROM payments WHERE order_id = ?',
//       [orderId],
//     );
//     if (result == null || result.isEmpty) {
//       return null;
//     }
//     final row = result.first;
//     return {
//       'id': row['id'],
//       'order_id': row['order_id'],
//       'user_id': row['user_id'],
//       'payment_screenshot_url': row['payment_screenshot_url'],
//       'status': row['status'],
//       'created_at': row['created_at'].toString(),
//     };
//   }

//   Future<void> updatePaymentStatus(int paymentId, String status) async {
//     final conn = await dbConn.getConnection();
//     await conn?.query(
//       'UPDATE payments SET status = ?, updated_at = NOW() WHERE id = ?',
//       [status, paymentId],
//     );
//   }
}
