import 'package:cloud_firestore/cloud_firestore.dart';

class StoreSettings {
  const StoreSettings({
    this.currencyCode = 'EGP',
    this.currencyMinorDigits = 2,
    this.stockControlEnabled = true,
    this.manualPaymentEnabled = true,
    this.cashOnDeliveryEnabled = true,
    this.bannerEnabled = true,
    this.bannerTitleAr = '',
    this.bannerTitleEn = '',
    this.bannerSubtitleAr = '',
    this.bannerSubtitleEn = '',
    this.bannerImageUrl,
  });

  final String currencyCode;
  final int currencyMinorDigits;
  final bool stockControlEnabled;
  final bool manualPaymentEnabled;
  final bool cashOnDeliveryEnabled;
  final bool bannerEnabled;
  final String bannerTitleAr;
  final String bannerTitleEn;
  final String bannerSubtitleAr;
  final String bannerSubtitleEn;
  final String? bannerImageUrl;

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
      bannerEnabled: map['bannerEnabled'] as bool? ?? true,
      bannerTitleAr: map['bannerTitleAr']?.toString() ?? '',
      bannerTitleEn: map['bannerTitleEn']?.toString() ?? '',
      bannerSubtitleAr: map['bannerSubtitleAr']?.toString() ?? '',
      bannerSubtitleEn: map['bannerSubtitleEn']?.toString() ?? '',
      bannerImageUrl: map['bannerImageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
    'currencyCode': currencyCode,
    'currencyMinorDigits': currencyMinorDigits,
    'stockControlEnabled': stockControlEnabled,
    'manualPaymentEnabled': manualPaymentEnabled,
    'cashOnDeliveryEnabled': cashOnDeliveryEnabled,
    'bannerEnabled': bannerEnabled,
    'bannerTitleAr': bannerTitleAr,
    'bannerTitleEn': bannerTitleEn,
    'bannerSubtitleAr': bannerSubtitleAr,
    'bannerSubtitleEn': bannerSubtitleEn,
    'bannerImageUrl': bannerImageUrl,
    'public': true,
  };
}
