import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

class TicketCard extends StatelessWidget {
  const TicketCard({required this.ticket, super.key});

  final Ticket ticket;

  void onCalendar() {
    print('onCalendar');
  }

  @override
  Widget build(BuildContext context) {
    final isTicketFree =
        ticket.event?.price == null || ticket.event?.price == 0.0;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header với mã đặt chỗ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ticket.bookingCode}',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.event, color: Colors.white),
                  onPressed: onCalendar,
                  tooltip: 'Add reminder to calendar',
                ),
              ],
            ),
          ),

          // Nội dung chi tiết vé
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên sự kiện
                Text(
                  ticket.event?.name ?? "N/A",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Thông tin chi tiết
                _buildTicketInfoRow(
                  icon: Icons.calendar_today,
                  text: ticket.event!.date!.toDDMMYYYY(),
                ),
                const SizedBox(height: 8),
                _buildTicketInfoRow(
                  icon: Icons.location_on,
                  text: ticket.event?.location ?? "N/A",
                ),
                if (!isTicketFree) ...[
                  const SizedBox(height: 8),
                  _buildTicketInfoRow(
                    icon: Icons.monetization_on,
                    text: ticket.event?.price?.toCurrency() ?? "N/A",
                  ),
                ],
                const SizedBox(height: 16),

                // Trạng thái vé
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusChip(
                      context,
                      label: ticket.status?.name ?? "N/A",
                      color: ticket.status == TicketStatus.booked
                          ? Colors.green
                          : Colors.red,
                    ),
                    if (!isTicketFree)
                      _buildStatusChip(
                        context,
                        label: ticket.paymentStatus?.name ?? "N/A",
                        color: ticket.paymentStatus == PaymentStatus.paid
                            ? Colors.green
                            : Colors.orange,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 14,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(BuildContext context,
      {required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelMedium!
            .copyWith(color: Colors.white),
      ),
    );
  }
}
