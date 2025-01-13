import 'dart:typed_data';
import 'package:event_ticket/models/user.dart';
import 'package:flutter/material.dart';

class PickAvatar extends StatelessWidget {
  const PickAvatar(
    this.user, {
    super.key,
    this.radius = 30,
    this.onTap,
    this.selectedImageBytes,
    this.showCamera = false,
  });

  final User? user;
  final double radius;
  final VoidCallback? onTap;
  final Uint8List? selectedImageBytes; // Thay File bằng Uint8List
  final bool showCamera;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: _getBackgroundImage(),
            child: _buildChild(context),
          ),
          if (showCamera)
            Positioned.fill(
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 50,
                ),
              ),
            ),
        ],
      ),
    );
  }

  ImageProvider? _getBackgroundImage() {
    if (selectedImageBytes != null) {
      return MemoryImage(selectedImageBytes!); // Hiển thị từ Uint8List
    }
    if (user?.avatar != null && user!.avatar!.isNotEmpty) {
      return NetworkImage(user!.avatar!); // Hiển thị từ URL
    }
    return null;
  }

  Widget? _buildChild(BuildContext context) {
    // Nếu đã có ảnh được chọn, không hiển thị child
    if (selectedImageBytes != null) return null;

    // Nếu có camera và không có ảnh, hiển thị icon camera
    if (showCamera && user?.avatar == null) {
      return Icon(Icons.camera_alt, size: radius * 0.7);
    }

    // Nếu có avatar, xử lý loading state
    if (user?.avatar != null && user!.avatar!.isNotEmpty) {
      return FutureBuilder<void>(
        future: precacheImage(NetworkImage(user!.avatar!), context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildInitialOrIcon();
          } else if (snapshot.hasError) {
            return _buildInitialOrIcon();
          }
          return const SizedBox();
        },
      );
    }

    // Fallback về initial hoặc icon
    return _buildInitialOrIcon();
  }

  Widget _buildInitialOrIcon() {
    if (user?.name != null && user!.name!.isNotEmpty) {
      return Text(
        user!.name![0].toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }
    return Icon(
      Icons.person,
      size: radius * 0.8,
      color: Colors.white,
    );
  }
}
