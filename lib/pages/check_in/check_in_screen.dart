import 'dart:async';

import 'package:event_ticket/extensions/context_extesion.dart';
import 'package:event_ticket/pages/check_in/widget/check_list.dart';
import 'package:event_ticket/providers/checked_in_ticket_provider.dart';
import 'package:event_ticket/service/nfc_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nfc_manager/nfc_manager.dart';

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
  bool _isNfcMode = false;
  final _nfcService = NfcService();

  // Khóa thởi gian debounce
  Timer? _debounceTimer;
  String? _lastScannedCode;
  bool _isProcessing = false; // Thêm trạng thái xử lý

  // Thêm method để kiểm tra khả năng đọc NFC
  Future<bool> _checkNfcAvailability() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    return isAvailable;
  }

  // Phương thức quét NFC để lấy Student ID
  Future<void> _startNfcScan() async {
    bool isAvailable = await _nfcService.isNfcAvailable();
    if (!isAvailable) {
      context.showAnimatedToast('NFC is not available on this device');
      return;
    }
    _nfcService.startNfcScan(
      onStudentIdDetected: (studentId) async {
        print('NFC StudentID: $studentId');
        final message = await ref
            .read(checkedInTicketProvider.notifier)
            .checkInByStudentId(studentId);
        if (message != null) {
          context.showAnimatedToast(message);
        }
      },
      onError: (error) {
        context.showAnimatedToast(error);
      },
    );
  }

  // Thêm nút chuyển đổi giữa QR và NFC
  Widget _buildNfcToggleButton() {
    return IconButton(
      icon: Icon(_isNfcMode ? Icons.qr_code : Icons.nfc),
      onPressed: () async {
        if (!_isNfcMode) {
          bool nfcAvailable = await _checkNfcAvailability();
          if (nfcAvailable) {
            setState(() {
              _isNfcMode = true;
              _controller.stop(); // Dừng quét QR
            });
            _startNfcScan();
          } else {
            context.showAnimatedToast('NFC is not available on this device');
          }
        } else {
          setState(() {
            _isNfcMode = false;
            _controller.start(); // Bắt đầu quét QR lại
          });
        }
      },
    );
  }

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
    // Ngăn chặn quét liên tục và sử dụng debounce
    if (_isProcessing || (_debounceTimer?.isActive ?? false)) return;

    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      _isProcessing = true;

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
          context.showAnimatedToast(message);
        }
      }

      // Đặt lại trạng thái sau 1 giây
      await Future.delayed(const Duration(seconds: 1), () {
        _isProcessing = false;
      });
    });
  }

  void _showCheckedInList(BuildContext context) {
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
      builder: (context) => const CheckList(),
    );
  }

  Widget _buildPausedState(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pause_circle_outline,
              size: 100,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            Text(
              'Scanning Paused',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap "Resume" to continue scanning QR codes',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _toggleScanning,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: Text(
                'Resume Scanning',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen = constraints.maxWidth > 900;

        return Scaffold(
          appBar: AppBar(
            title: Text(_isNfcMode ? 'NFC Check-In' : 'QR Check-In'),
            actions: [
              _buildNfcToggleButton(),
              if (!isLargeScreen)
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () => _showCheckedInList(context),
                ),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                child: _isNfcMode
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.nfc,
                              size: 200,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Hold your NFC card near the device',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: _buildPausedState(context),
                          ),
                          MobileScanner(
                            controller: _controller,
                            onDetect: _handleBarcode,
                          ),
                          if (_isScanning)
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              height: 80,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                    onPressed: _toggleScanning,
                                    child:
                                        Text(_isScanning ? 'Pause' : 'Resume'),
                                  ).w(120).py(12).centered(),
                                ],
                              ),
                            )
                        ],
                      ),
              ),
              if (isLargeScreen) const CheckList().expand().w(400),
            ],
          ),
        );
      },
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
