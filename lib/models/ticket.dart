import 'payment_data.dart';

class Ticket {
  String id;
  String? eventId;
  String? buyerId;
  String? bookingCode;
  String? qrCode;
  String? status;
  String? paymentStatus;
  PaymentData? paymentData;

  Ticket({
    required this.id,
    this.eventId,
    this.buyerId,
    this.bookingCode,
    this.qrCode,
    this.status,
    this.paymentStatus,
    this.paymentData,
  });

  Ticket copyWith({
    String? id,
    String? eventId,
    String? buyerId,
    String? bookingCode,
    String? qrCode,
    String? status,
    String? paymentStatus,
    PaymentData? paymentData,
  }) {
    return Ticket(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      buyerId: buyerId ?? this.buyerId,
      bookingCode: bookingCode ?? this.bookingCode,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentData: paymentData ?? this.paymentData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'eventId': eventId,
      'buyerId': buyerId,
      'bookingCode': bookingCode,
      'qrCode': qrCode,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentData': paymentData,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] as String,
      eventId: json['eventId'] as String?,
      buyerId: json['buyerId'] as String?,
      bookingCode: json['bookingCode'] as String?,
      qrCode: json['qrCode'] as String?,
      status: json['status'] as String?,
      paymentStatus: json['paymentStatus'] as String?,
      paymentData: json['paymentData'] == null
          ? null
          : PaymentData.fromJson(json['paymentData'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() =>
      "Ticket(id: $id,eventId: $eventId,buyerId: $buyerId,bookingCode: $bookingCode,qrCode: $qrCode,status: $status,paymentStatus: $paymentStatus,paymentData: $paymentData)";

  @override
  int get hashCode => Object.hash(id, eventId, buyerId, bookingCode, qrCode,
      status, paymentStatus, paymentData);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ticket &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          eventId == other.eventId &&
          buyerId == other.buyerId &&
          bookingCode == other.bookingCode &&
          qrCode == other.qrCode &&
          status == other.status &&
          paymentStatus == other.paymentStatus &&
          paymentData == other.paymentData;
}
