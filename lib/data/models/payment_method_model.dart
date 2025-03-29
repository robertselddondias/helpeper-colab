class PaymentMethodModel {
  final String id;
  final String type;
  final String? brand;
  final String? bankName;
  final String? accountType;
  final String lastFourDigits;
  final int? expiryMonth;
  final int? expiryYear;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.type,
    this.brand,
    this.bankName,
    this.accountType,
    required this.lastFourDigits,
    this.expiryMonth,
    this.expiryYear,
    required this.isDefault,
  });

  PaymentMethodModel copyWith({
    String? id,
    String? type,
    String? brand,
    String? bankName,
    String? accountType,
    String? lastFourDigits,
    int? expiryMonth,
    int? expiryYear,
    bool? isDefault,
  }) {
    return PaymentMethodModel(
      id: id ?? this.id,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      bankName: bankName ?? this.bankName,
      accountType: accountType ?? this.accountType,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      expiryMonth: expiryMonth ?? this.expiryMonth,
      expiryYear: expiryYear ?? this.expiryYear,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
