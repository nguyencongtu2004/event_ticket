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
      backgroundColor: Colors.grey.shade300,
      child: ClipOval(
        child: user?.avatar != null
            ? FutureBuilder<void>(
                future: precacheImage(NetworkImage(user!.avatar!), context),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildInitialOrIcon(),
                        FadeInImage.assetNetwork(
                          placeholder: 'assets/images/transparent.png',
                          image: user!.avatar!,
                          fit: BoxFit.cover,
                          fadeInDuration: const Duration(milliseconds: 5000),
                          imageErrorBuilder: (context, error, stackTrace) {
                            return _buildInitialOrIcon();
                          },
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    return _buildInitialOrIcon();
                  }
                  return Image.network(
                    user!.avatar!,
                    fit: BoxFit.cover,
                    width: radius * 2,
                    height: radius * 2,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildInitialOrIcon();
                    },
                  );
                },
              )
            : _buildInitialOrIcon(),
      ),
    );
  }

  Widget _buildInitialOrIcon() {
    if (user?.name != null && user!.name!.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        color: Colors.grey.shade300,
        alignment: Alignment.center,
        child: Text(
          user!.name![0].toUpperCase(),
          style: TextStyle(
            fontSize: radius * 0.8,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Container(
      width: radius * 2,
      height: radius * 2,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: Icon(Icons.person, size: radius),
    );
  }
}
