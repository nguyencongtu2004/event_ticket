class PaymentData {
  String? partnerCode;
  String? orderId;
  String? requestId;
  int? amount;
  int? responseTime;
  String? message;
  int? resultCode;
  String? payUrl;
  String? deeplink;
  String? qrCodeUrl;

  PaymentData({
    this.partnerCode,
    this.orderId,
    this.requestId,
    this.amount,
    this.responseTime,
    this.message,
    this.resultCode,
    this.payUrl,
    this.deeplink,
    this.qrCodeUrl,
  });

  PaymentData copyWith({
    String? partnerCode,
    String? orderId,
    String? requestId,
    int? amount,
    int? responseTime,
    String? message,
    int? resultCode,
    String? payUrl,
    String? deeplink,
    String? qrCodeUrl,
  }) {
    return PaymentData(
      partnerCode: partnerCode ?? this.partnerCode,
      orderId: orderId ?? this.orderId,
      requestId: requestId ?? this.requestId,
      amount: amount ?? this.amount,
      responseTime: responseTime ?? this.responseTime,
      message: message ?? this.message,
      resultCode: resultCode ?? this.resultCode,
      payUrl: payUrl ?? this.payUrl,
      deeplink: deeplink ?? this.deeplink,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'partnerCode': partnerCode,
      'orderId': orderId,
      'requestId': requestId,
      'amount': amount,
      'responseTime': responseTime,
      'message': message,
      'resultCode': resultCode,
      'payUrl': payUrl,
      'deeplink': deeplink,
      'qrCodeUrl': qrCodeUrl,
    };
  }

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      partnerCode: json['partnerCode'] as String?,
      orderId: json['orderId'] as String?,
      requestId: json['requestId'] as String?,
      amount: json['amount'] as int?,
      responseTime: json['responseTime'] as int?,
      message: json['message'] as String?,
      resultCode: json['resultCode'] as int?,
      payUrl: json['payUrl'] as String?,
      deeplink: json['deeplink'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String?,
    );
  }

  @override
  String toString() =>
      "PaymentData(partnerCode: $partnerCode,orderId: $orderId,requestId: $requestId,amount: $amount,responseTime: $responseTime,message: $message,resultCode: $resultCode,payUrl: $payUrl,deeplink: $deeplink,qrCodeUrl: $qrCodeUrl)";

  @override
  int get hashCode => Object.hash(partnerCode, orderId, requestId, amount,
      responseTime, message, resultCode, payUrl, deeplink, qrCodeUrl);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentData &&
          runtimeType == other.runtimeType &&
          partnerCode == other.partnerCode &&
          orderId == other.orderId &&
          requestId == other.requestId &&
          amount == other.amount &&
          responseTime == other.responseTime &&
          message == other.message &&
          resultCode == other.resultCode &&
          payUrl == other.payUrl &&
          deeplink == other.deeplink &&
          qrCodeUrl == other.qrCodeUrl;
}
