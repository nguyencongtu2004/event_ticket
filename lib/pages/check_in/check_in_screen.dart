import 'dart:async';

import 'package:event_ticket/providers/checked_in_ticket_provider.dart';
import 'package:event_ticket/ulties/format.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen>
    with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
  );
  StreamSubscription<Object?>? _subscription;
  bool _isScanning = true;

  // Khóa thời gian debounce
  Timer? _debounceTimer;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = _controller.barcodes.listen(_handleBarcode);
    unawaited(_controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = _controller.barcodes.listen(_handleBarcode);

        unawaited(_controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(_controller.stop());
    }
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        _controller.start();
      } else {
        _controller.stop();
      }
    });
  }

  Future<void> _handleBarcode(BarcodeCapture barcode) async {
    if (_debounceTimer?.isActive ?? false) return; // Khóa thời gian debounce

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final barcodes = barcode.barcodes;
      for (var element in barcodes) {
        // Bỏ qua nếu trùng
        if (element.displayValue == _lastScannedCode) continue;
        _lastScannedCode = element.displayValue;

        print('QR Code Found: ${element.displayValue}');
        final message = await ref
            .read(checkedInTicketProvider.notifier)
            .checkInTicket(element.displayValue!);

        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      }
    });
  }

  void _showCheckedInList(BuildContext context, List checkedInTicket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      showDragHandle: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      builder: (context) {
        return checkedInTicket.isEmpty
            ? const Text('No checked-in tickets').py(16).centered()
            : Column(
                children: [
                  Text(
                    'Checked-in tickets',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider().py(4),
                  ListView.builder(
                    itemCount: checkedInTicket.length,
                    itemBuilder: (context, index) {
                      final ticket = checkedInTicket[index];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage:
                              NetworkImage(ticket.buyer?.avatar ?? ''),
                          onBackgroundImageError: (_, __) =>
                              const Icon(Icons.person),
                          child: ticket.buyer?.avatar == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          'Attendee: ${ticket.buyer?.name ?? 'N/A'}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Event: ${ticket.event?.name ?? 'N/A'}'),
                            Text(
                                'Check-in Time: ${Format.formatDDMMYYYYHHMM(ticket.checkInTime!)}'),
                          ],
                        ),
                      );
                    },
                  ).expand(),
                ],
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final checkedInTicket = ref.watch(checkedInTicketProvider).value ?? [];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: const Text('TODO: Check-in Screen Background').centered(),
          ),
          MobileScanner(
            controller: _controller,
            onDetect: (barcodeCapture) {
              for (final barcode in barcodeCapture.barcodes) {
                debugPrint('QR Code Found: ${barcode.rawValue}');
              }
            },
            fit: BoxFit.cover,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _toggleScanning,
                  child: Text(_isScanning ? 'Pause' : 'Resume'),
                ).w(120).py(12).centered(),
                ElevatedButton(
                  onPressed: () => _showCheckedInList(context, checkedInTicket),
                  child: const Text('Show checked-in list'),
                ).py(12).centered(),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await _controller.dispose();
  }
}
