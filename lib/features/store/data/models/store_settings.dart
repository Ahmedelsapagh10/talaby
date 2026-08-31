import 'package:cloud_firestore/cloud_firestore.dart';

class StoreSettings {
  const StoreSettings({
    this.currencyCode = 'EGP',
    this.currencyMinorDigits = 2,
    this.stockControlEnabled = true,
    this.manualPaymentEnabled = true,
    this.cashOnDeliveryEnabled = true,
  });

  final String currencyCode;
  final int currencyMinorDigits;
  final bool stockControlEnabled;
  final bool manualPaymentEnabled;
  final bool cashOnDeliveryEnabled;

  factory StoreSettings.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final map = doc.data() ?? const <String, dynamic>{};
    return StoreSettings(
      currencyCode: map['currencyCode']?.toString() ?? 'EGP',
      currencyMinorDigits: (map['currencyMinorDigits'] as num?)?.toInt() ?? 2,
      stockControlEnabled: map['stockControlEnabled'] as bool? ?? true,
      manualPaymentEnabled: map['manualPaymentEnabled'] as bool? ?? true,
      cashOnDeliveryEnabled: map['cashOnDeliveryEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() => {
    'currencyCode': currencyCode,
    'currencyMinorDigits': currencyMinorDigits,
    'stockControlEnabled': stockControlEnabled,
    'manualPaymentEnabled': manualPaymentEnabled,
    'cashOnDeliveryEnabled': cashOnDeliveryEnabled,
    'public': true,
  };
}
