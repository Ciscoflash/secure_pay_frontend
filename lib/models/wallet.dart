class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.balanceAfter,
    required this.description,
    this.createdAt,
  });
  final String id;
  final String type;
  final int amount;
  final int balanceAfter;
  final String description;
  final DateTime? createdAt;
  bool get isCredit => type == 'credit';
  factory WalletTransaction.fromJson(Map<String, dynamic> json) =>
      WalletTransaction(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
        description: json['description']?.toString() ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '')?.toLocal(),
      );
}
class WalletAccount {
  const WalletAccount({
    required this.balance,
    required this.accountNumber,
    required this.bankName,
    required this.transactions,
  });
  final int balance;
  final String accountNumber;
  final String bankName;
  final List<WalletTransaction> transactions;
  WalletAccount copyWith({int? balance}) => WalletAccount(
    balance: balance ?? this.balance,
    accountNumber: accountNumber,
    bankName: bankName,
    transactions: transactions,
  );
  factory WalletAccount.fromJson(Map<String, dynamic> json) => WalletAccount(
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    accountNumber: json['accountNumber']?.toString() ?? '',
    bankName: json['bankName']?.toString() ?? '',
    transactions: [
      if (json['transactions'] is List)
        for (final t in (json['transactions'] as List).whereType<
            Map<String, dynamic>>())
          WalletTransaction.fromJson(t),
    ],
  );
}