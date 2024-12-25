import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/requests/user_request.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final _userRequest = UserRequest();
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final response = await _userRequest.getAllUsers();
    if (response.statusCode == 200) {
      users = (response.data as List).map((e) => User.fromJson(e)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return const TicketScaffold(
      body: Center(
        child: Text('Account Management'),
      ),
    );
  }
}
