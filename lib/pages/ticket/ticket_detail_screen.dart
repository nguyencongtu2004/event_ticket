import 'package:event_ticket/enum.dart';
import 'package:event_ticket/extensions/context_extesion.dart';
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
  bool isShowBottomSheet = true;

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
      builder: (BuildContext context) {
        final width = MediaQuery.sizeOf(context).width;
        final height = MediaQuery.sizeOf(context).height;
        final minSize = width < height ? width : height;
        return Dialog(
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
                      color: Colors.black.withValues(alpha: 0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: QrImageView(
                  data: ticket!.bookingCode!,
                  version: QrVersions.auto,
                  size: minSize * 0.7,
                ),
              ),
              const SizedBox(height: 24),

              // instructions
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
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
        );
      },
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
          context.showAnimatedToast('Ticket cancelled successfully!');
        }
      } catch (e, st) {
        print('Error in TicketDetailScreen.onCancelTicket: $e');
        print(st);
      }
    }
  }

  void onTransferTicket() async {
    final message =
        await context.push<String>(Routes.transferTicketSearch, extra: ticket);
    if (message != null) {
      // show success message
      context.showAnimatedToast(message);
      setState(() {
        isShowBottomSheet = false;
      });
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
          : RefreshIndicator(
              onRefresh: () => getTicketDetail(),
              child: ListView(
                //crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildQrCode(context),
                  _buildTicketInformation(context),
                  _buildPaymentInformation(context),
                  _buildEventInformation(context),
                  if (isShowBottomSheet &&
                      ticket!.status == TicketStatus.booked)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // cancel button
                        ElevatedButton(
                          onPressed: () => onCancelTicket(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[500],
                          ),
                          child: const Text(
                            'Cancel Ticket',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ).p16(),

                        // transfer button
                        ElevatedButton(
                          onPressed: onTransferTicket,
                          child: const Text('Transfer Ticket'),
                        ).p16(),
                      ],
                    )
                ],
              ),
            ),
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
            color: Colors.grey.withValues(alpha: 0.2),
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
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow(context,
                  icon: Icons.confirmation_number_outlined,
                  label: 'Booking Code',
                  value: ticket!.bookingCode ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow(context,
                  icon: Icons.check_circle_outline,
                  label: 'Status',
                  value: ticket!.status!.value),
              if (ticket!.cancelReason != null) ...[
                const SizedBox(height: 8),
                _buildInfoRow(context,
                    icon: Icons.cancel_outlined,
                    label: 'Cancel Reason',
                    value: ticket!.cancelReason ?? 'N/A'),
              ],
              const SizedBox(height: 8),
              _buildInfoRow(context,
                  icon: Icons.calendar_today_outlined,
                  label: 'Created At',
                  value: ticket!.createdAt?.toFullDate() ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow(context,
                  icon: Icons.person_outline,
                  label: 'Buyer',
                  value: ticket!.buyer?.name ?? 'N/A'),
              const SizedBox(height: 8),
              _buildInfoRow(context,
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: ticket!.buyer?.email ?? 'N/A'),
            ],
          ).p(16),
        ),
      ],
    ).p(16);
  }

  // Helper method to create consistent info rows
  Widget _buildInfoRow(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
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
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPaymentInfoRow(
                      context,
                      icon: Icons.monetization_on_outlined,
                      label: 'Amount',
                      value:
                          ticket!.paymentData!.amount!.toDouble().toCurrency(),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentInfoRow(
                      context,
                      icon: ticket!.paymentData!.resultCode == 0
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      label: 'Status',
                      value: ticket!.paymentData!.resultCode == 0
                          ? 'Payment Successful'
                          : (ticket!.paymentData!.message ?? 'Payment Failed'),
                      valueColor: ticket!.paymentData!.resultCode == 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ).p(16),
              ),
              if (ticket!.paymentData!.resultCode != 0) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => onBuyerTap(),
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              ],
            ],
          ).p(16);
  }

  // Helper method to create consistent payment info rows
  Widget _buildPaymentInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).primaryColor.withValues(alpha: 0.7),
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    color: valueColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
                            Text(
                                'Location: ${ticket!.event?.location ?? "N/A"}'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on),
                            const SizedBox(width: 8),
                            Text(
                                'Status: ${ticket!.event!.status?.value ?? "N/A"}'),
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
