
class AuthUser {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    this.firstName = '',
    this.lastName = '',
    this.phone,
    this.countryCode,
    this.role = 'user',
    this.walletBalance = 0,
    this.emailVerified = false,
  });
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String? countryCode;
  final String role;
  final int walletBalance;
  final bool emailVerified;
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }
  AuthUser copyWith({bool? emailVerified}) => AuthUser(
    id: id,
    name: name,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phone,
    countryCode: countryCode,
    role: role,
    walletBalance: walletBalance,
    emailVerified: emailVerified ?? this.emailVerified,
  );
  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    firstName: json['firstName']?.toString() ?? '',
    lastName: json['lastName']?.toString() ?? '',
    phone: json['phone']?.toString(),
    countryCode: json['countryCode']?.toString(),
    role: json['role']?.toString() ?? 'user',
    walletBalance: (json['walletBalance'] as num?)?.toInt() ?? 0,
    emailVerified: json['emailVerified'] == true,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'countryCode': countryCode,
    'role': role,
    'walletBalance': walletBalance,
    'emailVerified': emailVerified,
  };
}
