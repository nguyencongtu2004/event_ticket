import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final User user;

  const UserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Avatar(user, radius: 70),
        const SizedBox(height: 12),
        Text(
          user.name ?? 'No name',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
