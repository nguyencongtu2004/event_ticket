import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/pages/admin/management/register_form_bottom_sheet.dart';
import 'package:event_ticket/pages/admin/management/user_detail_bottom_sheet.dart';
import 'package:event_ticket/pages/admin/management/user_form_bottom_sheet.dart';
import 'package:event_ticket/requests/user_request.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:velocity_x/velocity_x.dart';

class AccountManagementScreen extends ConsumerStatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  ConsumerState<AccountManagementScreen> createState() =>
      _AccountManagementScreenState();
}

class _AccountManagementScreenState
    extends ConsumerState<AccountManagementScreen> {
  final _userRequest = UserRequest();
  late Future<List<User>> _usersFuture;
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  Future<List<User>> _loadUsers() async {
    final response = await _userRequest.getAllUsers();
    if (response.statusCode == 200) {
      setState(() {
        _isFirstLoad = false;
      });
      return List<User>.from(response.data.map((e) => User.fromJson(e)));
    } else {
      setState(() {
        _isFirstLoad = false;
      });
      context.showAnimatedToast(response.data['message']);
      return [];
    }
  }

  Future<void> _refreshUsers() async {
    setState(() {
      _usersFuture = _loadUsers();
    });
  }

  void onDeleteUser(User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final response = await _userRequest.deleteUser(user.id);
      if (response.statusCode == 200) {
        setState(() {
          _usersFuture = _loadUsers();
        });
      }
      if (mounted) {
        context.showAnimatedToast(response.data['message']);
      }
    }
  }

  void onSeeDetails(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UserDetailBottomSheet(user: user),
    );
  }

  void onEditUser(User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UserFormBottomSheet(
        user: user,
        onSuccess: _refreshUsers,
      ),
    );
  }

  void onRegisterUser() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RegisterFormBottomSheet(
        onSuccess: _refreshUsers,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: 'Account Management',
      floatingActionButton: FloatingActionButton(
        heroTag: 'addUser',
        onPressed: onRegisterUser,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (_isFirstLoad &&
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final users = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: _refreshUsers,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        user.avatar != null ? NetworkImage(user.avatar!) : null,
                    child: user.avatar == null
                        ? Text(user.name?[0].toUpperCase() ?? '')
                        : null,
                  ),
                  title: Text(user.name ?? ''),
                  subtitle: Text(user.email ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => onEditUser(user),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => onDeleteUser(user),
                      ),
                    ],
                  ),
                  onTap: () => onSeeDetails(user),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
