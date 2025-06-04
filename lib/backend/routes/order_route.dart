import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import '../services/order_service.dart';

final _orderService = OrderService();

class orderRouter {
  Router get router {
    final router = Router();

    router.post('/create', (Request req) async {
      final payload = await req.readAsString();
      final data = Uri.splitQueryString(payload);
      final orderId = await _orderService.createOrder(data);

      return Response.ok(
        jsonEncode({
          'message': 'Order created successfully',
          'order_id': orderId,
        }),
      );
    });

    // Legacy route for manual payment upload - currently not used
    // router.post('/upload-payment', (Request request) async{
    //   final queryParams = request.url.queryParameters;
    //   final orderId = int.parse(queryParams['order_id']!);

    //   final file = File('uploads/payment_${orderId}.jpg');
    //   final sink = file.openWrite();
    //   await request.read().forEach(sink.add);
    //   await sink.close();

    //   await _orderService.uploadPayment(orderId, file.path);

    //   return Response.ok(jsonEncode({'message': 'Payment uploaded'}));
    // });

    router.get('/generate-tickets', (Request request) async {
      await _orderService.generateTicketIfApproved();
      return Response.ok('Tickets generated');
    });

    router.get('/my-tickets/<userId>', (Request request, String userId) async {
      final tickets = await _orderService.getUserTickets(int.parse(userId));
      return Response.ok(tickets.toString());
    });

    router.post('/midtrans/charge', (Request request) async {
      try {
        final payload = jsonDecode(await request.readAsString());
        final midtransResponse = await _orderService.createMidtransTransaction(
          payload,
        );
        return Response.ok(
          jsonEncode(midtransResponse),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    router.post('/midtrans/notification', (Request request) async {
      try {
        final notification = jsonDecode(await request.readAsString());
        await _orderService.handleMidtransNotification(notification);
        return Response.ok(
          jsonEncode({'message': 'Notification processed'}),
          headers: {'Content-Type': 'application/json'},
        );
      } catch (e) {
        return Response.internalServerError(
          body: jsonEncode({'error': e.toString()}),
          headers: {'Content-Type': 'application/json'},
        );
      }
    });

    // router.get('/user/<userId>', (Request req, String userId) async {
    //   final orders = await _orderService.getUserOrders(int.parse(userId));
    //   return Response.ok(jsonEncode(orders));
    // });

    // router.post('/approve/<orderId>', (Request req, String orderId) async {
    //   await _orderService.updateOrderStatus(int.parse(orderId), 'approved');
    //   return Response.ok(jsonEncode({'message': 'Order approved'}));
    // });

    // router.post('/payment/submit', (Request req) async {
    //   final payload = jsonDecode(await req.readAsString());
    //   await _orderService.createPayment(payload);
    //   return Response.ok(
    //     jsonEncode({'message': 'Payment submitted successfully'}),
    //   );
    // });

    // router.post('/payment/verify/<paymentId>', (
    //   Request req,
    //   String paymentId,
    // ) async {
    //   final payload = jsonDecode(await req.readAsString());
    //   final status = payload['status'];
    //   if (status == null || (status != 'approved' && status != 'rejected')) {
    //     return Response(400, body: jsonEncode({'error': 'Invalid status'}));
    //   }
    //   await _orderService.updatePaymentStatus(int.parse(paymentId), status);

    //   // Update order status accordingly
    //   final payment = await _orderService.getPaymentByOrderId(
    //     int.parse(paymentId),
    //   );
    //   if (payment != null) {
    //     final orderId = payment['order_id'];
    //     if (status == 'approved') {
    //       await _orderService.updateOrderStatus(orderId, 'paid');
    //       // TODO: trigger notification to user with ticket
    //     } else if (status == 'rejected') {
    //       await _orderService.updateOrderStatus(orderId, 'payment_failed');
    //       // TODO: trigger notification to user about payment failure
    //     }
    //   }

    //   return Response.ok(jsonEncode({'message': 'Payment status updated'}));
    // });

    return router;
  }
}
