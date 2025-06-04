class Payment {
  final int id;
  final int orderId;
  final int userId;
  final String file_path;
  final String status;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.file_path,
    required this.status,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      orderId: json['order_id'],
      userId: json['user_id'],
      file_path: json['file_path'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'user_id': userId,
    'file_path': file_path,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };
}
