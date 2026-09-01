class CustomerProfile {
  const CustomerProfile({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    required this.defaultCity,
    required this.defaultAddress,
  });

  final String userId;
  final String name;
  final String email;
  final String phone;
  final String defaultCity;
  final String defaultAddress;
}
