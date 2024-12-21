import 'package:event_ticket/models/user.dart';
import 'package:flutter/material.dart';

class Avatar extends StatelessWidget {
  const Avatar(
    this.user, {
    super.key,
    this.radius = 30,
  });

  final User? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundImage:
          user?.avatar != null ? NetworkImage(user!.avatar!) : null,
      child: user?.avatar != null
          ? FutureBuilder<void>(
              future: precacheImage(NetworkImage(user!.avatar!), context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildInitialOrIcon();
                } else if (snapshot.hasError) {
                  return _buildInitialOrIcon();
                }
                return const SizedBox();
              },
            )
          : _buildInitialOrIcon(),
    );
  }

  Widget _buildInitialOrIcon() {
    if (user?.name != null && user!.name!.isNotEmpty) {
      return Text(
        user!.name![0].toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Icon(Icons.person, size: radius);
  }
}
