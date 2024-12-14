enum Genders { male, female, other }

enum Roles { admin, eventCreator, ticketBuyer }

enum EventStatus { active, completed, cancelled }

enum TicketStatus { booked, cancelled, checkedIn }

enum PaymentStatus { pending, paid, failed }

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
      default:
        return '';
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
      default:
        return '';
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
      default:
        return '';
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
      default:
        return '';
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
      default:
        return '';
    }
  }
}
