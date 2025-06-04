// Frontend Flutter screen for "My Tickets" to display and download tickets
// Suggestions for your review and integration

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyTicketsScreen extends StatefulWidget {
  final int userId;

  MyTicketsScreen({super.key, required this.userId});

  @override
  _MyTicketsScreenState createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<dynamic> tickets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTickets();
  }

  Future<void> fetchTickets() async {
    final url = Uri.parse('http://yourserver.com/order/user/${widget.userId}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        tickets = data['data'] ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      // Handle error
    }
  }

  void openTicket(String ticketUrl) {
    // Implement logic to open or download the ticket PDF/image
    // For example, use url_launcher package to open URL in browser
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Tickets')),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : tickets.isEmpty
              ? Center(child: Text('No tickets found'))
              : ListView.builder(
                itemCount: tickets.length,
                itemBuilder: (context, index) {
                  final ticket = tickets[index];
                  return ListTile(
                    title: Text('Order ID: ${ticket['id']}'),
                    subtitle: Text('Status: ${ticket['status']}'),
                    trailing:
                        ticket['ticket_url'] != null
                            ? IconButton(
                              icon: Icon(Icons.picture_as_pdf),
                              onPressed: () => openTicket(ticket['ticket_url']),
                            )
                            : null,
                  );
                },
              ),
    );
  }
}
