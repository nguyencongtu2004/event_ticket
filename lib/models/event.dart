import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/category.dart';
import 'package:event_ticket/models/conversasion.dart';
import 'package:event_ticket/models/user.dart';

class Event {
  final String id;
  final String? name;
  final List<String> images;
  final String? description;
  final List<Category> category;
  final String? location;
  final DateTime? date;
  final double? price;
  final User? createdBy;
  final List<User> attendees;
  final List<User> collaborators;
  final int? maxAttendees;
  final int? ticketsSold;
  final EventStatus? status;
  final Conversasion? conversation;

  Event({
    required this.id,
    this.name,
    this.images = const [],
    this.description,
    this.category = const [],
    this.location,
    this.date,
    this.price,
    this.createdBy,
    this.attendees = const [],
    this.collaborators = const [],
    this.maxAttendees,
    this.ticketsSold,
    this.status,
    this.conversation,
  });

  // Factory method
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      name: json['name'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],
      description: json['description'],
      category: json['category'] != null
          ? List<Category>.from(
              json['category'].map((x) => Category.fromJson(x)))
          : [],
      location: json['location'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      price: json['price'] != null
          ? double.tryParse(json['price'].toString())
          : null,
      createdBy:
          json['createdBy'] != null ? User.fromJson(json['createdBy']) : null,
      attendees: json['attendees'] != null
          ? (json['attendees'] as List).map((e) => User.fromJson(e)).toList()
          : [],
      collaborators: json['collaborators'] != null
          ? (json['collaborators'] as List)
              .map((e) => User.fromJson(e))
              .toList()
          : [],
      maxAttendees: json['maxAttendees'],
      ticketsSold: json['ticketsSold'],
      status: EventStatus.values.cast<EventStatus?>().firstWhere(
            (e) => e?.name == json['status'],
            orElse: () => null,
          ),
      conversation: json['conversation'] != null
          ? Conversasion.fromJson(json['conversation'])
          : json['conversationId'] != null
              ? Conversasion(id: json['conversationId'])
              : null,
    );
  }

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      'description': description,
      'category': category.map((c) => c.toJson()).toList(),
      'location': location,
      'date': date?.toIso8601String(),
      'price': price,
      'createdBy': createdBy?.toJson(),
      'attendees': attendees.map((a) => a.toJson()).toList(),
      'collaborators': collaborators.map((c) => c.toJson()).toList(),
      'maxAttendees': maxAttendees,
      'ticketsSold': ticketsSold,
      'status': status?.name,
      'conservation': conversation,
    };
  }

  // Create a new Event with updated values
  Event copyWith({
    String? id,
    String? name,
    List<String>? images,
    String? description,
    List<Category>? category,
    String? location,
    DateTime? date,
    double? price,
    User? createdBy,
    List<User>? attendees,
    List<User>? collaborators,
    int? maxAttendees,
    int? ticketsSold,
    EventStatus? status,
    Conversasion? conversation,
  }) {
    return Event(
      id: this.id,
      name: name ?? this.name,
      images: images ?? this.images,
      description: description ?? this.description,
      category: category ?? this.category,
      location: location ?? this.location,
      date: date ?? this.date,
      price: price ?? this.price,
      createdBy: createdBy ?? this.createdBy,
      attendees: attendees ?? this.attendees,
      collaborators: collaborators ?? this.collaborators,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      ticketsSold: ticketsSold ?? this.ticketsSold,
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
    );
  }

  @override
  String toString() {
    return 'Event(id: $id, name: $name, images: $images, description: $description, '
        'category: $category, location: $location, date: $date, price: $price, '
        'createdBy: $createdBy, attendees: $attendees, collaborators: $collaborators, '
        'maxAttendees: $maxAttendees, ticketsSold: $ticketsSold, status: $status, '
        'conversation: $conversation)';
  }

  @override
  int get hashCode => Object.hash(
        id,
        name,
        images,
        description,
        category,
        location,
        date,
        price,
        createdBy,
        attendees,
        collaborators,
        maxAttendees,
        ticketsSold,
        status,
        conversation,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event &&
        other.id == id &&
        other.name == name &&
        other.images == images &&
        other.description == description &&
        other.category == category &&
        other.location == location &&
        other.date == date &&
        other.price == price &&
        other.createdBy == createdBy &&
        other.attendees == attendees &&
        other.collaborators == collaborators &&
        other.maxAttendees == maxAttendees &&
        other.ticketsSold == ticketsSold &&
        other.status == status &&
        other.conversation == conversation;
  }
}
