import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants/constants_server.dart';
import '../models/destination_model.dart';

class DestinationServices {
  // Get semua destinasi
  static Future<List<Map<String, dynamic>>> getAllDestinations() async {
    try {
      final response = await http.get(
        Uri.parse('$destinationEndpoint/'),
      ).timeout(apiTO);

      final data = jsonDecode(response.body);
      final result = data['data'] ?? [];

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(result);
      } else {
        throw Exception(data['error'] ?? 'Failed to get destinations');
      }
    } catch (e) {
      print('[getAllDestination] error: $e');
      throw Exception('Failed to Connect to server: $e');
    }
  }

  // get Detail dari destinasi
  static Future<Map<String, dynamic>> getDestinationDetail(int destination_id) async {
    try {
      final response = await http.get(
        Uri.parse('$destinationEndpoint/$destination_id'),
      );

      final data = jsonDecode(response.body).cast<String, dynamic>();

      if (response.statusCode == 200) {
        return data;
      }else {
        throw Exception(data ['error'] ?? 'Failed to get destination detail');
      }
    } catch (e) {
      throw Exception('Failed to Connect to server: $e');
    }
  }

  // Search destinasi based-on keyword
  static Future<List<Map<String, dynamic>>> searchDestinations(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$destinationEndpoint/search?q=$keyword'),
        );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(data['error'] ?? 'Failed to search destinations');
      }
    } catch (e) {
      throw Exception('Failed to Connect to server: $e');
    }
  }

  // // get destinasi based-on kategori
  // static Future<List<Map<String, dynamic>>> getDestinationsByCategory(String category) async {
  //  try {
  //    final response =  await http.get(
  //     Uri.parse('$destinationEndpoint/category/$category'),
  //     );

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       return List<Map<String, dynamic>>.from(data);
  //     } else {
  //       throw Exception(data['error'] ?? 'Failed to get destinations by category');
  //     }
  //  } catch (e) {
  //    throw Exception('Failed to Connect to server: $e');
  //  } 
  // }

  // // get destinasi based-on popularity
  // static Future<List<Map<String, dynamic>>> getPopularDestinations() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$destinationEndpoint/popular'),
  //       );

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       return List<Map<String, dynamic>>.from(data);
  //     } else {
  //       throw Exception(data['error'] ?? 'Failed to get popular destinations');
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to Connect to Server');
  //   }
  // }
}