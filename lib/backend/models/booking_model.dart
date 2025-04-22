enum BookingStatus {
  pending,
  confirmed,
  paid,
  completed,
  cancelled
}

class Booking {
  final String id; // id booking
  final String uid; // id user
  final String destinationId; // id destinasi
  final DateTime visitDate;
  final int numberOfVisitors;
  final bool isPackage;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? paymentDetails;
  final List<String>? visitorNames;
  // final String? specialRequests;

  Booking({
    required this.id,
    required this.uid,
    required this.destinationId,
    required this.visitDate,
    required this.numberOfVisitors,
    required this.isPackage,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.paymentDetails,
    this.visitorNames,
    // this.specialRequests,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      uid: json['uid'],
      destinationId: json['destinationId'],
      visitDate: DateTime.parse(json['visitDate']),
      numberOfVisitors: json['numberOfVisitors'],
      isPackage: json['isPackage'],
      totalPrice: json['totalPrice'].toDouble(),
      status: BookingStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'])
          : null,
      paymentDetails: json['paymentDetails'],
      visitorNames: json['visitorNames'] != null 
          ? List<String>.from(json['visitorNames'])
          : null,
      // specialRequests: json['specialRequests'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'destinationId': destinationId,
      'visitDate': visitDate.toIso8601String(),
      'numberOfVisitors': numberOfVisitors,
      'isPackage': isPackage,
      'totalPrice': totalPrice,
      'status': status.toString(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'paymentDetails': paymentDetails,
      'visitorNames': visitorNames,
      // 'specialRequests': specialRequests,
    };
  }

  Booking copyWith({
    String? id,
    String? uid,
    String? destinationId,
    DateTime? visitDate,
    int? numberOfVisitors,
    bool? isPackage,
    double? totalPrice,
    BookingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? paymentDetails,
    List<String>? visitorNames,
    // String? specialRequests,
  }) {
    return Booking(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      destinationId: destinationId ?? this.destinationId,
      visitDate: visitDate ?? this.visitDate,
      numberOfVisitors: numberOfVisitors ?? this.numberOfVisitors,
      isPackage: isPackage ?? this.isPackage,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      visitorNames: visitorNames ?? this.visitorNames,
      // specialRequests: specialRequests ?? this.specialRequests,
    );
  }
}
