import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  // Kiểm tra khả năng sử dụng NFC
  Future<bool> isNfcAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  // Bắt đầu quét NFC
  Future<void> startNfcScan(
      {required Function(String) onStudentIdDetected,
      required Function(String) onError}) async {
    try {
      await NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Giải mã thông tin từ thẻ NFC
            Ndef? ndef = Ndef.from(tag);
            if (ndef == null) {
              onError('Thẻ không tương thích với NDEF');
              return;
            }

            // Lấy payload từ bản ghi đầu tiên
            final records = ndef.cachedMessage?.records;
            if (records == null || records.isEmpty) {
              onError('Không tìm thấy bản ghi NDEF');
              return;
            }

            final payload = records.first.payload;
            final studentId = _decodeTextPayload(payload);
            if (studentId.isNotEmpty) {
              onStudentIdDetected(studentId);
            } else {
              onError('Không thể giải mã mã số sinh viên');
            }
          } catch (e) {
            onError('Lỗi xử lý NFC: $e');
          }
        },
      );
    } catch (e) {
      onError('Không thể bắt đầu phiên NFC: $e');
    }
  }

  // Giải mã payload dạng văn bản từ thẻ NFC
  String _decodeTextPayload(Uint8List payload) {
    try {
      final languageCodeLength = payload[0] & 0x3F; // Độ dài mã ngôn ngữ
      final text =
          String.fromCharCodes(payload.sublist(1 + languageCodeLength));
      return text;
    } catch (e) {
      return '';
    }
  }

  // Dừng quét NFC
  Future<void> stopNfcScan() async {
    try {
      await NfcManager.instance.stopSession();
    } catch (e) {
      print('Lỗi khi dừng phiên NFC: $e');
    }
  }
}
