import 'package:event_ticket/enum.dart';
import 'package:event_ticket/models/ticket.dart';
import 'package:event_ticket/providers/ticket_provider.dart';
import 'package:event_ticket/requests/ticket_request.dart';
import 'package:event_ticket/router/routes.dart';
import 'package:event_ticket/extensions/extension.dart';
import 'package:event_ticket/wrapper/ticket_scafford.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _ticketRequest = TicketRequest();
  Ticket? ticket;
  bool isQrFullScreen = false;
  final TextEditingController _cancelReasonController = TextEditingController();
  final FocusNode _cancelReasonFocusNode = FocusNode();

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

  Future<void> onCancelTicket() async {
    // show confirm dialog
    _cancelReasonFocusNode.requestFocus();
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Cancel'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to cancel this ticket?'),
            TextField(
              controller: _cancelReasonController,
              focusNode: _cancelReasonFocusNode,
              decoration: const InputDecoration(
                labelText: 'Cancel Reason',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              if (!_cancelReasonController.text.isNotEmpty) {
                _cancelReasonController.text = 'No entered reason';
              }
              Navigator.pop(context, true);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldCancel != null && shouldCancel) {
      final cancelReason = _cancelReasonController.text;
      try {
        final response =
            await _ticketRequest.cancelTicket(ticket!.id, cancelReason);
        if (response.statusCode == 200) {
          setState(() {
            ticket = ticket?.copyWith(status: TicketStatus.cancelled);
          });
          ref.invalidate(ticketProvider);
          // show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ticket cancelled successfully'),
            ),
          );
        }
      } catch (e, st) {
        print('Error in TicketDetailScreen.onCancelTicket: $e');
        print(st);
      }
    }
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
                _buildQrCode(context),
                _buildTicketInformation(context),
                _buildPaymentInformation(context),
                _buildEventInformation(context),

                // cancel button
                if (ticket!.status != TicketStatus.cancelled &&
                    ticket!.status != TicketStatus.checkedIn)
                  ElevatedButton(
                    onPressed: () => onCancelTicket(),
                    child: const Text('Cancel Ticket'),
                  ).p16(),
              ],
            ).scrollVertical(),
    );
  }

  Widget _buildQrCode(BuildContext context) {
    return Container(
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
    ).centered();
  }

  Widget _buildTicketInformation(BuildContext context) {
    return Column(
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
          Text('Created At: ${ticket!.createdAt!.toFullDate()}'),
        Text('Buyer: ${ticket!.buyer?.name ?? "N/A"}'),
        Text('Email: ${ticket!.buyer?.email ?? "N/A"}'),
      ],
    ).p16();
  }

  Widget _buildPaymentInformation(BuildContext context) {
    return ticket?.paymentData == null
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Payment Information',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                  'Amount: ${ticket!.paymentData!.amount!.toDouble().toCurrency()}'),
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
            ],
          ).p16();
  }

  Widget _buildEventInformation(BuildContext context) {
    return ticket!.event == null
        ? const SizedBox.shrink()
        : Column(
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
                            Text('Date: ${ticket!.event!.date!.toFullDate()}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Text('Location: ${ticket!.event!.location}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Text('Status: ${ticket!.event!.status!.value}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About Event:',
                              style: Theme.of(context).textTheme.titleMedium,
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
          ).p(16);
  }

  @override
  void dispose() {
    _cancelReasonController.dispose();
    super.dispose();
  }
}
