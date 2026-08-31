import 'package:cloud_firestore/cloud_firestore.dart';

class Owner {
  const Owner({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.primaryColor,
    this.secondaryColor,
    this.phone,
    this.whatsappPhone,
    this.email,
    this.instagram,
    this.facebook,
    this.active = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String? primaryColor;
  final String? secondaryColor;
  final String? phone;
  final String? whatsappPhone;
  final String? email;
  final String? instagram;
  final String? facebook;
  final bool active;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Owner copyWith({
    String? name,
    String? slug,
    String? logoUrl,
    String? primaryColor,
    String? secondaryColor,
    String? phone,
    String? whatsappPhone,
    String? email,
    String? instagram,
    String? facebook,
    bool? active,
  }) => Owner(
    id: id,
    name: name ?? this.name,
    slug: slug ?? this.slug,
    logoUrl: logoUrl ?? this.logoUrl,
    primaryColor: primaryColor ?? this.primaryColor,
    secondaryColor: secondaryColor ?? this.secondaryColor,
    phone: phone ?? this.phone,
    whatsappPhone: whatsappPhone ?? this.whatsappPhone,
    email: email ?? this.email,
    instagram: instagram ?? this.instagram,
    facebook: facebook ?? this.facebook,
    active: active ?? this.active,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory Owner.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = doc.data() ?? const <String, dynamic>{};
    return Owner(
      id: doc.id,
      name: map['name']?.toString() ?? '',
      slug: map['slug']?.toString() ?? '',
      logoUrl: map['logoUrl']?.toString(),
      primaryColor: map['primaryColor']?.toString(),
      secondaryColor: map['secondaryColor']?.toString(),
      phone: map['phone']?.toString(),
      whatsappPhone: map['whatsappPhone']?.toString(),
      email: map['email']?.toString(),
      instagram: map['instagram']?.toString(),
      facebook: map['facebook']?.toString(),
      active: map['active'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toPublicProfileMap() => {
    'name': name,
    'slug': slug,
    'logoUrl': logoUrl,
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'phone': phone,
    'whatsappPhone': whatsappPhone,
    'email': email,
    'instagram': instagram,
    'facebook': facebook,
  };
}
