import 'package:event_ticket/models/user.dart';
import 'package:flutter/material.dart';

class UserInfo extends StatelessWidget {
  final User user;

  const UserInfo({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Avatar tròn với trạng thái loading/lỗi
        ClipOval(
          child: Image.network(
            user.avatar ?? '',
            height: 140,
            width: 140,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 140,
                width: 140,
                child: Icon(Icons.person, size: 140),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 140,
                width: 140,
                child: Icon(Icons.person, size: 140), // Ảnh mặc định khi lỗi
              );
            },
          ),
        ),
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
