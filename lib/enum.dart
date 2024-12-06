enum Genders { male, female, other }

enum Roles { admin, eventCreator, ticketBuyer }

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

enum EventStatus { active, completed, cancelled }
