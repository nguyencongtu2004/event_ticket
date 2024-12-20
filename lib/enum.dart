enum Genders { male, female, other }

enum Roles { admin, eventCreator, ticketBuyer }

enum EventStatus { active, completed, cancelled }

enum TicketStatus { booked, cancelled, checkedIn, transferring, transferred }

enum PaymentStatus { pending, paid, failed }

enum ConversasionType { private, public }

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
