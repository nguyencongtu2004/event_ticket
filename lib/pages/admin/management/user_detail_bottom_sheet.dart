import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/user.dart';
import 'package:event_ticket/wrapper/avatar.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class UserDetailBottomSheet extends StatelessWidget {
  final User user;

  const UserDetailBottomSheet({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'User Details',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Avatar(user, radius: 50),
        const SizedBox(height: 16),
        _buildDetailItem(context, 'Name', user.name ?? 'N/A'),
        _buildDetailItem(context, 'Email', user.email ?? 'N/A'),
        _buildDetailItem(context, 'Phone', user.phone ?? 'N/A'),
        _buildDetailItem(context, 'Student ID', user.studentId ?? 'N/A'),
        _buildDetailItem(context, 'Role', user.role?.value ?? 'N/A'),
        _buildDetailItem(
            context, 'Gender', user.gender?.name.capitalized ?? 'N/A'),
        _buildDetailItem(context, 'University', user.university?.name ?? 'N/A'),
        _buildDetailItem(context, 'Faculty', user.faculty?.name ?? 'N/A'),
        _buildDetailItem(context, 'Major', user.major?.name ?? 'N/A'),
        _buildDetailItem(context, 'Events Created',
            user.eventsCreated?.length.toString() ?? '0'),
        _buildDetailItem(context, 'Tickets Bought',
            user.ticketsBought?.length.toString() ?? '0'),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ).p(16).scrollVertical();
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 32),
          Text(
            value,
            textAlign: TextAlign.end,
          ).expand(),
        ],
      ),
    );
  }
}
