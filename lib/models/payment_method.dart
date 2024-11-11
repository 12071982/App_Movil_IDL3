enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.creditCard:
        return 'credit-card';
      case PaymentMethod.debitCard:
        return 'debit-card';
    }
  }
}
