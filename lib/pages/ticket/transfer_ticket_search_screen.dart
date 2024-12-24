import 'dart:async';
import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:event_ticket/requests/user_request.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class TransferTicketSearchScreen extends ConsumerStatefulWidget {
  const TransferTicketSearchScreen({super.key, this.ticket});

  final Ticket? ticket;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TransferTicketSearchScreenState();
}

class _TransferTicketSearchScreenState
    extends ConsumerState<TransferTicketSearchScreen> {
  final _userRequest = UserRequest();
  Timer? _debounce;
  List<User> searchSuggestions = [];
  final _ticketRequest = TicketRequest();

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchSuggestions = [];
      });
      return;
    }
    final suggestions = await _userRequest.searchUser(
      query: query,
      role: Roles.ticketBuyer,
    );
    setState(() {
      searchSuggestions = suggestions;
    });
  }

  void _onSearchChanged(String query) {
    // Debounce logic
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
    });
  }

  Future<void> _onTransferTicket(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Transfer'),
        content: Text('Do you want to transfer the ticket to ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      print('Ticket transferred to ${user.name}');
      // Thực hiện hành động chuyển vé
      final response =
          await _ticketRequest.transferTicket(widget.ticket!.id, user.id);
      if (response.statusCode != 200) {
        context
            .showAnimatedToast('Failed to transfer ticket: ${response.data}');
        return;
      }
      context.pop(response.data is Map ? response.data['message'] : 'Success');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Transfer Ticket',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          SearchBar(
            onChanged: _onSearchChanged,
            hintText: 'Search for a user...',
            leading: const Icon(Icons.search).p(12),
          ).p16(),

          // Suggestions dropdown
          if (searchSuggestions.isNotEmpty)
            ListView.builder(
              itemCount: searchSuggestions.length,
              itemBuilder: (context, index) {
                final user = searchSuggestions[index];
                return ListTile(
                  leading: Avatar(user, radius: 25),
                  title: Text(user.name ?? 'No name'),
                  subtitle: Text(user.studentId ?? 'No student ID'),
                  onTap: () => _onTransferTicket(user),
                );
              },
            ).expand(),
        ],
      ),
    );
  }
}
