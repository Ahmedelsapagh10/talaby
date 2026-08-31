class CheckoutDetails {
  const CheckoutDetails({
    required this.name,
    required this.mobile,
    required this.city,
    required this.address,
    this.notes,
  });

  final String name;
  final String mobile;
  final String city;
  final String address;
  final String? notes;

  Map<String, dynamic> toMap() => {
    'name': name.trim(),
    'mobile': mobile.trim(),
    'city': city.trim(),
    'address': address.trim(),
    'notes': notes?.trim(),
  };
}
