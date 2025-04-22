enum PaymentStatus {
  pending,
  processing,
  completed,
  failed,
  refunded
}

enum PaymentMethod {
  bankTransfer,
  eWallet,
}

class Payment {
  final String id;
  final String bookingId;
  final double amount;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? transactionDetails;
  final String? proofOfPayment;
  final String? errorMessage;

  Payment({
    required this.id,
    required this.bookingId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.transactionDetails,
    this.proofOfPayment,
    this.errorMessage,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      bookingId: json['bookingId'],
      amount: json['amount'].toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == json['method'],
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      transactionDetails: json['transactionDetails'],
      proofOfPayment: json['proofOfPayment'],
      errorMessage: json['errorMessage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'amount': amount,
      'method': method.toString(),
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'transactionDetails': transactionDetails,
      'proofOfPayment': proofOfPayment,
      'errorMessage': errorMessage,
    };
  }

  Payment copyWith({
    String? id,
    String? bookingId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? transactionDetails,
    String? proofOfPayment,
    String? errorMessage,
  }) {
    return Payment(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      transactionDetails: transactionDetails ?? this.transactionDetails,
      proofOfPayment: proofOfPayment ?? this.proofOfPayment,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
