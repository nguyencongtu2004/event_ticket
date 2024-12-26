enum Genders { male, female, other }

enum Roles { admin, eventCreator, ticketBuyer }

enum EventStatus { active, completed, cancelled }

enum TicketStatus { booked, cancelled, checkedIn, transferring, transferred }

enum PaymentStatus { pending, paid, failed }

enum ConversasionType { private, public }

enum TransferStatus { pending, success, cancelled }

enum NotificationType {
  paymentSuccess,
  checkIn,
  newEvent,
  eventUpdate,
  ticketBooking,
  ticketCancel,
  ticketTransfer,
  commentReply,
  unknown
}

enum ChartIntervals { day, week, month, year }

//////////////////////////
// get value

extension GendersExtension on Genders {
  String get value {
    switch (this) {
      case Genders.male:
        return 'male';
      case Genders.female:
        return 'female';
      case Genders.other:
        return 'other';
    }
  }
}

extension EventStatusExtension on EventStatus {
  String get value {
    switch (this) {
      case EventStatus.active:
        return 'active';
      case EventStatus.cancelled:
        return 'cancelled';
      case EventStatus.completed:
        return 'completed';
    }
  }
}

extension RolesExtension on Roles {
  String get value {
    switch (this) {
      case Roles.admin:
        return 'admin';
      case Roles.eventCreator:
        return 'event_creator';
      case Roles.ticketBuyer:
        return 'ticket_buyer';
    }
  }
}

extension PaymentStatusExtension on PaymentStatus {
  String get value {
    switch (this) {
      case PaymentStatus.pending:
        return 'pending';
      case PaymentStatus.paid:
        return 'paid';
      case PaymentStatus.failed:
        return 'failed';
    }
  }
}

extension TicketStatusExtension on TicketStatus {
  String get value {
    switch (this) {
      case TicketStatus.booked:
        return 'booked';
      case TicketStatus.cancelled:
        return 'cancelled';
      case TicketStatus.checkedIn:
        return 'checked-in';
      case TicketStatus.transferring:
        return 'transferring';
      case TicketStatus.transferred:
        return 'transferred';
    }
  }
}

extension ConversasionTypeExtension on ConversasionType {
  String get value {
    switch (this) {
      case ConversasionType.private:
        return 'private';
      case ConversasionType.public:
        return 'public';
    }
  }
}

extension TransferStatusExtension on TransferStatus {
  String get value {
    switch (this) {
      case TransferStatus.pending:
        return 'pending';
      case TransferStatus.success:
        return 'success';
      case TransferStatus.cancelled:
        return 'cancelled';
    }
  }
}

extension NotificationTypeExtension on NotificationType {
  String get value {
    switch (this) {
      case NotificationType.paymentSuccess:
        return 'payment_success';
      case NotificationType.checkIn:
        return 'check_in';
      case NotificationType.newEvent:
        return 'new_event';
      case NotificationType.eventUpdate:
        return 'event_update';
      case NotificationType.ticketBooking:
        return 'ticket_booking';
      case NotificationType.ticketCancel:
        return 'ticket_cancel';
      case NotificationType.ticketTransfer:
        return 'ticket_transfer';
      case NotificationType.commentReply:
        return 'comment_reply';
      case NotificationType.unknown:
        return 'unknown';
    }
  }
}

extension ChartIntervalsExtension on ChartIntervals {
  String get value {
    switch (this) {
      case ChartIntervals.day:
        return 'day';
      case ChartIntervals.week:
        return 'week';
      case ChartIntervals.month:
        return 'month';
      case ChartIntervals.year:
        return 'year';
    }
  }
}