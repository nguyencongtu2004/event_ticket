import 'package:event_ticket/models/event.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class ParticipantScreen extends StatefulWidget {
  const ParticipantScreen({super.key, required this.event});
  final Event event;

  @override
  State<ParticipantScreen> createState() => _ParticipantScreenState();
}

class _ParticipantScreenState extends State<ParticipantScreen> {
  // Future<List<User>> getAttendees() async {
  //   final response = await EventRequest().getEventAttendees(widget.event.id);
  //   if (response.statusCode == 200) {
  //     return (response.data as List).map((e) => User.fromJson(e)).toList();
  //   } else {
  //     context.showAnimatedToast(response.data['message']);
  //     return [];
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: TicketScaffold(
        title: 'Participants',
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(text: 'Collaborators'),
                Tab(text: 'Attendees'),
              ],
            ),
            TabBarView(
              children: [
                // Tab 1: Collaborators
                ListView(
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Created by:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ).px(16),
                    ListTile(
                      leading: Avatar(widget.event.createdBy, radius: 25),
                      title: Text(widget.event.createdBy?.name ?? 'No name'),
                      subtitle: Text(
                          widget.event.createdBy?.studentId ?? 'No student ID'),
                    ),
                    Text(
                      'Collaborators:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ).px(16),
                    ...widget.event.collaborators
                        .map((collaborator) => ListTile(
                              leading: Avatar(collaborator, radius: 25),
                              title: Text(collaborator.name ?? 'No name'),
                              subtitle: Text(
                                  collaborator.studentId ?? 'No student ID'),
                            )),
                  ],
                ),

                // Tab 2: Attendees
                if (widget.event.attendees.isEmpty)
                  const Center(child: Text('No attendees yet')).expand()
                else
                  ListView(
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        'Attendees:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ).px(16),
                      ...widget.event.attendees.map((attendee) => ListTile(
                            leading: Avatar(attendee, radius: 25),
                            title: Text(attendee.name ?? 'No name'),
                            subtitle:
                                Text(attendee.studentId ?? 'No student ID'),
                          )),
                    ],
                  )
              ],
            ).expand(),
          ],
        ),
      ),
    );
  }
}
