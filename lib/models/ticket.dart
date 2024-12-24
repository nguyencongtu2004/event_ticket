import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/event.dart';
import 'payment_data.dart';
import 'user.dart'; // Assuming the User class is defined in this file

class Ticket {
  String id;
  Event? event;
  String? bookingCode;
  String? qrCode;
  TicketStatus? status;
  DateTime? createdAt;
  String? cancelReason;
  PaymentStatus? paymentStatus;
  PaymentData? paymentData;
  User? buyer;
  DateTime? checkInTime;

  Ticket({
    required this.id,
    this.event,
    this.bookingCode,
    this.qrCode,
    this.status,
    this.paymentStatus,
    this.paymentData,
    this.createdAt,
    this.cancelReason,
    this.buyer,
    this.checkInTime,
  }) {
    if (paymentData?.resultCode != null && paymentData?.resultCode == 0) {
      paymentStatus = PaymentStatus.paid;
    }
  }

  Ticket copyWith({
    String? id,
    Event? event,
    String? buyerId,
    String? bookingCode,
    String? qrCode,
    TicketStatus? status,
    PaymentStatus? paymentStatus,
    PaymentData? paymentData,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancelReason,
    User? buyer,
    DateTime? checkInTime,
  }) {
    return Ticket(
      id: id ?? this.id,
      event: event ?? this.event,
      bookingCode: bookingCode ?? this.bookingCode,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentData: paymentData ?? this.paymentData,
      createdAt: createdAt ?? this.createdAt,
      cancelReason: cancelReason ?? this.cancelReason,
      buyer: buyer ?? this.buyer,
      checkInTime: checkInTime ?? this.checkInTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'event': event?.toJson(),
      'bookingCode': bookingCode,
      'qrCode': qrCode,
      'status': status?.value,
      'paymentStatus': paymentStatus?.value,
      'paymentData': paymentData?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'cancelReason': cancelReason,
      'buyer': buyer?.toJson(),
      'checkInTime': checkInTime?.toIso8601String(),
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] as String,
      event: json['event'] != null
          ? Event.fromJson(json['event'])
          : (json['eventId'] != null ? Event.fromJson(json['eventId']) : null),
      bookingCode: json['bookingCode'] as String?,
      qrCode: json['qrCode'] as String?,
      status: TicketStatus.values.cast<TicketStatus?>().firstWhere(
            (e) => e?.value == json['status'],
            orElse: () => null,
          ),
      paymentStatus: PaymentStatus.values.cast<PaymentStatus?>().firstWhere(
            (e) => e?.value == json['paymentStatus'],
            orElse: () => null,
          ),
      paymentData: json['paymentData'] == null
          ? null
          : PaymentData.fromJson(json['paymentData'] as Map<String, dynamic>),
      createdAt: DateTime.tryParse(json['createdAt'] ?? ''),
      cancelReason: json['cancelReason'] as String?,
      buyer: json['buyer'] != null ? User.fromJson(json['buyer']) : null,
      checkInTime: DateTime.tryParse(json['checkInTime'] ?? ''),
    );
  }

  @override
  String toString() =>
      "Ticket(id: $id, event: $event, bookingCode: $bookingCode, qrCode: $qrCode, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, cancelReason: $cancelReason, paymentData: $paymentData, buyer: $buyer, checkInTime: $checkInTime)";

  @override
  int get hashCode => Object.hash(id, event, bookingCode, qrCode, status,
      paymentStatus, createdAt, cancelReason, paymentData, buyer, checkInTime);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ticket &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          event == other.event &&
          bookingCode == other.bookingCode &&
          qrCode == other.qrCode &&
          status == other.status &&
          paymentStatus == other.paymentStatus &&
          createdAt == other.createdAt &&
          cancelReason == other.cancelReason &&
          paymentData == other.paymentData &&
          buyer == other.buyer &&
          checkInTime == other.checkInTime;
}
