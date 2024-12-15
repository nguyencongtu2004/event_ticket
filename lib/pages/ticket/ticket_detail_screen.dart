import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/ulties/format.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  final String ticketId;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  final _ticketRequest = TicketRequest();
  Ticket? ticket;
  bool isQrFullScreen = false;

  @override
  void initState() {
    super.initState();
    getTicketDetail();
  }

  Future<void> getTicketDetail() async {
    try {
      final response = await _ticketRequest.getTicketDetail(widget.ticketId);

      if (response.statusCode == 200) {
        setState(() {
          ticket = Ticket.fromJson(response.data as Map<String, dynamic>);
        });
      }
    } catch (e, st) {
      print('Error in TicketDetailScreen.getTicketDetail: $e');
      print(st);
    }
  }

  void onEventTap() {
    context.push(Routes.getEventDetailPath(ticket!.event!.id));
  }

  Future<void> onBuyerTap() async {
    final Uri url = Uri.parse(ticket!.paymentData!.deeplink!);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Could not launch $url: $e');
    }
  }

  void onQrCodeTap() {
    setState(() {
      isQrFullScreen = true;
    });
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // qr container
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 5,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: QrImageView(
                data: ticket!.bookingCode!,
                version: QrVersions.auto,
                size: MediaQuery.of(context).size.width * 0.7,
              ),
            ),
            const SizedBox(height: 16),

            // instructions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    spreadRadius: 5,
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    ticket!.bookingCode!,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please show this code to the check-in staff',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        isQrFullScreen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return TicketScaffold(
      title: ticket?.event?.name != null
          ? 'Ticket to ${ticket?.event?.name}'
          : 'Ticket Details',
      body: ticket == null
          ? const CircularProgressIndicator().centered()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // QR Code
                Container(
                  height: 200,
                  width: 200,
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: ticket != null && !isQrFullScreen ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: ticket != null
                            ? QrImageView(
                                data: ticket!.bookingCode!,
                                version: QrVersions.auto,
                                size: 200.0,
                              )
                            : const SizedBox.shrink(),
                      ),
                      AnimatedOpacity(
                        opacity: isQrFullScreen ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(Icons.qr_code, size: 150),
                      ),
                    ],
                  ).onTap(onQrCodeTap),
                ).centered(),

                // Center booking code
                if (ticket?.bookingCode != null)
                  Text(
                    ticket!.bookingCode!,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ).centered(),
                const SizedBox(height: 16),

                // Ticket Information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ticket Information',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text('Booking Code: ${ticket!.bookingCode}'),
                    Text('Status: ${ticket!.status!.value}'),
                    if (ticket!.cancelReason != null)
                      Text('Cancel Reason: ${ticket!.cancelReason ?? "N/A"}'),
                    if (ticket!.createdAt != null)
                      Text(
                          'Created At: ${Format.formatDDMMYYYYHHMM(ticket!.createdAt!)}'),
                    Text('Buyer: ${ticket!.buyer?.name ?? "N/A"}'),
                    Text('Email: ${ticket!.buyer?.email ?? "N/A"}'),
                  ],
                ).p16(),

                // Payment Information (placeholder)
                if (ticket?.paymentData != null)
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Information',
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                            'Amount: ${Format.formatPrice(ticket!.paymentData!.amount!.toDouble())}'),
                        if (ticket!.paymentData!.resultCode != 0) ...[
                          Text(
                              'Payment Status: ${ticket!.paymentData!.message ?? "N/A"}'),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => onBuyerTap(),
                            child: const Text('Pay Now'),
                          ).w(double.infinity).px(16),
                        ] else
                          const Text('Payment Status: Success'),
                      ]).p16(),

                // Event Information
                if (ticket!.event != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Information',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (ticket!.event!.images.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  ticket!.event!.images.first,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ).h(300),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.event),
                                    const SizedBox(width: 8),
                                    Text('Name: ${ticket!.event!.name}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.date_range),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Date: ${Format.formatDDMMYYYY(ticket!.event!.date!)}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on),
                                    const SizedBox(width: 8),
                                    Text(
                                        'Location: ${ticket!.event!.location}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'About Event:',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(ticket!.event!.description ?? 'N/A'),
                                  ],
                                ).w(double.infinity),
                              ],
                            ).p(16),
                          ],
                        ),
                      ).onTap(onEventTap),
                    ],
                  ).p(16),
              ],
            ).scrollVertical(),
    );
  }
}
