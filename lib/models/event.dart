import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/category.dart';
import 'package:event_ticket/models/user.dart';

class Event {
  final String id;
  final String name;
  final List<String> images;
  final String description;
  final List<Category> category;
  final String location;
  final DateTime date;
  final double price;
  final User createdBy;
  final List<String> attendees;
  final List<String> collaborators;
  final int maxAttendees;
  final int ticketsSold;
  final EventStatus status;
  final String? conservation;

  Event({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.price,
    required this.createdBy,
    required this.attendees,
    required this.collaborators,
    required this.maxAttendees,
    required this.ticketsSold,
    required this.status,
    this.conservation,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['_id'],
      name: json['name'],
      images: List<String>.from(json['images']),
      description: json['description'],
      category: List<Category>.from(
          json['category'].map((x) => Category.fromJson(x))),
      location: json['location'],
      date: DateTime.parse(json['date']),
      price: json['price'].toDouble(),
      createdBy: User.fromJson(json['createdBy']),
      attendees:
          json['attendees'] != null ? List<String>.from(json['attendees']) : [],
      collaborators: List<String>.from(json['collaborators']),
      maxAttendees: json['maxAttendees'],
      ticketsSold: json['ticketsSold'],
      status: EventStatus.values.firstWhere((e) => e.name == json['status']),
      conservation: json['conservation'],
    );
  }
}
