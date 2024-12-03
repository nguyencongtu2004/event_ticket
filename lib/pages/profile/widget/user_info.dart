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
            user.avatar,
            height: 100,
            width: 100,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                height: 100,
                width: 100,
                child: Icon(Icons.person, size: 100),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(
                height: 100,
                width: 100,
                child: Icon(Icons.person, size: 100), // Ảnh mặc định khi lỗi
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Text(user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            )),
      ],
    );
  }
}
