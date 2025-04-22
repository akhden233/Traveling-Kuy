import 'dart:convert';

class Destination {
  final int destination_id;
  final String name;
  final String imageUrl;
  final String address;
  final double latitude;
  final double longitude;
  final String description;
  final Map<String, double> price;
  final bool is_active;
  final DateTime created_at;
  final DateTime updated_at;

  Destination({
    required this.destination_id,
    required this.name,
    required this.imageUrl,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.price,
    required this.is_active,
    required this.created_at,
    required this.updated_at,
  });

  factory Destination.fromJson(Map<String, dynamic> json) {
    final priceMap = Map<String, double>.from(
      (json['price'] ??{}).map(
        (key, value) => MapEntry(key, (value as num).toDouble()),
      ),
    );

    return Destination(
      destination_id: json['destination_id'] ?? 0,
      name: json['name'] ?? '',
      imageUrl: json['image_url'] ?? '',
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      price: priceMap,
      is_active: json['is_active'] == 1 || json['is_active'] == true,
      created_at: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updated_at: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'destination_id': destination_id,
      'name': name,
      'image_url': imageUrl,
      'description': description,
      'price' : jsonEncode(price),
      'latitude': latitude,
      'longitude': longitude,
      'is_active' : is_active ? 1:0,
      'created_at' : created_at.toIso8601String(),
      'updated_at' : updated_at.toIso8601String(),
    };
  }
}
