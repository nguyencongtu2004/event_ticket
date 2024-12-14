import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/event.dart';
import 'payment_data.dart';

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
  });

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
    String? cancelReason,
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
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['_id'] as String,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
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
    );
  }

  @override
  String toString() =>
      "Ticket(id: $id, event: $event, bookingCode: $bookingCode, qrCode: $qrCode, status: $status, paymentStatus: $paymentStatus, createdAt: $createdAt, cancelReason: $cancelReason, paymentData: $paymentData)";

  @override
  int get hashCode => Object.hash(id, event, bookingCode, qrCode, status,
      paymentStatus, createdAt, cancelReason, paymentData);

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
          paymentData == other.paymentData;
}
