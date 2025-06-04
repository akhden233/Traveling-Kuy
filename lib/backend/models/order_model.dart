class Order {
  final int id;
  final int userId;
  final int destinationId;
  final String packageType;
  final DateTime bookingDate;
  final int quantity;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.destinationId,
    required this.packageType,
    required this.bookingDate,
    required this.quantity,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      destinationId: json['destination_id'],
      packageType: json['package_type'],
      bookingDate: DateTime.parse(json['booking_date']),
      quantity: json['quantity'],
      status: json['status'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'destination_id': destinationId,
    'package_type': packageType,
    'booking_date': bookingDate.toIso8601String(),
    'quantity': quantity,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
